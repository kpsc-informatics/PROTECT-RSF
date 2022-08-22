################################################################################
##  This program is used to perform variable selection in a forward selection ##
##  process with respect to c-index.                                          ##
##  Input(s): dataset contains all the candidate variable with time and event ##
##  Parameter(s): (1) threshold for c-index                                   ##
##                (2) seed number if needed                                   ##
##                (3) forced in variable in the model                         ##
##  Output(s): a dataset that contains variable name and c-index              ##
################################################################################

### set parameters
c_index_th <- 0.05     ## threshold for minimum c-index improvement
seed_num <- 1234       ## seed number
fixed_var <- "var_37"  ## forced in variable - age in this paper

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

## build an initial RSF model only with forced in variable
rsf_tree <- rfsrc(Surv(daysfu, pdac_18mos_num) ~ .,
                  data = training_dt[, which(colnames(training_dt) %in% c("pdac_18mos_num", "daysfu", fixed_var))],
                  ntree=20,nodedepth =7,nsplit=0,
                  importance = FALSE, tree.err=FALSE)

old_c <- max(1-rsf_tree$err.rate, na.rm=T)

## add one variable each time into the RSF model until the improvement of 
## c-index is less than the threshold

n <- length(incol_list[!incol_list %in% fixed_var])-1

# initiate c_impv to at least start one selection round
c_impv <- 1

selected_var <- fixed_var
### outer loop: each time choose the variable that contributes the max c-index
for(round_num in 1:n){
  cand_train<-incol_list[!incol_list %in% selected_var]
  n_col <- length(cand_train)
  
  if(c_impv > min.impv){
    selection_result <- data.frame(var_name = cand_train,
                                   c_index = rep(NA,n_col))
    ### inner loop: each time test one candidate variable and record c-index
    for (col_index in 1:n_col) {
      selected_var <- c(selected_var, cand_train[col_index])
      temp_training_data <- training_dt[, which(colnames(training_dt) %in% c("pdac_18mos_num", "daysfu", selected_var))]
      set.seed(seed_num)
      #fit RSF model
      rsf_tree <- rfsrc(Surv(daysfu, pdac_18mos_num) ~ .,
                        data = temp_training_data,
                        ntree=20,nodedepth =7,nsplit=0,
                        importance = FALSE, tree.err=FALSE)
      # Calculate C-index
      selection_result$c_index[col_index] <- max(1-rsf_tree$err.rate, na.rm=T)
    }
    write.csv(selection_result,paste0('~path/to/folder', '/selection_result_round', round_num, '.csv'))
    # update iteration variable 
    new_c <- max(selection_result$c_index)
    winning_var <- as.character(selection_result$var_name[which.max(selection_result$c_index)])
    c_impv <- new_c - old_c
    old_c <- new_c
    select_var <- c(select_var, winning_var)
  } else {
    break
  }
}
