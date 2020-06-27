rm(list=ls())
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




##Hashtags Only without Ontology
####################################################
tweet_raw <- read.csv("combined_hashtags_data.csv",stringsAsFactors=FALSE)
tweet_raw$class <- factor(tweet_raw$class)

####LDA modelling
t <- as.data.frame(tweet_raw$text[1:8000])
names(t) <- "text"

#Set parameters for Gibbs sampling
burnin <- 4000
iter <- 2000
thin <- 500
seed <-list(2003,5,63,100001,765)
nstart <- 5
best <- TRUE


#Number of topics
k <- 10

t1 <- corpus(t$text)
dfm_train<- dfm(t1)
rowTotals <- apply(dfm_train , 1, sum) #Find the sum of words in each Document
dtm.new <- dfm_train[rowTotals> 0, ]           #remove all docs without words


#Run LDA using Gibbs sampling
ldaOut <-LDA(dtm.new,k, method="Gibbs", control=list(nstart=nstart, seed = seed, best=best, burnin = burnin, iter = iter, thin=thin))

#write out results
#docs to topics
ldaOut.topics <- as.matrix(topics(ldaOut))


#top 6 terms in each topic
ldaOut.terms <- as.matrix(terms(ldaOut,10))

#probabilities associated with each topic assignment
#topicProbabilities <- as.data.frame(ldaOut@gamma)
##########################################################


##Hashtags Only without Ontology
####################################################
tweet_raw <- read.csv("combined_hashtags_data.csv",stringsAsFactors=FALSE)
tweet_raw$class <- factor(tweet_raw$class)

#Quanteda package
tweet_corpus <- corpus(tweet_raw$text)
tweet_corpus_train<- tweet_corpus[1:8000]
tweet_corpus_test<- tweet_corpus[8001:155382]

lda_tags <- read.csv("lda_final_list.csv")
lda_tags <- lda_tags[,-1]

dfm_train<- dfm(tweet_corpus_train,select= lda_tags)
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


##Hashtags with Ontology
####################################################
tweet_raw <- read.csv("combined_ont_hashtags_data.csv",stringsAsFactors=FALSE)
tweet_raw$class <- factor(tweet_raw$class)

####LDA modelling
t <- as.data.frame(tweet_raw$text[1:8000])
names(t) <- "text"

#Quanteda package
tweet_corpus <- corpus(tweet_raw$text)
tweet_corpus_train<- tweet_corpus[1:8000]
tweet_corpus_test<- tweet_corpus[8001:155382]

lda_tags <- read.csv("lda_final_list.csv")
lda_tags <- lda_tags[,-1]

dfm_train<- dfm(tweet_corpus_train,select= lda_tags)
dfm_test<- dfm(tweet_corpus_test)

(final_test <- dfm_select(dfm_test, dfm_train))
identical(featnames(dfm_train), featnames(final_test))

#classification using naive bayes
tweet_raw$textClass[tweet_raw$class=="sports/enter"]<- "TRUE"
tweet_raw$textClass[tweet_raw$class!="sports/enter"]<- "FALSE"

tweet_raw$textClass <- factor(tweet_raw$textClass)
tweet_model <- textmodel_nb(dfm_train, tweet_raw$textClass[1:8000],distribution = c("multinomial"))

tweet_predict <- predict(tweet_model,newdata = final_test)

tweet_predict1 <- as.factor(tweet_predict)

cm2<-confusionMatrix(
  tweet_predict1,
  tweet_raw$textClass[8001:155382],positive="TRUE"
)

cm2


