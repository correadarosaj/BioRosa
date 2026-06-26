#' Build a BigTab of per-contrast statistics from a model fit
#'
#' @description
#' `runBigTab()` assembles a **BigTab** — BioRosa's central per-gene,
#' per-contrast results table — from an `ebfit` object (a list carrying a
#' coefficient matrix `$coef` and a p-value matrix `$p.value`, genes x
#' contrasts, e.g. from [runEbfit()] or a limma fit). For every contrast it
#' emits a consistent block of columns:
#'
#' * `lgFCH_<contrast>` — log2 fold change (the coefficient).
#' * `FCH_<contrast>` — signed linear fold change, `sign(lgFCH) * 2^|lgFCH|`.
#' * `pvals_<contrast>` — p-value.
#' * `fdrs_<contrast>` — BH-adjusted p-value.
#' * `StatusFCH<mcut><P|FDR><pcut>_<contrast>` — DEG call from
#'   `limma::decideTests` (`-1` down, `0` n.s., `1` up).
#'
#' Underscores in contrast names are converted to dots so the suffixes stay
#' parseable by the heatmap and enrichment functions. The resulting table feeds
#' [doAnnotatedHeatmap()], [doAnnotatedHeatmapGrid()], [process_degs()] and
#' [enrichment_onestep()].
#'
#' @param ebfit A list with `$coef` (numeric matrix, genes x contrasts) and
#'   `$p.value` (matrix of the same shape). Row names are gene identifiers.
#' @param adj P-value adjustment method passed to `limma::decideTests`
#'   (`"BH"`, `"none"`, ...). Default `"BH"`; controls whether the status column
#'   is labelled `FDR` or `P`.
#' @param mcut Fold-change cutoff (linear scale) for the DEG call. Default `1.2`.
#' @param pcut P-value / FDR cutoff for the DEG call. Default `0.05`.
#' @param annot Logical. Prepend annotation columns (`SYMBOL` / `GENENAME`
#'   first) from `annotTab` or `ebfit$genes`. Default `FALSE`.
#' @param annotTab Optional annotation data frame indexed by the same gene IDs.
#'
#' @return A data frame (the BigTab): one row per gene, the per-contrast column
#'   blocks described above (plus annotation columns when `annot = TRUE`).
#' @seealso [runEbfit()], [process_degs()], [doAnnotatedHeatmapGrid()]
#' @examples
#' \dontrun{
#' ebfit  <- runEbfit(tidy_model_table)
#' BigTab <- runBigTab(ebfit, adj = "BH", mcut = 1.3, pcut = 0.05)
#' }
#' @export
runBigTab<-function(ebfit,adj='BH',mcut=1.2,pcut=0.05, annot=FALSE, annotTab=NULL){

  ctrnames<-gsub("_",".",colnames(ebfit$coef),fixed=TRUE)

  logFCHs<-round(ebfit$coef,2); colnames(logFCHs)<-paste('lgFCH',ctrnames,sep='_')
  FCHs<-round(sign(ebfit$coef)*2^abs(ebfit$coef),2); colnames(FCHs)<-paste('FCH',ctrnames,sep='_')

  reformatps<-function(p){as.numeric(format(p,digit=3,drop0trailing = TRUE))}
  pvals<-ebfit$p.value; colnames(pvals)<-paste('pvals',ctrnames,sep='_')
  fdrs<-apply(pvals,2,p.adjust,method='BH'); colnames(fdrs)<-paste('fdrs',ctrnames,sep='_')
  pvals<-apply(pvals,2, reformatps)
  fdrs<-apply(fdrs,2, reformatps)

  D<-decideTests(ebfit$p.value,method="separate",adjust.method=adj,p.value=pcut,lfc=log2(mcut),coefficients = ebfit$coef)
  colnames(D)<-paste('StatusFCH',mcut,ifelse(adj=='none','P','FDR'),pcut,"_",ctrnames,sep='')
  Tab<-cbind(logFCHs,FCHs,pvals,fdrs,D); cn<-colnames(Tab)

  CNS<-sapply(colnames(Tab),function(x){gsub(paste(strsplit(x,'_')[[1]][1],"_",sep=''),"",x)})
  Tab<-(Tab[,sapply(ctrnames,function(cn,CNS){which(CNS==cn)},CNS)])
  if (annot){

    if(!is.null(annotTab)) {
      imp.ann.col<-which(colnames(annotTab)%in%c('SYMBOL','GENENAME'))
      Tab<-cbind(annotTab[rownames(Tab), imp.ann.col],
                 Tab,
                 annotTab[rownames(Tab),-imp.ann.col])
    } else {
      #         if (!is.null(fData(ebfit))){
      #             if (ncol(fData(ebfit))>1) {annotTab<-fData(ebfit)[rownames(Tab),]}
      #          }
      if (!is.null(ebfit$genes)){
        if (ncol(ebfit$genes)>1) {annotTab<-ebfit$genes[rownames(Tab),] }
      }
    } #else
  }
  return(Tab)
}
