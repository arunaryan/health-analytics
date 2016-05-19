library(devtools)
library(plyr)
library(RCurl)
library(Rcpp)
library(coreNLP)
library(tm)
library(tm.lexicon.GeneralInquirer)
library(plyr)
library(ggplot2)
library(wordcloud)
library(RColorBrewer)
library(base64enc)
library(httpuv)
library(servr)
library(rJava)
library(topicmodels)
library(lda)
library(LDAvis)
library(slam)

##Topic modeling for words which generally describe the +ve, -ve comments from cohorts giving >8.0 and <=6.0 Net promoter score NPS ##


index_comm_pos35 = data$sentimentValue.35==3
index_comm_neg35 = data$sentimentValue.35==1
index_comm_pos16 = data$sentimentValue.16==3
index_comm_neg16 = data$sentimentValue.16==1
index_NPS_neg = comments_data$q34<=6
index_NPS_pos = comments_data$q34>8

comments_data$Facility <- as.character(comments_data$Facility)
all_facility <- unique(comments_data$Facility)

unk_q16<- comments_data$q16=="UNKNOWN"
unk_q35<- comments_data$q35=="UNKNOWN"
comms_SCH <- comments_data$Facility=="SCH"
comments_SCH_q16 <-comments_data[!unk_q16&comms_SCH,]$q16
comments_SCH_q35 <-comments_data[!unk_q35&comms_SCH,]$q35
commentsq16_nNPS_pos <- comments_data[index_NPS_neg&index_comm_pos16,]$q16 
commentsq16_nNPS_neg <- comments_data[index_NPS_neg&index_comm_neg16,]$q16 
comments_SCH_q16 <-comments_data[index_NPS_neg&index_comm_neg16&comms_SCH,]$q16
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



commentsq16_NPS_pos <- comments_data[index_NPS_pos&index_comm_pos16,]$q16 
commentsq16_NPS_neg <- comments_data[index_NPS_pos&index_comm_neg16,]$q16

commentsq35_NPS_pos <- comments_data[index_NPS_pos&index_comm_pos35,]$q35 
commentsq35_NPS_neg <- comments_data[index_NPS_pos&index_comm_neg35,]$q35

commq16_NPS_pos <- VCorpus(VectorSource(commentsq16_NPS_pos))

commq16_NPS_neg <- VCorpus(VectorSource(commentsq16_NPS_neg))

commq35_NPS_pos <- VCorpus(VectorSource(commentsq35_NPS_pos))

commq35_NPS_neg <- VCorpus(VectorSource(commentsq35_NPS_neg))

## Topic analysis for NPS >8.0 and NPS<=6.0 with pos and negative comments for q15 and q34 ##
data(reviews, package = "LDAvisData")
stop_words <- stopwords("SMART")
comments_pos_q16 <- matrix("NA",1,length(all_facility))
comments_neg_q16 <- matrix("NA",1,length(all_facility))
comments_pos_q35 <- matrix("NA",1,length(all_facility))
comments_neg_q35 <- matrix("NA",1,length(all_facility))
# pre-processing:
for( i in 1:length(all_facility)){
  
  
  comms_facility <- comments_data$Facility==all_facility[i]
  
  comments_pos_q16[i] <-paste(c(comments_data[(!unk_q16)&comms_facility&index_NPS_pos&index_comm_pos16,]$q16),collapse="|")
  comments_neg_q16[i] <-paste(c(comments_data[(!unk_q16)&comms_facility&index_NPS_neg&index_comm_neg16,]$q16),collapse="|")
  comments_pos_q35[i] <-paste(c(comments_data[(!unk_q35)&comms_facility&index_NPS_pos&index_comm_pos35,]$q35),collapse="|")
  comments_neg_q35[i] <-paste(c(comments_data[(!unk_q35)&comms_facility&index_NPS_neg&index_comm_neg35,]$q35),collapse="|")
  
  pos_q16 <- prepForLDA(comments_data[(!unk_q16)&comms_facility&index_NPS_pos&index_comm_pos16,]$q16)
  neg_q16 <- prepForLDA(comments_data[(!unk_q16)&comms_facility&index_NPS_neg&index_comm_neg16,]$q16)
  pos_q35 <- prepForLDA(comments_data[(!unk_q35)&comms_facility&index_NPS_pos&index_comm_pos35,]$q35)
  neg_q35 <- prepForLDA(comments_data[(!unk_q35)&comms_facility&index_NPS_neg&index_comm_neg35,]$q35)
  
# MCMC and model tuning parameters:
K <- 3
G <- 2500
alpha <- 0.02
eta <- 0.02

# Fit LDA models for q16 +ve and -ve feedback

set.seed(12345+i)

t1 <- Sys.time()

pos_q16.fit <- lda.collapsed.gibbs.sampler(documents = pos_q16$documents, K = K, vocab = pos_q16$vocab, 
                                   num.iterations = G, alpha = alpha, 
                                   eta = eta, initial = NULL, burnin = 1000,
                                   compute.log.likelihood = TRUE)
t2 <- Sys.time()
print("time taken for LDA model fit:", t2 - t1) # print timetaken for the model fit

theta <- t(apply(pos_q16.fit$document_sums + alpha, 2, function(x) x/sum(x)))
phi <- t(apply(t(pos_q16.fit$topics) + eta, 2, function(x) x/sum(x)))

pos_q16_list <- list(phi = phi,
                     theta = theta,
                     doc.length = pos_q16$doc.length,
                     vocab = pos_q16$vocab,
                     term.frequency = pos_q16$tf)

# create the JSON object to feed the visualization:
pos_q16_json <- createJSON(phi = pos_q16_list$phi, 
                   theta = pos_q16_list$theta, 
                   doc.length = pos_q16_list$doc.length, 
                   vocab = pos_q16_list$vocab, 
                   term.frequency = pos_q16_list$term.frequency)

serVis(pos_q16_json, out.dir = paste("LDAvis/pos_q16_",all_facility[i],sep=""), open.browser = FALSE)

t1 <- Sys.time()

neg_q16.fit <- lda.collapsed.gibbs.sampler(documents = neg_q16$documents, K = K, vocab = neg_q16$vocab, 
                                           num.iterations = G, alpha = alpha, 
                                           eta = eta, initial = NULL, burnin =1000,
                                           compute.log.likelihood = TRUE)
t2 <- Sys.time()
print("time taken for LDA model fit:") # print timetaken for the model fit
t2-t1
theta <- t(apply(neg_q16.fit$document_sums + alpha, 2, function(x) x/sum(x)))
phi <- t(apply(t(neg_q16.fit$topics) + eta, 2, function(x) x/sum(x)))

neg_q16_list <- list(phi = phi,
                     theta = theta,
                     doc.length = neg_q16$doc.length,
                     vocab = neg_q16$vocab,
                     term.frequency = neg_q16$tf)

# create the JSON object to feed the visualization:
neg_q16_json <- createJSON(phi = neg_q16_list$phi, 
                           theta = neg_q16_list$theta, 
                           doc.length = neg_q16_list$doc.length, 
                           vocab = neg_q16_list$vocab, 
                           term.frequency = neg_q16_list$term.frequency)

serVis(neg_q16_json, out.dir = paste("LDAvis/neg_q16_",all_facility[i],sep=""), open.browser = FALSE)

## LDA for question 35 +ve and -ve feedback

t1 <- Sys.time()

pos_q35.fit <- lda.collapsed.gibbs.sampler(documents = pos_q35$documents, K = K, vocab = pos_q35$vocab, 
                                           num.iterations = G, alpha = alpha, 
                                           eta = eta, initial = NULL, burnin = 1000,
                                           compute.log.likelihood = TRUE)
t2 <- Sys.time()
print("time taken for LDA model fit:", t2 - t1) # print timetaken for the model fit

theta <- t(apply(pos_q35.fit$document_sums + alpha, 2, function(x) x/sum(x)))
phi <- t(apply(t(pos_q35.fit$topics) + eta, 2, function(x) x/sum(x)))

pos_q35_list <- list(phi = phi,
                     theta = theta,
                     doc.length = pos_q35$doc.length,
                     vocab = pos_q35$vocab,
                     term.frequency = pos_q35$tf)

# create the JSON object to feed the visualization:
pos_q35_json <- createJSON(phi = pos_q35_list$phi, 
                           theta = pos_q35_list$theta, 
                           doc.length = pos_q35_list$doc.length, 
                           vocab = pos_q35_list$vocab, 
                           term.frequency = pos_q35_list$term.frequency)

serVis(pos_q35_json, out.dir = paste("LDAvis/pos_q35_",all_facility[i],sep=""), open.browser = FALSE)

t1 <- Sys.time()

neg_q35.fit <- lda.collapsed.gibbs.sampler(documents = neg_q35$documents, K = K, vocab = neg_q35$vocab, 
                                           num.iterations = G, alpha = alpha, 
                                           eta = eta, initial = NULL, burnin = 1000,
                                           compute.log.likelihood = TRUE)
t2 <- Sys.time()
print("time taken for LDA model fit:", t2 - t1) # print timetaken for the model fit

theta <- t(apply(neg_q35.fit$document_sums + alpha, 2, function(x) x/sum(x)))
phi <- t(apply(t(neg_q35.fit$topics) + eta, 2, function(x) x/sum(x)))

neg_q35_list <- list(phi = phi,
                     theta = theta,
                     doc.length = neg_q35$doc.length,
                     vocab = neg_q35$vocab,
                     term.frequency = neg_q35$tf)

# create the JSON object to feed the visualization:
neg_q35_json <- createJSON(phi = neg_q35_list$phi, 
                           theta = neg_q35_list$theta, 
                           doc.length = neg_q35_list$doc.length, 
                           vocab = neg_q35_list$vocab, 
                           term.frequency = neg_q35_list$term.frequency)

serVis(neg_q35_json, out.dir = paste("LDAvis/neg_q35_",all_facility[i],sep=""), open.browser = FALSE)
}
#serVis(comments_SCH_q16_json,open.browser = TRUE)
##Topic modeling for words which generally describe the +ve, -ve comments from cohorts giving >8.0 and <=6.0 NPS ##
cleanTxt <- function(str)
{
  str <- gsub("http\\w+", "", str)
  str<-gsub("[^[:alnum:] ]", " ", str)
  # remove unnecessary spaces
  str <- gsub("[ \t]{2,}", " ", str)
  str <- gsub("^\\s+|\\s+$", "", str)
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

prepForLDA <- function(strarray)
{
  strarray <-cleanTxt(strarray)
  strarray <- tolower(strarray)  # force to lowercase
  
  # tokenize on space and output as a list:
  strarray.list <- strsplit(strarray, "[[:space:]]+")
  
  tt <- table(unlist(strarray.list))
  tt <- sort(tt, decreasing = TRUE)
  
  del <- names(tt) %in% stop_words | tt <=1
  tt <- tt[!del]
  vocab <- names(tt)
  
  
  documents <- lapply(strarray.list, get.terms)
  
  
  # Compute some statistics related to the data set:
  D <- length(documents)  # number of documents
  W <- length(vocab)  # number of terms in the vocab 
  doc.length <- sapply(documents, function(x) sum(x[2, ]))  # number of tokens per document 
  N <- sum(doc.length)  # total number of tokens in the data 
  term.frequency <- as.integer(tt)  # frequencies of terms in the corpus

strList <- list("documents"=documents,"vocab"=vocab,"D"=D,"W"=W,"doc.length"=doc.length,"N"=N,"tf"=term.frequency)
return(strList)
  }

get.terms <- function(x) {
  index <- match(x, vocab)
  index <- index[!is.na(index)]
  rbind(as.integer(index - 1), as.integer(rep(1, length(index))))
}
