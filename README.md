# DHQ_TM
I've combined things into two scripts, which should be the only things you'll need to run to get things working. These files go out to the internet to download things, they add new directories to your computer, and they outsource to some of the other LDA scripts we got from Neal. I hoped only to make things easier so we can spend our time on important things like deciding the number of topics to find, finding ways to interpret the data, figuring out which of our questions are answerable, and maybe deciding which additional questions are worth asking. But if anything I did raises hackles or doubt, please let me know!

## getDHQ.R
The first of these, **getDHQ.R** takes a long time to run the first time, but it's much faster each subsequent time. I think it took me nearly an hour on first run; my computer was built in 2012. The first run does everything in the steps 1-12, below. Later runs of the script skips the most time-intensive steps (12, 6, and 11 in descending order of time intensity). Since the data set we've been using so far doesn't include the latest issues of the journal, this script automates things. When each new issue of DHQ gets released, all we theoretically need to do is delete folders "xml" and "txt" and "txt-n" to get the whole set again, including new titles.

1. scrapes data on the [DHQ website] (http://www.digitalhumanities.org/dhq/index/title.html)
2. corrects a few problems from the DHQ's coding on their web page
3. extrapolates addresses to the relevant XML files
4. stores data in a data frame in R, "dhq.data"
5. exports a CSV file of this data frame, "dhq-data.csv"
6. checks to see if a folder called "xml" exists; skips the rest of step 6 if so
	- creates the folder "xml"
	- downloads all the XML files from the website into this folder
7. scrapes these XML files for richer data to allow for comparison against website
8. stores data in a data frame in R, "doc.data"
9. exports a CSV file of this data frame, "xmldocument-data.csv"
10. separates the body text of each XML file into ~1,000-word chunks (see [Jockers' reasoning](http://www.matthewjockers.net/2013/04/12/secret-recipe-for-topic-modeling-themes/), though it may be less applicable to articles, which are shorter in length, which might result in a topic getting split across two chunks, thereby cutting it out of the model altogether)
11. checks to see if a folder called "txt" exists; skips the rest of step 11 if so
	- creates the folder "txt"
	- saves the ~1,000-word chunks in individual text files into this folder
12. checks to see if a folder called "txt-n" exists; skips the rest of 12 if so
	- reads each text file in "txt" one at a time
	- tags each word as a part of speech
	- strips out everything that isn't tagged as a common noun (again, explained by Jockers on a [blog post](http://www.matthewjockers.net/2013/04/12/secret-recipe-for-topic-modeling-themes/))
	- saves each common noun chunk in the "txt-n" folder

## ldaDHQ.R
The second file, **ldaDHQ.R** is pretty much the same as "example_1.R" that we've been using so far, but it also does a few other things:

1. sets the correct directory to the one created by "getDHQ.R"
2. sets a seed so that we get consistent results each time we run it (and on different computers)
3. uses a simplified stop list, since our data only uses common nouns
4. sets the topic number to 45 (*which we should decide on*)
5. recombines results for all the ~1,000-word chunks into one result per original XML file, averaging each chunk's resulting topic distributions for each DHQ entry
6. calculates a threshold of topic significance by finding the median topic score for each document and then averaging this median across the corpus (*a method which we should debate*)
7. counts the number of topics above the threshold for each document 
8. stores many results in a data frame in R, "dhq.topics"
9. plots a comparison of author counts to topic counts per document (*which may not actually show anything useful, but we can discuss it*)
10. filters and averages topic distribution by number of authors, stored in a data frame in R, "dhq.topics.bynums.auth"
11. filters and averages topic distribution by number of affiliations, stored in a data frame in R, "dhq.topics.bynums.affil"
12. exports CSV files for "dhq.topics" ("newest-topics.csv"), "dhq.topics.bynums.auth" ("newest-topics-bynums-auth.csv"), and "dhq.topics.bynums.affil" ("newest-topics-bynums-affil.csv").
