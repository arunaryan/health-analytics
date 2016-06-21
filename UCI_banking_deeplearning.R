library(h2o)

localH2O = h2o.init(ip = 'localhost', port = 54321, nthreads= -1,max_mem_size = '4g')

banking$y <-as.factor(banking$y)


banking <- h2o.importFile(path = normalizePath("banking.csv"))

dim(banking)
head(banking)
splits <- h2o.splitFrame(banking, c(0.6,0.2,0.2))
train  <- h2o.assign(splits[[1]], "train.hex") # 60%
valid  <- h2o.assign(splits[[2]], "valid.hex") # 20%
test   <- h2o.assign(splits[[3]], "test.hex")  # 20%

par(mfrow=c(1,1)) # reset canvas
plot(h2o.tabulate(banking, "education","y"))
plot(h2o.tabulate(banking, "job", "y"))
plot(h2o.tabulate(banking, "marital", "y"))
plot(h2o.tabulate(banking, "age", "y" ))

response <- "y"
predictors <- setdiff(names(banking), response)


m1 <- h2o.deeplearning(
  model_id="dl_model_first", 
  training_frame=train, 
  validation_frame=valid,   ## validation dataset: used for scoring and early stopping
  x=predictors,
  y=response,
  #activation="Rectifier",  ## default
  #hidden=c(200,200),       ## default: 2 hidden layers with 200 neurons each
  epochs=1,
  variable_importances=T    ## not enabled by default
)
summary(m1)

head(as.data.frame(h2o.varimp(m1)))


m3 <- h2o.deeplearning(
  model_id="dl_model_tuned", 
  training_frame=train, 
  validation_frame=valid, 
  x=predictors, 
  y=response, 
  overwrite_with_best_model=F,    ## Return the final model after 10 epochs, even if not the best
  hidden=c(128,128,128),          ## more hidden layers -> more complex interactions
  epochs=10,                      ## to keep it short enough
  score_validation_samples=10000, ## downsample validation set for faster scoring
  score_duty_cycle=0.025,         ## don't score more than 2.5% of the wall time
  adaptive_rate=F,                ## manually tuned learning rate
  rate=0.01, 
  rate_annealing=2e-6,            
  momentum_start=0.2,             ## manually tuned momentum
  momentum_stable=0.4, 
  momentum_ramp=1e7, 
  l1=1e-5,                        ## add some L1/L2 regularization
  l2=1e-5,
  max_w2=10                       ## helps stability for Rectifier
) 
summary(m3)

h2o.performance(m3, train=T)          ## sampled training data (from model building)
h2o.performance(m3, valid=T)          ## sampled validation data (from model building)
h2o.performance(m3, newdata=train)    ## full training data
h2o.performance(m3, newdata=valid)    ## full validation data
h2o.performance(m3, newdata=test)     ## full test data

pred <- h2o.predict(m3, test)
pred
test$Accuracy <- pred$predict == test$y
1-mean(test$Accuracy)

## Hyper parameter grid search ##

sampled_train=train[1:1000,]

hyper_params <- list(
  hidden=list(c(32,32,32),c(64,64)),
  input_dropout_ratio=c(0,0.05),
  rate=c(0.01,0.02),
  rate_annealing=c(1e-8,1e-7,1e-6)
)

hyper_params
grid <- h2o.grid(
  algorithm="deeplearning",
  grid_id="dl_grid", 
  training_frame=sampled_train,
  validation_frame=valid, 
  x=predictors, 
  y=response,
  epochs=10,
  stopping_metric="misclassification",
  stopping_tolerance=1e-2,        ## stop when misclassification does not improve by >=1% for 2 scoring events
  stopping_rounds=2,
  score_validation_samples=1000, ## downsample validation set for faster scoring
  score_duty_cycle=0.025,         ## don't score more than 2.5% of the wall time
  adaptive_rate=F,                ## manually tuned learning rate
  momentum_start=0.5,             ## manually tuned momentum
  momentum_stable=0.9, 
  momentum_ramp=1e7, 
  l1=1e-5,
  l2=1e-5,
  activation=c("Rectifier"),
  max_w2=10,                      ## can help improve stability for Rectifier
  hyper_params=hyper_params
)
grid
