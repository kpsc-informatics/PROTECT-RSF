################################################################################
##  This program is used to perform variable pre-selection based on the       ##
##  minimum depth in Random Servival Forest Model.                            ##
##  Input(s): dataset contains all the candidate variable with time and event ##
##  Parameter(s): (1) threshold for minimum depth                             ##
##                (2) seed number if needed                                   ##
##  Output(s): a list contains all selected variables with their minimum depth##
################################################################################

### set parameters
min_dep_th <- 3.5     ## threshold for minimum depth
seed_num <- 1234      ## seed number

### library
library(haven)
library(survival)
library(randomForestSRC)
library(tictoc)
library(Hmisc)
set.seed(seed_num)
options(scipen=999)

### Training data
training_dt<-read_sas('~path/to/traing/data')

### transfer categorical variables to factors
training_dt$var_404<-as.factor(training_dt$var_404)
training_dt<-as.data.frame(training_dt)

### list include all predictors
incol_list <- colnames(training_dt)
incol_list <- incol_list[-which(incol_list %in% c("MRN", "pdac_18mos_num", "daysfu"))]

### hyperparameters in RSF
ntree=20
mtry=length(incol_list)-2

### train RSF
rsf_tree <- rfsrc(Surv(daysfu, pdac_18mos_num) ~ .,
                  data = training_dt[, which(colnames(training_dt) %in% incol_list)],
                  ntree=ntree,nodedepth =7,nsplit=0,mtry=mtry,
                  split.depth = "all.trees", 
                  importance = FALSE, tree.err=FALSE)

### pull minimum depth for each predictor at patient level
min_dep_dt <- as.data.frame(rsf_tree$split.depth)
colnames(min_dep_dt) <- incol_list

### calculate average minimum depth across all records 
min_dep_all_var <- apply(min_dep_dt, 2, mean)

### final selected variable list
selected_vars <- data.frame(vars = incol_list[which(min_dep_all_var<min_dep_th)],
                            min_dep = min_dep_all_var[which(min_dep_all_var<min_dep_th)])

### save the list
write.csv(selected_vars, "~path/to/target/file/selected_vars.csv", row.names = FALSE)
