library(XML)

filelist <- list.files(path="data",pattern="*xml",recursive=TRUE,full.names=T)

docbodies <- c()
for (file in 1:length(filelist)) {
  doc <- xmlTreeParse(filelist[file], useInternalNodes=TRUE)
  docextract <- getNodeSet(doc, "/tei:TEI//tei:teiHeader",namespaces = c(tei = "http://www.tei-c.org/ns/1.0"))
  doc.authors <- xmlElementsByTagName(docextract[[1]],"authors", recursive=TRUE)
  doc.authors.v <- xmlValue(doc.authors[[1]])
  articlefile <- paste("data/authors/",file,sep="")
  articlefile <- paste(articlefile,".txt",sep="")
  write(doc.authors.v,file=articlefile,append=FALSE,sep="")
}