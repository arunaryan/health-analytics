library(RODBC)
library(data.table)
library(sqldf)
library(dplyr)
library(zoo)
library(reshape2)
library(Hmisc)
library(rms)
library(ggplot2)                                                                                                                                                                                                               


## Get SOFA relevant data tables from Netezza ##


channel<- odbcConnect("CERNER_OLD", uid="******", pwd="*******", believeNRows=FALSE)


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
query_string<- paste("SELECT * FROM RSTUDIES.NZADMIN.DATA_SEPSIS_MED_ADMIN_CERNER", ";", sep="")


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
query_string<- paste("SELECT * FROM RSTUDIES.NZADMIN.DATA_SEPSIS_MICRO_ORDERS", ";", sep="")


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
query_string<- paste("SELECT * FROM RSTUDIES.NZADMIN.DATA_SEPSIS_VITALS_CERNER where VITAL_TYPE = 'MAP'", ";", sep="")


query_string <- strwrap(query_string, width=100000000, simplify=TRUE)
start.time <- Sys.time()
DATA_SEPSIS_VITALS_CERNER <- sqlQuery(channel,query_string, as.is=TRUE)
end.time <- Sys.time()
time.taken <- end.time - start.time
time.taken


## Data Munging ##
sepsis_codes <- c("78552","99591","99592")
FN_Facility <- paste(c("DES","SYL","SRE","SYL"),collapse='\',\'')

DATA_SEPSIS$ENCOUNTERID <- paste(DATA_SEPSIS$FACILITY_DISP,":",DATA_SEPSIS$FIN_NBR,sep='')
DATA_SEPSIS$SEPSIS_FLG <- ifelse(DATA_SEPSIS$PRIMARY_ICD9_DIAGNOSIS_CODE %in% sepsis_codes,1,0)
DATA_SEPSIS$ADMIT_DT_TM <- strptime(DATA_SEPSIS$ADMIT_DT_TM, "%Y-%m-%d %H:%M:%OS", tz="GMT")
DATA_SEPSIS$ADMIT_DT_TM <- as.POSIXct(DATA_SEPSIS$ADMIT_DT_TM)

DATA_SEPSIS$DC_DT_TM <- strptime(DATA_SEPSIS$DC_DT_TM , "%Y-%m-%d %H:%M:%OS", tz="GMT")
DATA_SEPSIS$DC_DT_TM  <- as.POSIXct(DATA_SEPSIS$DC_DT_TM )

DATA_SEPSIS_ICD9DIAG$ENCOUNTERID <- paste(DATA_SEPSIS_ICD9DIAG$FACILITY_DISP,":",DATA_SEPSIS_ICD9DIAG$FIN_NBR,sep='')
DATA_SEPSIS_ICD10DIAG$ENCOUNTERID <- paste(DATA_SEPSIS_ICD10DIAG$FACILITY_DISP,":",DATA_SEPSIS_ICD10DIAG$FIN_NBR,sep='')

DATA_SEPSIS_ICD9DIAG$SEPSIS_FLG <- ifelse(DATA_SEPSIS_ICD9DIAG$ICD9_CODE %in% sepsis_codes,1,0)

#rm(encounters_all)
encounters_all<- paste(DATA_SEPSIS$FACILITY_DISP,":",DATA_SEPSIS$FIN_NBR,sep='')
encounters_sepsis <-unique(DATA_SEPSIS_ICD9DIAG[DATA_SEPSIS_ICD9DIAG$SEPSIS_FLG==1,]$ENCOUNTERID)
encounters <- unique(encounters_all)
encounters_all <- data.frame(encounters_all)
encounters_all$ENCOUNTERID<- encounters

encounters_all <- subset(encounters_all, select = c("ENCOUNTERID"))
encounters_all$ENCOUNTERID<- as.character(encounters_all$encounters_all)
encounters_all$ADMIT_DT_TM <- ifelse(encounters_all$ENCOUNTERID %in% DATA_SEPSIS$ENCOUNTERID,DATA_SEPSIS$ADMIT_DT_TM,"NA")
DATA_SEPSIS$ADMIT_DT_TM<-as.character(DATA_SEPSIS$ADMIT_DT_TM)



map_rel <- DATA_SEPSIS_VITALS_CERNER[DATA_SEPSIS_VITALS_CERNER$VITAL_TYPE =="MAP" ,]
map_rel$ENCOUNTERID <- paste(map_rel$FACILITY_DISP,":",map_rel$FIN_NBR,sep='')
map_rel$RESULT_VAL <-as.numeric(map_rel$RESULT_VAL)

creat_rel <-DATA_SEPSIS_LAB_RESULTS[DATA_SEPSIS_LAB_RESULTS$EVENT_DISP %in% c("Creatinine Lvl"),]
creat_rel$ENCOUNTERID <- paste(creat_rel$FACILITY_DISP,":",creat_rel$FIN_NBR,sep='')
creat_rel$RESULT_VALUE <-as.numeric(creat_rel$RESULT_VALUE)

urine_rel <-DATA_SEPSIS_DOC[DATA_SEPSIS_DOC$DOC_TYPE %in% c("Urine Output"),]
urine_rel$ENCOUNTERID <- paste(urine_rel$FACILITY_DISP,":",urine_rel$FIN_NBR,sep='')
urine_rel$DOC_VAL <- as.numeric(urine_rel$DOC_VAL)

weight_rel <-DATA_SEPSIS_DOC[DATA_SEPSIS_DOC$DOC_TYPE %in% c("Weight"),]
weight_rel$ENCOUNTERID <- paste(weight_rel$FACILITY_DISP,":",weight_rel$FIN_NBR,sep='')
weight_rel$DOC_VAL <- as.numeric(weight_rel$DOC_VAL)

platelets_rel <-subset(DATA_SEPSIS_LAB_RESULTS, grepl("platelet", DATA_SEPSIS_LAB_RESULTS$EVENT_DISP, ignore.case=TRUE)) 
platelets_rel$ENCOUNTERID <- paste(platelets_rel$FACILITY_DISP,":",platelets_rel$FIN_NBR,sep='')
platelets_rel$RESULT_VALUE <- as.numeric(platelets_rel$RESULT_VALUE)

dop_rel <-subset(DATA_SEPSIS_MED_ADMIN2_CERNER, grepl("dopamine", DATA_SEPSIS_MED_ADMIN2_CERNER$PRIMARY_MNEMONIC, ignore.case=TRUE))
dop_rel$ENCOUNTERID <- paste(dop_rel$FACILITY_DISP,":",dop_rel$FIN_NBR,sep='')
dop_rel <-subset(dop_rel,select = c("ENCOUNTERID","CLINICAL_EVENT_SK","PRIMARY_MNEMONIC","PARENT_EVENT_SK","EVENT_TAG","PERFORMED_DT_TM","EVENT_DISP"))
dop_rel$dose <- as.numeric(sapply(strsplit(dop_rel$EVENT_TAG,"[ ]"),function(x) x[[1]]))


dob_rel <-subset(DATA_SEPSIS_DOBUTAMINE_ADMIN_CERNER, grepl("dobutamine", DATA_SEPSIS_DOBUTAMINE_ADMIN_CERNER$PRIMARY_MNEMONIC, ignore.case=TRUE)) 
dob_rel$ENCOUNTERID <- paste(dob_rel$FACILITY_DISP,":",dob_rel$FIN_NBR,sep='')
dob_rel <-subset(dob_rel,select = c("ENCOUNTERID","CLINICAL_EVENT_SK","PRIMARY_MNEMONIC","PARENT_EVENT_SK","EVENT_TAG","PERFORMED_DT_TM","EVENT_DISP"))
dob_rel$dose <- as.numeric(sapply(strsplit(dob_rel$EVENT_TAG,"[ ]"),function(x) x[[1]]))

epi_rel <-subset(DATA_SEPSIS_MED_ADMIN2_CERNER, grepl("epinephrine", DATA_SEPSIS_MED_ADMIN2_CERNER$PRIMARY_MNEMONIC, ignore.case=TRUE)) 
epi_rel$ENCOUNTERID <- paste(epi_rel$FACILITY_DISP,":",epi_rel$FIN_NBR,sep='')
epi_rel <-subset(epi_rel,select = c("ENCOUNTERID","CLINICAL_EVENT_SK","PRIMARY_MNEMONIC","PARENT_EVENT_SK","EVENT_TAG","PERFORMED_DT_TM","EVENT_DISP"))
epi_rel$dose <- as.numeric(sapply(strsplit(epi_rel$EVENT_TAG,"[ ]"),function(x) x[[1]]))


norepi_rel <-subset(DATA_SEPSIS_MED_ADMIN2_CERNER, grepl("norepinephrine", DATA_SEPSIS_MED_ADMIN2_CERNER$PRIMARY_MNEMONIC, ignore.case=TRUE)) 
norepi_rel$ENCOUNTERID <- paste(norepi_rel$FACILITY_DISP,":",norepi_rel$FIN_NBR,sep='')
norepi_rel <-subset(norepi_rel,select = c("ENCOUNTERID","CLINICAL_EVENT_SK","PRIMARY_MNEMONIC","PARENT_EVENT_SK","EVENT_TAG","PERFORMED_DT_TM","EVENT_DISP"))
norepi_rel$dose <- as.numeric(sapply(strsplit(norepi_rel$EVENT_TAG,"[ ]"),function(x) x[[1]]))

bili_rel <-subset(DATA_SEPSIS_LAB_RESULTS, grepl("bili", DATA_SEPSIS_LAB_RESULTS$EVENT_DISP, ignore.case=TRUE)) 
bili_rel$ENCOUNTERID <- paste(bili_rel$FACILITY_DISP,":",bili_rel$FIN_NBR,sep='')
bili_rel$RESULT_VALUE <- as.numeric(bili_rel$RESULT_VALUE)

PO2_FiO2_rel <-DATA_SEPSIS_LAB_RESULTS[DATA_SEPSIS_LAB_RESULTS$EVENT_DISP %in% c("pO2","FiO2","pO2 tc","FiO2 tc"),]
PO2_FiO2_rel$ENCOUNTERID <- paste(PO2_FiO2_rel$FACILITY_DISP,":",PO2_FiO2_rel$FIN_NBR,sep='')
PO2_FiO2_rel$RESULT_VALUE <- as.numeric(PO2_FiO2_rel$RESULT_VALUE)

GCS <- DATA_SEPSIS_DOC[DATA_SEPSIS_DOC$DOC_TYPE %in% c("Glasgow Coma Score"),]
GCS$ENCOUNTERID <- paste(GCS$FACILITY_DISP,":",GCS$FIN_NBR,sep='')
GCS$DOC_TYPE <- "GCS"
GCS$DOC_VAL <- as.numeric(GCS$DOC_VAL)


all_SOFA_vasopressors <- rbind(dop_rel,epi_rel,norepi_rel)

## Sort vasopressors data by performed dt tm and encounterid

all_SOFA_vasopressors$PERFORMED_DT_TM <-strptime(all_SOFA_vasopressors$PERFORMED_DT_TM, "%Y-%m-%d %H:%M:%OS", tz="GMT")
all_SOFA_vasopressors$PERFORMED_DT_TM <- as.POSIXct(all_SOFA_vasopressors$PERFORMED_DT_TM)

all_SOFA_vasopressors_1 <- all_SOFA_vasopressors[all_SOFA_vasopressors$INFUSION_UNIT %in% c("mcg/kg/min"),]
all_SOFA_vasopressors <- data.table(all_SOFA_vasopressors)

setkey(all_SOFA_vasopressors, ENCOUNTERID, PERFORMED_DT_TM)

all_SOFA_vasopressors <- setorder(all_SOFA_vasopressors, ENCOUNTERID, PERFORMED_DT_TM)

all_SOFA_vasopressors <- all_SOFA_vasopressors[!(all_SOFA_vasopressors$EVENT_DISP %in% c("Administration Information")),]

all_SOFA_vasopressors1 <- all_SOFA_vasopressors[grepl("mcg/kg/min",all_SOFA_vasopressors$EVENT_TAG ),]

all_SOFA_vasopressors$SOFA <- ifelse(all_SOFA_vasopressors$EVENT_DISP == "DOPamine",ifelse(all_SOFA_vasopressors$dose<5.0,2,ifelse(all_SOFA_vasopressors$dose>=5.0&all_SOFA_vasopressors$dose<=15.0,3,ifelse(all_SOFA_vasopressors$dose>15.0,4,0))),0)
all_SOFA_vasopressors$SOFA <- ifelse(all_SOFA_vasopressors$EVENT_DISP == "epinephrine",ifelse(all_SOFA_vasopressors$dose<=0.1,3,ifelse(all_SOFA_vasopressors$dose>0.1,4,all_SOFA_vasopressors$SOFA)),all_SOFA_vasopressors$SOFA)
all_SOFA_vasopressors$SOFA <- ifelse(all_SOFA_vasopressors$EVENT_DISP == "norepinephrine",ifelse(all_SOFA_vasopressors$dose<=0.1,3,ifelse(all_SOFA_vasopressors$dose>0.1,4,all_SOFA_vasopressors$SOFA)),all_SOFA_vasopressors$SOFA)

all_SOFA_vasopressors <- merge(all_SOFA_vasopressors,subset(DATA_SEPSIS,select=c("ENCOUNTERID","ADMIT_DT_TM")),by="ENCOUNTERID",all.x=TRUE)
all_SOFA_vasopressors$timediff <- as.numeric(difftime(all_SOFA_vasopressors$PERFORMED_DT_TM,all_SOFA_vasopressors$ADMIT_DT_TM, units=c("hours"),tz='GMT'))

## Sort PiO2,FiO2 data by timestamp and encounter id

PO2_FiO2_rel$EVENT_DISP <- ifelse(PO2_FiO2_rel$EVENT_DISP == "pO2 tc", "pO2",PO2_FiO2_rel$EVENT_DISP)

PO2_FiO2_rel$EVENT_DISP[PO2_FiO2_rel$EVENT_DISP=="pO2 tc"] <-"pO2"
PO2_FiO2_rel$ORDER_DT_TM <-strptime(PO2_FiO2_rel$ORDER_DT_TM , "%Y-%m-%d %H:%M:%OS", tz="GMT")
PO2_FiO2_rel$ORDER_DT_TM  <- as.POSIXct(PO2_FiO2_rel$ORDER_DT_TM )

PO2_FiO2_rel$COLLECTION_DT_TM <-strptime(PO2_FiO2_rel$COLLECTION_DT_TM  , "%Y-%m-%d %H:%M:%OS", tz="GMT")
PO2_FiO2_rel$COLLECTION_DT_TM   <- as.POSIXct(PO2_FiO2_rel$COLLECTION_DT_TM  )


PO2_FiO2_rel$RESULT_DT_TM <-strptime(PO2_FiO2_rel$RESULT_DT_TM  , "%Y-%m-%d %H:%M:%OS", tz="GMT")
PO2_FiO2_rel$RESULT_DT_TM   <- as.POSIXct(PO2_FiO2_rel$RESULT_DT_TM  )



PO2_FiO2_rel <- data.table(PO2_FiO2_rel)

setkey(PO2_FiO2_rel, ENCOUNTERID, RESULT_DT_TM)

PO2_FiO2_rel <- setorder(PO2_FiO2_rel, ENCOUNTERID, RESULT_DT_TM)

temp6<-PO2_FiO2_rel

lg <- function(x)c(NA, x[1:(length(x)-1)])
temp6$RESULT_DT_TM<-as.character(temp6$RESULT_DT_TM)
temp6$prev.time <- ave(temp6$RESULT_DT_TM, temp6$ENCOUNTERID, FUN=lg)
temp6<-data.frame(temp6)
temp6$prev.event <- ave(temp6$EVENT_DISP, temp6$ENCOUNTERID, FUN=lg)
temp6$prev.value <- ave(temp6$RESULT_VALUE,temp6$ENCOUNTERID, FUN=lg)

all_PO2_FiO2_events <- temp6

temp6$prev.time <- ifelse(is.na(temp6$prev.time),temp6$RESULT_DT_TM,temp6$prev.time)
temp6$prev.event <- ifelse(is.na(temp6$prev.event),temp6$EVENT_DISP,temp6$prev.event)
temp6$prev.value <- ifelse(is.na(temp6$prev.event),temp6$RESULT_VALUE,temp6$prev.value)

temp6$RESULT_DT_TM<-strptime(temp6$RESULT_DT_TM, "%Y-%m-%d %H:%M:%OS", tz="GMT")
temp6$RESULT_DT_TM <- as.POSIXct(temp6$RESULT_DT_TM)

temp6$prev.time<-strptime(temp6$prev.time, "%Y-%m-%d %H:%M:%OS", tz="GMT")
temp6$prev.time <- as.POSIXct(temp6$prev.time)

temp6$timediff <- ifelse(temp6$EVENT_DISP == temp6$prev.event,9999,difftime(temp6$RESULT_DT_TM,temp6$prev.time, units=c("hours"),tz='GMT'))
temp6$fio2.po2.ratio <- ifelse(!(temp6$timediff==9999),ifelse(temp6$EVENT_DISP=="pO2",temp6$RESULT_VALUE/temp6$prev.value*100,temp6$prev.value/temp6$RESULT_VALUE*100),9999)
all_PO2_FiO2_events<-temp6
all_PO2_FiO2_events$SOFA <- ifelse(all_PO2_FiO2_events$fio2.po2.ratio>=400,0,ifelse(all_PO2_FiO2_events$fio2.po2.ratio<400&all_PO2_FiO2_events$fio2.po2.ratio>300,1,ifelse(all_PO2_FiO2_events$fio2.po2.ratio<=300&all_PO2_FiO2_events$fio2.po2.ratio>200,2,ifelse(all_PO2_FiO2_events$fio2.po2.ratio<=200&all_PO2_FiO2_events$fio2.po2.ratio>100,3,ifelse(all_PO2_FiO2_events$fio2.po2.ratio<100&all_PO2_FiO2_events$fio2.po2.ratio>0,4,0)))))
all_PO2_FiO2_events <- merge(all_PO2_FiO2_events,subset(DATA_SEPSIS,select=c("ENCOUNTERID","ADMIT_DT_TM")),by="ENCOUNTERID",all.x=TRUE)
all_PO2_FiO2_events$timediff <- as.numeric(difftime(all_PO2_FiO2_events$RESULT_DT_TM,all_PO2_FiO2_events$ADMIT_DT_TM, units=c("hours"),tz='GMT'))

## Sort urine data
urine_rel <- urine_rel[!(urine_rel$DOC_NAME=="Urine Count"),]

urine_rel$PERFORM_DT_TM <-strptime(urine_rel$PERFORM_DT_TM, "%Y-%m-%d %H:%M:%OS", tz="GMT")
urine_rel$PERFORM_DT_TM <- as.POSIXct(urine_rel$PERFORM_DT_TM)

urine_rel <- data.table(urine_rel)

setkey(urine_rel, ENCOUNTERID, PERFORM_DT_TM)

urine_rel<- setorder(urine_rel, ENCOUNTERID, PERFORM_DT_TM)
urine_rel$SOFA <- ifelse(urine_rel$DOC_VAL>=500,0,ifelse(urine_rel$DOC_VAL<500&urine_rel$DOC_VAL>=200,3,ifelse(urine_rel$DOC_VAL<200&urine_rel$DOC_VAL>=0,4,0)))
urine_rel <- merge(urine_rel,subset(DATA_SEPSIS,select=c("ENCOUNTERID","ADMIT_DT_TM")),by="ENCOUNTERID",all.x=TRUE)
urine_rel$timediff <- as.numeric(difftime(urine_rel$PERFORM_DT_TM,urine_rel$ADMIT_DT_TM, units=c("hours"),tz='GMT'))

## Sort weight data

weight_rel$PERFORM_DT_TM <-strptime(weight_rel$PERFORM_DT_TM, "%Y-%m-%d %H:%M:%OS", tz="GMT")
weight_rel$PERFORM_DT_TM <- as.POSIXct(weight_rel$PERFORM_DT_TM)

weight_rel <- data.table(weight_rel)

setkey(weight_rel, ENCOUNTERID, PERFORM_DT_TM)

weight_rel<- setorder(weight_rel, ENCOUNTERID, PERFORM_DT_TM)
weight_rel <- merge(weight_rel,subset(DATA_SEPSIS,select=c("ENCOUNTERID","ADMIT_DT_TM")),by="ENCOUNTERID",all.x=TRUE)
weight_rel$timediff <- as.numeric(difftime(weight_rel$PERFORM_DT_TM,weight_rel$ADMIT_DT_TM, units=c("hours"),tz='GMT'))
## Sort creatinine data
creat_rel$RESULT_DT_TM <-strptime(creat_rel$RESULT_DT_TM, "%Y-%m-%d %H:%M:%OS", tz="GMT")
creat_rel$RESULT_DT_TM <- as.POSIXct(creat_rel$RESULT_DT_TM)

creat_rel <- data.table(creat_rel)

setkey(creat_rel, ENCOUNTERID, RESULT_DT_TM)

creat_rel<- setorder(creat_rel, ENCOUNTERID, RESULT_DT_TM)

creat_rel$SOFA <- ifelse(creat_rel$RESULT_VALUE<1.2,0,ifelse(creat_rel$RESULT_VALUE>=1.2&creat_rel$RESULT_VALUE<2.0,1,ifelse(creat_rel$RESULT_VALUE>=2.0&creat_rel$RESULT_VALUE<3.4,2,ifelse(creat_rel$RESULT_VALUE>=3.4&creat_rel$RESULT_VALUE<4.9,3,ifelse(creat_rel$RESULT_VALUE>=4.9,4,0)))))

creat_rel <- merge(creat_rel,subset(DATA_SEPSIS,select=c("ENCOUNTERID","ADMIT_DT_TM")),by="ENCOUNTERID",all.x=TRUE)
creat_rel$timediff <- as.numeric(difftime(creat_rel$RESULT_DT_TM,creat_rel$ADMIT_DT_TM, units=c("hours"),tz='GMT'))

## Sort bili data

bili_rel$RESULT_DT_TM <-strptime(bili_rel$RESULT_DT_TM, "%Y-%m-%d %H:%M:%OS", tz="GMT")
bili_rel$RESULT_DT_TM <- as.POSIXct(bili_rel$RESULT_DT_TM)

bili_rel <- data.table(bili_rel)

setkey(bili_rel, ENCOUNTERID, RESULT_DT_TM)

bili_rel<- setorder(bili_rel, ENCOUNTERID, RESULT_DT_TM)

bili_rel$SOFA <- ifelse(bili_rel$RESULT_VALUE<1.2,0,ifelse(bili_rel$RESULT_VALUE>=1.2&bili_rel$RESULT_VALUE<2.0,1,ifelse(bili_rel$RESULT_VALUE>=2.0&bili_rel$RESULT_VALUE<6.0,2,ifelse(bili_rel$RESULT_VALUE>=6.0&bili_rel$RESULT_VALUE<12.0,3,ifelse(bili_rel$RESULT_VALUE>=12.0,4,0)))))
bili_rel <- merge(bili_rel,subset(DATA_SEPSIS,select=c("ENCOUNTERID","ADMIT_DT_TM")),by="ENCOUNTERID",all.x=TRUE)
bili_rel$timediff <- as.numeric(difftime(bili_rel$RESULT_DT_TM,bili_rel$ADMIT_DT_TM, units=c("hours"),tz='GMT'))

## Sort platelets data

platelets_rel$RESULT_DT_TM <-strptime(platelets_rel$RESULT_DT_TM, "%Y-%m-%d %H:%M:%OS", tz="GMT")
platelets_rel$RESULT_DT_TM <- as.POSIXct(platelets_rel$RESULT_DT_TM)

platelets_rel <- data.table(platelets_rel)

setkey(platelets_rel, ENCOUNTERID, RESULT_DT_TM)

platelets_rel<- setorder(platelets_rel, ENCOUNTERID, RESULT_DT_TM)

platelets_rel$SOFA <- ifelse(platelets_rel$RESULT_VALUE>150,0,ifelse(platelets_rel$RESULT_VALUE<=150&platelets_rel$RESULT_VALUE>100,1,ifelse(platelets_rel$RESULT_VALUE<=100&platelets_rel$RESULT_VALUE>50,2,ifelse(platelets_rel$RESULT_VALUE<=50&platelets_rel$RESULT_VALUE>20,3,ifelse(platelets_rel$RESULT_VALUE<=20,4,0)))))
platelets_rel <- merge(platelets_rel,subset(DATA_SEPSIS,select=c("ENCOUNTERID","ADMIT_DT_TM")),by="ENCOUNTERID",all.x=TRUE)
platelets_rel$timediff <- as.numeric(difftime(platelets_rel$RESULT_DT_TM,platelets_rel$ADMIT_DT_TM, units=c("hours"),tz='GMT'))

## Sort MAP data

map_rel$PERFORM_DT_TM <-strptime(map_rel$PERFORM_DT_TM, "%Y-%m-%d %H:%M:%OS", tz="GMT")
map_rel$PERFORM_DT_TM <- as.POSIXct(map_rel$PERFORM_DT_TM)

map_rel <- data.table(map_rel)

setkey(map_rel, ENCOUNTERID, PERFORM_DT_TM)

map_rel<- setorder(map_rel, ENCOUNTERID, PERFORM_DT_TM)

map_rel$SOFA <- ifelse(map_rel$RESULT_VAL >= 70,0,1)
map_rel <- merge(map_rel,subset(DATA_SEPSIS,select=c("ENCOUNTERID","ADMIT_DT_TM")),by="ENCOUNTERID",all.x=TRUE)
map_rel$timediff <- as.numeric(difftime(map_rel$PERFORM_DT_TM,map_rel$ADMIT_DT_TM, units=c("hours"),tz='GMT'))

## Sort GCS scores

GCS$PERFORM_DT_TM <-strptime(GCS$PERFORM_DT_TM, "%Y-%m-%d %H:%M:%OS", tz="GMT")
GCS$PERFORM_DT_TM <- as.POSIXct(GCS$PERFORM_DT_TM)

GCS <- data.table(GCS)

setkey(GCS, ENCOUNTERID, PERFORM_DT_TM)

GCS<- setorder(GCS, ENCOUNTERID, PERFORM_DT_TM)

GCS$SOFA <- ifelse(GCS$DOC_VAL>=15,0,ifelse(GCS$DOC_VAL<15&GCS$DOC_VAL>=13,1,ifelse(GCS$DOC_VAL<13&GCS$DOC_VAL>=10,2,ifelse(GCS$DOC_VAL<10&GCS$DOC_VAL>=6,3,ifelse(GCS$DOC_VAL<6,4,0)))))
GCS <- merge(GCS,subset(DATA_SEPSIS,select=c("ENCOUNTERID","ADMIT_DT_TM")),by="ENCOUNTERID",all.x=TRUE)
GCS$timediff <- as.numeric(difftime(GCS$PERFORM_DT_TM,GCS$ADMIT_DT_TM, units=c("hours"),tz='GMT'))

## Aggregate scores for SOFA by encounterid.

  t.inter <- c(0,24,48,72)
##for <=24 hours
  
  maxVASSO.1d <- sqldf("select ENCOUNTERID, max(SOFA) as SOFA from all_SOFA_vasopressors where timediff<=24.0  group by ENCOUNTERID")
  maxbili.1d <- sqldf("select ENCOUNTERID, max(SOFA) as SOFA from bili_rel where timediff<=24.0 group by ENCOUNTERID")
  maxcreat.1d <- sqldf("select ENCOUNTERID, max(SOFA) as SOFA from creat_rel where timediff<=24.0 group by ENCOUNTERID")
  maxurine.1d <- sqldf("select ENCOUNTERID, max(SOFA) as SOFA from urine_rel where timediff<=24.0 group by ENCOUNTERID")
  maxGCS.1d <- sqldf("select ENCOUNTERID, max(SOFA) as SOFA from GCS where timediff<=24.0 group by ENCOUNTERID")
  maxplatelets.1d <- sqldf("select ENCOUNTERID, max(SOFA) as SOFA from platelets_rel where timediff<=24.0 group by ENCOUNTERID")
  maxmap.1d <- sqldf("select ENCOUNTERID, max(SOFA) as SOFA from map_rel where timediff<=24.0 group by ENCOUNTERID")
  maxpo2fio2.1d <- sqldf("select ENCOUNTERID, max(SOFA) as SOFA from all_PO2_FiO2_events where timediff<=24.0 group by ENCOUNTERID")
  
## for 24-48 hrs
 
  maxVASSO.2d <- sqldf("select ENCOUNTERID, max(SOFA) as SOFA from  all_SOFA_vasopressors where timediff>24.0 and timediff<=48.0 group by ENCOUNTERID")
  maxbili.2d <- sqldf("select ENCOUNTERID, max(SOFA) as SOFA from bili_rel where timediff>24.0 and timediff<=48.0 group by ENCOUNTERID")
  maxcreat.2d <- sqldf("select ENCOUNTERID, max(SOFA) as SOFA from  creat_rel where timediff>24.0 and timediff<=48.0 group by ENCOUNTERID")
  maxurine.2d <- sqldf("select ENCOUNTERID, max(SOFA) as SOFA from urine_rel where timediff>24.0 and timediff<=48.0 group by ENCOUNTERID")
  maxGCS.2d <- sqldf("select ENCOUNTERID, max(SOFA) as SOFA from GCS where timediff>24.0 and timediff<=48.0 group by ENCOUNTERID")
  maxplatelets.2d <- sqldf("select ENCOUNTERID, max(SOFA) as SOFA from platelets_rel where timediff>24.0 and timediff<=48.0 group by ENCOUNTERID")
  maxmap.2d <- sqldf("select ENCOUNTERID, max(SOFA) as SOFA from map_rel where timediff>24.0 and timediff<=48.0 group by ENCOUNTERID")
  maxpo2fio2.2d <- sqldf("select ENCOUNTERID, max(SOFA) as SOFA from all_PO2_FiO2_events where timediff>24.0 and timediff<=48.0 group by ENCOUNTERID")

  ## for 48-72 hrs
  
  maxVASSO.3d <- sqldf("select ENCOUNTERID, max(SOFA) as SOFA from all_SOFA_vasopressors where timediff>48.0 and timediff<=72.0 group by ENCOUNTERID")
  maxbili.3d <- sqldf("select ENCOUNTERID, max(SOFA) as SOFA from bili_rel where timediff>48.0 and timediff<=72.0 group by ENCOUNTERID")
  maxcreat.3d <- sqldf("select ENCOUNTERID, max(SOFA) as SOFA from creat_rel where timediff>48.0 and timediff<=72.0 group by ENCOUNTERID")
  maxurine.3d <- sqldf("select ENCOUNTERID, max(SOFA) as SOFA from urine_rel where timediff>48.0 and timediff<=72.0 group by ENCOUNTERID")
  maxGCS.3d <- sqldf("select ENCOUNTERID, max(SOFA) as SOFA from GCS where timediff>48.0 and timediff<=72.0 group by ENCOUNTERID")
  maxplatelets.3d <- sqldf("select ENCOUNTERID, max(SOFA) as SOFA from platelets_rel where timediff>48.0 and timediff<=72.0 group by ENCOUNTERID")
  maxmap.3d <- sqldf("select ENCOUNTERID, max(SOFA) as SOFA from map_rel where timediff>48.0 and timediff<=72.0 group by ENCOUNTERID")
  maxpo2fio2.3d <- sqldf("select ENCOUNTERID, max(SOFA) as SOFA from all_PO2_FiO2_events where timediff>48.0 and timediff<=72.0 group by ENCOUNTERID")
  
## for >72 hrs

  maxVASSO.all <- sqldf("select ENCOUNTERID, max(SOFA) as SOFA from all_SOFA_vasopressors where timediff>72.0 group by ENCOUNTERID")
  maxbili.all <- sqldf("select ENCOUNTERID, max(SOFA) as SOFA from bili_rel where timediff>72.0 group by ENCOUNTERID")
  maxcreat.all <- sqldf("select ENCOUNTERID, max(SOFA) as SOFA from creat_rel where timediff>72.0  group by ENCOUNTERID")
  maxurine.all <- sqldf("select ENCOUNTERID, max(SOFA) as SOFA from urine_rel where timediff>72.0  group by ENCOUNTERID")
  maxGCS.all <- sqldf("select ENCOUNTERID, max(SOFA) as SOFA from GCS where timediff>72.0  group by ENCOUNTERID")
  maxplatelets.all <- sqldf("select ENCOUNTERID, max(SOFA) as SOFA from platelets_rel where timediff>72.0  group by ENCOUNTERID")
  maxmap.all <- sqldf("select ENCOUNTERID, max(SOFA) as SOFA from map_rel where timediff>72.0  group by ENCOUNTERID")
  maxpo2fio2.all <- sqldf("select ENCOUNTERID, max(SOFA) as SOFA from all_PO2_FiO2_events where timediff>72.0  group by ENCOUNTERID")
  
## Compute total sofa scores  
  encounters_all$vasso.1d<-ifelse(encounters_all$ENCOUNTERID %in% maxVASSO.1d$ENCOUNTERID,maxVASSO.1d$SOFA,0)
  encounters_all$vasso.2d<-ifelse(encounters_all$ENCOUNTERID %in% maxVASSO.2d$ENCOUNTERID,maxVASSO.2d$SOFA,0)
  encounters_all$vasso.3d<-ifelse(encounters_all$ENCOUNTERID %in% maxVASSO.3d$ENCOUNTERID,maxVASSO.3d$SOFA,0)
  encounters_all$vasso.later<-ifelse(encounters_all$ENCOUNTERID %in% maxVASSO.all$ENCOUNTERID,maxVASSO.all$SOFA,0)
  
  encounters_all$bili.1d<-ifelse(encounters_all$ENCOUNTERID %in% maxbili.1d$ENCOUNTERID,maxbili.1d$SOFA,0)
  encounters_all$bili.2d<-ifelse(encounters_all$ENCOUNTERID %in% maxbili.2d$ENCOUNTERID,maxbili.2d$SOFA,0)
  encounters_all$bili.3d<-ifelse(encounters_all$ENCOUNTERID %in% maxbili.3d$ENCOUNTERID,maxbili.3d$SOFA,0)
  encounters_all$bili.later<-ifelse(encounters_all$ENCOUNTERID %in% maxbili.all$ENCOUNTERID,maxbili.all$SOFA,0)
  
  encounters_all$creat.1d<-ifelse(encounters_all$ENCOUNTERID %in% maxcreat.1d$ENCOUNTERID,maxcreat.1d$SOFA,0)
  encounters_all$creat.2d<-ifelse(encounters_all$ENCOUNTERID %in% maxcreat.2d$ENCOUNTERID,maxcreat.2d$SOFA,0)
  encounters_all$creat.3d<-ifelse(encounters_all$ENCOUNTERID %in% maxcreat.3d$ENCOUNTERID,maxcreat.3d$SOFA,0)
  encounters_all$creat.later<-ifelse(encounters_all$ENCOUNTERID %in% maxcreat.all$ENCOUNTERID,maxcreat.all$SOFA,0)
  
  encounters_all$urine.1d<-ifelse(encounters_all$ENCOUNTERID %in% maxurine.1d$ENCOUNTERID,maxurine.1d$SOFA,0)
  encounters_all$urine.2d<-ifelse(encounters_all$ENCOUNTERID %in% maxurine.2d$ENCOUNTERID,maxurine.2d$SOFA,0)
  encounters_all$urine.3d<-ifelse(encounters_all$ENCOUNTERID %in% maxurine.3d$ENCOUNTERID,maxurine.3d$SOFA,0)
  encounters_all$urine.later<-ifelse(encounters_all$ENCOUNTERID %in% maxurine.all$ENCOUNTERID,maxurine.all$SOFA,0)
  
  encounters_all$GCS.1d<-ifelse(encounters_all$ENCOUNTERID %in% maxGCS.1d$ENCOUNTERID,maxGCS.1d$SOFA,0)
  encounters_all$GCS.2d<-ifelse(encounters_all$ENCOUNTERID %in% maxGCS.2d$ENCOUNTERID,maxGCS.2d$SOFA,0)
  encounters_all$GCS.3d<-ifelse(encounters_all$ENCOUNTERID %in% maxGCS.3d$ENCOUNTERID,maxGCS.3d$SOFA,0)
  encounters_all$GCS.later<-ifelse(encounters_all$ENCOUNTERID %in% maxGCS.all$ENCOUNTERID,maxGCS.all$SOFA,0)
  
  encounters_all$platelets.1d<-ifelse(encounters_all$ENCOUNTERID %in% maxplatelets.1d$ENCOUNTERID,maxplatelets.1d$SOFA,0)
  encounters_all$platelets.2d<-ifelse(encounters_all$ENCOUNTERID %in% maxplatelets.2d$ENCOUNTERID,maxplatelets.2d$SOFA,0)
  encounters_all$platelets.3d<-ifelse(encounters_all$ENCOUNTERID %in% maxplatelets.3d$ENCOUNTERID,maxplatelets.3d$SOFA,0)
  encounters_all$platelets.later<-ifelse(encounters_all$ENCOUNTERID %in% maxplatelets.all$ENCOUNTERID,maxplatelets.all$SOFA,0)
  
  encounters_all$map.1d<-ifelse(encounters_all$ENCOUNTERID %in% maxmap.1d$ENCOUNTERID,maxmap.1d$SOFA,0)
  encounters_all$map.2d<-ifelse(encounters_all$ENCOUNTERID %in% maxmap.2d$ENCOUNTERID,maxmap.2d$SOFA,0)
  encounters_all$map.3d<-ifelse(encounters_all$ENCOUNTERID %in% maxmap.3d$ENCOUNTERID,maxmap.3d$SOFA,0)
  encounters_all$map.later<-ifelse(encounters_all$ENCOUNTERID %in% maxmap.all$ENCOUNTERID,maxmap.all$SOFA,0)
  
  encounters_all$po2.fio2.1d<-ifelse(encounters_all$ENCOUNTERID %in% maxpo2fio2.1d$ENCOUNTERID,maxpo2fio2.1d$SOFA,0)
  encounters_all$po2.fio2.2d<-ifelse(encounters_all$ENCOUNTERID %in% maxpo2fio2.2d$ENCOUNTERID,maxpo2fio2.2d$SOFA,0)
  encounters_all$po2.fio2.3d<-ifelse(encounters_all$ENCOUNTERID %in% maxpo2fio2.3d$ENCOUNTERID,maxpo2fio2.3d$SOFA,0)
  encounters_all$po2.fio2.later<-ifelse(encounters_all$ENCOUNTERID %in% maxpo2fio2.all$ENCOUNTERID,maxpo2fio2.all$SOFA,0)
  
  
  encounters_all[is.na(encounters_all)]<-0
  encounters_all$SOFA.1d <- pmax(encounters_all$map.1d,encounters_all$vasso.1d)+encounters_all$bili.1d+encounters_all$creat.1d+encounters_all$urine.1d+encounters_all$GCS.1d+encounters_all$platelets.1d+encounters_all$po2.fio2.1d
  encounters_all$SOFA.2d <- pmax(encounters_all$map.2d,encounters_all$vasso.2d)+encounters_all$bili.2d+encounters_all$creat.2d+encounters_all$urine.2d+encounters_all$GCS.2d+encounters_all$platelets.2d+encounters_all$po2.fio2.2d
  encounters_all$SOFA.3d <- pmax(encounters_all$map.3d,encounters_all$vasso.3d)+encounters_all$bili.3d+encounters_all$creat.3d+encounters_all$urine.3d+encounters_all$GCS.3d+encounters_all$platelets.3d+encounters_all$po2.fio2.3d
  encounters_all$SOFA.later <- pmax(encounters_all$map.later,encounters_all$vasso.later)+encounters_all$bili.later+encounters_all$creat.later+encounters_all$urine.later+encounters_all$GCS.later+encounters_all$platelets.later+encounters_all$po2.fio2.later
  
  
  
  
