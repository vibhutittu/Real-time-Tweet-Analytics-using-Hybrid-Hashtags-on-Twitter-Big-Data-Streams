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



##Hashtags Only without Ontology
####################################################
###LIWC Formatted dictionary

# import a LIWC formatted dictionary from http://www.moralfoundations.org
download.file("http://bit.ly/37cV95h", tf <- tempfile())
dictliwc <- dictionary(file = tf, format = "LIWC")

tweet_raw <- read.csv("combined_hashtags_data.csv",stringsAsFactors=FALSE)
tweet_raw$class <- factor(tweet_raw$class)

####LIWC Modelling
t <- as.data.frame(tweet_raw$text[1:8000])
names(t) <- "text"


#Quanteda package
tweet_corpus <- corpus(tweet_raw$text)
tweet_corpus_train<- tweet_corpus[1:8000]
tweet_corpus_test<- tweet_corpus[8001:155382]

liwc_tags <- read.csv("liwc_final_list.csv")
liwc_tags <- liwc_tags[,-1]


dfm_train<- dfm(tweet_corpus_train,select=liwc_tags)
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

####LIWC Modelling
t <- as.data.frame(tweet_raw$text[1:8000])
names(t) <- "text"

#Quanteda package
tweet_corpus <- corpus(tweet_raw$text)
tweet_corpus_train<- tweet_corpus[1:8000]
tweet_corpus_test<- tweet_corpus[8001:155382]

liwc_tags <- read.csv("liwc_final_list.csv")
liwc_tags <- liwc_tags[,-1]


dfm_train<- dfm(tweet_corpus_train,select=liwc_tags)
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
