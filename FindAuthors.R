library(XML)

filelist <- list.files(path="data",pattern="*xml",recursive=TRUE,full.names=T)

docbodies <- c()
for (file in 1:length(filelist)) {
  doc <- xmlTreeParse(filelist[file], useInternalNodes=TRUE)
  docextract <- getNodeSet(doc, "/tei:TEI//tei:teiHeader",namespaces = c(tei = "http://www.tei-c.org/ns/1.0"))
  doc.author <- xmlElementsByTagName(docextract[[1]],"author", recursive=TRUE)
  doc.author.v <- xmlValue(doc.author[[1]])
  articlefile <- paste("data/author/",file,sep="")
  articlefile <- paste(articlefile,".txt",sep="")
  write(doc.author.v,file=articlefile,append=FALSE,sep="")
}