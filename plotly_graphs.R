library(plotly)
library(dplyr)
library(scales)
##Topic modeling for words which generally describe the +ve, -ve comments from cohorts giving >8.0 and <=6.0 NPS ##

PatSS_comnt<-merge(sentiment.comnt,subset(emotion.comnt,select=c("COMMENTID","emotion","polarity")),by="COMMENTID",all=TRUE)
PatSS_data<-merge(comments_data,PatSS_comnt,by.x="ID",by.y="COMMENTID",all.x=TRUE)
keeps<-c("ID","HSP_CODE",'PATIENT_AGE_YEARS',"GENDER","FINAL_DRG","PAYOR_TYPE","DISCHARGE_STATUS","RESPONSE_CODE","RESPONSE_DESCRIPTION","sentimentValue","sentiment","emotion","comment")
PatSS_data<-PatSS_data[,names(PatSS_data) %in% keeps]


PatSS_data$sentiment[PatSS_data$sentiment=="Verypositive"] <-"Positive"
PatSS_data$sentiment[PatSS_data$sentiment=="Verynegative"] <-"Negative"

PatSS_data$RESPONSE_DESCRIPTION[PatSS_data$RESPONSE_DESCRIPTION=="Probably yes"] <-"Other"
PatSS_data$RESPONSE_DESCRIPTION[PatSS_data$RESPONSE_DESCRIPTION=="Probably no"] <-"Other"

PatSS_data1<-PatSS_data[!PatSS_data$RESPONSE_DESCRIPTION=="Missing/Don't Know",]

## Plot basic data from sentiment+demo data

count.Patss_SVH <- PatSS_data1[index_SVH,] %>%
  group_by(HSP_CODE) %>%
  summarize(count = n())
count.Patss <- data.table(count.Patss)
setkey(count.Patss,HSP_CODE,count)
count.Patss<-setorder(count.Patss,-count)
top_5_HSP_neg <- count.Patss_neg[1:5,]$HSP_CODE
library(data.table)
sentiment.PatSS <- PatSS_data1 %>%
  group_by(sentiment) %>%
  summarize(count = n())
response.PatSS<- PatSS_data1 %>%
  group_by(RESPONSE_DESCRIPTION) %>%
  summarize(count = n())
plot_ly(sentiment.PatSS_SVH, labels = sentiment, values = count, type = "pie", hole = 0.6, showlegend = T) %>%
  layout(title = "Sentiment distribution - SVH")
plot_ly(response.PatSS_SVH, labels = RESPONSE_DESCRIPTION, values = count, type = "pie", hole = 0.6, showlegend = T) %>%
  layout(title = "Response distribution - SVH")


sentiment.PatSS_HSP <- PatSS_data1 %>%
  group_by(HSP_CODE,sentiment) %>%
  summarize(count = n())

sentiment.PatSS_HSP<-ddply(PatSS_data1,~HSP_CODE+sentiment,summarise, volume=length(HSP_CODE), count=n(), 
              percent=(count/volume)*100)
# sentiment.PatSS_HSP<-mutate(sentiment.PatSS_HSP,total=sum(count))
# sentiment.PatSS_HSP <-arrange(sentiment.PatSS_HSP,total)

response.PatSS_HSP<- PatSS_data1 %>%
  group_by(RESPONSE_DESCRIPTION, HSP_CODE) %>%
  summarize(count = n())
response.PatSS_HSP<-ddply(PatSS_data1,~HSP_CODE+RESPONSE_DESCRIPTION,summarise, volume=length(HSP_CODE), count=n(), 
                           percent=(count/volume)*100)
datm <- melt(cbind(sentiment.PatSS_HSP, ind = rownames(sentiment.PatSS_HSP)), id.vars = c('sentiment'))
ggplot(datm,aes(x = sentiment.PatSS_HSP$count, y = sentiment.PatSS_HSP$HSP_CODE,fill = ind)) + 
  geom_bar(position = "fill",stat = "identity") + 
  scale_y_continuous(labels = percent_format())

p1<-plot_ly(x =sentiment.PatSS_HSP$count , y =sentiment.PatSS_HSP$HSP_CODE , type = "bar", orientation="h", color = sentiment.PatSS_HSP$sentiment)
p2<-layout(p1,barmode="stack",title = "Sentiment distribution by Facility")
p2
#plotly_IMAGE(p2, format = "png", out_file = "top5_HSP_sentimentDist.png")
p1<-plot_ly(x =response.PatSS_HSP$count , y = response.PatSS_HSP$HSP_CODE, type = "bar", orientation="h",color = response.PatSS_HSP$RESPONSE_DESCRIPTION)
p2<-layout(p1,barmode="stack",title = "Response distribution by Facility")
p2
