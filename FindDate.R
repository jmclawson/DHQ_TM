library(XML)

filelist <- list.files(path="data",pattern="*xml",recursive=TRUE,full.names=T)

docbodies <- c()
for (file in 1:length(filelist)) {
  doc <- xmlTreeParse(filelist[file], useInternalNodes=TRUE)
  docextract <- getNodeSet(doc, "/tei:TEI//tei:teiHeader",namespaces = c(tei = "http://www.tei-c.org/ns/1.0"))
  doc.date <- xmlElementsByTagName(docextract[[1]],"date", recursive=TRUE)
  doc.date.v <- xmlValue(doc.date[[1]])
  articlefile <- paste("data/date/",file,sep="")
  articlefile <- paste(articlefile,".txt",sep="")
  write(doc.date.v,file=articlefile,append=FALSE,sep="")
}