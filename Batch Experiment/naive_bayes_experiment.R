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

#Words Only
############################################################
ptm <- proc.time()

tweet_raw <- read.csv("combined_words_only_data.csv",stringsAsFactors=FALSE)
tweet_raw<- tweet_raw[,2:3]
tweet_raw$class <- factor(tweet_raw$class)


#Quanteda package
tweet_corpus <- corpus(tweet_raw$text)
tweet_corpus_train<- tweet_corpus[1:8000,]
tweet_corpus_test<- tweet_corpus[8001:155382,]

dfm_train<- dfm(tweet_corpus_train)
dfm_test<- dfm(tweet_corpus_test)

(final_test <- dfm_select(dfm_test, dfm_train))
identical(featnames(dfm_train), featnames(final_test))

#classification using naive bayes
tweet_raw$textClass[tweet_raw$class=="sports/enter"]<- "TRUE"
tweet_raw$textClass[tweet_raw$class!="sports/enter"]<- "FALSE"

tweet_raw$textClass <- factor(tweet_raw$textClass)
tweet_model <- textmodel_nb(dfm_train, tweet_raw$textClass[1:8000],prior="termfreq")

tweet_predict <- predict(tweet_model,newdata = final_test)
proc.time() - ptm

tweet_predict1 <- as.factor(tweet_predict)

cm2<-confusionMatrix(
  tweet_predict1,
  tweet_raw$textClass[8001:155382],positive="TRUE"
)

cm2



##Words with hashtags
########################################################
ptm <- proc.time()

tweet_raw <- read.csv("combined_words_#_data.csv",stringsAsFactors=FALSE)
tweet_raw<- tweet_raw[,2:3]
tweet_raw$class <- factor(tweet_raw$class)


#Quanteda package
tweet_corpus <- corpus(tweet_raw$text)
tweet_corpus_train<- tweet_corpus[1:8000,]
tweet_corpus_test<- tweet_corpus[8001:155382,]

dfm_train<- dfm(tweet_corpus_train)
dfm_test<- dfm(tweet_corpus_test)

(final_test <- dfm_select(dfm_test, dfm_train))
identical(featnames(dfm_train), featnames(final_test))

#classification using naive bayes
tweet_raw$textClass[tweet_raw$class=="sports/enter"]<- "TRUE"
tweet_raw$textClass[tweet_raw$class!="sports/enter"]<- "FALSE"

tweet_raw$textClass <- factor(tweet_raw$textClass)
tweet_model <- textmodel_nb(dfm_train, tweet_raw$textClass[1:8000],prior="termfreq")

tweet_predict <- predict(tweet_model,newdata = final_test)
proc.time() - ptm

tweet_predict1 <- as.factor(tweet_predict)

cm2<-confusionMatrix(
  tweet_predict1,
  tweet_raw$textClass[8001:155382],positive="TRUE"
)

cm2

##Hashtags Only without Ontology
####################################################
ptm <- proc.time()

tweet_raw <- read.csv("combined_hashtags_data.csv",stringsAsFactors=FALSE)
tweet_raw$class <- factor(tweet_raw$class)


#Quanteda package
tweet_corpus <- corpus(tweet_raw$text)
tweet_corpus_train<- tweet_corpus[1:8000]
tweet_corpus_test<- tweet_corpus[8001:155382]

dfm_train<- dfm(tweet_corpus_train)
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

## Ontology
####################################################
ptm <- proc.time()

tweet_raw <- read.csv("combined_ont_hashtags_data.csv",stringsAsFactors=FALSE)
tweet_raw<- tweet_raw[,2:3]
tweet_raw$class <- factor(tweet_raw$class)


#Quanteda package
tweet_corpus <- corpus(tweet_raw$text)
tweet_corpus_train<- tweet_corpus[1:8000]
tweet_corpus_test<- tweet_corpus[8001:155382]

dfm_train<- dfm(tweet_corpus_train)
dfm_test<- dfm(tweet_corpus_test)

(final_test <- dfm_select(dfm_test, dfm_train))
identical(featnames(dfm_train), featnames(final_test))

#classification using naive bayes
tweet_raw$textClass[tweet_raw$class=="sports/enter"]<- "TRUE"
tweet_raw$textClass[tweet_raw$class!="sports/enter"]<- "FALSE"

tweet_raw$textClass <- factor(tweet_raw$textClass)

tweet_model <- textmodel_nb(dfm_train, tweet_raw$textClass[1:8000], prior ="docfreq")

tweet_predict <- predict(tweet_model,newdata = final_test)
proc.time() - ptm

tweet_predict1 <- as.factor(tweet_predict)

cm2<-confusionMatrix(
  tweet_predict1,
  tweet_raw$textClass[8001:155382],positive="TRUE"
)

cm2


