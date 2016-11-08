


wordFrequency <-function(con) {
  
library("tm")
library("SnowballC")
posts<- read.csv("WSA.csv", header = TRUE,  fileEncoding="latin1")
corpus <- Corpus(VectorSource(posts$WSA)) # create corpus object
corpus <- tm_map(corpus, tolower, mc.cores=1) # convert all text to lower case
corpus <- tm_map(corpus, mc.cores=1, removePunctuation)
corpus <- tm_map(corpus, removeNumbers, mc.cores=1)
corpus <- tm_map(corpus, removeWords, stopwords("english"), mc.cores=1)

corpus <- tm_map(corpus, PlainTextDocument)

#tdm <- TermDocumentMatrix(corpus)
#tdm <- TermDocumentMatrix(corpus, control = list(weighting = weightTfIdf))

mydata.df <- as.data.frame(inspect(tdm))
count<- as.data.frame(rowSums(mydata.df))
count$word = rownames(count)
colnames(count) <- c("count","word" )
count<-count[order(count$count, decreasing=TRUE), ]
}
      