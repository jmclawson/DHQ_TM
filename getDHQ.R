# This script creates a data frame detailing DHQ metadata and downloads all the XML files

library(rvest)
library(stringr)

# Get started with the list of all titles
dhq.alltitles <- read_html(x="http://www.digitalhumanities.org/dhq/index/title.html")
dhq.items <- list()
dhq.items$urls <- dhq.alltitles %>%
  html_nodes(".ptext a") %>%
  html_attr("href")

# Account for errors on the DHQ website
dhq.items$urls <- gsub("[[:space:]]+","",dhq.items$urls)
dhq.items$urls[grep("000193",dhq.items$urls)] <- "/dhq/vol/9/3/000193/000193.html"
dhq.items$urls[grep("000195",dhq.items$urls)] <- "/dhq/vol/8/4/000195/000195.html"
dhq.items$urls[grep("000197",dhq.items$urls)] <- "/dhq/vol/8/4/000197/000197.html"
dhq.items$urls[grep("000217",dhq.items$urls)] <- "/dhq/vol/9/2/000217/000217.html"
dhq.items$urls[grep("000223",dhq.items$urls)] <- "/dhq/vol/9/3/000223/000223.html"
dhq.items$urls[grep("000242",dhq.items$urls)] <- "/dhq/vol/10/2/000242/000242.html"
dhq.items$urls[grep("000244",dhq.items$urls)] <- "/dhq/vol/10/3/000244/000244.html"
dhq.items$urls[grep("000248",dhq.items$urls)] <- "/dhq/vol/10/2/000248/000248.html"
dhq.items$urls[grep("000251",dhq.items$urls)] <- "/dhq/vol/10/2/000251/000251.html"

# Predict XML links from HTML links
dhq.items$xml <- c()
dhq.items$id <- c()
dhq.items$volume <- c()
dhq.items$issue <- c()
for (url in dhq.items$urls) {
  dhq.url.vol <- regmatches(url,regexec("dhq/vol/([0-9]{1,2})",url))
  dhq.url.iss <- regmatches(url,regexec("dhq/vol/[0-9]{1,2}/([1-9]{1,2})",url))
  dhq.url.id <- regmatches(url,regexec("dhq/vol/[0-9]{1,2}/[1-9]{1}/([0-9]{6})",url))
  dhq.url.xml <- paste(dhq.url.id[[1]][2],"xml",sep=".")
  dhq.url.path <- paste("http://www.digitalhumanities.org/dhq/vol",dhq.url.vol[[1]][2],dhq.url.iss[[1]][2],dhq.url.xml,sep="/")
  dhq.items$id <- c(dhq.items$id,dhq.url.id[[1]][2])
  dhq.items$volume <- c(dhq.items$volume,dhq.url.vol[[1]][2])
  dhq.items$issue <- c(dhq.items$issue,dhq.url.iss[[1]][2])
  dhq.items$xml <- c(dhq.items$xml,dhq.url.path)
  rm(dhq.url.vol,dhq.url.iss,dhq.url.id,dhq.url.xml,dhq.url.path)
}
rm(url)

# Account for an inconsistency in the DHQ linking scheme
dhq.items$xml[grep("000043",dhq.items$xml)] <- "http://www.digitalhumanities.org/dhq/vol/3/2/000043/000043.xml"

# Extract other metadata
dhq.items$titles <- dhq.alltitles %>%
  html_nodes(".ptext a") %>%
  html_text()
dhq.items$titles <- gsub("[[:space:]]+"," ",dhq.items$titles)
dhq.items$attribution <- dhq.alltitles %>%
  html_nodes(".authors") %>%
  html_text()
dhq.items$attribution <- strsplit(dhq.items$attribution,"; ")
dhq.items$authors <- list()
dhq.items$affiliations <- list()
dhq.items$affil.1 <- c()
dhq.items$affil.2 <- c()
dhq.items$affil.3 <- c()
dhq.items$author.1 <- c()
dhq.items$author.2 <- c()
dhq.items$author.3 <- c()
for (number in 1:length(dhq.items$attribution)) {
  dhq.items$affiliations[[number]] <- sapply(strsplit(unlist(dhq.items$attribution[number]),", "), tail, n=1)
  dhq.items$affil.1 <- c(dhq.items$affil.1,dhq.items$affiliations[[number]][1])
  dhq.items$affil.2 <- c(dhq.items$affil.2,dhq.items$affiliations[[number]][2])
  dhq.items$affil.3 <- c(dhq.items$affil.3,dhq.items$affiliations[[number]][3])
  dhq.items$authors[[number]] <- sapply(strsplit(unlist(dhq.items$attribution[number]),", "), head, n=1)
  dhq.items$author.1 <- c(dhq.items$author.1,dhq.items$authors[[number]][1])
  dhq.items$author.2 <- c(dhq.items$author.2,dhq.items$authors[[number]][2])
  dhq.items$author.3 <- c(dhq.items$author.3,dhq.items$authors[[number]][3])
  dhq.items$author.nums[number] <- length(dhq.items$authors[[number]])
}
rm(number)

# Put all the data into a useful table
dhq.data <- data.frame(urls = dhq.items$xml, vol = dhq.items$volume, iss = dhq.items$issue, id = dhq.items$id, title = dhq.items$titles, auth.nums = dhq.items$author.nums, auth.1 = dhq.items$author.1, affil.1 = dhq.items$affil.1, auth.2 = dhq.items$author.2, affil.2 = dhq.items$affil.2, auth.3 = dhq.items$author.3, affil.3 = dhq.items$affil.3, stringsAsFactors = FALSE)

# print("To see all the affiliations for a work, e.g., that on the 7th row, dhq.items$affiliation[[7]] will list them:")
# print(dhq.items$affiliations[[7]])

# print("Similarly, dhq.items$authors[[7]] will list the author names:")
# print(dhq.items$authors[[7]])

write.csv(dhq.data,file="dhq-data.csv")

# Download the files into a new directory
if (!file.exists("xml")) {
  dir.create(file.path(getwd(), "xml"))
  for (number in 1:length(dhq.items$xml)){
    dhq.filename <- paste("xml",dhq.items$id[number],sep="/")
    dhq.filename <- paste(dhq.filename,"xml",sep=".")
    download.file(dhq.items$xml[number], destfile = dhq.filename, method="auto")
  }
  rm(dhq.filename,number)
}

## parse the XML file contents
library(XML)
filelist <- list.files(path="xml",pattern="*xml",recursive=TRUE,full.names=T)

# Get the dates
doc.date <- c()
for (file in 1:length(filelist)) {
  doc <- xmlTreeParse(filelist[file], useInternalNodes=TRUE)
  docextract <- getNodeSet(doc, "/tei:TEI//tei:teiHeader",namespaces = c(tei = "http://www.tei-c.org/ns/1.0"))
  doc.date.pre1 <- xmlElementsByTagName(docextract[[1]],"date", recursive=TRUE)
  doc.date.pre2 <- as.Date(xmlValue(doc.date.pre1[[1]]),format='%d %B %Y')
  doc.date.pre3 <- format(doc.date.pre2[[1]],"%Y-%m-%d")
  doc.date <- c(doc.date,doc.date.pre3[[1]])
  rm(doc.date.pre1,doc.date.pre2,doc.date.pre3)
}

# Get the author family names and author counts
doc.authors <- c()
doc.authorcount <- c()
for (file in 1:length(filelist)) {
  doc <- xmlTreeParse(filelist[file], useInternalNodes=TRUE)
  docextract <- getNodeSet(doc, "/tei:TEI//tei:teiHeader",namespaces = c(tei = "http://www.tei-c.org/ns/1.0"))
  doc.authorcount <- c(doc.authorcount,xpathApply(xmlRoot(doc),path="count(//dhq:family)",xmlValue))
  doc.authors.pre1 <- xmlElementsByTagName(docextract[[1]],"family", recursive=TRUE)
  doc.authors <- c(doc.authors,xmlValue(doc.authors.pre1[[1]]))
  rm(doc.authors.pre1)
}

# Get the titles
doc.title <- c()
for (file in 1:length(filelist)) {
  doc <- xmlTreeParse(filelist[file], useInternalNodes=TRUE)
  docextract <- getNodeSet(doc, "/tei:TEI//tei:teiHeader",namespaces = c(tei = "http://www.tei-c.org/ns/1.0"))
  doc.title.pre1 <- xmlElementsByTagName(docextract[[1]],"title", recursive=TRUE)
  doc.title.fix <- gsub("\\s+|\\s+|\\/|:","_",xmlValue(doc.title.pre1[[1]],trim=TRUE)) #
  doc.title <- c(doc.title,doc.title.fix)
  rm(doc.title.pre1,doc.title.fix)
}

# Extract the ID, volume, issue
doc.idno <- list()
doc.id <- c()
doc.vol <- c()
doc.iss <- c()
for (file in 1:length(filelist)) {
  doc <- xmlTreeParse(filelist[file], useInternalNodes=TRUE)
  docextract <- getNodeSet(doc, "/tei:TEI//tei:teiHeader",namespaces = c(tei = "http://www.tei-c.org/ns/1.0"))
  doc.idno[[file]] <- xmlElementsByTagName(docextract[[1]],"idno", recursive=TRUE)
}
for (file in 1:length(filelist)) {
  doc.id[file] <- unlist(lapply(doc.idno[[file]][1], xmlValue, trim=TRUE))
  doc.vol[file] <- unlist(lapply(doc.idno[[file]][2], xmlValue, trim=TRUE))
  doc.iss[file] <- unlist(lapply(doc.idno[[file]][3], xmlValue, trim=TRUE))
}

# Get the affiliations
doc.affil.list <- list()
doc.affil.1 <- c()
for (file in 1:length(filelist)) {
  doc <- xmlTreeParse(filelist[file], useInternalNodes=TRUE)
  docextract <- getNodeSet(doc, "/tei:TEI//tei:teiHeader",namespaces = c(tei = "http://www.tei-c.org/ns/1.0"))
  doc.affil.list[[file]] <- xmlElementsByTagName(docextract[[1]],"affiliation", recursive=TRUE)
  doc.affil.list[[file]] <- lapply(doc.affil.list[[file]], xmlValue, trim=TRUE)
  doc.affil.unique[file] <- length(unique(doc.affil.list[[file]]))
  doc.affil.1[file] <- unlist(doc.affil.list[[file]][1])
}

# Get the contents of the bodies
doc.body <- c()
for (file in 1:length(filelist)) {
  doc <- xmlTreeParse(filelist[file], useInternalNodes=TRUE)
  header.extract <- getNodeSet(doc, "/tei:TEI//tei:titleStmt",namespaces = c(tei = "http://www.tei-c.org/ns/1.0"))
  text.extract <- getNodeSet(doc, "/tei:TEI//tei:text",namespaces = c(tei = "http://www.tei-c.org/ns/1.0"))
  doc.body.pre1 <- xmlValue(xmlElementsByTagName(text.extract[[1]],"body")[[1]])
  doc.body <- c(doc.body,doc.body.pre1)
  rm(doc.body.pre1)
}

# # Write it to files -- done later in chunks
# if (!dir.exists("txt")) {
#   dir.create(file.path(getwd(), "txt"))
#   for (file in 1:length(filelist)) {
#     filename <- paste("txt/",doc.id[file],".txt",sep="")
#     write(doc.body[file],file=filename,append=FALSE,sep="")
#   }
# }
# rm(file)

# write it out to a data frame to compare with the one from the website
doc.data <- data.frame(vol = doc.vol, issue = doc.iss, id = doc.id, title = doc.title, auth.nums = doc.authorcount, affil.nums = doc.affil.unique, auth.1 = doc.authors, affil.1 = doc.affil.1, stringsAsFactors = FALSE)

write.csv(doc.data,file="xmldocument-data.csv")

# Chunk the text (from Jockers' Text Analysis with R)
makeFlexTextChunks <- function(dhq.doc.text, chunk.size=1000, percentage=TRUE){
  words.lower <- tolower(dhq.doc.text)
  words.lower <- gsub("[^[:alnum:][:space:]']", " ", words.lower)
  words.l <- strsplit(words.lower, "\\s+")
  word.v <- unlist(words.l)
  x <- seq_along(word.v)
  if(length(word.v) <= chunk.size) {
    chunks.l <- split(word.v, ceiling(x/chunk.size))
  }
  else {
    if(percentage){
      max.length <- length(word.v)/chunk.size
      chunks.l <- split(word.v, ceiling(x/max.length))
      }
    else {
      chunks.l <- split(word.v, ceiling(x/chunk.size))
      if(length(chunks.l[[length(chunks.l)]]) <= chunk.size/2){
        chunks.l[[length(chunks.l)-1]] <- c(chunks.l[[length(chunks.l)-1]], chunks.l[[length(chunks.l)]])
        chunks.l[[length(chunks.l)]] <- NULL
      }
    }
  }
  chunks.l <- lapply(chunks.l, paste, collapse=" ")
  chunks.df <- do.call(rbind, chunks.l)
}

doc.chunks <- list()
for (number in 1:length(filelist)) {
  doc.chunks[[number]] <- makeFlexTextChunks(doc.body[number], chunk.size = 1000, percentage = FALSE)
}

# Write text to files in chunks ~1,000 each, but only if txt dir doesn't exist
if (!dir.exists("txt")) {
  dir.create(file.path(getwd(), "txt"))
  for (number in 1:length(doc.chunks)) {
    for (sub in 1:length(doc.chunks[[number]])) {
      filename <- paste("txt/",doc.id[number],"-",sub,".txt",sep="")
      write(doc.chunks[[number]][sub],file=filename,append=FALSE,sep="")
    }
  }
}
rm(number,sub)

## Strip out everything but the common nouns, but only if txt-n dir doesn't exist
# via http://stackoverflow.com/questions/30995232/how-to-use-opennlp-to-get-pos-tags-in-r
if (!dir.exists("txt-n")) {
  dir.create(file.path(getwd(), "txt-n"))
  library(NLP) 
  library(openNLP)
  noun.startdir <- "txt/"
  noun.enddir <- "txt-n/"
  noun.files <- list.files(path=noun.startdir)
  for (noun.file in noun.files) {
    txt <- as.String(readLines(paste(noun.startdir, noun.file, sep="")))
    wordAnnotation <- annotate(txt, list(Maxent_Sent_Token_Annotator(), Maxent_Word_Token_Annotator()))
    POSAnnotation <- annotate(txt, Maxent_POS_Tag_Annotator(), wordAnnotation)
    POSwords <- subset(POSAnnotation, type == "word")
    tags <- sapply(POSwords$features, '[[', "POS")
    # The next line searches for tagged common nouns (NN); change it for other part-of-speech tags
    thisPOSindex <- grep("NN$", tags)
    tokenizedAndTagged <- sprintf("%s/%s", txt[POSwords][thisPOSindex], tags[thisPOSindex])
    untokenizedAndTagged <- paste(tokenizedAndTagged, collapse = " ")
    # "NN" in the next line signifies common nouns, too
    untokenizedAndTagged <- gsub("\\/NN", "", untokenizedAndTagged)
    noun.savefile <- paste(noun.enddir, "n", noun.file, sep="")
    write(untokenizedAndTagged, file=noun.savefile, append = FALSE, sep="")
  }
}
rm(noun.startdir, noun.enddir, noun.files, txt, wordAnnotation, POSAnnotation, POSwords, tags, thisPOSindex, tokenizedAndTagged, untokenizedAndTagged, noun.savefile, noun.file)