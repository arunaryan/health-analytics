library(RODBC)
library(data.table)
library(sqldf)
library(dplyr)
library(zoo)
library(reshape2)
library(Hmisc)
library(rms)
library(ggplot2)                                                                                                                                                                                                               
library(foreach)
library(doParallel)

## Data acuisition from Netezza ##

channel<- odbcConnect("CERNER_OLD", uid="*******", pwd="********", believeNRows=FALSE)


start.time<-Sys.time()
query_string<- paste("SELECT * FROM RSTUDIES.NZADMIN.DATA_SEPSIS", ";", sep="") ##WHERE FACILITY_DISP in (\'", FN_Facility, "\')


query_string <- strwrap(query_string, width=100000000, simplify=TRUE)
start.time <- Sys.time()
DATA_SEPSIS <- sqlQuery(channel,query_string, as.is=TRUE)
end.time <- Sys.time()
time.taken <- end.time - start.time
time.taken

start.time<-Sys.time()
query_string<- paste("SELECT * FROM RSTUDIES.NZADMIN.DATA_SEPSIS_DOCUMENTATION_CERNER", ";", sep="")


query_string <- strwrap(query_string, width=100000000, simplify=TRUE)
start.time <- Sys.time()
DATA_SEPSIS_DOC <- sqlQuery(channel,query_string, as.is=TRUE)
end.time <- Sys.time()
time.taken <- end.time - start.time
time.taken

start.time<-Sys.time()
query_string<- paste("SELECT * FROM RSTUDIES.NZADMIN.DATA_SEPSIS_ICD10DIAG", ";", sep="")


query_string <- strwrap(query_string, width=100000000, simplify=TRUE)
start.time <- Sys.time()
DATA_SEPSIS_ICD10DIAG <- sqlQuery(channel,query_string, as.is=TRUE)
end.time <- Sys.time()
time.taken <- end.time - start.time
time.taken

start.time<-Sys.time()
query_string<- paste("SELECT * FROM RSTUDIES.NZADMIN.DATA_SEPSIS_ICD9DIAG", ";", sep="")


query_string <- strwrap(query_string, width=100000000, simplify=TRUE)
start.time <- Sys.time()
DATA_SEPSIS_ICD9DIAG <- sqlQuery(channel,query_string, as.is=TRUE)
end.time <- Sys.time()
time.taken <- end.time - start.time
time.taken

start.time<-Sys.time()
query_string<- paste("SELECT * FROM RSTUDIES.NZADMIN.DATA_BASE_ICD9PROC", ";", sep="")


query_string <- strwrap(query_string, width=100000000, simplify=TRUE)
start.time <- Sys.time()
DATA_SEPSIS_ICD9PROC <- sqlQuery(channel,query_string, as.is=TRUE)
end.time <- Sys.time()
time.taken <- end.time - start.time
time.taken

start.time<-Sys.time()
query_string<- paste("SELECT * FROM RSTUDIES.NZADMIN.DATA_BASE_ICD10PROC", ";", sep="")


query_string <- strwrap(query_string, width=100000000, simplify=TRUE)
start.time <- Sys.time()
DATA_SEPSIS_ICD10PROC <- sqlQuery(channel,query_string, as.is=TRUE)
end.time <- Sys.time()
time.taken <- end.time - start.time
time.taken

start.time<-Sys.time()
query_string<- paste("SELECT * FROM RSTUDIES.NZADMIN.DATA_SEPSIS_LAB_ORDERS", ";", sep="")


query_string <- strwrap(query_string, width=100000000, simplify=TRUE)
start.time <- Sys.time()
DATA_SEPSIS_LAB_ORDERS <- sqlQuery(channel,query_string, as.is=TRUE)
end.time <- Sys.time()
time.taken <- end.time - start.time
time.taken

start.time<-Sys.time()
query_string<- paste("SELECT * FROM RSTUDIES.NZADMIN.DATA_SEPSIS_LAB_RESULTS", ";", sep="")


query_string <- strwrap(query_string, width=100000000, simplify=TRUE)
start.time <- Sys.time()
DATA_SEPSIS_LAB_RESULTS <- sqlQuery(channel,query_string, as.is=TRUE)
end.time <- Sys.time()
time.taken <- end.time - start.time
time.taken

start.time<-Sys.time()
query_string<- paste("SELECT * FROM RSTUDIES.NZADMIN.DATA_SEPSIS_MED_ADMINS", ";", sep="")


query_string <- strwrap(query_string, width=100000000, simplify=TRUE)
start.time <- Sys.time()
DATA_SEPSIS_MED_ADMINS <- sqlQuery(channel,query_string, as.is=TRUE)
end.time <- Sys.time()
time.taken <- end.time - start.time
time.taken

start.time<-Sys.time()
query_string<- paste("SELECT * FROM RSTUDIES.NZADMIN.DATA_SEPSIS_DOBUTAMINE_ADMIN_CERNER", ";", sep="")


query_string <- strwrap(query_string, width=100000000, simplify=TRUE)
start.time <- Sys.time()
DATA_SEPSIS_DOBUTAMINE_ADMIN_CERNER <- sqlQuery(channel,query_string, as.is=TRUE)
end.time <- Sys.time()
time.taken <- end.time - start.time
time.taken

start.time<-Sys.time()
query_string<- paste("SELECT * FROM RSTUDIES.NZADMIN.DATA_SEPSIS_MED_ADMIN_CERNER where MED_TYPE = 'SEPSIS ANTIBIOTICS'", ";", sep="")


query_string <- strwrap(query_string, width=100000000, simplify=TRUE)
start.time <- Sys.time()
DATA_SEPSIS_MED_ADMIN_CERNER <- sqlQuery(channel,query_string, as.is=TRUE)
end.time <- Sys.time()
time.taken <- end.time - start.time
time.taken

start.time<-Sys.time()
query_string<- paste("SELECT * FROM RSTUDIES.NZADMIN.DATA_SEPSIS_MED_ADMIN2_CERNER", ";", sep="")


query_string <- strwrap(query_string, width=100000000, simplify=TRUE)
start.time <- Sys.time()
DATA_SEPSIS_MED_ADMIN2_CERNER <- sqlQuery(channel,query_string, as.is=TRUE)
end.time <- Sys.time()
time.taken <- end.time - start.time
time.taken

start.time<-Sys.time()
query_string<- paste("SELECT * FROM RSTUDIES.NZADMIN.DATA_SEPSIS_MEDS_FLUID_CERNER", ";", sep="")


query_string <- strwrap(query_string, width=100000000, simplify=TRUE)
start.time <- Sys.time()
DATA_SEPSIS_MEDS_FLUID_CERNER <- sqlQuery(channel,query_string, as.is=TRUE)
end.time <- Sys.time()
time.taken <- end.time - start.time
time.taken

start.time<-Sys.time()
query_string<- paste("SELECT * FROM RSTUDIES.NZADMIN.DATA_SEPSIS_MICRO_ORDERS where ORDER_TYPE = 'Blood Culture'", ";", sep="")


query_string <- strwrap(query_string, width=100000000, simplify=TRUE)
start.time <- Sys.time()
DATA_SEPSIS_MICRO_ORDERS <- sqlQuery(channel,query_string, as.is=TRUE)
end.time <- Sys.time()
time.taken <- end.time - start.time
time.taken

start.time<-Sys.time()
query_string<- paste("SELECT * FROM RSTUDIES.NZADMIN.DATA_SEPSIS_MISC_ORDERS", ";", sep="")


query_string <- strwrap(query_string, width=100000000, simplify=TRUE)
start.time <- Sys.time()
DATA_SEPSIS_MISC_ORDERS <- sqlQuery(channel,query_string, as.is=TRUE)
end.time <- Sys.time()
time.taken <- end.time - start.time
time.taken

start.time<-Sys.time()
query_string<- paste("SELECT * FROM RSTUDIES.NZADMIN.DATA_SEPSIS_RADIOLOGY_ORDERS", ";", sep="")


query_string <- strwrap(query_string, width=100000000, simplify=TRUE)
start.time <- Sys.time()
DATA_SEPSIS_RADIOLOGY_ORDERS <- sqlQuery(channel,query_string, as.is=TRUE)
end.time <- Sys.time()
time.taken <- end.time - start.time
time.taken

start.time<-Sys.time()
query_string<- paste("SELECT * FROM RSTUDIES.NZADMIN.DATA_SEPSIS_VITALS_CERNER 
                      where VITAL_TYPE in ('SBP','Respiratory Rate','Heart Rate')", ";", sep="")


query_string <- strwrap(query_string, width=100000000, simplify=TRUE)
start.time <- Sys.time()
DATA_SEPSIS_VITALS_CERNER <- sqlQuery(channel,query_string, as.is=TRUE)
end.time <- Sys.time()
time.taken <- end.time - start.time
time.taken




## Data Munging ##
sepsis_codes <- c("78552","99591","99592")
DATA_SEPSIS$ENCOUNTERID <- paste(DATA_SEPSIS$FACILITY_DISP,":",DATA_SEPSIS$FIN_NBR,sep='')
encounters<- paste(DATA_SEPSIS$FACILITY_DISP,":",DATA_SEPSIS$FIN_NBR,sep='')

DATA_SEPSIS_LAB_ORDERS$ENCOUNTERID <- paste(DATA_SEPSIS_LAB_ORDERS$FACILITY_DISP,":",DATA_SEPSIS_LAB_ORDERS$FIN_NBR,sep='')
DATA_SEPSIS_MICRO_ORDERS$ENCOUNTERID <- paste(DATA_SEPSIS_MICRO_ORDERS$FACILITY_DISP,":",DATA_SEPSIS_MICRO_ORDERS$FIN_NBR,sep='')
DATA_SEPSIS_MED_ADMIN_CERNER$ENCOUNTERID <-paste(DATA_SEPSIS_MED_ADMIN_CERNER$FACILITY_DISP,":",DATA_SEPSIS_MED_ADMIN_CERNER$FIN_NBR,sep='')

DATA_SEPSIS_VITALS_CERNER$ENCOUNTERID <- paste(DATA_SEPSIS_VITALS_CERNER$FACILITY_DISP,":",DATA_SEPSIS_VITALS_CERNER$FIN_NBR,sep='')



micro_rel <- DATA_SEPSIS_MICRO_ORDERS[DATA_SEPSIS_MICRO_ORDERS$ORDER_TYPE =="Blood Culture",]
med_rel <-DATA_SEPSIS_MED_ADMIN_CERNER[DATA_SEPSIS_MED_ADMIN_CERNER$MED_TYPE == "SEPSIS ANTIBIOTICS",]

micro_rel <- micro_rel[,(names(micro_rel) %in% c("ENCOUNTERID","ORDER_DT_TM","ORDER_TYPE"))]
med_rel <- med_rel[,(names(med_rel) %in% c("ENCOUNTERID","ORDER_DT_TM","MED_TYPE"))]

sbp_rel <- DATA_SEPSIS_VITALS_CERNER[DATA_SEPSIS_VITALS_CERNER$VITAL_TYPE =="SBP" & as.numeric(DATA_SEPSIS_VITALS_CERNER$RESULT_VAL)<100,]
rr_rel <-DATA_SEPSIS_VITALS_CERNER[DATA_SEPSIS_VITALS_CERNER$VITAL_TYPE =="Respiratory Rate" &as.numeric(DATA_SEPSIS_VITALS_CERNER$RESULT_VAL)>=22,]

sbp_rel <- sbp_rel[,(names(sbp_rel) %in% c("ENCOUNTERID","VITAL_TYPE","RESULT_VAL","PERFORM_DT_TM"))]
rr_rel <- rr_rel[,(names(rr_rel) %in% c("ENCOUNTERID","VITAL_TYPE","RESULT_VAL","PERFORM_DT_TM"))]

sbp_rel$RESULT_VAL <- as.numeric(sbp_rel$RESULT_VAL)
rr_rel$RESULT_VAL <- as.numeric(rr_rel$RESULT_VAL)


GCS1<-GCS[GCS$DOC_VAL<=13.0,]

GCS1 <- subset(GCS1, select = c("ENCOUNTERID","DOC_TYPE","DOC_VAL","PERFORM_DT_TM"))
colnames(GCS1)<-c("ENCOUNTERID","EVENT_TYPE","RESULT_VAL","TIMESTAMP")

colnames(sbp_rel)<-c("EVENT_TYPE","RESULT_VAL","TIMESTAMP","ENCOUNTERID")
colnames(rr_rel)<-c("EVENT_TYPE","RESULT_VAL","TIMESTAMP","ENCOUNTERID")

all_qsofa_vitals <- rbind(sbp_rel,rr_rel)
all_qsofa_vitals <- all_qsofa_vitals[complete.cases(all_qsofa_vitals),]

all_qsofa_vitals$TIMESTAMP<-strptime(all_qsofa_vitals$TIMESTAMP, "%Y-%m-%d %H:%M:%OS", tz="GMT")
all_qsofa_vitals$TIMESTAMP <- as.POSIXct(all_qsofa_vitals$TIMESTAMP)
all_qsofa_vitals<-all_qsofa_vitals[c("ENCOUNTERID","EVENT_TYPE","TIMESTAMP","RESULT_VAL")]

all_qsofa_vitals <- rbind(all_qsofa_vitals,GCS1)
all_qsofa_vitals <- all_qsofa_vitals[complete.cases(all_qsofa_vitals),]

all_qsofa_vitals <- data.table(all_qsofa_vitals)

setkey(all_qsofa_vitals, ENCOUNTERID, TIMESTAMP)

all_qsofa_vitals <- setorder(all_qsofa_vitals, ENCOUNTERID, TIMESTAMP)


med_rel1<-med_rel
micro_rel1 <- micro_rel

med_encs <- unique(med_rel$ENCOUNTERID)
micro_encs <- unique(micro_rel$ENCOUNTERID)


colnames(micro_rel1)<-c("TIMESTAMP","EVENT_TYPE","ENCOUNTERID")
colnames(med_rel1)<-c("TIMESTAMP","EVENT_TYPE","ENCOUNTERID")

all_med_micro <- rbind(med_rel1,micro_rel1)
all_med_micro <- all_med_micro[complete.cases(all_med_micro),]

all_med_micro$TIMESTAMP<-strptime(all_med_micro$TIMESTAMP, "%Y-%m-%d %H:%M:%OS", tz="GMT")
all_med_micro$TIMESTAMP <- as.POSIXct(all_med_micro$TIMESTAMP)


all_med_micro <- data.table(all_med_micro)

setkey(all_med_micro, ENCOUNTERID, TIMESTAMP)

all_med_micro <- setorder(all_med_micro, ENCOUNTERID, TIMESTAMP)

temp6<-all_med_micro
lg <- function(x)c(NA, x[1:(length(x)-1)])
temp6$TIMESTAMP<-as.character(temp6$TIMESTAMP)
temp6$prev.time <- ave(temp6$TIMESTAMP, temp6$ENCOUNTERID, FUN=lg)
temp6<-data.frame(temp6)
temp6$prev.event <- ave(temp6$EVENT_TYPE, temp6$ENCOUNTERID, FUN=lg)

all_qSOFA_events <- temp6

temp6$prev.time <- ifelse(is.na(temp6$prev.time),temp6$TIMESTAMP,temp6$prev.time)
temp6$prev.event <- ifelse(is.na(temp6$prev.event),temp6$EVENT_TYPE,temp6$prev.event)


temp6$TIMESTAMP<-strptime(temp6$TIMESTAMP, "%Y-%m-%d %H:%M:%OS", tz="GMT")
temp6$TIMESTAMP <- as.POSIXct(temp6$TIMESTAMP)

temp6$prev.time<-strptime(temp6$prev.time, "%Y-%m-%d %H:%M:%OS", tz="GMT")
temp6$prev.time <- as.POSIXct(temp6$prev.time)

temp6$timediff <- ifelse(temp6$EVENT_TYPE == temp6$prev.event,9999,difftime(temp6$TIMESTAMP,temp6$prev.time, units=c("hours"),tz='GMT'))

antib.prev<-temp6[temp6$prev.event == "SEPSIS ANTIBIOTICS",]
antib.prev <- antib.prev[antib.prev$timediff<=24.0,]

bc.prev<-temp6[temp6$prev.event == "Blood Culture",]

bc.prev <- bc.prev[bc.prev$timediff <=72.0,]

temp7 <- rbind(bc.prev,antib.prev)
temp7 <- temp7[complete.cases(temp7),]

#Sort by time and a difftime
temp7<-data.table(temp7)
setkey(temp7, ENCOUNTERID, timediff)
temp7<-setorder(temp7, ENCOUNTERID, timediff)

#Now just do ENCOUNTERID, and pick first.does not change order. Use first time as time 0.
setkey(temp7, ENCOUNTERID) 
temp7<-setorder(temp7, ENCOUNTERID)
choose<-unique(temp7)[,key(temp7), with = FALSE]
temp8<-temp7[choose,mult = 'first']

write.table(temp8,file=paste("C:\\DATA SCIENCE\\Arun\\Projects\\Sepsis\\Data\\04_11_2016\\qSOFA_antib_bc_all_time0_v1.0.csv",sep=""), sep=",",row.names=FALSE)
rm(temp6)
rm(temp7)
rm(temp8)

## flag by the first encounter of antibiotics/blood culture as time-zero ##
setkey(all_med_micro, ENCOUNTERID) 
temp4<-setorder(all_med_micro, ENCOUNTERID)
choose<-unique(temp4)[,key(temp4), with = FALSE]
temp9<-all_med_micro[choose,mult = 'first']


## qSOFA score calculations $$


all_qsofa_vitals$time0 <- ifelse(all_qsofa_vitals$ENCOUNTERID %in% temp9$ENCOUNTERID,temp9$TIMESTAMP, NA)
all_qsofa_vitals1 <- merge(subset(all_qsofa_vitals, ENCOUNTERID %in% temp9$ENCOUNTERID), 
                                subset(temp9,select=c('ENCOUNTERID','TIMESTAMP')), by='ENCOUNTERID', all.x=TRUE)
all_qsofa_vitals1$timediff<-as.numeric(difftime(as.POSIXct(all_qsofa_vitals1$TIMESTAMP.x,origin="1970-01-01",tz="GMT"),
                                                as.POSIXct(all_qsofa_vitals1$TIMESTAMP.y,origin="1970-01-01",tz="GMT"),
                                                units=c("hours"),tz='GMT'))

all_qsofa_vitals$timediff <-ifelse(is.na(all_qsofa_vitals$time0),9999,as.numeric(difftime(as.POSIXct(all_qsofa_vitals$TIMESTAMP,origin="1970-01-01",tz="GMT"),as.POSIXct(all_qsofa_vitals$time0,origin="1970-01-01",tz="GMT"),units=c("hours"),tz='GMT')))

all_qsofa_vitals1<-all_qsofa_vitals[all_qsofa_vitals$timediff>=-48.0&all_qsofa_vitals$timediff<=24.0,]

all_qsofa_rr <-all_qsofa_vitals[all_qsofa_vitals$EVENT_TYPE == "Respiratory Rate",]
all_qsofa_sbp <-all_qsofa_vitals[all_qsofa_vitals$EVENT_TYPE == "SBP",]
all_qsofa_gcs <-all_qsofa_vitals[all_qsofa_vitals$EVENT_TYPE == "GCS",]

temp9$RR.flag <-ifelse(temp9$ENCOUNTERID %in% all_qsofa_rr$ENCOUNTERID, 1,0)
temp9$SBP.flag <-ifelse(temp9$ENCOUNTERID %in% all_qsofa_sbp$ENCOUNTERID, 1,0)
temp9$GCS.flag <-ifelse(temp9$ENCOUNTERID %in% all_qsofa_gcs$ENCOUNTERID, 1,0)
temp9$qSOFA.score <-temp9$RR.flag+temp9$SBP.flag+temp9$GCS.flag
## time window to search for qSOFA criteria for RR, SBP and GCS being within [T0-48,T0+24]hrs ##

no_cores <- detectCores() - 2

# Initiate cluster
cl <- makeCluster(no_cores)

registerDoParallel(cl)


# for(i in 1:length(SIRSf5[1,]))
#  {
start.time <- Sys.time()
print(start.time)


temp0<-data.frame(all_qsofa_vitals1)#[all_SIRS_data$EVENT_NAME %in% c(SIRSf5[,i]),])
print(paste("Number of rows processing:",nrow(temp0),sep=" "))
#temp0 <- data.frame(temp0)
Encs <- unique(temp9$ENCOUNTERID)

index <- 1:length(Encs)
testindex <- sample(index, 1000)
tempEncs <- Encs[testindex]
temp1 <-data.frame()

temp1<-foreach(j = 1:length(tempEncs), .combine=rbind, .packages="dplyr", .verbose=TRUE) %dopar%
{
  
  
  
  qSOFAscore(tempEncs[j],temp0[temp0$ENCOUNTERID==tempEncs[j],],temp9[temp9$ENCOUNTERID == tempEncs[j],]$TIMESTAMP)
  
}
end.time <- Sys.time()
print(end.time)
time.taken <- end.time - start.time
print(time.taken)
stopCluster(cl)
gc()
## function to calculate qSOFA score for encounters ##

qSOFAscore <- function(enc,df,time0)
{
  
  RR.flag<-0
  SBP.flag<-0
  GCS.flag<-0
  qSOFA.score<-0
  ENCOUNTERID<-enc
  result<-data.frame(ENCOUNTERID,RR.flag,SBP.flag,GCS.flag,qSOFA.score)
  result$ENCOUNTERID<-as.character(result$ENCOUNTERID)
  if(nrow(df)>0){
    df$timediff<-as.numeric(difftime(as.POSIXct(df$TIMESTAMP,origin="1970-01-01",tz="GMT"),as.POSIXct(time0,origin="1970-01-01",tz="GMT"),units=c("hours"),tz='GMT'))
    df<-df[df$timediff>=-48.0&df$timediff<=24.0,]
    
#   for( i in 1:nrow(df))
#   {
#     timediff<-as.numeric(difftime(as.POSIXct(df[i,]$TIMESTAMP,origin="1970-01-01",tz="GMT"),as.POSIXct(time0,origin="1970-01-01",tz="GMT"),units=c("hours"),tz='GMT'))
#     if(timediff>=-48.0|timediff<=24.0)
#     {
    if(nrow(df[df$EVENT_TYPE=="SBP",])) SBP.flag=1
    if(nrow(df[df$EVENT_TYPE=="Respiratory Rate",])) RR.flag=1
    if(nrow(df[df$EVENT_TYPE=="GCS",])) GCS.flag=1
#     }
#   }
  
  qSOFA.score<-RR.flag+SBP.flag+GCS.flag
  
  result[1,]$RR.flag<-RR.flag
  result[1,]$SBP.flag<-SBP.flag
  result[1,]$GCS.flag<-GCS.flag
  result[1,]$qSOFA.score<-qSOFA.score
  }
  
  return(result)
}
