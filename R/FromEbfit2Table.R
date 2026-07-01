# read important functions
#' creates an output table including all genes in ebfit
#' @description For each contratst in ebfit, a matrix with lgFCH, FCH,pvalue , fdr and Status (1 up,-1 doen,0 non sign) is created using pre-specified cut-oofs
#' @param ebfit output of eBayes
#' @param adj adjustment method for multiple hypothesis
#' @param mcut cutoff for FCH (to be used for Status columns)
#' @param pcut cutoff for pvalue/FDR  (to be used for Status columns)
#' @param annot should the dat be annotated? If TRUE it will check if tehre is annotTab or otherwise whatever annotation is stored in ebfit$genes
#' @param annotTab annotation database
#' @examples
#' Tab<-FromEbfit2Table(ebfit,pcut=0.05,mcut=2)

FromEbfit2Table<-function(ebfit,adj='BH',mcut=2,pcut=0.05, annot=FALSE, annotTab=NULL){

  ctrnames<-gsub("_",".",colnames(ebfit$coef),fixed=TRUE)

  logFCHs<-round(ebfit$coef,2); colnames(logFCHs)<-paste('lgFCH',ctrnames,sep='_')
  FCHs<-round(sign(ebfit$coef)*2^abs(ebfit$coef),2); colnames(FCHs)<-paste('FCH',ctrnames,sep='_')

  reformatps<-function(p){as.numeric(format(p,digit=3,drop0trailing = TRUE))}
  pvals<-ebfit$p.value; colnames(pvals)<-paste('pvals',ctrnames,sep='_')
  fdrs<-apply(pvals,2,p.adjust,adj); colnames(fdrs)<-paste('fdrs',ctrnames,sep='_')
  pvals<-apply(pvals,2, reformatps)
  fdrs<-apply(fdrs,2, reformatps)

  D<-limma::decideTests(ebfit,method="separate",adjust.method=adj,p.value=pcut,lfc=log2(mcut))
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
