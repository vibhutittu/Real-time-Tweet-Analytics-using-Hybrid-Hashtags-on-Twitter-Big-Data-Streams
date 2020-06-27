library(wordnet)
library(data.table)
library(dplyr)
library(tm)
library(rtweet)
library(jsonlite)
require(data.table)
library(streamR)
library(knitr)
library(ggplot2)
library(quanteda)
library(MASS)
library(caret)
library(tm)
library(pander)
library(dplyr)
library(qdap)
library(stringr)
library(e1071)
library(class)
library(stringi)
library(quanteda)
library(topicmodels)
library(tm)
library(quanteda.textmodels)
library(text2vec)
library(lsa)
library(LSAfun)



d1<- read.csv("hashtags_wordnet.csv")
d1<- d1[,2:3]
d2<- read.csv("hashtags_wiki.csv")
d2<- d2[,2:3]

d1$wiki_exist <- d2$wiki_exist
d3 <- filter(d1,wordnet_exist==TRUE|wiki_exist==TRUE)
d3 <- d3$term


##Hashtags without Ontology
####################################################
tweet_raw <- read.csv("combined_hashtags_data.csv",stringsAsFactors=FALSE)
tweet_raw$class <- factor(tweet_raw$class)

####wordnet Modelling
t <- as.data.frame(tweet_raw$text[1:8000])
names(t) <- "text"

tweet_corpus_train<- Corpus(VectorSource(t$text)) 
tweet_train <- DocumentTermMatrix(tweet_corpus_train)


m2 <- list()
for(i in d3){
  m1<- findAssocs(tweet_train, i, corlimit=0.1)
  m2 <- c(m2,m1)
  
}


m4 <- list()
for(i in 1:length(m2)){
  m3 <- names(m2[[i]])
  m4 <- c(m4,m3)
  
}

m4<- as.character(m4)
write.csv(m4,"wordnet_wiki_associated.csv")

r <- read.csv("wordnet_wiki_associated.csv",stringsAsFactors = FALSE,header=FALSE)
r <- r[-1,-1]


r<- unique(r)
write.csv(r,file="wordnet_wiki_final_list.csv")


#Quanteda package
tweet_corpus <- corpus(tweet_raw$text)
tweet_corpus_train<- tweet_corpus[1:8000]
tweet_corpus_test<- tweet_corpus[8001:155382]

wordnet_wiki_tags <- read.csv("wordnet_wiki_final_list.csv")
wordnet_wiki_tags <- wordnet_wiki_tags[,-1]


dfm_train<- dfm(tweet_corpus_train,select=wordnet_wiki_tags)
dfm_test<- dfm(tweet_corpus_test)

(final_test <- dfm_select(dfm_test, dfm_train))
identical(featnames(dfm_train), featnames(final_test))

#classification using naive bayes
tweet_raw$textClass[tweet_raw$class=="sports/enter"]<- "TRUE"
tweet_raw$textClass[tweet_raw$class!="sports/enter"]<- "FALSE"

tweet_raw$textClass <- factor(tweet_raw$textClass)
tweet_model <- textmodel_nb(dfm_train, tweet_raw$textClass[1:8000],distribution = c("multinomial"))

tweet_predict <- predict(tweet_model,newdata = final_test)
proc.time() - ptm

tweet_predict1 <- as.factor(tweet_predict)

cm2<-confusionMatrix(
  tweet_predict1,
  tweet_raw$textClass[8001:155382],positive="TRUE"
)

cm2


