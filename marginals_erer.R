library(pROC)
library(erer)
library(Hmisc)
library(glmnet)


cdiff_new_num_factors_data_v1.1<-load("~//cdiff_new_num_factors_data_v1.1.csv")

cdiff_data1<- cdiff_new_num_factors_data_v1.0[,-c(1,17,18,19,20,21)]

## split data into a train and test set
index <- 1:nrow(cdiff_data1)
testindex <- sample(index, trunc(length(index)*0.2))
trainset <- cdiff_data1

testset <- cdiff_data1
testout <-testset$clinical.result
testset$clinical.result <- NULL

## fit glm

logitmodel <-  glm(clinical.result ~ ., data=trainset, family=binomial, x=TRUE) 
glm.pred <- predict(logitmodel,testset, type='response')

## ROC analysis
roc.glm <- roc(testout,glm.pred) 
plot(roc.glm,legacy.axes=TRUE)
ci.sp(roc.marg1,sensitivities=c(.8,.9,.95,.99))
ci.thresholds(roc.marg1, thresholds=c(.01,.05,.1,.2,.3,.4,.5,.6,.7,.8,.9))

## Compute marginals for the logitmodel

glm.marg<-maBina(logitmodel, x.mean = FALSE, rev.dum = TRUE, digits = 3,subset.name = NULL, subset.value)$out

glm.marg<-data.frame(cbind(rownames(glm.marg),glm.marg))

write.table(glm.marg,file="~//CDIFF_marginals_factors_v1.0.csv", sep=",",row.names=FALSE)

## Once you have data from the marginals you can perform ROC analysis on the marginals
