# testing with one file
# save the path to the file
data.dir <- "data/1/1/000006/000006.xml"

# read all the lines into a vector
filelines <- readLines(data.dir)

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

authorgrep <- "^//<author" # figure out general expression here
author <- grep(authorgrep, filelines, value=TRUE) # gather line contents for author
# author <- grep(authorgrep, filelines, value=FALSE) # gather vector addresses for author
