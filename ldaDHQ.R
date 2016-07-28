## Modified from example_1.R
##
## This file is optimized for collaborative work modeling DHQ. For more
## on the original, see: https://www.cs.princeton.edu/~blei/lda-c/index.html

# options(java.parameters = "-Xmx4g")
source("functions/lda.R")
source("functions/import.R")
set.seed(4444) # makes our trials consistent each time (good for collaborating)

# Set data.dir to the directory with data. First using getDHQ.R will
# ensure an up-to-date data set that has been chunked into 1,000-word
# segments and then stripped of everything but common nouns.
data.dir <- "txt-n"
if (!file.exists(data.dir)){
  print("Please run getDHQ.R first.")
}
if (!file.exists("plots")){
  dir.create(file.path(getwd(), "plots"))
}

# This loads the documents from the directory above in a format that can be used 
# with Mallet.
docs <- loadDocuments(data.dir);

# Specify a set of stop-words, or commonly used words to be removed from the documents
# in order to improve model performance.
stoplist <- "stop-words/stop-words_english_2_en.txt"

# Train a document model with 45 topics. This will run Mallet over the documents
# from data.dir and store the results along with some supporting information 
# in a convenient data structure
dhq.k <- 45
model <- trainSimpleLDAModel(docs, dhq.k, stoplist=stoplist)

# Print the resulting topics as wordclouds for easy visualization.
print("printing topic word clouds")
plotTopicWordcloud(model, verbose=T)

## Now modify the output to present the results in a useful format

# load a necessary package
library(plyr)

# Get and clean up the ids and add them alongside the topics
dhq.ids <- gsub("^n|-.*$","", model$documents[,1])
dhq.topics <- cbind(dhq.ids,model$docAssignments)

# Recombine all the chunks for each id by averaging the scores
mode(dhq.topics) <- "numeric"
dhq.topics <- ddply(as.data.frame(dhq.topics),.(dhq.ids),numcolwise(mean))
dhq.topics <- cbind(id=unique(dhq.ids),dhq.topics[,2:ncol(dhq.topics)])
colnames(dhq.topics)[2:ncol(dhq.topics)] <- paste("Topic", 1:model$K, sep=" ")
dhq.topics <- cbind(vol = doc.vol, iss = doc.iss, auth.count = doc.authorcount, affil.count = doc.affil.unique, dhq.topics)

# Calculate number of significant topics per document, using average median score of topics as a threshold
dhq.averagetopicmedian <- mean(apply(dhq.topics[,6:ncol(dhq.topics)],1,median))
dhq.topicsabovethreshold <- rowSums(dhq.topics[,6:ncol(dhq.topics)] > dhq.averagetopicmedian)
dhq.topics <- cbind(dhq.topics[,1:5], topic.count = dhq.topicsabovethreshold, dhq.topics[,6:ncol(dhq.topics)])

# Add useful labels to the topics
dhq.topwords <- c()
for (topic in 1:dhq.k) {
  dhq.topwords[topic] <- paste(names(model$getTopic(topic)$getWords(3)), collapse=", ")
}
attr(dhq.topics, "variable.labels")[(6+1):(6+dhq.k)] <- dhq.topwords

# Add filters by the number of authors, number of unique affiliations
dhq.topics.bynums.auth <- dhq.topics[,c(3,6:ncol(dhq.topics))]
dhq.topics.bynums.auth <- ddply(as.data.frame(dhq.topics.bynums.auth),.(auth.count),numcolwise(mean))
dhq.topics.bynums.affil <- dhq.topics[,c(4,6:ncol(dhq.topics))]
dhq.topics.bynums.affil <- ddply(as.data.frame(dhq.topics.bynums.affil),.(affil.count),numcolwise(mean))

# Plot something suggestive comparing author counts to topic counts per document
plot(unlist(dhq.topics["auth.count"]), unlist(dhq.topics["topic.count"]), xlab="Number of authors per text", ylab="Number of topics per text", main="Single-author works show wider topic diversity.", sub="(Collaborative works cluster around a smaller range of topic counts.)", col = "dark red")

# Export useful CSV files for analysis
write.csv(dhq.topics, file="newest-topics.csv")
write.csv(dhq.topics.bynums.auth, file="newest-topics-bynums-auth.csv")
write.csv(dhq.topics.bynums.affil, file="newest-topics-bynums-affil.csv")
