## The script is used on a curated dataset of about ~800k rows of non-contrast Head-CT scan orders for non-trauma cases. 
## various machine learning models are fitted to te data to predict if the Head-CT would reveal a condition from one of the 119 ICD-9 codes
## identified as serious conditions requiring early detection and hence an appropriate use of a radiation imaging.

library(RODBC)
library(data.table)
library(sqldf)
library(plyr)
library(zoo)
library(reshape2)
library(Hmisc)
library(rms)
library(ggplot2)
library(glmnet)
library(randomForest)
library(pROC)
library(gbm)
library(missForest)
library(caret)
library(party)
library(partykit)
library(xgboost)
library(corrplot)
library(Rtsne)
library(xgboost)
library(stats)
library(knitr)
library(ggplot2)

#Separate head_ct data for all kip_codes

Head_CT_pop <- read.table("C:\\DATA SCIENCE\\Arun\\Projects\\imaging\\Head_CT_population_v1.2.csv",check.names=TRUE, sep=",",header=TRUE,as.is=TRUE, fill = TRUE)

Head_CT_pop <- subset(Head_CT_pop, select = c("FACILITYABBREVIATION","ISRESULTABNORMAL","ORDERDATETIME","ENCOUNTERID","ENCOUNTERTYPE","ADMITDATETIME","DISCHARGEDATETIME","ADMITSERVICE","ADMITDIAGNOSISLOCALTERM","ADMITDIAGNOSISLOCALDESCRIPTION","ADMITTYPESTANDARDDESCRIPTION","AGEATADMISSION","DISCHARGESERVICE","DISCHARGEDISPOSITIONSTANDARDDESCRIPTION","ISEDPATIENT","EDDEPARTUREDATETIME","ENCOUNTERSTANDARDDESCRIPTION","PRIMARY_ICD9_DIAG_CD","PRIMARY_ICD9_DIAG_DESC"))
#Head_CT_labs <- subset(Head_CT_labs, select = c(""))
Head_CT_pop$PRIMARY_ICD9_DIAG_CD <- as.character(Head_CT_pop$PRIMARY_ICD9_DIAG_CD)
Head_CT_pop$pos.result <- ifelse(Head_CT_pop$PRIMARY_ICD9_DIAG_CD %in% kip_codes_rel1$ICD9, 1,0 )
Head_CT_pop$rank <- ifelse(Head_CT_pop$PRIMARY_ICD9_DIAG_CD %in% kip_codes$ICD9, kip_codes$rank,0 )
#Head_CT_pop$PRIMARY_ICD9_DIAG_CD <- ifelse(Head_CT_pop$PRIMARY_ICD9_DIAG_CD %in% CCSICD9$ICD9, CCSICD9$CCSID,"UNK")
Head_CT_pop$PRIMARY_ICD9_DIAG <- ifelse(substr(Head_CT_pop$PRIMARY_ICD9_DIAG_CD,1,2)=="00",substr(Head_CT_pop$PRIMARY_ICD9_DIAG_CD,2,nchar(Head_CT_pop$PRIMARY_ICD9_DIAG_CD)) ,Head_CT_pop$PRIMARY_ICD9_DIAG_CD )
Head_CT_pop$CCSID <- ifelse(Head_CT_pop$PRIMARY_ICD9_DIAG_CD %in% CCSICD9$ICD9, CCSICD9$CCSID,0)

Head_CT_labs <- read.table(paste("C:\\DATA SCIENCE\\Arun\\Projects\\imaging\\new\\12_23_2015\\labs_vitals_results_1_v1.0.csv", sep=""),header = TRUE, sep = ",", quote = "\"", dec = ".",
                           fill = TRUE, comment.char = "", as.is=TRUE)
for (i in 2:13)
{
  
lab_results_1 <- read.table(paste("C:\\DATA SCIENCE\\Arun\\Projects\\imaging\\new\\12_23_2015\\labs_vitals_results_",i,"_v1.0.csv", sep=""),header = TRUE, sep = ",", quote = "\"", dec = ".",
                          fill = TRUE, comment.char = "", as.is=TRUE)
Head_CT_labs <- rbind(Head_CT_labs, lab_results_1)
rm(lab_results_1)

}

Head_CT_labs_vitals <- sqldf('SELECT DISTINCT * FROM Head_CT_labs')
#Head_CT_labs$ENCOUNTERID <- paste(Head_CT_labs$FACILITY_CD,":",Head_CT_labs$PATIENT_ACCOUNT_NBR,sep='')
## Convert string to date time for timestamps
Head_CT_labs$EVENT_END_DT_TM <-strptime(Head_CT_labs_vitals$EVENT_END_DT_TM, "%Y-%m-%d %H:%M:%OS", tz="GMT")
Head_CT_labs_vitals$EVENT_END_DT_TM <- as.POSIXct(Head_CT_labs_vitals$EVENT_END_DT_TM)

Head_CT_labs_vitals$PERFORMED_DT_TM <-strptime(Head_CT_labs_vitals$PERFORMED_DT_TM, "%Y-%m-%d %H:%M:%OS", tz="GMT")
Head_CT_labs_vitals$PERFORMED_DT_TM <- as.POSIXct(Head_CT_labs_vitals$PERFORMED_DT_TM)

Head_CT_pop$ORDERDATETIME <-strptime(Head_CT_pop$ORDERDATETIME, "%Y-%m-%d %H:%M:%OS", tz="GMT")
Head_CT_pop$ORDERDATETIME <- as.POSIXct(Head_CT_pop$ORDERDATETIME)

Head_CT_pop$ADMITDATETIME <-strptime(Head_CT_pop$ADMITDATETIME, "%Y-%m-%d %H:%M:%OS", tz="GMT")
Head_CT_pop$ADMITDATETIME <- as.POSIXct(Head_CT_pop$ADMITDATETIME)

Head_CT_pop$DISCHARGEDATETIME <-strptime(Head_CT_pop$DISCHARGEDATETIME, "%Y-%m-%d %H:%M:%OS", tz="GMT")
Head_CT_pop$DISCHARGEDATETIME <- as.POSIXct(Head_CT_pop$DISCHARGEDATETIME)

# Head_CT_pop$EDDEPARTUREDATETIME <-strptime(Head_CT_pop$EDDEPARTUREDATETIME, "%Y-%m-%d %H:%M:%OS", tz="GMT")
# Head_CT_pop$EDDEPARTUREDATETIME <- as.POSIXct(Head_CT_pop$EDDEPARTUREDATETIME)


## Split vitals and lab datatsets.
vital_codes <- c("Diastolic BP","Diastolic Blood Pressure", "Systolic BP","Systolic Blood Pressure","SpO2/Pulse Oximetry","Mean Arterial Pressure","MAP","Temperature F", "Respiratory Rate", "Heart Rate",  "Current Weight","Current Height")
lab_codes <- c("Sodium Lvl","ALT","AST","Potassium Lvl", "Creatinine Lvl","Glucose Level","Calcium Lvl", "Magnesium Lvl","Albumin Lvl","Total Protein","Stroke Volume","Phosphate")
codes <- c(vital_codes,lab_codes)
Head_CT_labs_rel <-Head_CT_labs_vitals[grep(paste(codes, collapse='|'), Head_CT_labs_vitals$RESULT_TYPE, ignore.case=TRUE),]
Head_CT_labs_rel <-Head_CT_labs_vitals[Head_CT_labs_vitals$RESULT_TYPE %in% codes,]

# for(i in 2:length(lab_codes))
# {
# Head_CT_labs_1 <-subset(Head_CT_labs,grepl(paste("*",lab_codes[i],"*",sep=""),Head_CT_labs$RESULTSTANDARDDESCRIPTION))
# Head_CT_labs_rel <- rbind(Head_CT_labs_1,Head_CT_labs_rel)
# rm(Head_CT_labs_1)
# }

Head_CT_labs_vitals$RESULT_TYPE[Head_CT_labs_vitals$RESULT_TYPE=="Heart Rate-Vital Signs"] <-"Heart Rate"
Head_CT_labs_vitals$RESULT_TYPE[Head_CT_labs_vitals$RESULT_TYPE=="Post Heart Rate"] <-"Heart Rate"
Head_CT_labs_vitals$RESULT_TYPE[Head_CT_labs_vitals$RESULT_TYPE=="Systolic Blood Pressure"] <-"Systolic BP"
Head_CT_labs_vitals$RESULT_TYPE[Head_CT_labs_vitals$RESULT_TYPE=="MU Cardiac Rhythm"] <-"Cardiac Rhythm"
Head_CT_labs_vitals$RESULT_TYPE[Head_CT_labs_vitals$RESULT_TYPE=="Diastolic Blood Pressure"] <-"Diastolic BP"
Head_CT_labs_vitals$RESULT_TYPE[Head_CT_labs_vitals$RESULT_TYPE=="MU Cardiac Rhythm"] <-"Cardiac Rhythm"
Head_CT_labs_vitals$RESULT_TYPE[Head_CT_labs_vitals$RESULT_TYPE=="Mean Arterial Pressure"] <-"MAP"
Head_CT_labs_vitals$RESULT_TYPE[Head_CT_labs_vitals$RESULT_TYPE=="Systolic Blood Pressure Invasive"] <-"Systolic BP Invasive"
Head_CT_labs_vitals$RESULT_TYPE[Head_CT_labs_vitals$RESULT_TYPE=="Diastolic Blood Pressure Invasive"] <-"Diastolic BP Invasive"
Head_CT_labs_vitals$RESULT_TYPE[Head_CT_labs_vitals$RESULT_TYPE=="Temperature F Converted"] <-"Temperature F"
#Head_CT_labs_vitals$RESULT_TYPE[Head_CT_labs_vitals$RESULT_TYPE=="Temperature C Converted"] <-"Temperature C"
## Create combined dataset for labs and vitals with population

Head_CT_data<-merge(Head_CT_labs_rel, subset(Head_CT_pop,select=c("ENCOUNTERID","ORDERDATETIME")), by.x='ENCOUNTERID',by.y='ENCOUNTERID', all=TRUE)
Head_CT_data$difftime<-difftime(Head_CT_data$EVENT_END_DT_TM,Head_CT_data$ORDERDATETIME, units=c('hours'), tz='GMT')
Head_CT_data$difftime<-as.numeric(Head_CT_data$difftime)
Head_CT_data$difftime<-abs(Head_CT_data$difftime)
Head_CT_data <- data.table(Head_CT_data)
setkey(Head_CT_data, ENCOUNTERID, difftime, RESULT_TYPE)
Head_CT_data<-setorder(Head_CT_data, ENCOUNTERID, difftime, RESULT_TYPE)

setkey(Head_CT_data, ENCOUNTERID, RESULT_TYPE)
choose<-unique(Head_CT_data)[,key(Head_CT_data), with = FALSE]
first<-Head_CT_data[choose,mult = 'first']
Head_CT_data[,.N,by=ENCOUNTERID ]
summary(Head_CT_data[,.N,by=ENCOUNTERID ]$N)

#Reshape the data to spread it to wide format using dcast
first1 <-dcast(data = first,formula = ENCOUNTERID+PERFORMED_DT_TM ~RESULT_TYPE,fun.aggregate = NULL,value.var = "RESULT_VAL")
names1<-make.names(names(first1))
colnames(first1) <- names1

Head_CT_data_final <- merge(Head_CT_pop,first1,by='ENCOUNTERID', all.x=TRUE)
write.table(Head_CT_data_final,file=paste("C:\\DATA SCIENCE\\Arun\\Projects\\imaging\\new\\12_30_2015\\Head_CT_data_final_v1.0.csv",sep=""), sep=",",row.names=FALSE)
##Create data table with usable variables in modeling

Head_CT_w_pos <- subset(Head_CT_data_final, select = -c(ENCOUNTERID,ADMITDIAGNOSISLOCALTERM,FACILITYABBREVIATION,RESULTENTRYDATETIME,ISRESULTABNORMAL,ORDERDATETIME,ADMITDATETIME,DISCHARGEDATETIME,ADMITDIAGNOSISLOCALDESCRIPTION,DISCHARGESERVICE,DISCHARGEDISPOSITIONSTANDARDDESCRIPTION,PRIMARY_ICD9_DIAG_CD,PRIMARY_ICD9_DIAG_DESC,PRIMARY_ICD9_DIAG,PERFORMED_DT_TM),drop=FALSE)

Head_CT_w_pos$ENCOUNTERTYPE <- as.factor(Head_CT_w_pos$ENCOUNTERTYPE)
Head_CT_w_pos$ADMITSERVICE <- as.factor(Head_CT_w_pos$ADMITSERVICE)
Head_CT_w_pos$ADMITTYPESTANDARDDESCRIPTION <- as.factor(Head_CT_w_pos$ADMITTYPESTANDARDDESCRIPTION)
Head_CT_w_pos$ISEDPATIENT <- as.factor(Head_CT_w_pos$ISEDPATIENT)
Head_CT_w_pos$CCSID <- as.factor(Head_CT_w_pos$CCSID)
Head_CT_w_pos$pos.result <- as.factor(Head_CT_w_pos$pos.result)
Head_CT_w_pos$rank <- as.factor(Head_CT_w_pos$rank)
Head_CT_w_pos <- subset(Head_CT_w_pos, select = -c(rank),drop=FALSE)

## Change continuos variables to factors here ##

Head_CT_w_pos1 <- subset(Head_CT_w_pos, select = -c(Stroke.Volume))

Head_CT_w_pos1$ENCOUNTERTYPE <- as.factor(ifelse(is.na(Head_CT_w_pos1$ENCOUNTERTYPE),"UNK",Head_CT_w_pos1$ENCOUNTERTYPE))

Head_CT_w_pos1$ADMITSERVICE <- as.factor(ifelse(is.na(Head_CT_w_pos1$ADMITSERVICE),"UNK",Head_CT_w_pos1$ADMITSERVICE))

Head_CT_w_pos1$ADMITTYPESTANDARDDESCRIPTION <- as.factor(ifelse(is.na(Head_CT_w_pos1$ADMITTYPESTANDARDDESCRIPTION),"UNK",Head_CT_w_pos1$ADMITTYPESTANDARDDESCRIPTION))

Head_CT_w_pos1$AGEATADMISSION <- ifelse(is.na(Head_CT_w_pos1$AGEATADMISSION),0,Head_CT_w_pos1$AGEATADMISSION)

Head_CT_w_pos1$Albumin.Lvl <- as.factor(ifelse((Head_CT_w_pos1$Albumin.Lvl<3.4),"Low",ifelse((Head_CT_w_pos1$Albumin.Lvl>=3.4)&(Head_CT_w_pos1$Albumin.Lvl<=5.4), "Normal",ifelse((Head_CT_w_pos1$Albumin.Lvl>5.4), "High","UNK"))))
Head_CT_w_pos1$Albumin.Lvl <-as.factor(ifelse(is.na(Head_CT_w_pos1$Albumin.Lvl),"UNK",Head_CT_w_pos1$Albumin.Lvl))

Head_CT_w_pos1$ALT <- as.factor(ifelse((Head_CT_w_pos1$ALT<7),"Low",ifelse((Head_CT_w_pos1$ALT>=7)&(Head_CT_w_pos1$ALT<=40), "Normal",ifelse((Head_CT_w_pos1$ALT>40), "High","UNK"))))
Head_CT_w_pos1$ALT <-as.factor(ifelse(is.na(Head_CT_w_pos1$ALT),"UNK",Head_CT_w_pos1$ALT))

Head_CT_w_pos1$AST <- as.factor(ifelse((Head_CT_w_pos1$AST<10),"Low",ifelse((Head_CT_w_pos1$AST>=10)&(Head_CT_w_pos1$AST<=34), "Normal",ifelse((Head_CT_w_pos1$AST>34), "High","UNK"))))
Head_CT_w_pos1$AST <-as.factor(ifelse(is.na(Head_CT_w_pos1$AST),"UNK",Head_CT_w_pos1$AST))

Head_CT_w_pos1$Calcium.Lvl <- as.factor(ifelse((Head_CT_w_pos1$Calcium.Lvl<8.5),"Low",ifelse((Head_CT_w_pos1$Calcium.Lvl>=8.5)&(Head_CT_w_pos1$Calcium.Lvl<=10.2), "Normal",ifelse((Head_CT_w_pos1$Calcium.Lvl>10.2), "High","UNK"))))
Head_CT_w_pos1$Calcium.Lvl <-as.factor(ifelse(is.na(Head_CT_w_pos1$Calcium.Lvl),"UNK",Head_CT_w_pos1$Calcium.Lvl))


Head_CT_w_pos1$Creatinine.Lvl <- as.factor(ifelse((Head_CT_w_pos1$Creatinine.Lvl<0.7),"Low",ifelse((Head_CT_w_pos1$Creatinine.Lvl>=0.7)&(Head_CT_w_pos1$Creatinine.Lvl<=1.3), "Normal",ifelse((Head_CT_w_pos1$Creatinine.Lvl>1.3), "High","UNK"))))
Head_CT_w_pos1$Creatinine.Lvl <-as.factor(ifelse(is.na(Head_CT_w_pos1$Creatinine.Lvl),"UNK",Head_CT_w_pos1$Creatinine.Lvl))

Head_CT_w_pos1$Diastolic.BP <- as.factor(ifelse((Head_CT_w_pos1$Diastolic.BP<40),"Low",ifelse((Head_CT_w_pos1$Diastolic.BP.Lvl>=40)&(Head_CT_w_pos1$Diastolic.BP<=100), "Normal",ifelse((Head_CT_w_pos1$Diastolic.BP>100), "High","UNK"))))
Head_CT_w_pos1$Diastolic.BP <-as.factor(ifelse(is.na(Head_CT_w_pos1$Diastolic.BP),"UNK",Head_CT_w_pos1$Diastolic.BP))

Head_CT_w_pos1$Current.Weight <- as.factor(ifelse((Head_CT_w_pos1$Current.Weight<0),"Low",ifelse((Head_CT_w_pos1$Current.Weight>=0)&(Head_CT_w_pos1$Current.Weight<=300), "Normal",ifelse((Head_CT_w_pos1$Current.Weight>300), "High","UNK"))))
Head_CT_w_pos1$Current.Weight <-as.factor(ifelse(is.na(Head_CT_w_pos1$Current.Weight),"UNK",Head_CT_w_pos1$Current.Weight))

Head_CT_w_pos1$Glucose.Level <- as.factor(ifelse((Head_CT_w_pos1$Glucose.Level<70),"Low",ifelse((Head_CT_w_pos1$Glucose.Level>=70)&(Head_CT_w_pos1$Glucose.Level<=125), "Normal",ifelse((Head_CT_w_pos1$Glucose.Level>125), "High","UNK"))))
Head_CT_w_pos1$Glucose.Level <-as.factor(ifelse(is.na(Head_CT_w_pos1$Glucose.Level),"UNK",Head_CT_w_pos1$Glucose.Level))

Head_CT_w_pos1$Heart.Rate <- as.factor(ifelse((Head_CT_w_pos1$Heart.Rate<60),"Low",ifelse((Head_CT_w_pos1$Heart.Rate>=60)&(Head_CT_w_pos1$Heart.Rate<=100), "Normal",ifelse((Head_CT_w_pos1$Heart.Rate>100), "High","UNK"))))
Head_CT_w_pos1$Heart.Rate <-as.factor(ifelse(is.na(Head_CT_w_pos1$Heart.Rate),"UNK",Head_CT_w_pos1$Heart.Rate))
## Change limits from here

Head_CT_w_pos1$Magnesium.Lvl <- as.factor(ifelse((Head_CT_w_pos1$Magnesium.Lvl<1.7),"Low",ifelse((Head_CT_w_pos1$Magnesium.Lvl>=1.7)&(Head_CT_w_pos1$Magnesium.Lvl<=2.2), "Normal",ifelse((Head_CT_w_pos1$Magnesium.Lvl>2.2), "High","UNK"))))
Head_CT_w_pos1$Magnesium.Lvl <-as.factor(ifelse(is.na(Head_CT_w_pos1$Magnesium.Lvl),"UNK",Head_CT_w_pos1$Magnesium.Lvl))

Head_CT_w_pos1$MAP <- as.factor(ifelse((Head_CT_w_pos1$MAP<65),"Low",ifelse((Head_CT_w_pos1$MAP>=65)&(Head_CT_w_pos1$MAP<=110), "Normal",ifelse((Head_CT_w_pos1$MAP>110), "High","UNK"))))
Head_CT_w_pos1$MAP <-as.factor(ifelse(is.na(Head_CT_w_pos1$MAP),"UNK",Head_CT_w_pos1$MAP))

Head_CT_w_pos1$Phosphate <- as.factor(ifelse((Head_CT_w_pos1$Phosphate<2.4),"Low",ifelse((Head_CT_w_pos1$Phosphate>=2.4)&(Head_CT_w_pos1$Phosphate<=4.1), "Normal",ifelse((Head_CT_w_pos1$Phosphate>4.1), "High","UNK"))))
Head_CT_w_pos1$Phosphate <-as.factor(ifelse(is.na(Head_CT_w_pos1$Phosphate),"UNK",Head_CT_w_pos1$Phosphate))

Head_CT_w_pos1$Potassium.Lvl <- as.factor(ifelse((Head_CT_w_pos1$Potassium.Lvl<3.7),"Low",ifelse((Head_CT_w_pos1$Potassium.Lvl>=3.7)&(Head_CT_w_pos1$Potassium.Lvl<=5.2), "Normal",ifelse((Head_CT_w_pos1$Potassium.Lvl>5.2), "High","UNK"))))
Head_CT_w_pos1$Potassium.Lvl <-as.factor(ifelse(is.na(Head_CT_w_pos1$Potassium.Lvl),"UNK",Head_CT_w_pos1$Potassium.Lvl))


Head_CT_w_pos1$Respiratory.Rate <- as.factor(ifelse((Head_CT_w_pos1$Respiratory.Rate<12),"Low",ifelse((Head_CT_w_pos1$Respiratory.Rate>=12)&(Head_CT_w_pos1$Respiratory.Rate<=25), "Normal",ifelse((Head_CT_w_pos1$Respiratory.Rate>25), "High","UNK"))))
Head_CT_w_pos1$Respiratory.Rate <-as.factor(ifelse(is.na(Head_CT_w_pos1$Respiratory.Rate),"UNK",Head_CT_w_pos1$Respiratory.Rate))

Head_CT_w_pos1$Sodium.Lvl <- as.factor(ifelse((Head_CT_w_pos1$Sodium.Lvl<135),"Low",ifelse((Head_CT_w_pos1$Sodium.Lvl>=135)&(Head_CT_w_pos1$Sodium.Lvl<=145), "Normal",ifelse((Head_CT_w_pos1$Sodium.Lvl>145), "High","UNK"))))
Head_CT_w_pos1$Sodium.Lvl <-as.factor(ifelse(is.na(Head_CT_w_pos1$Sodium.Lvl),"UNK",Head_CT_w_pos1$Sodium.Lvl))

Head_CT_w_pos1$SpO2.Pulse.Oximetry <- as.factor(ifelse((Head_CT_w_pos1$SpO2.Pulse.Oximetry<90),"Low",ifelse((Head_CT_w_pos1$SpO2.Pulse.Oximetry>=90)&(Head_CT_w_pos1$SpO2.Pulse.Oximetry<=100), "Normal",ifelse((Head_CT_w_pos1$SpO2.Pulse.Oximetry>100), "High","UNK"))))
Head_CT_w_pos1$SpO2.Pulse.Oximetry <-as.factor(ifelse(is.na(Head_CT_w_pos1$SpO2.Pulse.Oximetry),"UNK",Head_CT_w_pos1$SpO2.Pulse.Oximetry))


# Head_CT_w_pos1$Stroke.Volume <- as.factor(ifelse((Head_CT_w_pos1$Stroke.Volume<60),"Low",ifelse((Head_CT_w_pos1$Stroke.Volume>=60)&(Head_CT_w_pos1$Stroke.Volume<=100), "Normal",ifelse((Head_CT_w_pos1$Stroke.Volume>100), "High","UNK"))))
# Head_CT_w_pos1$Stroke.Volume <-as.factor(ifelse(is.na(Head_CT_w_pos1$Stroke.Volume),"UNK",Head_CT_w_pos1$Stroke.Volume))

Head_CT_w_pos1$Systolic.BP <- as.factor(ifelse((Head_CT_w_pos1$Systolic.BP<70),"Low",ifelse((Head_CT_w_pos1$Systolic.BP>=70)&(Head_CT_w_pos1$Systolic.BP<=190), "Normal",ifelse((Head_CT_w_pos1$Systolic.BP>190), "High","UNK"))))
Head_CT_w_pos1$Systolic.BP <-as.factor(ifelse(is.na(Head_CT_w_pos1$Systolic.BP),"UNK",Head_CT_w_pos1$Systolic.BP))

Head_CT_w_pos1$Temperature.F <- as.factor(ifelse((Head_CT_w_pos1$Temperature.F<97),"Low",ifelse((Head_CT_w_pos1$Temperature.F>=97)&(Head_CT_w_pos1$Temperature.F<=105), "Normal",ifelse((Head_CT_w_pos1$Temperature.F>105), "High","UNK"))))
Head_CT_w_pos1$Temperature.F <-as.factor(ifelse(is.na(Head_CT_w_pos1$Temperature.F),"UNK",Head_CT_w_pos1$Temperature.F))

Head_CT_w_pos1$Total.Protein <- as.factor(ifelse((Head_CT_w_pos1$Total.Protein<6),"Low",ifelse((Head_CT_w_pos1$Total.Protein>=6)&(Head_CT_w_pos1$Total.Protein<=8.3), "Normal",ifelse((Head_CT_w_pos1$Total.Protein>8.3), "High","UNK"))))
Head_CT_w_pos1$Total.Protein <-as.factor(ifelse(is.na(Head_CT_w_pos1$Total.Protein),"UNK",Head_CT_w_pos1$Total.Protein))



write.table(Head_CT_w_pos1,file=paste("C:\\DATA SCIENCE\\Arun\\Projects\\imaging\\new\\12_30_2015\\Head_CT_w_pos_factors_v1.0.csv",sep=""), sep=",",row.names=FALSE)
## split data into a train and test set
index <- 1:nrow(Head_CT_w_pos)
testindex <- sample(index, trunc(length(index)/3))
trainset <- Head_CT_w_pos[-testindex,]

testset <- Head_CT_w_pos[testindex,]
testout <-testset$pos.result
testset$pos.result <- NULL

################################################################################
# MODEL FITTING AND ROC ANALYSIS
################################################################################
start_time <-Sys.time()
start_time
logitmodel <-  glm(pos.result ~ ., data=trainset, family=binomial) 
glm.pred <- predict(logitmodel,testset, type="response")

end_time<- Sys.time()
end_time
time_taken<- end_time-start_time
time_taken
### glm ROC analysis
roc.glm <- roc(testout,glm.pred) 
plot(roc.glm,legacy.axes=TRUE)

###fit gbm
start_time <-Sys.time()
start_time
glb.model<-gbm(pos.result~ .,trainset,distribution = "adaboost", n.trees=1200, 
               shrinkage =0.01, interaction.depth=1,cv.folds=5, 
               n.minobsinnode = 10, bag.fraction=0.5,verbose = TRUE, n.cores=3)
glb.pred <- predict(object=glb.model, newdata=testset,n.trees=gbm.perf(glb.model, plot.it=FALSE), type = "response") #predict(glb.model,testset, type='response')

end_time<- Sys.time()
end_time
time_taken<- end_time-start_time
time_taken
### gbm ROC analysis
start.time<- Sys.time()

roc.glb <- roc(testout,glb.pred) 
plot(roc.glb,legacy.axes=TRUE)
ci.sp(roc.glb,sensitivities=c(.8,.9,.95,.99))
ci.thresholds(roc.glb, thresholds=c(.01,.05,.1,.2,.3,.4,.5,.6,.7,.8,.9))

end.time <- Sys.time()

total.time <- end.time-start.time

total.time
## Fine tune GBM using caret ##

start_time <- Sys.time()

fitControl <- trainControl(## 10-fold CV
  method = "repeatedcv",
  number = 5,
  ## repeated ten times
  repeats = 5)

gbmGrid <-  expand.grid(interaction.depth = c(1, 5, 9),
                        n.trees = (1:30)*50,
                        shrinkage = c(0.1,0.01),
                        n.minobsinnode = seq(20,50,100))

nrow(gbmGrid)

set.seed(825)
gbmFit2 <- train(pos.result ~ ., data = trainset,
                 method = "gbm",
                 trControl = fitControl,
                 verbose = FALSE,
                 ## Now specify the exact models 
                 ## to evaluate:
                 tuneGrid = gbmGrid)
end_time<- Sys.time()
end_time
time_taken<- end_time-start_time
time_taken

gbmFit2

#specify tuneGrid
# tuneGrid <- expand.grid(
#   n_trees = c(600,900,1200,2000)
#   shrink = c(0.1,0.01,0.001),
#   i.depth = seq(3,5,10,15),
#   minobs = 100,
#   distro = c(0,1) #0 = bernoulli, 1 = adaboost
# )
# cl <- makeCluster(2, outfile="GBMlistening.txt")
# registerDoParallel(cl) #4 parent cores to run in parallel
# err.vect <- NA #initialize
# system.time(
#   err.vect <- foreach (j=1:nrow(tuneGrid), .packages=c('gbm'),.combine=rbind) %dopar% {
#     fit <- gbm(pos.result~., data=trainset, 
#                n.trees = tuneGrid[j, 'n_trees'], 
#                shrinkage = tuneGrid[j, 'shrink'],
#                interaction.depth=tuneGrid[j, 'i.depth'], 
#                n.minobsinnode = tuneGrid[j, 'minobs'], 
#                distribution=ifelse(tuneGrid[j, 'distro']==0, "bernoulli", "adaboost"),
#                bag.fraction=0.5,
#                cv.folds=3,
#                n.cores = 3) #will this make 4X3=12 workers?
#     cv.test <- data.frame(scores=1/(1 + exp(-fit$cv.fitted)), Weight=training$Weight, Label=trainset$pos.result)
#     print(j) #write out to the listener
#     cbind(gbm.roc.area(cv.test$Label, cv.test$scores), getAMS(cv.test), tuneGrid[j, 'n_trees'], tuneGrid[j, 'shrink'], tuneGrid[j, 'i.depth'],tuneGrid[j, 'minobs'], tuneGrid[j, 'distro'], j )
#   }
# )
# stopCluster(cl) #clean up after ourselves   

## Fit XGBoost model ##



##Run decision tree models for continuous variables to find natural splits for factorization##
start.time <- Sys.time()

ct.model <- ctree(pos.result ~ Glucose.Level,data = Head_CT_w_pos)
plot(ct.model)

end.time <- Sys.time()

time.taken <-end.time-start.time

time.taken

## Fit Lasso ##

# FIT glmnet w 10-fold cross validation

x.train<-subset(trainset,select = -c(pos.result),drop = FALSE)
cvfit = cv.glmnet(x=data.matrix(x.train), y=trainset$pos.result, family = "binomial", type.measure = "auc")

plot(cvfit)

# optimal lambda value
cvfit$lambda.min

# optimal AUC
max(cvfit$cvm)

# model coefs
lasso_coef <- data.frame(as.matrix(coef(cvfit, s="lambda.min")))
lasso_coef$VAR <- row.names(lasso_coef)
lasso_coef <- lasso_coef[order(-(abs(lasso_coef$X1))),]
lasso_coef <- subset(lasso_coef, X1 != 0)
glm.pred <- predict(cvfit,as.matrix(testset), type="response")
roc.glm <- roc(testout,glm.pred) 
plot(roc.glm,legacy.axes=TRUE)
### Fit elasticNET -- not using b/c I get sparse matrix error
library(glmnet)
enet<-cv.glmnet(as.matrix(testset), as.factor(cdiff[,16]), family="binomial")
enet.pred<- predict(enet,newx=data.matrix(cdiff_old[,-c(2,16)]), s="lambda.min", type='response')

### enet ROC analysis
roc.enet <- roc(cdiff[,16],enet.pred) 
plot(roc.enet,legacy.axes=TRUE)

### randomForrest
library(randomForest)

rfor<-randomForest(trainset[,-7], as.factor(trainset[,7]))

###predicted probability
rfor.pred<- (predict(rfor,OOB = TRUE,type = "prob"))

### rfor ROC analysis
roc.rfor <- roc(testset[,7],rfor.pred[,2]) 
plot(roc.rfor,legacy.axes=TRUE)

#########################################################################
# COMPARE SPECIFICITY/ FP RATE at 90% Sensitivity
#########################################################################

### COMPARE
ci.sp(roc.rb,sensitivities=c(.9))
ci.sp(roc.glm,sensitivities=c(.9))
ci.sp(roc.glb,sensitivities=c(.9))
ci.sp(roc.enet,sensitivities=c(.9))
ci.sp(roc.rfor,sensitivities=c(.9))
