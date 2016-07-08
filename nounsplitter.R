library(NLP) 
library(openNLP)

# credit due to http://stackoverflow.com/questions/30995232/how-to-use-opennlp-to-get-pos-tags-in-r
## SET "data.dir" to a directory containing text files
#### It's not designed for nested folders, as I feared data loss, so do one level at a time
## SET "saveas.file" to the destination directory
#### The resulting file has an "n" prepended to the file name. Whether you reuse the same directory is your choice.
data.dir <- "data/txt/Gavin/"
saveas.file <- "data/txt-n/Gavin/" # on second thought, it's best to have a different folder, as the LDA scripts will read everything in a directory

file.list <- list.files(path=data.dir) # get all the filenames in the path

for (text in file.list) { # run the loop for every file in the folder
  txt <- readLines(paste(data.dir, text, sep=""))
  txt <- as.String(txt)
  wordAnnotation <- annotate(txt, list(Maxent_Sent_Token_Annotator(), Maxent_Word_Token_Annotator()))
  POSAnnotation <- annotate(txt, Maxent_POS_Tag_Annotator(), wordAnnotation)
  POSwords <- subset(POSAnnotation, type == "word")
  tags <- sapply(POSwords$features, '[[', "POS")
  # The next line searches for tagged common nouns (NN); change it for other part-of-speech tags
  thisPOSindex <- grep("NN$", tags)
  tokenizedAndTagged <- sprintf("%s/%s", txt[POSwords][thisPOSindex], tags[thisPOSindex])
  untokenizedAndTagged <- paste(tokenizedAndTagged, collapse = " ")
  # "NN" in the next line signifies common nouns
  untokenizedAndTagged <- gsub("\\/NN", "", untokenizedAndTagged)
  save.text <- paste(saveas.file, "n", text, sep="")
  write(untokenizedAndTagged, file=save.text, append = FALSE, sep="")
}