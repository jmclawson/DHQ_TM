library(XML)

filelist <- list.files(path="data",pattern="*xml",recursive=TRUE,full.names=T)

# Get the dates
doc.date <- c()
for (file in 1:length(filelist)) {
  doc <- xmlTreeParse(filelist[file], useInternalNodes=TRUE)
  docextract <- getNodeSet(doc, "/tei:TEI//tei:teiHeader",namespaces = c(tei = "http://www.tei-c.org/ns/1.0"))
  doc.date.prel <- xmlElementsByTagName(docextract[[1]],"date", recursive=TRUE)
  doc.date <- c(doc.date,xmlValue(doc.date.prel[[1]]))
}

# Get the author names
doc.authors <- c()
for (file in 1:length(filelist)) {
  doc <- xmlTreeParse(filelist[file], useInternalNodes=TRUE)
  docextract <- getNodeSet(doc, "/tei:TEI//tei:teiHeader",namespaces = c(tei = "http://www.tei-c.org/ns/1.0"))
  doc.authors.prel <- xmlElementsByTagName(docextract[[1]],"family", recursive=TRUE)
  doc.authors <- c(doc.authors,xmlValue(doc.authors.prel[[1]]))
}

# Get the title names
doc.title <- c()
for (file in 1:length(filelist)) {
  doc <- xmlTreeParse(filelist[file], useInternalNodes=TRUE)
  docextract <- getNodeSet(doc, "/tei:TEI//tei:teiHeader",namespaces = c(tei = "http://www.tei-c.org/ns/1.0"))
  doc.title.prel <- xmlElementsByTagName(docextract[[1]],"title", recursive=TRUE)
  doc.title.fix <- gsub("\\s+|\\s+|\\/|:","_",xmlValue(doc.title.prel[[1]])) #
  doc.title <- c(doc.title,doc.title.fix)
}

# Get the contents of the bodies
doc.body <- c()
for (file in 1:length(filelist)) {
  doc <- xmlTreeParse(filelist[file], useInternalNodes=TRUE)
  header.extract <- getNodeSet(doc, "/tei:TEI//tei:titleStmt",namespaces = c(tei = "http://www.tei-c.org/ns/1.0"))
  text.extract <- getNodeSet(doc, "/tei:TEI//tei:text",namespaces = c(tei = "http://www.tei-c.org/ns/1.0"))
  doc.body.prel <- xmlValue(xmlElementsByTagName(text.extract[[1]],"body")[[1]])
  doc.body <- c(doc.body,doc.body.prel)
}

# Write it to files
for (file in 1:length(filelist)) {
  folder.target.grandparent <- paste("data/txt")
  if (!file.exists(folder.target.grandparent)){
    dir.create(file.path(getwd(), folder.target.grandparent))
  }
  folder.target.parent <- paste(folder.target.grandparent,doc.date[file],sep="/")
  folder.target.main <- paste(folder.target.parent,doc.authors[file],sep="/")
  if (!file.exists(folder.target.parent)){
    dir.create(file.path(getwd(), folder.target.parent))
  }
  if (!file.exists(folder.target.main)){
    dir.create(file.path(getwd(), folder.target.main))
  }
  filename <- paste(doc.title[file],".txt",sep="")
  filename <- paste(folder.target.main,filename,sep="/")
  write(doc.body[file],file=filename,append=FALSE,sep="")
}