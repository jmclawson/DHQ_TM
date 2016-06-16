library(XML)

filelist <- list.files(path="data",pattern="*xml",recursive=TRUE,full.names=T)

docbodies <- c()
for (file in 1:length(filelist)) {
  doc <- xmlTreeParse(filelist[file], useInternalNodes=TRUE)
  docextract <- getNodeSet(doc, "/tei:TEI//tei:text",namespaces = c(tei = "http://www.tei-c.org/ns/1.0"))
  doc.body <- xmlElementsByTagName(docextract[[1]],"body")
  doc.body.v <- xmlValue(doc.body[[1]])
  articlefile <- paste("data/texts/",file,sep="")
  articlefile <- paste(articlefile,".txt",sep="")
  write(doc.body.v,file=articlefile,append=FALSE,sep="")
}