################################################################################
##  This program is to provide sample codes to update/validate the KPSC model ##
##  by using the same predictors selected by the current study.               ##
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

### Update KPSC model

### Import SAS format data
training_dt<-read_sas('~path/training/data')

### final selected variable list
incol_list<-c("daysfu", "event","age","alt_change","HgA1c","abdominal_pain", "weight_change")
training_dt_model<-training_dt[,which(names(training_dt) %in% incol_list)]

### transfer categorical variables to factors
training_dt_model$abdominal_pain<-as.factor(training_dt_model$abdominal_pain)

### hyperparameters in RSF
ntree=20
mtry=length(incol_list)-2
nodedepth =7
nsplit=0

### Fit RSF model
rsf_tree <- rfsrc(Surv(daysfu, pdac_18mos_num) ~ .,
                  data = training_dt_model,
                  ntree=ntree,nodedepth =nodedepth,nsplit=nsplit,mtry=mtry,
                  importance = FALSE, tree.err=FALSE)

save(rsf_tree, '~path/to/final_rsf/object.RData')

### Validate the model above (using a test dataset)

rsf_tree <- readRDS('~path/to/final_rsf/object.RData')

### loading SAS format data for prediction
### Make sure this data contains all variables in the final RSF model
test_dt<-read_sas('~path/test/data')

### transfer categorical variables to factors
test_dt$abdominal_pain<-as.factor(test_dt$abdominal_pain)
test_dt<-as.data.frame(test_dt)

test_pred <- predict(rsf_tree, test_dt, outcome="test")

### calculate c-index on test data
error_rate<-test_pred$err.rate
cindex<-1-error_rate
cindex
