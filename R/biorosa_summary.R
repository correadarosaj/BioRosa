# Source this file, then call biorosa_summary('/path/to/BioRosa/enrichment').
# No files, packages, working-directory changes or network calls occur on sourcing.

#' Synthesize a BioRosa enrichment directory into a publication draft and figure.
#'
#' @param path Directory containing GO/, KEGG/, Reactome/, Hallmark/, RXGR/,
#'   gse/GSE.xlsx and/or FGSEA_results.xlsx. Missing collections are allowed.
#' @param output_dir Destination; defaults to path/biorosa_consensus_summary.
#' @param contrast Optional human-readable contrast description.
#' @param positive_group,negative_group Explicit meanings of positive/negative
#'   exported gene statistics. Supply both to use group-specific report wording.
#' @param reverse Reverse the exported contrast, including NES and gene log2FC.
#' @param alpha Source adjusted-p cutoff. Values are not recomputed or combined.
#' @param top_n Maximum displayed groups per direction; all evidence is exported.
#' @param min_jaccard Gene-overlap threshold for descriptive grouping.
#' @param clustering 'network' (weighted Louvain), 'complete', or 'none'.
#' @param gene_map Optional data.frame with ENTREZID and SYMBOL columns.
#'   Otherwise human Entrez IDs are mapped with org.Hs.eg.db when available and
#'   human identifiers are observed. Unresolved IDs remain namespace-prefixed.
#' @param seed Reproducible network-clustering seed; caller RNG state is restored.
#' @param overwrite Replace only a previous output owned by this function.
#' @return Invisibly, a list with evidence, themes, selected, genes, figure,
#'   publication_text, methods_text, diagnostics, files and settings.
#' @details Requires readxl, data.table, Matrix, igraph, ggplot2 and jsonlite.
#'   No LLM or earlier agent output is needed. No new enrichment test is run.
#' @seealso [enrichment_onestep()], which calls this automatically after a run.
#' @export
biorosa_summary <- function(path, output_dir = file.path(path, "biorosa_consensus_summary"),
                            contrast = NULL, positive_group = NULL, negative_group = NULL,
                            reverse = FALSE, alpha = 0.05, top_n = 5L,
                            min_jaccard = 0.25, clustering = c("network", "complete", "none"),
                            gene_map = NULL, seed = 1L, overwrite = FALSE) {
  version <- "1.0.0"
  needed <- c("readxl", "data.table", "Matrix", "igraph", "ggplot2", "jsonlite")
  missing <- needed[!vapply(needed, requireNamespace, quietly=TRUE, FUN.VALUE=logical(1))]
  if(length(missing)) stop("Install required R packages: ", paste(missing, collapse=", "), call.=FALSE)
  clustering <- match.arg(clustering)
  string <- function(x) is.character(x) && length(x)==1L && !is.na(x) && nzchar(trimws(x))
  flag <- function(x) is.logical(x) && length(x)==1L && !is.na(x)
  if(!string(path)||!dir.exists(path)) stop("path must be an existing directory",call.=FALSE)
  if(!string(output_dir)) stop("output_dir must be a nonempty path",call.=FALSE)
  if(!is.numeric(alpha)||length(alpha)!=1L||!is.finite(alpha)||alpha<=0||alpha>1) stop("alpha must be in (0, 1]",call.=FALSE)
  if(!is.numeric(min_jaccard)||length(min_jaccard)!=1L||!is.finite(min_jaccard)||min_jaccard<=0||min_jaccard>1) stop("min_jaccard must be in (0, 1]",call.=FALSE)
  if(!is.numeric(top_n)||length(top_n)!=1L||!is.finite(top_n)||top_n<1||top_n!=as.integer(top_n)) stop("top_n must be a positive integer",call.=FALSE)
  if(!is.numeric(seed)||length(seed)!=1L||!is.finite(seed)||seed<0||seed>.Machine$integer.max||seed!=as.integer(seed)) stop("seed must be a nonnegative integer",call.=FALSE)
  if(!flag(reverse)||!flag(overwrite)) stop("reverse and overwrite must be TRUE or FALSE",call.=FALSE)
  if(!is.null(contrast)&&!string(contrast)) stop("contrast must be NULL or a nonempty string",call.=FALSE)
  groups_supplied <- !is.null(positive_group)||!is.null(negative_group)
  if(groups_supplied && (!string(positive_group)||!string(negative_group)||positive_group==negative_group)) stop("Supply two different positive_group and negative_group labels",call.=FALSE)
  root <- normalizePath(path, winslash="/",mustWork=TRUE)
  if(!dir.exists(dirname(output_dir))) dir.create(dirname(output_dir),recursive=TRUE,showWarnings=FALSE)
  dest <- file.path(normalizePath(dirname(output_dir),winslash="/",mustWork=TRUE),basename(output_dir))
  protected <- file.path(root,c("GO","KEGG","Reactome","Hallmark","RXGR","gse"))
  if(dest==root || any(vapply(protected,function(p)dest==p||startsWith(dest,paste0(p,"/")),logical(1)))) stop("output_dir must not be the input directory or an enrichment source subdirectory",call.=FALSE)
  marker <- ".biorosa_summary"
  if(dir.exists(dest) && length(list.files(dest,all.files=TRUE,no..=TRUE))) {
    if(!overwrite || !file.exists(file.path(dest,marker))) stop("Output directory is nonempty. Choose a new directory, or use overwrite=TRUE for a prior biorosa_summary output",call.=FALSE)
  }
  old_threads <- data.table::getDTthreads(); data.table::setDTthreads(min(2L,old_threads))
  on.exit(data.table::setDTthreads(old_threads),add=TRUE)
  had_rng <- exists(".Random.seed",envir=.GlobalEnv,inherits=FALSE)
  if(had_rng) old_rng <- get(".Random.seed",envir=.GlobalEnv)
  old_kind <- RNGkind()
  on.exit({do.call(RNGkind,as.list(old_kind)); if(had_rng)assign(".Random.seed",old_rng,envir=.GlobalEnv) else if(exists(".Random.seed",envir=.GlobalEnv,inherits=FALSE))rm(".Random.seed",envir=.GlobalEnv)},add=TRUE)
  dt <- data.table::data.table; rb <- data.table::rbindlist; un <- data.table::uniqueN
  diagnostics <- dt(level=character(),code=character(),detail=character())
  note <- function(code,detail,level="note") diagnostics <<- rb(list(diagnostics,dt(level=level,code=code,detail=detail)))
  normal <- function(x) tolower(trimws(gsub(" +"," ",gsub("_"," ",sub("^(HALLMARK|GOBP|GOCC|GOMF|KEGG|REACTOME)_","",x)))))
  genesplit <- function(x) {
    if(is.na(x)||!nzchar(x))return(character())
    x<-sub("^c\\(","",sub("\\)$","",x))
    sort(unique(Filter(nzchar,trimws(unlist(strsplit(gsub('[\"\x27]',"",x),"[/,;]"))))))
  }
  # Only recognized source locations are scanned: generated reports never re-enter.
  candidates <- unlist(lapply(c("GO","KEGG","Reactome","Hallmark","RXGR","gse"),function(p)
    list.files(file.path(root,p),pattern="\\.(xlsx|csv|tsv|txt)$",recursive=TRUE,full.names=TRUE,ignore.case=TRUE)),use.names=FALSE)
  candidates <- candidates[grepl("(_(UP|DOWN)(_enrichment)?|GSE)\\.(xlsx|csv|tsv|txt)$",basename(candidates),ignore.case=TRUE)]
  candidates <- c(candidates,list.files(root,pattern="^FGSEA_results\\.(xlsx|csv|tsv|txt)$",full.names=TRUE,ignore.case=TRUE))
  if(!length(candidates))stop("No recognized BioRosa enrichment exports found",call.=FALSE)
  registry<-dt(file=sort(unique(candidates)))
  registry[,format:=tolower(tools::file_ext(file))]
  registry[,logical_file:=sub("\\.[^.]+$","",file)]
  registry[,preference:=match(format,c("xlsx","tsv","txt","csv"))]
  data.table::setorder(registry,logical_file,preference)
  registry[,selected:=!duplicated(logical_file)]
  if(any(!registry$selected))note("alternate_formats",sprintf("Ignored %d alternate-format exports; XLSX is preferred to avoid duplicate evidence",sum(!registry$selected)))
  files<-registry[selected==TRUE,file]
  gene_files<-file.path(root,c("up_df.csv","down_df.csv"));gene_files<-gene_files[file.exists(gene_files)]
  checksums<-tools::md5sum(c(files,gene_files))
  parts<-list(); inventories<-list()
  for(f in files) {
    sheets<-if(tolower(tools::file_ext(f))=="xlsx")readxl::excel_sheets(f) else "text"
    for(sh in sheets) {
      d<-if(sh=="text")data.table::fread(f) else data.table::as.data.table(readxl::read_excel(f,sheet=sh))
      rel<-substring(f,nchar(root)+2L);rx<-startsWith(rel,"RXGR/")
      fg<-grepl("^FGSEA_results\\.",basename(f),ignore.case=TRUE);gs<-startsWith(rel,"gse/")
      ranked<-fg||gs;tool<-if(rx)"RXGR"else if(fg)"FGSEA"else if(gs)"GSE"else"ORA"
      required<-if(rx)c("id","name","adjp","overlap")else if(fg)c("pathway","NES","padj","leadingEdge")else if(gs)c("ID","Description","NES","p.adjust","core_enrichment")else c("ID","Description","p.adjust","geneID")
      if(!nrow(d)) {note("empty_export",paste(rel,sh,"contains no rows"));next}
      if(length(setdiff(required,names(d))))stop("Unrecognized schema in ",rel," / ",sh,": missing ",paste(setdiff(required,names(d)),collapse=", "),call.=FALSE)
      getc<-function(n)if(n %in% names(d))as.character(d[[n]])else rep(NA_character_,nrow(d))
      getn<-function(n){x<-getc(n);v<-suppressWarnings(as.numeric(x));if(any(!is.na(x)&nzchar(x)&is.na(v)))stop("Non-numeric ",n," in ",rel,call.=FALSE);v}
      collection<-if(rx)basename(dirname(f))else if(fg&&sh!="text")sh else if(fg)rep("FGSEA_unspecified",nrow(d)) else if(gs)if("ONTOLOGY"%in%names(d))paste0("GO_",d$ONTOLOGY)else "GO_unspecified" else sub("_(UP|DOWN)\\.[^.]+$","",basename(f),ignore.case=TRUE)
      if(fg&&sh=="text") {
        prefixes<-c(HALLMARK_="Hallmark",GOBP_="GO_BP",GOCC_="GO_CC",GOMF_="GO_MF",REACTOME_="Reactome",KEGG_="KEGG")
        for(pre in names(prefixes))collection[startsWith(as.character(d$pathway),pre)]<-prefixes[[pre]]
      }
      direction<-if(ranked)ifelse(is.na(d$NES)|d$NES==0,"UNKNOWN",ifelse(d$NES>0,"UP","DOWN"))else if(grepl("_UP",basename(f),ignore.case=TRUE))"UP"else"DOWN"
      q<-getn(if(rx)"adjp"else if(fg)"padj"else"p.adjust")
      if(any(!is.na(q)&(!is.finite(q)|q<0|q>1)))stop("Invalid adjusted p-value in ",rel,call.=FALSE)
      z<-dt(file=rel,sheet=sh,row=seq_len(nrow(d))+1L,tool=tool,family=if(ranked)"RANKED"else"ORA",collection=collection,
        direction=direction,term_id=getc(if(rx)"id"else if(fg)"pathway"else"ID"),
        term_name=getc(if(rx)"name"else if(fg)"pathway"else"Description"),padj=q,
        pvalue=getn(if(fg)"pval"else"pvalue"),NES=if(ranked)getn("NES")else NA_real_,
        fold_enrichment=getn(if(rx)"fc"else"FoldEnrichment"),odds_ratio=if(rx)getn("or")else NA_real_,
        background_ratio=getc("BgRatio"),query_ratio=getc("GeneRatio"),
        gene_role=if(ranked)"leading_edge"else"observed_overlap",genes_raw=getc(if(rx)"overlap"else if(fg)"leadingEdge"else if(gs)"core_enrichment"else"geneID"))
      if(any(is.na(z$term_name)|!nzchar(z$term_name)|is.na(z$term_id)|!nzchar(z$term_id)))stop("Missing term identifier/name in ",rel,call.=FALSE)
      parts[[length(parts)+1L]]<-z
      inventories[[length(inventories)+1L]]<-z[,.(rows=.N,significant=sum(!is.na(padj)&padj<alpha),
        nonsignificant=sum(!is.na(padj)&padj>=alpha),missing_padj=sum(is.na(padj))),by=.(file,sheet,tool,family,collection)]
    }
  }
  if(!length(parts))stop("Recognized exports contain no enrichment rows",call.=FALSE)
  ev<-rb(parts);inventory<-rb(inventories)
  inventory[,coverage:=ifelse(nonsignificant==0,"No nonsignificant rows observed; absence is unknown","Nonsignificant rows retained; completeness unverified")]
  ev[,source_direction:=direction];ev[,source_NES:=NES]
  if(reverse){ev[,direction:=ifelse(direction=="UP","DOWN",ifelse(direction=="DOWN","UP","UNKNOWN"))];ev[,NES:=-NES]}
  if(reverse&&groups_supplied){tmp<-positive_group;positive_group<-negative_group;negative_group<-tmp}
  ev[,evidence_id:=sprintf("E%06d",.I)]
  ev[,normalized_name:=normal(term_name)]
  ev[,term_key:=paste(collection,normalized_name,sep="::")]
  # Name matching is collection-scoped. Preserve names and IDs for audit.
  bridges<-ev[,.(ids=paste(sort(unique(term_id)),collapse=";"),n_ids=un(term_id)),by=.(collection,normalized_name)]
  numeric_ids<-sort(unique(unlist(lapply(ev$genes_raw,genesplit))))
  numeric_ids<-numeric_ids[grepl("^[0-9]+$",numeric_ids)]
  mapping<-dt(ENTREZID=character(),SYMBOL=character(),status=character())
  if(length(numeric_ids)) {
    human<-any(grepl("^hsa|^R-HSA-",ev$term_id))
    if(!is.null(gene_map)) {
      if(!is.data.frame(gene_map)||!all(c("ENTREZID","SYMBOL")%in%names(gene_map)))stop("gene_map requires ENTREZID and SYMBOL columns",call.=FALSE)
      mp<-data.table::as.data.table(gene_map)[,.(ENTREZID=as.character(ENTREZID),SYMBOL=as.character(SYMBOL))]
      note("gene_mapping","Used the supplied Entrez-to-symbol mapping")
    } else if(human&&requireNamespace("AnnotationDbi",quietly=TRUE)&&requireNamespace("org.Hs.eg.db",quietly=TRUE)) {
      mp<-data.table::as.data.table(suppressMessages(AnnotationDbi::select(org.Hs.eg.db::org.Hs.eg.db,keys=numeric_ids,keytype="ENTREZID",columns="SYMBOL")))
      note("gene_mapping",paste("Human identifiers observed; mapped with org.Hs.eg.db",utils::packageVersion("org.Hs.eg.db")))
    } else {
      mp<-dt(ENTREZID=numeric_ids,SYMBOL=NA_character_)
      note("unmapped_identifiers","Entrez mapping unavailable; numeric identifiers are retained with an ENTREZ: prefix and will not match gene symbols","warning")
    }
    mp<-mp[,.(symbols=paste(sort(unique(SYMBOL[!is.na(SYMBOL)&nzchar(SYMBOL)])),collapse=";"),n=un(SYMBOL[!is.na(SYMBOL)&nzchar(SYMBOL)])),by=ENTREZID]
    mapping<-merge(dt(ENTREZID=numeric_ids),mp,by="ENTREZID",all.x=TRUE)
    mapping[,status:=ifelse(is.na(n)|n==0,"unmapped",ifelse(n==1,"mapped","ambiguous"))]
    mapping[,SYMBOL:=ifelse(status=="mapped",symbols,NA_character_)]
  }
  lookup<-setNames(mapping$SYMBOL,mapping$ENTREZID)
  gs<-lapply(ev$genes_raw,function(x){g<-genesplit(x);num<-grepl("^[0-9]+$",g);m<-unname(lookup[g[num]]);m[is.na(m)]<-paste0("ENTREZ:",g[num][is.na(m)]);sort(unique(c(g[!num],m)))})
  ev[,genes:=vapply(gs,paste,collapse=";",FUN.VALUE=character(1))]
  ev[,n_genes:=lengths(gs)]
  deg<-dt(SYMBOL=character(),log2FoldChange=numeric(),gene_padj=numeric())
  for(f in gene_files) {
    x<-data.table::fread(f)
    if(!all(c("SYMBOL","log2FoldChange")%in%names(x)))stop("Invalid DEG schema in ",basename(f),call.=FALSE)
    if(any(!is.finite(x$log2FoldChange))||anyNA(x$SYMBOL)||any(!nzchar(x$SYMBOL)))stop("Invalid DEG values in ",basename(f),call.=FALSE)
    expected<-if(basename(f)=="up_df.csv")1 else -1
    if(any(sign(x$log2FoldChange)!=expected))stop("DEG signs contradict ",basename(f),call.=FALSE)
    deg<-rb(list(deg,dt(SYMBOL=x$SYMBOL,log2FoldChange=if(reverse)-x$log2FoldChange else x$log2FoldChange,gene_padj=if("padj"%in%names(x))x$padj else NA_real_)))
  }
  if(anyDuplicated(deg$SYMBOL))stop("Duplicate gene symbols in DEG input; resolve ambiguous gene effects first",call.=FALSE)
  if(!nrow(deg))note("missing_DEGs","No DEG CSVs available; gene fold changes will be reported as unavailable")
  up<-deg[log2FoldChange>0,SYMBOL];down<-deg[log2FoldChange<0,SYMBOL]
  ev[,opposite_known_genes:=vapply(seq_along(gs),function(i)sum(gs[[i]]%in%if(ev$direction[i]=="UP")down else if(ev$direction[i]=="DOWN")up else character()),integer(1))]
  if(any(ev$family=="ORA"&ev$opposite_known_genes>0))stop("ORA overlaps contradict supplied DEG direction; check the contrast and gene mapping",call.=FALSE)
  ev[,significant:=!is.na(padj)&padj<alpha&direction!="UNKNOWN"]
  if(any(ev$significant&ev$opposite_known_genes>0))note("ranked_opposing_genes","Some significant leading edges contain known opposite-side DEGs; inspect gene_direction_audit.csv","warning")
  # Keep all rows for audit, but count exact tool/term/direction duplicates once.
  dupkey<-c("tool","collection","term_id","direction")
  dd<-ev[,.(n=.N,nq=un(padj),ng=un(genes),nn=un(NES)),by=dupkey][n>1]
  if(any(dd$nq>1|dd$ng>1|dd$nn>1))stop("Conflicting duplicate tool/term/direction rows detected",call.=FALSE)
  ev[,duplicate:=duplicated(.SD),.SDcols=dupkey]
  sig<-ev[significant==TRUE&duplicate==FALSE]
  term_support<-if(nrow(sig))sig[,.(n_tools=un(tool),n_families=un(family),best_source_padj=min(padj),evidence_ids=paste(evidence_id,collapse=";")),by=.(term_key,direction)]else dt(term_key=character(),direction=character(),n_tools=integer(),n_families=integer(),best_source_padj=numeric(),evidence_ids=character())
  conflicts<-sig[,.(directions=paste(sort(unique(direction)),collapse=";"),n_directions=un(direction),evidence_ids=paste(evidence_id,collapse=";")),by=term_key][n_directions>1]
  terms<-sig[,.(label=normalized_name[1],genes=paste(sort(unique(unlist(lapply(genes,genesplit)))),collapse=";")),by=term_key]
  data.table::setorder(terms,term_key)
  nterm<-nrow(terms)
  if(nterm>10000L && clustering=="complete")stop("Complete-linkage is limited to 10,000 terms; use network or none",call.=FALSE)
  sim<-NULL
  if(nterm && clustering!="none") {
    lists<-lapply(terms$genes,genesplit);vocab<-sort(unique(unlist(lists)))
    inc<-Matrix::sparseMatrix(i=rep(seq_len(nterm),lengths(lists)),j=match(unlist(lists),vocab),x=1,dims=c(nterm,length(vocab)))
    ints<-Matrix::tcrossprod(inc);sizes<-Matrix::rowSums(inc)
    trip<-Matrix::summary(ints)
    if(nrow(trip)){trip$x<-trip$x/pmax(sizes[trip$i]+sizes[trip$j]-trip$x,1);trip<-trip[trip$i!=trip$j&trip$x>=min_jaccard,,drop=FALSE]}
    if(clustering=="network") {
      edges<-Matrix::sparseMatrix(i=integer(),j=integer(),x=numeric(),dims=c(nterm,nterm))
      # tcrossprod may be symmetric or general; force exact symmetric weights.
      if(nrow(trip)) {
        e<-dt(i=pmin(trip$i,trip$j),j=pmax(trip$i,trip$j),x=trip$x)[,.(x=max(x)),by=.(i,j)]
        edges<-Matrix::sparseMatrix(i=c(e$i,e$j),j=c(e$j,e$i),x=rep(e$x,2),dims=c(nterm,nterm))
      }
      graph<-igraph::graph_from_adjacency_matrix(edges,mode="undirected",weighted=TRUE,diag=FALSE)
      set.seed(seed)
      cl<-if(igraph::ecount(graph))as.integer(igraph::membership(igraph::cluster_louvain(graph)))else seq_len(nterm)
    } else if(nterm==1L)cl<-1L else {
      ints<-as.matrix(ints);sim<-ints/pmax(outer(sizes,sizes,"+")-ints,1);diag(sim)<-1
      cl<-stats::cutree(stats::hclust(stats::as.dist(1-sim),method="complete"),h=1-min_jaccard)
    }
  } else cl<-seq_len(nterm)
  # Stable group numbering by first sorted term, independent of arbitrary IDs.
  if(nterm)cl<-match(cl,unique(cl))
  terms[,theme_id:=sprintf("T%04d",cl)]
  sig<-merge(sig,terms[,.(term_key,theme_id)],by="term_key",all.x=TRUE,sort=FALSE)
  # Explicit empty schema supports zero significant results and one-sided inputs.
  themes<-dt(theme_id=character(),direction=character(),label=character(),n_terms=integer(),n_tools=integer(),n_families=integer(),
    n_concordant_terms=integer(),weakest_family_best_padj=numeric(),mixed=logical(),evidence_ids=character())
  if(nrow(sig)) {
    tt<-sig[,.(nf=un(family),q=min(padj),label=normalized_name[1]),by=.(theme_id,direction,term_key)]
    themes<-sig[,{
      per<- .SD[,.(nf=un(family),q=min(padj),label=normalized_name[1]),by=term_key][order(-nf,q,label)]
      fq<-.SD[,.(q=min(padj)),by=family]
      list(label=per$label[1],n_terms=un(term_key),n_tools=un(tool),n_families=un(family),n_concordant_terms=sum(per$nf==2),
        weakest_family_best_padj=max(fq$q),evidence_ids=paste(evidence_id,collapse=";"))
    },by=.(theme_id,direction)]
    mixed<-themes[,.(n=un(direction)),by=theme_id][n>1,theme_id]
    themes[,mixed:=theme_id%in%mixed]
    themes[,same_term_corroboration:=n_concordant_terms>0]
    themes[,single_family_tool_count:=ifelse(n_families==1L,n_tools,0L)]
    data.table::setorderv(themes,c("direction","same_term_corroboration","n_families","single_family_tool_count","weakest_family_best_padj","theme_id"),c(1,-1,-1,-1,1,1))
  }
  selected<-themes[,head(.SD,top_n),by=direction]
  # Build representative evidence with a bounded number of terms, keeping all
  # original support in the supplementary tables. Conflicts are never capped.
  evidence_selected<-sig[0];gene_facts<-dt(theme_id=character(),direction=character(),SYMBOL=character(),n_terms=integer(),n_families=integer(),log2FoldChange=numeric(),gene_padj=numeric())
  for(i in seq_len(nrow(selected))) {
    z<-selected[i];r<-sig[theme_id==z$theme_id&direction==z$direction]
    rt<-r[,.(nf=un(family),q=min(padj)),by=term_key][order(-nf,q,term_key)]
    er<-r[term_key%in%head(rt$term_key,3)]
    evidence_selected<-rb(list(evidence_selected,er))
    gg<-rb(lapply(seq_len(nrow(er)),function(j){g<-genesplit(er$genes[j]);dt(SYMBOL=g,term_key=rep(er$term_key[j],length(g)),family=rep(er$family[j],length(g)))}))
    if(nrow(gg)) {
      gf<-gg[,.(n_terms=un(term_key),n_families=un(family)),by=SYMBOL]
      gf<-merge(gf,deg,by="SYMBOL",all.x=TRUE)
      gf<-gf[is.na(log2FoldChange)|if(z$direction=="UP")log2FoldChange>0 else log2FoldChange<0]
      gf[,known:=!is.na(log2FoldChange)];data.table::setorderv(gf,c("n_families","n_terms","known","SYMBOL"),c(-1,-1,-1,1))
      gf<-head(gf,8);gf[,known:=NULL];gf[,`:=`(theme_id=z$theme_id,direction=z$direction)]
      gene_facts<-rb(list(gene_facts,gf),use.names=TRUE)
    }
  }
  # Coverage includes explicit nonsignificance; missing exports are never zeros.
  coverage<-dt(theme_id=character(),direction=character(),tool=character(),n_significant=integer(),status=character())
  tool_order<-c("ORA","RXGR","GSE","FGSEA");tools_present<-tool_order[tool_order%in%ev$tool]
  for(i in seq_len(nrow(selected)))for(tool_name in tools_present) {
    z<-selected[i];keys<-terms[theme_id==z$theme_id,term_key]
    x<-ev[term_key%in%keys&tool==tool_name&duplicate==FALSE]
    n<-un(x[significant==TRUE&direction==z$direction,term_key])
    nonsig<-any(!is.na(x$padj)&x$padj>=alpha&(x$family=="RANKED"|x$direction==z$direction))
    opposite<-any(x$significant&x$direction!=z$direction)
    status<-if(n)"Significant support"else if(opposite)"Opposite-side support"else if(nonsig)"Nonsignificant observed"else"No result observed"
    coverage<-rb(list(coverage,dt(theme_id=z$theme_id,direction=z$direction,tool=tool_name,n_significant=n,status=status)))
  }
  # Publication text contains source-derived findings, not a fixed biological story.
  context<-if(is.null(contrast))"the supplied contrast"else contrast
  meanings<-if(groups_supplied)c(UP=paste("associated with higher expression in",positive_group,"than",negative_group),DOWN=paste("associated with higher expression in",negative_group,"than",positive_group))else c(UP="on the positive side of the supplied contrast",DOWN="on the negative side of the supplied contrast")
  label_list<-function(x) {
    x<-unique(x);if(!length(x))return("")
    if(length(x)==1L)return(x)
    if(length(x)==2L)return(paste(x,collapse=" and "))
    paste0(paste(head(x,-1),collapse=", "),", and ",tail(x,1))
  }
  results<-sprintf("For %s, %s enrichment records met their source-specific adjusted-P threshold of %.3g, representing %s distinct collection-specific terms.",context,nrow(sig),alpha,nrow(terms))
  for(di in c("UP","DOWN")) {
    n<-sig[direction==di,.N];ss<-selected[direction==di]
    if(!n)results<-paste(results,sprintf("No significant enrichment was observed on the %s among the available exports.",if(di=="UP")"positive side"else"negative side")) else {
      cons<-ss[n_concordant_terms>0];other<-ss[n_concordant_terms==0]
      if(nrow(cons))results<-paste(results,sprintf("Among the selected transcriptional programs %s, %s had concordant ORA and ranked-enrichment support for at least one matched term.",meanings[[di]],label_list(cons$label)))
      if(nrow(other))results<-paste(results,sprintf("Additional selected programs %s included %s; these lacked same-term corroboration across the two method families in the available exports.",meanings[[di]],label_list(other$label)))
    }
  }
  if(nrow(conflicts))results<-paste(results,sprintf("Significant evidence on both sides was observed for %d matched term(s), which were retained as conflicting findings (see supplementary evidence).",nrow(conflicts)))
  results<-paste(results,"Agreement across methods was interpreted as descriptive corroboration because the methods share underlying gene-level data; enrichment alone does not establish functional pathway activation or inhibition.")
  if(!groups_supplied)results<-paste("DRAFT: group orientation must be specified before attributing these findings to treatment.",results)
  method<-sprintf("Previously generated BioRosa enrichment exports were harmonized while retaining source file, worksheet, row, gene identifiers, enrichment statistics and adjusted P values. ORA and RXGR were classified as overrepresentation methods; FGSEA and GSE were classified as ranked enrichment methods. Terms were selected at source adjusted P < %.3g without recomputing or combining P values. Direction was taken from the input UP/DOWN list for ORA and the sign of NES for ranked enrichment%s. Exact normalized names were matched within collections; repeated exports were counted once. Descriptive groups were constructed using %s%s. Groups with same-term support from both method families were prioritized, followed by their weaker family's smallest source adjusted P value, used only as an ordering statistic. Up to %d groups per direction were displayed, while all significant results and both-direction conflicts were retained. Representative genes were selected by distinct-term and method-family occurrence within up to three representative terms per group, with available gene-level log2 fold changes attached. The analysis used biorosa_summary version %s (seed %d).",
    alpha,if(reverse)", with the exported contrast reversed"else"",if(clustering=="network")"weighted Louvain clustering of observed gene-overlap similarities"else if(clustering=="complete")"complete-linkage clustering of observed gene overlaps"else"one group per matched term",
    if(clustering!="none")sprintf(" at Jaccard similarity %.2f",min_jaccard)else"",top_n,version,seed)
  limitations<-c("Source adjusted P values refer to potentially different test families, gene universes and gene-set versions. No theme-level P value or independent-replication score is calculated.",
    "Group names are actual representative annotations, not proof of mechanism. Gene-set names containing UP/DOWN describe their reference signature, not this contrast.",
    "Only observed overlap/leading-edge genes were available for grouping. Groupings are dataset-specific, and different programs can share genes.",
    "Absence from a filtered export is unknown. Nonsignificance is recorded only when a corresponding row is present. Missing collections are allowed.",
    "Transcriptional enrichment alone cannot distinguish cell-composition changes from within-cell regulation. The original model, contrast, gene universe and enrichment settings remain the analyst's responsibility.")
  if(!groups_supplied)limitations<-c("Positive and negative group labels were not supplied. The publication draft deliberately avoids treatment attribution.",limitations)
  caption<-sprintf("Figure. Directional concordance of selected enrichment groups for %s. Each cell shows the number of distinct significant member terms for one tool on the indicated side (source adjusted P < %.3g). Color indicates direction, and cell labels retain counts. 'ns' indicates a corresponding nonsignificant row was observed; 'opp' indicates significant opposite-side evidence; '-' indicates no applicable result was observed. Rows are selected descriptive groups, not independent tests; counts and group size do not measure effect size. Groups may have evidence in both directions. All significant results, including non-displayed groups, are provided in the supplementary evidence.",context,alpha)
  # One portable figure object plus vector PDF and 300-dpi PNG.
  if(nrow(selected)) {
    pd<-merge(coverage,selected[,.(theme_id,direction,label)],by=c("theme_id","direction"),sort=FALSE)
    pd[,support_fill:=factor(ifelse(n_significant>0,direction,"No same-side support"),levels=c("UP","DOWN","No same-side support"))]
    pd[,cell:=ifelse(n_significant>0,as.character(n_significant),ifelse(status=="Nonsignificant observed","ns",ifelse(status=="Opposite-side support","opp","-")))]
    pd[,display:=paste0(ifelse(direction=="UP","UP: ","DOWN: "),label," [",theme_id,"]")]
    order_rows<-selected[order(match(direction,c("UP","DOWN"))),paste0(ifelse(direction=="UP","UP: ","DOWN: "),label," [",theme_id,"]")]
    wrapped<-vapply(order_rows,function(x)paste(strwrap(x,width=58),collapse="\n"),character(1))
    pd[,display:=factor(display,levels=rev(order_rows),labels=rev(wrapped))]
    pd[,tool:=factor(tool,levels=tools_present)]
    fig<-ggplot2::ggplot(pd,ggplot2::aes(tool,display,fill=support_fill))+ggplot2::geom_tile(color="white",linewidth=.8)+
      ggplot2::geom_text(ggplot2::aes(label=cell),size=3.5)+
      ggplot2::scale_fill_manual(values=c(UP="#f2c09e",DOWN="#b9cee5","No same-side support"="#f1f2f4"),drop=FALSE)+
      ggplot2::labs(title="Consensus across enrichment methods",subtitle=paste(strwrap(context,width=100),collapse="\n"),x=NULL,y=NULL,fill=NULL,
        caption="Cell numbers = significant member terms. ns = nonsignificant observed; opp = opposite side; - = unknown.\nORA / RXGR: overrepresentation; GSE / FGSEA: ranked enrichment. Counts are not effect sizes.")+
      ggplot2::theme_minimal(base_size=11)+ggplot2::theme(panel.grid=ggplot2::element_blank(),legend.position="bottom",plot.caption=ggplot2::element_text(hjust=0,size=9),axis.text.y=ggplot2::element_text(color="#253445"))
    height<-max(5,2.5+sum(lengths(strsplit(wrapped,"\n",fixed=TRUE)))*.34)
  } else {
    fig<-ggplot2::ggplot()+ggplot2::annotate("text",x=0,y=0,label=paste("No significant enrichment in the available exports",sprintf("Source adjusted P < %.3g",alpha),sep="\n"),size=5)+ggplot2::theme_void()+ggplot2::labs(title="Enrichment consensus")
    height<-5
  }
  stopifnot(nrow(sig)==sum(ev$significant&!ev$duplicate),!anyNA(sig$theme_id),!anyDuplicated(sig$evidence_id))
  if(!identical(unname(tools::md5sum(names(checksums))),unname(checksums)))stop("Source files changed during analysis; rerun on a stable snapshot",call.=FALSE)
  settings<-list(version=version,path=root,contrast=contrast,positive_group=positive_group,negative_group=negative_group,reverse=reverse,alpha=alpha,top_n=top_n,min_jaccard=min_jaccard,clustering=clustering,seed=seed)
  # Stage outputs and publish only after successful analysis and rendering.
  stage<-tempfile("biorosa-stage-",tmpdir=dirname(dest));dir.create(stage)
  on.exit(unlink(stage,recursive=TRUE),add=TRUE)
  write_table<-function(x,name)data.table::fwrite(x,file.path(stage,paste0(name,".csv")),na="NA")
  write_table(ev,"evidence_all");write_table(sig,"evidence_significant");write_table(inventory,"source_inventory")
  write_table(registry,"input_formats");write_table(bridges[n_ids>1],"term_id_bridges");write_table(mapping,"gene_mapping")
  write_table(term_support,"term_support");write_table(terms,"theme_membership");write_table(themes,"themes");write_table(selected,"selected_themes")
  write_table(coverage,"tool_coverage");write_table(conflicts,"conflicts");write_table(gene_facts,"representative_genes")
  write_table(evidence_selected,"publication_evidence");write_table(ev[opposite_known_genes>0],"gene_direction_audit")
  write_table(diagnostics,"diagnostics");write_table(dt(file=names(checksums),md5=unname(checksums)),"input_checksums")
  write_table(dt(package=needed,version=vapply(needed,function(p)as.character(utils::packageVersion(p)),character(1))),"package_versions")
  jsonlite::write_json(settings,file.path(stage,"settings.json"),pretty=TRUE,auto_unbox=TRUE,null="null")
  writeLines(c("RESULTS",results,"","METHODS",method,"","FIGURE LEGEND",caption,"","REVIEW BEFORE SUBMISSION",limitations),file.path(stage,"publication_text.txt"))
  writeLines(c("# Publication text draft","",results,"","## Methods","",method,"","## Figure legend","",caption,"","## Review before submission","",paste0("- ",limitations)),file.path(stage,"publication_text.md"))
  ggplot2::ggsave(file.path(stage,"summary_figure.png"),fig,width=11,height=height,dpi=300,bg="white",limitsize=FALSE)
  ggplot2::ggsave(file.path(stage,"summary_figure.pdf"),fig,width=11,height=height,device=grDevices::pdf,useDingbats=FALSE,limitsize=FALSE)
  esc<-function(x){x<-gsub("&","&amp;",as.character(x),fixed=TRUE);x<-gsub("<","&lt;",x,fixed=TRUE);x<-gsub(">","&gt;",x,fixed=TRUE);gsub('"',"&quot;",x,fixed=TRUE)}
  htmltable<-function(d){if(!nrow(d))return("<p>None observed.</p>");paste0("<div class='table'><table><thead><tr>",paste0("<th>",esc(names(d)),"</th>",collapse=""),"</tr></thead><tbody>",paste(vapply(seq_len(nrow(d)),function(i)paste0("<tr>",paste0("<td>",esc(unlist(d[i],use.names=FALSE)),"</td>",collapse=""),"</tr>"),character(1)),collapse=""),"</tbody></table></div>")}
  image64<-jsonlite::base64_enc(readBin(file.path(stage,"summary_figure.png"),"raw",n=file.info(file.path(stage,"summary_figure.png"))$size))
  html<-paste0("<!doctype html><html><head><meta charset='utf-8'><meta name='viewport' content='width=device-width, initial-scale=1'><title>BioRosa enrichment consensus</title><style>body{font:16px/1.6 Arial,sans-serif;color:#243445;max-width:1120px;margin:36px auto;padding:0 24px}h1,h2{color:#254e70;line-height:1.2}h2{margin-top:2em}img{max-width:100%}.table{overflow:auto}table{border-collapse:collapse;font-size:13px}td,th{padding:9px;border-bottom:1px solid #dce3eb;text-align:left}th{background:#edf3f7}a{color:#215e8b}.note{background:#f2f5f8;padding:14px}</style></head><body>",
    "<h1>BioRosa enrichment consensus</h1><p>",esc(context),"</p><p class='note'>",nrow(sig)," significant records; ",nrow(terms)," matched terms; ",nrow(selected)," displayed groups. Method agreement is descriptive, not independent replication.</p>",
    "<h2>Publication text draft</h2><p>",esc(results),"</p><p><a href='publication_text.txt'>Download results, methods and figure legend</a></p>",
    "<h2>Summary figure</h2><img alt='Directional consensus across enrichment methods' src='data:image/png;base64,",image64,"'><p>",esc(caption),"</p><p><a href='summary_figure.pdf'>Vector PDF</a> | <a href='summary_figure.png'>300-dpi PNG</a></p>",
    "<h2>Selected groups</h2>",htmltable(selected[,.(theme_id,direction,label,n_terms,n_tools,n_families,n_concordant_terms,mixed)]),
    "<h2>Representative gene effects</h2>",htmltable(gene_facts),"<h2>Conflicting evidence</h2>",htmltable(conflicts),
    "<h2>Methods</h2><p>",esc(method),"</p><h2>Interpretation and coverage</h2><ul>",paste0("<li>",esc(limitations),"</li>",collapse=""),"</ul>",htmltable(inventory),
    "<h2>Diagnostics</h2>",htmltable(diagnostics),"<h2>Supplementary evidence</h2><p><a href='evidence_all.csv'>All source rows</a> | <a href='publication_evidence.csv'>Publication evidence</a> | <a href='themes.csv'>All groups</a> | <a href='tool_coverage.csv'>Observed tool coverage</a> | <a href='input_checksums.csv'>Input checksums</a></p></body></html>")
  writeLines(html,file.path(stage,"report.html"))
  writeLines(paste("biorosa_summary",version),file.path(stage,marker))
  result<-list(evidence=ev,themes=themes,selected=selected,genes=gene_facts,figure=fig,publication_text=results,methods_text=method,diagnostics=diagnostics,settings=settings)
  saveRDS(result,file.path(stage,"summary.rds"))
  dir.create(dest,recursive=TRUE,showWarnings=FALSE)
  products<-list.files(stage,all.files=TRUE,no..=TRUE)
  copied<-file.copy(file.path(stage,products),file.path(dest,products),overwrite=overwrite)
  if(!all(copied))stop("Could not publish all staged outputs; check destination permissions",call.=FALSE)
  result$files<-setNames(file.path(dest,products),products)
  message("BioRosa summary: ",file.path(dest,"report.html"))
  invisible(result)
}
