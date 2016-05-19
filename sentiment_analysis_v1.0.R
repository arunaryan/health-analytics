options(java.parameters = "- Xmx4024m")
library(devtools)
library(RCurl)
library(Rcpp)
library(coreNLP)
library(tm.lexicon.GeneralInquirer)
library(tm)
library(plyr)
library(ggplot2)
library(wordcloud)
library(RColorBrewer)
library(base64enc)
library(httpuv)
library(rJava)
library(xlsx)


######################################################################################################
#
# FORMAT FOR SENTIMENT ANALYSIS
#
######################################################################################################


#initalize NLPCore
initCoreNLP('C:\\DATA SCIENCE\\Arun\\Projects\\Text_Analytics\\stanford-corenlp-full-2015-12-09',  mem = "4g")

#read in verbatims
data = read.xlsx("C:\\DATA SCIENCE\\Arun\\Projects\\Text_Analytics\\PatSS_data\\Q4_2015_IP_comments_WTR_NZ.xlsx",1)
comments_data<-data
# verbatim_txt<- read.table("C:\\DATA SCIENCE\\Arun\\Projects\\Text_Analytics\\testQ36.csv",header=TRUE, sep='|',quote = "")
# colnames(verbatim_txt) <- 'COMMENT'
# some_txt <- VCorpus(VectorSource(verbatim_txt$COMMENT))




sentiment.comnt <- data.frame(COMMENTID=numeric(), sentimentValue=numeric(), sentiment=character(),
                            comment=character())

some_txt <- VCorpus(VectorSource(comments_data$COMMENT))

#some_txt <- comments_data$COMMENT

start.time <- Sys.time()
print(start.time)

for (i in 1:length(some_txt)){
  print(i)
  comment <- as.character(lapply(some_txt[i], as.character))[1]
  
  ##Clean comments
  comment<-cleanTxt(comment)
  
  COMMENTID<- i
  
  anot_txt <- annotateString(as.character(comment[1]), format = "obj")
  sentiment1 <- getSentiment(anot_txt)[,2:3]
  if(is.null(sentiment1)){
    
    sentiment1[1,]$sentimentValue<-strtoi("2")
    sentiment1[1,]$sentiment <-as.character("Neutral")}
  
  sent_out <- cbind(COMMENTID, sentiment1, comment)
  sentiment.comnt <- rbind(sentiment.comnt, sent_out)
  
  
  
  
}

end.time <- Sys.time()
print(end.time)
time.taken <- end.time - start.time
print(time.taken)


##Classsify emotion and polarity for comments

emotion.comnt <- data.frame(COMMENTID=numeric(), anger=numeric(),disgust=numeric(),fear=numeric(),joy=numeric(),sadness=numeric(),surprise=numeric(),emotion=character(),pos=numeric(),neg=numeric(),pos_neg=numeric(),polarity=character(),
                          comment=character())

start.time <- Sys.time()
print(start.time)


for (i in 1:length(some_txt)){
  
  comment <- as.character(lapply(some_txt[i], as.character))[1]
  
  ##Clean comments
  comment<-cleanTxt(comment)
  
  COMMENTID<- i
  
  class_emo = classify_emotion(comment, algorithm="bayes", prior=1.0)
  # get emotion best fit
  emotion = class_emo
  colnames(emotion)<-c("anger","disgust","fear","joy","sadness","surprise","emotion")
  # substitute NA's by "unknown"
  
  # classify polarity
  class_pol = classify_polarity(comment, algorithm="bayes")
  # get polarity best fit
  polarity = class_pol
  colnames(polarity)=c("pos","neg","pos_neg","polarity")
  
  emo_out <- cbind(COMMENTID, emotion,polarity, comment)
  emotion.comnt <- rbind(emotion.comnt, emo_out)
  
  
  print(i)
}


end.time <- Sys.time()
print(end.time)
time.taken <- end.time - start.time
print(time.taken)

save.image("C:\\DATA SCIENCE\\Arun\\Projects\\Text_Analytics\\PatSS_data\\PatSS_sentiment_05_18_2016.RData")

emotion_comnt <- data.frame(COMMENTID=character(), anger=character(),disgust=character(),fear=character(),joy=character(),sadness=character(),surprise=character(),emotion=character(),pos=character(),neg=character(),pos_neg=character(),polarity=character(),
                          comment=character())
emotion_comnt <- data.frame(lapply(emotion.comnt, as.character), stringsAsFactors=FALSE)

#}
#Do topic modeling using LDA or CTM models#
library(topicmodels)
library(lda)
library(slam)

##Topic modeling for words which generally describe the +ve, -ve comments from cohorts giving >8.0 and <=6.0 NPS ##


index_comm_pos35 = data$sentimentValue.35==3
index_comm_neg35 = data$sentimentValue.35==1
index_comm_pos16 = data$sentimentValue.16==3
index_comm_neg16 = data$sentimentValue.16==1
index_NPS_neg = comments_data$q34<=6
index_NPS_pos = comments_data$q34>8

# commentsq16_NPS_pos <- paste(comments_data[index_NPS_pos&index_comm_pos16,]$q16,collapse="| ") 
# commentsq16_NPS_neg <- paste(comments_data[index_NPS_pos&index_comm_neg16,]$q16,collapse="| ")
# 
# commentsq35_NPS_pos <- paste(comments_data[index_NPS_pos&index_comm_pos35,]$q35,collapse="| ") 
# commentsq35_NPS_neg <- paste(comments_data[index_NPS_pos&index_comm_neg35,]$q35,collapse="| ")

commentsq16_NPS_pos <- comments_data[index_NPS_pos&index_comm_pos16,]$q16 
commentsq16_NPS_neg <- comments_data[index_NPS_pos&index_comm_neg16,]$q16

commentsq35_NPS_pos <- comments_data[index_NPS_pos&index_comm_pos35,]$q35 
commentsq35_NPS_neg <- comments_data[index_NPS_pos&index_comm_neg35,]$q35

commentsq16_nNPS_pos <- comments_data[index_NPS_neg&index_comm_pos16,]$q16 
commentsq16_nNPS_neg <- comments_data[index_NPS_neg&index_comm_neg16,]$q16 

commentsq35_nNPS_pos <- comments_data[index_NPS_neg&index_comm_pos35,]$q35 
commentsq35_nNPS_neg <- comments_data[index_NPS_neg&index_comm_neg35,]$q35 

commq35_nNPS_pos <- Corpus(VectorSource(commentsq35_nNPS_pos), readerControl=list(language="en")) 
commq35_nNPS_pos <- tm_map(commq35_nNPS_pos, tolower)
commq35_nNPS_pos <- tm_map(commq35_nNPS_pos, removePunctuation)
commq35_nNPS_pos <- tm_map(commq35_nNPS_pos, removeWords, stopwords("english"))
commq35_nNPS_pos <- tm_map(commq35_nNPS_pos, stripWhitespace)
commq35_nNPS_pos <- tm_map(commq35_nNPS_pos, removeNumbers)

commq16_nNPS_pos <- VCorpus(VectorSource(commentsq16_nNPS_pos))

commq16_nNPS_neg <- VCorpus(VectorSource(commentsq16_nNPS_neg))

commq35_nNPS_pos <- VCorpus(VectorSource(commentsq35_nNPS_pos))

commq35_nNPS_neg <- VCorpus(VectorSource(commentsq35_nNPS_neg))

## Topic analysis for NPS >8.0 and NPS<=6.0 with pos and negative comments for q15 and q34 ##

k<-5
commq35_nNPS_pos_dtm<-DocumentTermMatrix(commq35_nNPS_pos,control=list(stopwords=TRUE,minWordLength=3,removeNUmbers=TRUE,removePunctuation=TRUE,sparse=TRUE))

#rowTotals <- apply(commq35_nNPS_pos_dtm , 1, sum) #Find the sum of words in each Document
#commq35_nNPS_pos_dtm   <- commq35_nNPS_pos_dtm[rowTotals> 0, ]           #remove all docs without words
#summary(col_sums(commq35_nNPS_pos_dtm))

commq35_nNPS_pos_tfidf <- tapply(commq35_nNPS_pos_dtm$v/row_sums(commq35_nNPS_pos_dtm)[commq35_nNPS_pos_dtm$i],commq35_nNPS_pos_dtm$j,mean)*log2(nDocs(commq35_nNPS_pos_dtm)/col_sums(commq35_nNPS_pos_dtm>0))
commq35_nNPS_pos_dtm <- commq35_nNPS_pos_dtm[,commq35_nNPS_pos_tfidf >= 0.2]
commq35_nNPS_pos_dtm <- commq35_nNPS_pos_dtm[row_sums(commq35_nNPS_pos_dtm) > 0,]
summary(commq35_nNPS_pos_tfidf)

commq35_nNPS_pos_TM<-list(VEM=LDA(commq35_nNPS_pos_dtm,k=k,control=list(seed=SEED)),VEM_fixed=LDA(commq35_nNPS_pos_dtm,k=k,control=list(estimate.alpha=FALSE,seed=SEED)),Gibbs=LDA(commq35_nNPS_pos_dtm,k=k,method="Gibbs",control=list(seed=SEED,burnin=1000,thin=100,iter=1000)),CTM=CTM(commq35_nNPS_pos_dtm,k=k,control=list(seed=SEED,var=list(tol=10^-4),em=list(tol=10^-3))))

sapply(commq35_nNPS_pos_TM[1:2],slot,"alpha")

sapply(commq35_nNPS_pos_TM,function(x)mean(apply(posterior(x)$topics,1,function(z)-sum(z*log(z)))))

commq35_nNPS_pos_Topic <- topics(commq35_nNPS_pos_TM[["CTM"]])

commq35_nNPS_pos_Terms <-terms(commq35_nNPS_pos_TM[["CTM"]])

##Topic modeling for words which generally describe the +ve, -ve comments from cohorts giving >8.0 and <=6.0 NPS ##


index_comm_pos35 = data$sentimentValue.35==3
index_comm_neg35 = data$sentimentValue.35==1
index_comm_pos16 = data$sentimentValue.16==3
index_comm_neg16 = data$sentimentValue.16==1
index_NPS_neg = comments_data$q34<=6
index_NPS_pos = comments_data$q34>8


sen3ment <-function(comment,n)
{
  
  
  COMMENTID<- n
  #manualcode <- verbatim_txt$MANUAL.CODE[i]
  
  
  anot_txt <- annotateString(as.character(comment), format = "obj")
  sent <- getSentiment(anot_txt)[,2:3]
  sent_out <- cbind(COMMENTID, sent, comment)
  return(sent_out)
}

cleanTxt <- function(str)
{
  str <- gsub("http\\w+", "", str)
  str<-gsub("[^[:alnum:] ]", " ", str)
  # remove unnecessary spaces
  str <- gsub("[ \t]{2,}", " ", str)
  str <- gsub("^\\s+|\\s+$", "", str)
  #str <-tm_map(str, stemDocument)
  str = gsub("[[:punct:]]", "",str)  
  # remove numbers
  str = gsub("[[:digit:]]", "", str)
  # remove unnecessary spaces
  str = gsub("[ \t]{2,}", "", str)
  str = gsub("^\\s+|\\s+$", "", str)
  # remove NAs in some_txt
  str = str[!is.na(str)]
  return(str)
}
