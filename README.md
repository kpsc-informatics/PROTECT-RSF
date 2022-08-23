# PROTECT-RSF
Random Survival Forest model in 'Prediction Model for Detection of Sporadic Pancreatic Cancer (PRO-TECT) in Population-Based Cohort Using Machine Learning"

# Example of use <br />

(For the detailed data cleaning method, please refer to the paper's method section) <br />
**Step1 - Varible Pre-selection**: Because our training data contains too many variable, starting variable selection with forward selection is computationally impossible. We used minimum depth in RSF model to pre-select a group of predictors. In our paper, we began with 500+ variables, after pre-selection, there are 29 predictors remaining. Sample code: <br />
[variable_selection_min_depth.R](https://github.com/kpsc-informatics/PROTECT-RSF/blob/main/variable_selection_min_depth.R)<br />

**Step2 - Varible selection**:  For a reasonable number of predictors, we performed forward selection with respect to c-index. In our paper, we finally kept 5 variables out of 29 candidate predictors. Sample code: <br />
[variable_selection_cindex.R](https://github.com/kpsc-informatics/PROTECT-RSF/blob/main/variable_selection_cindex.R)<br />

**Step3 - Final model**: Apply variable selection process (step 2) in all training sets. Pick up the model with variables that most frequently appear. <br />

**Step4 - Prediction**: Make prediction based on the final model and calculate c-index in validation data. Sample code: <br />
[RSF_prediction.R](https://github.com/kpsc-informatics/PROTECT-RSF/blob/main/rsf_prediction.R)<br />
