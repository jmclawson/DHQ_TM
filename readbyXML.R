library(XML)

filelist <- list.files(path="data",pattern="*xml",recursive=TRUE,full.names=T)

docbodies <- c()
for (file in 1:length(filelist)) {
  doc <- xmlTreeParse(filelist[file], useInternalNodes=TRUE)
  docbody <- getNodeSet(doc, "/tei:TEI//tei:body",namespaces = c(tei = "http://www.tei-c.org/ns/1.0"))
  articlefile = paste("data/texts/",file,sep="")
  articlefile = paste(articlefile,".txt",sep="")
  write(docbody,file=articlefile,append=FALSE,sep="") 
}

# This gives us an error:
# Error in cat(list(...), file, sep, fill, labels, append) : argument 1 (type 'list') cannot be handled by 'cat'
