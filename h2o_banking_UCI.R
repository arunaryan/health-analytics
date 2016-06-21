## Author: Arun Kiran Aryasomayajula
## Last edit: 05/19/2016

## Script to read UCI banking data set and solve the 2-class classification problem using various ML algorithms in h2o and standard R libraries.
## data folder-- http://archive.ics.uci.edu/ml/machine-learning-databases/00222/
## data description -- http://archive.ics.uci.edu/ml/datasets/Bank+Marketing#
library(h2o)
library(data.table)
library(glmnet)
library(randomForest)
library(pROC)
library(gbm)
library(caret)
library(party)
library(partykit)
library(xgboost)
library(corrplot)
library(stats)

## Fit various calssification models using the h2o suite of models

localH2O = h2o.init(ip = 'localhost', port = 54321, nthreads= -1,max_mem_size = '8g')

banking.hex <- h2o.uploadFile(path = "banking.csv")
banking.hex[,21] <-as.factor(banking.hex[,21])

banking <- as.data.frame(banking.hex)
banking$y <- as.factor(banking$y)
summary(banking.hex)
banking_cols=colnames(banking.hex, do.NULL = TRUE, prefix = "col")


## split data into a train and test set
index <- 1:nrow(banking)
testindex <- sample(index, trunc(length(index)*0.3))
trainset <- banking[-testindex,]

testset <- banking[testindex,]
testout <-testset$y
testset$y <- NULL
#create test and train .hex files
trainset.hex = banking.hex[-testindex,]
testset.hex = banking.hex[testindex,]

## Fit GBM model to trainset.hex and validate on testset.hex

gbm.h2o.model1 <- h2o.gbm(x = 1:20, y = 21, training_frame = trainset.hex, distribution = "AUTO")
print(gbm.h2o.model1)
gbm.h2o.perf1 <- h2o.performance(gbm.h2o.model1,testset.hex)
h2o.auc(gbm.h2o.perf1)
plot(gbm.h2o.model1, timestep = "number_of_trees", metric = "logloss")

h2o.saveModel(object = gbm.h2o.model1, path = "C:\\DATA SCIENCE\\Arun\\R_code\\h2o\\", force=TRUE)
h2o.download_pojo(gbm.h2o.model1)
## Fit GLM model to banking.hex as y~.

myX = setdiff(colnames(trainset.hex), c("y"))

glmcv.h2o.model<-h2o.glm(y = "y", x = myX, training_frame = trainset.hex,
        family = "binomial", nfolds = 5, alpha = 0.5, lambda_search = FALSE)

glm.h2o.model<-h2o.glm(y = "y", x = myX, training_frame = trainset.hex,
                       family = "binomial", standardize=TRUE,
                       lambda_search=TRUE)

print(glm.h2o.model)
glm.h2o.perf <- h2o.performance(glm.h2o.model,testset.hex)
h2o.auc(glm.h2o.perf)
plot(glm.h2o.model, timestep = "number_of_trees", metric = "log_likelihood")
h2o.saveModel(object = glm.h2o.model, path = "C:\\DATA SCIENCE\\Arun\\R_code\\h2o\\", force=TRUE)
h2o.download_pojo(glm.h2o.model)

print(glmcv.h2o.model)
glmcv.h2o.perf <- h2o.performance(glmcv.h2o.model,testset.hex)
h2o.auc(glmcv.h2o.perf)
plot(glmcv.h2o.model, timestep = "number_of_trees", metric = "log_likelihood")
h2o.saveModel(object = glmcv.h2o.model, path = "C:\\DATA SCIENCE\\Arun\\R_code\\h2o\\", force=TRUE)
h2o.download_pojo(glmcv.h2o.model)

## Fit RandomForest to trainset.hex

rfor.h2o.model<- h2o.randomForest(x = myX, y = "y", training_frame=trainset.hex, ntrees = 100,
                                  max_depth = 20, min_rows = 1, nbins = 20, 
                                  balance_classes = FALSE,stopping_metric = c("AUC"), stopping_tolerance = 0.001)

print(rfor.h2o.model)
rfor.h2o.perf <- h2o.performance(rfor.h2o.model,testset.hex)
h2o.auc(rfor.h2o.perf)
plot(rfor.h2o.model, timestep = "number_of_trees", metric = "AUC")
h2o.saveModel(object = rfor.h2o.model, path = "C:\\DATA SCIENCE\\Arun\\R_code\\h2o\\", force=TRUE)
h2o.download_pojo(rfor.h2o.model)

# ################################################################################
# # MODEL FITTING AND ROC ANALYSIS USING standard R libraries
# ################################################################################


## Fit GLM model

start_time <-Sys.time()
start_time
logitmodel <-  glm(y ~ ., data=trainset, family=binomial)
glm.pred <- predict(logitmodel,testset, type="response")

end_time<- Sys.time()
end_time
time_taken<- end_time-start_time
time_taken

# ### glm ROC analysis

roc.glm <- roc(testout,glm.pred)
plot(roc.glm,legacy.axes=TRUE)



## Fine tune GBM using caret ##

start_time <- Sys.time()

fitControl <- trainControl(## 5-fold CV
  method = "repeatedcv",
  number = 5,
  ## repeated ten times
  repeats = 5)

gbmGrid <-  expand.grid(interaction.depth = c(1, 5, 9),
                        n.trees = (3:9)*100,
                        shrinkage = c(0.1,0.01),
                        n.minobsinnode = seq(5,10,15))

nrow(gbmGrid)

set.seed(825)

gbmFit2 <- train(y ~ ., data = trainset,
                 method = "gbm",
                 trControl = fitControl,
                 verbose = TRUE,
                 ## Now specify the exact models
                 ## to evaluate:
                 tuneGrid = gbmGrid)

end_time<- Sys.time()
end_time
time_taken<- end_time-start_time
time_taken

gbmFit2

## Plot the GBM model convergence w.r.t various parameters like "Kappa"

trellis.par.set(caretTheme())
plot(gbmFit2)

trellis.par.set(caretTheme())
plot(gbmFit2, metric = "Kappa")

trellis.par.set(caretTheme())
plot(gbmFit2, metric = "Kappa", plotType = "level",
     scales = list(x = list(rot = 90)))

## Fit XGBoost model ##




## Fit Lasso ##

# FIT glmnet w 10-fold cross validation

x.train<-subset(trainset,select = -c(y),drop = FALSE)
cvfit = cv.glmnet(x=data.matrix(x.train), y=trainset$y, family = "binomial", type.measure = "auc")

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
glm.pred <- predict(cvfit,data.matrix(testset), type="response")
roc.glm <- roc(testout,glm.pred)
plot(roc.glm,legacy.axes=TRUE)

### Fit elasticNET -- 
enet<-cv.glmnet(data.matrix(trainset[,-21]), trainset[,21], family="binomial")
enet.pred<- predict(enet,newx=data.matrix(testset), s="lambda.min", type='response')

### enet ROC analysis
roc.enet <- roc(testout,enet.pred)
plot(roc.enet,legacy.axes=TRUE)

### randomForrest


rfor<-randomForest(trainset[,-21], as.factor(trainset[,21]))

###predicted probability
rfor.pred<- (predict(rfor,OOB = TRUE,type = "prob"))

### rfor ROC analysis
roc.rfor <- roc(trainset[,21],rfor.pred[,2])
plot(roc.rfor,legacy.axes=TRUE)

#########################################################################
# COMPARE SPECIFICITY/ FP RATE at 90% Sensitivity
#########################################################################

### COMPARE

ci.sp(roc.glm,sensitivities=c(.9))
ci.sp(roc.glb,sensitivities=c(.9))
ci.sp(roc.enet,sensitivities=c(.9))
ci.sp(roc.rfor,sensitivities=c(.9))
