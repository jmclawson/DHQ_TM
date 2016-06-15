library(XML)

filelist <- list.files(path="data",pattern="*xml",recursive=TRUE,full.names=T)

docbodies <- c()
for (file in filelist) {
  doc <- xmlTreeParse(file, useInternalNodes=TRUE)
  docbody <- getNodeSet(doc, "/tei:TEI//tei:body",namespaces = c(tei = "http://www.tei-c.org/ns/1.0"))
  docbodies <- c(docbodies,docbody)
}

for (dbody in 1:length(docbodies)) {
  articlefile = paste("data/texts/",dbody,sep="")
  articlefile = paste(articlefile,".txt",sep="")
  write(docbodies[dbody],file=articlefile,append=FALSE,sep="") 
}