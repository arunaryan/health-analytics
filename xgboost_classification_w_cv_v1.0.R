library(caret)
library(xgboost)
library(readr)
library(dplyr)
library(pROC)
library(tidyr)
library(Matrix)
# load in the training data
# setwd("S:/Data Science/Tenet_reference/Boosting/Xgboost")


banking = read.csv("~\\banking.csv", fill = TRUE, header = TRUE,sep=",")

banking[sapply(banking, is.character)] <- lapply(banking[sapply(banking, is.character)], as.factor)
index <- 1:nrow(banking)
testindex <- sample(index, trunc(length(index)/3))
trainset <- banking[-testindex,!(names(banking) %in% c("y"))]
trainout <-banking[-testindex,]$y
testset <- banking[testindex,!(names(banking) %in% c("y"))]
testout <-banking[testindex,]$y

# xgboost fitting with arbitrary parameters
xgb_params_2 = list(
  objective = "binary:logistic",                                               # binary classification
  eta = 0.3,                                                                  # learning rate
  max.depth = 5,                                                               # max tree depth
  eval_metric = "auc"                                                          # evaluation/loss metric
)

# fit the model with the arbitrary parameters specified above
xgb_2 = xgboost(data = data.matrix(trainset),
                label= trainout,
                params = xgb_params_2,
                nrounds = 1000,                                                 # max number of trees to build
                verbose = TRUE,                                         
                print.every.n = 1,
                early.stop.round = 20,                                # stop if no improvement within 10 trees
                missing="NAN" 
)

# cross-validate xgboost to get the accurate measure of error
xgb_cv_2 = xgb.cv(params = xgb_params_2,
                  data = data.matrix(trainset),
                  label= trainout,
                  nrounds = 1000, 
                  nfold = 5,                                                   # number of folds in K-fold
                  prediction = TRUE,                                           # return the prediction using the final model 
                  showsd = TRUE,                                               # standard deviation of loss across folds
                  stratified = TRUE,                                           # sample is unbalanced; use stratified sampling
                  verbose = TRUE,
                  print.every.n = 1, 
                  early.stop.round = 20,
                  missing="NA" 
)

# plot the AUC for the training and testing samples
xgb_cv_2$dt %>%
  select(-contains("std")) %>%
  mutate(IterationNum = 1:n()) %>%
  gather(TestOrTrain, AUC, -IterationNum) %>%
  ggplot(aes(x = IterationNum, y = AUC, group = TestOrTrain, color = TestOrTrain)) + 
  geom_line() + 
  theme_bw()

names <- dimnames(trainset)[[2]]

# Compute feature importance matrix
importance_matrix <- xgb.importance(names, model = xgb_2)

# Nice graph
xgb.plot.importance(importance_matrix[1:20,])

#############################################################################################
# 
# Parameter tuning
# Full list of parameters tuned here: https://github.com/dmlc/xgboost/blob/master/doc/parameter.md
#
#############################################################################################
train1<- sparse.model.matrix(age ~., data = trainset)

test1 <- sparse.model.matrix(age ~., data = testset)

output.data<-ifelse(trainout==0, "Failure", "Success")

output.data1 <-ifelse(testout==0, "Failure", "Success")

# set up the cross-validated hyper-parameter search
xgb_grid_1 = expand.grid(
  nrounds = seq(1000,2000,by=200),
  eta = c(0.3,0.4,0.5),
  max_depth = c(4,5,6),
  gamma = 1,
  colsample_bytree = 1,    #default=1
  min_child_weight = 4     #default=1
)

# pack the training control parameters
xgb_trcontrol_1 = trainControl(
  method = "cv",
  number = 5,
  verboseIter = TRUE,
  returnData = FALSE,
  returnResamp = "all",                                                        # save losses across all models
  classProbs = TRUE,                                                           # set to TRUE for AUC to be computed
  summaryFunction = twoClassSummary,
  allowParallel = TRUE
)

# train the model for each parameter combination in the grid, 
#   using CV to evaluate

# df_train$SeriousDlqin2yrs<-ifelse(df_train$SeriousDlqin2yrs==1, "Failure", "Success")
# df_train2<-na.omit(df_train)

xgb_train_1 = train(
  x = as.matrix(train1),
  y = as.factor(output.data),
  trControl = xgb_trcontrol_1,
  tuneGrid = xgb_grid_1,
  method = "xgbTree",
  verbose=TRUE
)

# scatter plot of the AUC against max_depth and eta
ggplot(xgb_train_1$results, aes(x = as.factor(eta), y = max_depth, size = ROC, color = ROC)) + 
  geom_point() + 
  theme_bw() + 
  scale_size_continuous(guide = "none")

xgb1_pred <- predict(xgb_train_1,test1)

output.data<-ifelse(xgb1_pred=="Failure", 0,1)

start.time<- Sys.time()

roc.xgb <- roc(testout,output.data) 
plot(roc.xgb,legacy.axes=TRUE)
ci.sp(roc.xgb,sensitivities=c(.8,.9,.95,.99))
ci.thresholds(roc.xgb, thresholds=c(.01,.05,.1,.2,.3,.4,.5,.6,.7,.8,.9))

end.time <- Sys.time()

total.time <- end.time-start.time

total.time
