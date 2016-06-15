library(XML)

filelist <- list.files(path="data",pattern="*xml",recursive=TRUE,full.names=T)

# docs <- c()
# for (file in filelist) {
#   doc <- xmlTreeParse(file, useInternalNodes=TRUE)
#   docs <- c(docs,doc)
# }

docbodies <- c()
for (file in filelist) {
  doc <- xmlTreeParse(file, useInternalNodes=TRUE)
  docbody <- getNodeSet(doc, "/tei:TEI//tei:body",namespaces = c(tei = "http://www.tei-c.org/ns/1.0"))
  docbodies <- c(docbodies,docbody)
}