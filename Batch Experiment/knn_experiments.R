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
library(Matrix)

#Words Only
############################################################
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

#classification using knn
tweet_raw$textClass[tweet_raw$class=="sports/enter"]<- "TRUE"
tweet_raw$textClass[tweet_raw$class!="sports/enter"]<- "FALSE"

tweet_raw$textClass <- factor(tweet_raw$textClass)
knnFit <- train(tweet_raw$textClass[1:8000] ~ ., data = as.matrix(dfm_train), method = "knn")


knn.pred <- predict(model,newdata= final_test)

cm2<-confusionMatrix(
  knn.pred,
  preprocess$class[8001:155382],positive="TRUE"
)

cm2


##Words with hashtags
########################################################

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

#classification using svm
tweet_raw$textClass[tweet_raw$class=="sports/enter"]<- "TRUE"
tweet_raw$textClass[tweet_raw$class!="sports/enter"]<- "FALSE"

tweet_raw$textClass <- factor(tweet_raw$textClass)


svm.model<-svm(dfm_train,y=tweet_raw$textClass[1:8000],
               scale=TRUE,
               kernel="linear")

svm.pred <- predict(svm.model,final_test,type="raw")
svm.pred1 <- as.factor(svm.pred)
cm2<-confusionMatrix(
  svm.pred1,
  tweet_raw$textClass[8001:155382],positive="TRUE"
)

cm2

##Hashtags Only without Ontology
####################################################
tweet_raw <- read.csv("combined_hashtags_data.csv",stringsAsFactors=FALSE)
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

#classification using svm
tweet_raw$textClass[tweet_raw$class=="sports/enter"]<- "TRUE"
tweet_raw$textClass[tweet_raw$class!="sports/enter"]<- "FALSE"

tweet_raw$textClass <- factor(tweet_raw$textClass)


knnFit <- train(tweet_raw$textClass[1:8000] ~ ., data = as.matrix(dfm_train), method = "knn")


knn.pred <- predict(model,final_test,type="class")

cm2<-confusionMatrix(
  knn.pred,
  preprocess$class[8001:155382],positive="TRUE"
)

cm2

## Ontology
####################################################
tweet_raw <- read.csv("combined_ont_hashtags_data.csv",stringsAsFactors=FALSE)
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

#classification using svm
tweet_raw$textClass[tweet_raw$class=="sports/enter"]<- "TRUE"
tweet_raw$textClass[tweet_raw$class!="sports/enter"]<- "FALSE"

tweet_raw$textClass <- factor(tweet_raw$textClass)


svm.model<-svm(dfm_train,y=tweet_raw$textClass[1:8000],
               scale=TRUE,
               kernel="linear")

svm.pred <- predict(svm.model,final_test,type="raw")
svm.pred1 <- as.factor(svm.pred)
cm2<-confusionMatrix(
  svm.pred1,
  tweet_raw$textClass[8001:155382],positive="TRUE"
)

cm2


