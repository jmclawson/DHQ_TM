# testing with one file
# save the path to the file
filelist <- list.files(path="data",pattern="*xml",recursive=TRUE)

# data.dir <- "data/1/1/000006/000006.xml"

# read all the lines into a vector
# filelines <- readLines(data.dir)

# Collect important data
# number of authors (or just plurality?)
# author name
# publish date
# issue
# journal
# editor
# special issue or not
# institution
# keywords
# articletype

alldocs <- matrix()
for (file in filelist) {
  file <- paste("data/",file,sep="")
  filelines <- readLines(file)
  
  fileparse <- matrix()
  
  authorgrep <- "^/s<dhq:author_name>([A-Za-z ]*)/n" # figure out general expression here
  author <- grep(authorgrep, filelines, value=TRUE) # gather line contents for author
  
  titlegrep <- "^/s<title>([A-Za-z ,]*)<\\/title>" # figure out general expression here
  title <- grep(titlegrep, filelines, value=TRUE) # gather line contents for title
  
  fileparse <- cbind(fileparse,author,title)
  
  alldocs <- rbind(alldocs,fileparse)
}

print(alldocs)