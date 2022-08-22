################################################################################
##  This program is used to make prediction based on the final RSF model.     ##
##  Then, apply the final RSF model on a validation set and calculate c-index.##
##  Input(s): dataset contains all the selected variable with time and event  ##
################################################################################

### library
library(haven)
library(survival)
library(randomForestSRC)
library(tictoc)
library(Hmisc)
set.seed(1234)
options(scipen=999)

### Import final model object build from variable selection process
## In case when the object is not aviable, refer to the code in appendix below 
## to rebuild the RSF mdoel
rsf_tree <- readRDS('~path/to/final_rsf/object.RData')

### prediction
test_dt<-read_sas('~path/to/test/data')
test_dt$var_404<-as.factor(test_dt$var_404)
test_dt<-as.data.frame(test_dt)

test_pred <- predict(rsf_tree, test_dt, outcome="test")

### calculate c-index on test data
error_rate<-test_pred$err.rate
cindex<-1-error_rate


################################################################################
##                       Appendix: Rebuild RSF model                          ##
################################################################################

### Import data
training_dt<-read_sas('~path/to/traing/data')

### transfer categorical variables to factors
training_dt$var_404<-as.factor(training_dt$var_404)
training_dt<-as.data.frame(training_dt)

### final selected variable list
incol_list<-c("daysfu", "pdac_18mos_num","var_37","var_450","var_2","var_404",
              "var_17")

### variable meaning:
### daysfu:         follow up days after the index date
### pdac_18mos_num: factor variable - whether the patient has been diagnosed with 
###                 pancreatic cancer or not in 18 months follow-up period
### var_37:         age at index
### var_450:        ALT change
### var_2:          HgA1c
### var_404:        factor variable - whether the patient has abdominal pain
### var_17:         weight change in one year

### use a smaller training data which only include selected predictors and y-variable
training_dt_model<-training_dt[,which(names(training_dt) %in% incol_list)]

### hyperparameters in RSF
ntree=20
mtry=length(incol_list)-2

### train RSF
rsf_tree <- rfsrc(Surv(daysfu, pdac_18mos_num) ~ .,
                  data = training_dt_model,
                  ntree=ntree,nodedepth =7,nsplit=0,mtry=mtry,
                  importance = FALSE, tree.err=FALSE)

### prediction
test_dt<-read_sas('~path/to/test/data')
test_dt$var_404<-as.factor(test_dt$var_404)
test_dt<-as.data.frame(test_dt)

test_pred <- predict(rsf_tree, test_dt, outcome="test")

### calculate c-index on test data
error_rate<-test_pred$err.rate
cindex<-1-error_rate