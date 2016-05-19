library(Hmisc)
library(reshape2)
library(plyr)
library(ggplot2)

setwd("S:/Data Science/MedRec")
#load("C:/DATA SCIENCE/Arun/Projects/MedRec/MedRec_data_03_24_2016.RData")
data<-MedRec_excss_days
saveRDS(data, "data.rds")
rm(list=ls())
data<-readRDS("C:/DATA SCIENCE/Arun/Projects/MedRec/data.rds")

str(data)
names(data)
describe(data)


#Volume & Excess days
data$excess_days_1_0<-ifelse(data$Excess.Days.for.Calculation>0, 1, 0)

volume<-ddply(data,~Facility,summarise, volume=length(ENCOUNTERID), excess_days=sum(excess_days_1_0), 
              percent_excess=(excess_days/volume)*100)

volume<-volume[with(volume, order(volume)),]
a<-volume$Facility
volume$Facility<-factor(volume$Facility, levels=a)

describe(volume)
p2 <- ggplot(volume)
p2 + geom_bar(aes(Facility, volume, fill=volume), stat = "identity", position="dodge") + 
  scale_fill_gradient2(low = 'red', mid = 'yellow', high = 'green', midpoint = 8600) +  coord_flip() + theme_minimal() +
  theme(text=element_text(size=12)) +  labs(fill="Volume") + theme(legend.position="none")

volume<-volume[with(volume, order(percent_excess)),]
a<-volume$Facility
volume$Facility<-factor(volume$Facility, levels=a)

p2 <- ggplot(volume)
p2 + geom_bar(aes(Facility, percent_excess, fill=percent_excess), stat = "identity", position="dodge") + 
  scale_fill_gradient2(low = 'red', mid = 'yellow', high = 'green', midpoint = 40) +  coord_flip() + theme_minimal() +
  theme(text=element_text(size=12)) +  labs(fill="Percent excess LOS") + theme(legend.position="none")

## Home-Med, Discharge, Admisison completion medrec by facility

#Home_med Reconcilaition
Home_Med_rec<-ddply(MedRec_all[MedRec_all$No.Known.Home.Medications.Indicator==0,],~Facility,summarise, volume=length(ENCOUNTERID), home_med=sum(Home.Medication.Complete.Indicator), 
              percent_done=(home_med/volume)*100)

Home_Med_rec<-Home_Med_rec[with(Home_Med_rec, order(volume)),]
a<-Home_Med_rec$Facility
Home_Med_rec$Facility<-factor(Home_Med_rec$Facility, levels=a)

p2 <- ggplot(Home_Med_rec)
p2 + geom_bar(aes(Facility, volume, fill=volume), stat = "identity", position="dodge") + 
  scale_fill_gradient2(low = 'red', mid = 'yellow', high = 'green', midpoint = 8600) +  coord_flip() + theme_minimal() +
  theme(text=element_text(size=10)) +  labs(fill="Volume complete HomeMedRec") + theme(legend.position="none")


Home_Med_rec<-Home_Med_rec[with(Home_Med_rec, order(percent_done)),]
a<-Home_Med_rec$Facility
Home_Med_rec$Facility<-factor(Home_Med_rec$Facility, levels=a)

p2 <- ggplot(Home_Med_rec)
p2 + geom_bar(aes(Facility, percent_done, fill=percent_done), stat = "identity", position="dodge") + 
  scale_fill_gradient2(low = 'red', mid = 'yellow', high = 'green', midpoint = 80) +  coord_flip() + theme_minimal() +
  theme(text=element_text(size=10)) +  labs(fill="Percent complete HomeMedRec") + theme(legend.position="none")

# Admission Med Reconciliation

Adm_Med_rec<-ddply(MedRec_all,~Facility,summarise, volume=length(ENCOUNTERID), adm_med=sum(Admission.Reconciliation.Complete.Indicator), 
                    percent_done=(adm_med/volume)*100)

Adm_Med_rec<-Adm_Med_rec[with(Adm_Med_rec, order(volume)),]
a<-Adm_Med_rec$Facility
Adm_Med_rec$Facility<-factor(Adm_Med_rec$Facility, levels=a)

p2 <- ggplot(Adm_Med_rec)
p2 + geom_bar(aes(Facility, volume, fill=volume), stat = "identity", position="dodge") + 
  scale_fill_gradient2(low = 'red', mid = 'yellow', high = 'green', midpoint = 8600) +  coord_flip() + theme_minimal() +
  theme(text=element_text(size=10)) +  labs(fill="Volume complete AdmMedRec") + theme(legend.position="none")


Adm_Med_rec<-Adm_Med_rec[with(Adm_Med_rec, order(percent_done)),]
a<-Adm_Med_rec$Facility
Adm_Med_rec$Facility<-factor(Adm_Med_rec$Facility, levels=a)

p2 <- ggplot(Adm_Med_rec)
p2 + geom_bar(aes(Facility, percent_done, fill=percent_done), stat = "identity", position="dodge") + 
  scale_fill_gradient2(low = 'red', mid = 'yellow', high = 'green', midpoint = 80) +  coord_flip() + theme_minimal() +
  theme(text=element_text(size=10)) +  labs(fill="Percent complete AdmMedRec") + theme(legend.position="none")


# Discharge Med Rec

Disch_Med_rec<-ddply(MedRec_req,~Facility,summarise, volume=length(ENCOUNTERID), Disch_med=sum(DischRecComp), 
                   percent_done=(Disch_med/volume)*100)

Disch_Med_rec<-Disch_Med_rec[with(Disch_Med_rec, order(volume)),]
a<-Disch_Med_rec$Facility
Disch_Med_rec$Facility<-factor(Disch_Med_rec$Facility, levels=a)

p2 <- ggplot(Disch_Med_rec)
p2 + geom_bar(aes(Facility, volume, fill=volume), stat = "identity", position="dodge") + 
  scale_fill_gradient2(low = 'red', mid = 'yellow', high = 'green', midpoint = 8600) +  coord_flip() + theme_minimal() +
  theme(text=element_text(size=10)) +  labs(fill="Volume complete DischMedRec") + theme(legend.position="none")


Disch_Med_rec<-Disch_Med_rec[with(Disch_Med_rec, order(percent_done)),]
a<-Disch_Med_rec$Facility
Disch_Med_rec$Facility<-factor(Disch_Med_rec$Facility, levels=a)

p2 <- ggplot(Disch_Med_rec)
p2 + geom_bar(aes(Facility, percent_done, fill=percent_done), stat = "identity", position="dodge") + 
  scale_fill_gradient2(low = 'red', mid = 'yellow', high = 'green', midpoint = 40) +  coord_flip() + theme_minimal() +
  theme(text=element_text(size=10)) +  labs(fill="Percent compliance DischMedRec") + theme(legend.position="none")

## Excess days vs. Discharge Med Rec Compliance

data$excess_days_1_0<-ifelse(data$Excess.Days.for.Calculation>0, 1, 0)

disch_excess<-ddply(data,~Facility,summarise, volume=length(ENCOUNTERID), excess_days=sum(excess_days_1_0), 
              percent_excess=(excess_days/volume)*100, disch_comp = sum(Discharge.Reconciliation.Complete.Indicator), disch_percent = (disch_comp/volume)*100)

# volume<-volume[with(volume, order(volume)),]
# a<-volume$Facility
# volume$Facility<-factor(volume$Facility, levels=a)
# 
# describe(volume)
# p2 <- ggplot(volume)
# p2 + geom_bar(aes(Facility, volume, fill=volume), stat = "identity", position="dodge") + 
#   scale_fill_gradient2(low = 'red', mid = 'yellow', high = 'green', midpoint = 8600) +  coord_flip() + theme_minimal() +
#   theme(text=element_text(size=12)) +  labs(fill="Volume") + theme(legend.position="none")

disch_excess<-disch_excess[with(disch_excess, order(disch_percent)),]
a<-disch_excess$Facility
disch_excess$Facility<-factor(disch_excess$Facility, levels=a)

p2 <- ggplot(disch_excess,aes(disch_percent,percent_excess))
# p2 + geom_bar(aes(Facility, disch_percent, fill=percent_excess), stat = "identity", position="dodge") + 
#   scale_fill_gradient2(low = 'red', mid = 'yellow', high = 'green', midpoint = 40) +  coord_flip() + theme_minimal() +
#   theme(text=element_text(size=12)) +  labs(fill="Percent excess LOS") + theme(legend.position="none")

p2+geom_point(aes(color=Facility))

MedRec_all$DischargeRec.timediff <-as.numeric(difftime(MedRec_all$Discharge.Reconciliation.date.time,MedRec_all$Discharge.date.time, units=c("hours"),tz='GMT'))
MedRec_all$DischRecComp <- ifelse(abs(MedRec_all$DischargeRec.timediff)<= 24.0 & MedRec_all$DischargeRec.timediff<=0.0,1,0)
#MedRec_all$DischRecComp <- ifelse(is.na(MedRec_all$DischRecComp),0,MedRec_all$DischRecComp)
##MedRec_all$DischargeRec.timediff> -24.0 &
#Doing by physician for SYL

MedRec_DEL <-MedRec_all[MedRec_all$Facility=="HIA"&MedRec_all$Discharge.Reconciliation.Status=="Complete",]

Disch_Med_DEL<-ddply(MedRec_DEL,~Attending.MD,summarise, volume=length(ENCOUNTERID), Disch_med=sum(DischRecComp), 
                     percent_done=(Disch_med/volume)*100)
Disch_Med_DEL<-Disch_Med_DEL[Disch_Med_DEL$volume>100,]
Disch_Med_DEL<-Disch_Med_DEL[with(Disch_Med_DEL, order(volume)),]
a<-Disch_Med_DEL$Attending.MD
Disch_Med_DEL$Attending.MD<-factor(Disch_Med_DEL$Attending.MD, levels=a)

p2 <- ggplot(Disch_Med_DEL)
p2 + geom_bar(aes(Attending.MD, volume, fill=volume), stat = "identity", position="dodge") + 
  scale_fill_gradient2(low = 'red', mid = 'yellow', high = 'green', midpoint = 250) +  coord_flip() + theme_minimal() +
  theme(text=element_text(size=10)) +  labs(fill="Volume complete DischMedRec") + theme(legend.position="none")


Disch_Med_DEL<-Disch_Med_DEL[with(Disch_Med_DEL, order(percent_done)),]
a<-Disch_Med_DEL$Attending.MD
Disch_Med_DEL$Attending.MD<-factor(Disch_Med_DEL$Attending.MD, levels=a)

p2 <- ggplot(Disch_Med_DEL)
p2 + geom_bar(aes(Attending.MD, percent_done, fill=percent_done), stat = "identity", position="dodge") + 
  scale_fill_gradient2(low = 'red', mid = 'yellow', high = 'green', midpoint = 40) +  coord_flip() + theme_minimal() +
  theme(text=element_text(size=10)) +  labs(fill="Percent compliance DischMedRec") + theme(legend.position="none")

write.table(Disch_Med_rec,file=paste("C:\\DATA SCIENCE\\Arun\\Projects\\MedRec\\Disch_Med_rec.csv",sep=""), sep=",",row.names=FALSE)
write.table(volume,file=paste("C:\\DATA SCIENCE\\Arun\\Projects\\MedRec\\volume_excess_days_by_fac.csv",sep=""), sep=",",row.names=FALSE)
##

MedRec_rel <- data[data$Discharge.Reconciliation.Status=="Complete",]

m2c<-c("AHD","AHH","MHH","PBA","PRV","PVA","SES","SIE","WVH")
p2c <-c("DES","IND")

MedRec_rel$Discharge.date.time <-ifelse(MedRec_rel$Facility %in% m2c,MedRec_rel$Discharge.date.time-3600,MedRec_rel$Discharge.date.time)
MedRec_rel$Discharge.date.time <-ifelse(MedRec_rel$Facility %in% p2c,MedRec_rel$Discharge.date.time-2*3600,MedRec_rel$Discharge.date.time)

MedRec_rel$Discharge.Reconciliation.date.time <-ifelse(MedRec_rel$Facility %in% m2c,MedRec_rel$Discharge.Reconciliation.date.time-3600,MedRec_rel$Discharge.Reconciliation.date.time)
MedRec_rel$Discharge.Reconciliation.date.time <-ifelse(MedRec_rel$Facility %in% p2c,MedRec_rel$Discharge.Reconciliation.date.time-2*3600,MedRec_rel$Discharge.Reconciliation.date.time)


MedRec_req <- MedRec_all[MedRec_all$Deceased.Indicator==0&MedRec_all$Discharge.Reconciliation.Status=="Complete",]
MedRec_req$DischargeRec.timediff <-as.numeric(difftime(MedRec_req$Discharge.Reconciliation.date.time,MedRec_req$Discharge.date.time, units=c("hours"),tz='GMT'))
MedRec_req$DischRecComp <- ifelse(MedRec_req$DischargeRec.timediff>= -24.0 & MedRec_req$DischargeRec.timediff<=0.0,1,0)
MedRec_req$DischRecComp <- ifelse(is.na(MedRec_req$DischRecComp),0,MedRec_req$DischRecComp)
