library(XML)

filelist <- list.files(path="data",pattern="*xml",recursive=TRUE,full.names=T)

doc.matrix <- matrix()
for (file in 1:length(filelist)) {
  doc <- xmlTreeParse(filelist[file], useInternalNodes=TRUE)
  header.extract <- getNodeSet(doc, "/tei:TEI//tei:titleStmt",namespaces = c(tei = "http://www.tei-c.org/ns/1.0"))
  text.extract <- getNodeSet(doc, "/tei:TEI//tei:text",namespaces = c(tei = "http://www.tei-c.org/ns/1.0"))
  
  doc.title <- xmlValue(xpathApply(doc,"/tei:TEI//tei:title",namespaces = c(tei = "http://www.tei-c.org/ns/1.0"))[[1]])[[1]]
 
  # doc.author_name <- xmlValue(xpathApply(doc,"/tei:TEI//tei:author_name",namespaces = c(tei = "http://www.tei-c.org/ns/1.0")))
  # doc.author_name <- getNodeSet(doc,"tei:TEI//teiHeader//fileDesc//titleStmt//dhq:authorInfo",nnamespaces = c(tei = "http://www.tei-c.org/ns/1.0"))
  # doc.author_name.x <- xmlElementsByTagName(doc.author_name[[1]],"dhq:authorInfo")

  # doc.affiliation <- xmlElementsByTagName(header.extract[[1]],"dhq:affiliation")
  # doc.affiliation.v <- xmlValue(doc.affiliation[[1]]) 
  
  doc.body <- xmlValue(xmlElementsByTagName(text.extract[[1]],"body")[[1]])
break
  articlefile <- paste("data/texts/",file,sep="")
  articlefile <- paste(articlefile,".txt",sep="")
  write(doc.body,file=articlefile,append=FALSE,sep="")
}