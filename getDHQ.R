# This script creates a data frame detailing DHQ metadata and downloads the XML files

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
  rm(dhq.url.vol)
  rm(dhq.url.iss)
  rm(dhq.url.id)
  rm(dhq.url.xml)
  rm(dhq.url.path)
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
for (number in 1:length(dhq.items$xml)) {
  if (!file.exists("xml")){
    dir.create(file.path(getwd(), "xml"))
    }
  dhq.filename <- paste("xml",dhq.items$id[number],sep="/")
  dhq.filename <- paste(dhq.filename,"xml",sep=".")
  download.file(dhq.items$xml[number], destfile = dhq.filename, method="auto")
}
rm(number)