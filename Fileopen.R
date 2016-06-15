wd="./data"
xmlfiles <-list.files(recursive=T, pattern='*.xml', full.names=T)
file.copy(xmlfiles, wd)
mfiles <-list.files()

