# PROTECT-RSF
Random Survival Forest model in 'Prediction Model for Detection of Sporadic Pancreatic Cancer (PRO-TECT) in Population-Based Cohort Using Machine Learning"

# Example of use <br />

(For the detailed data cleaning method, please refer to the paper's method section) <br />
**Step1 - Vraible Pre-selection**: Because our training data contains too many variable, starting variable selection with forward selection is computationally impossible. We suggest a way to use minimum depth in RSF model to pre-select a group of predictors. In our paper, we began with 500+ variables, after pre-selection, there are 29 predictors remaining. Code: <br />
[variable_selection_min_depth.R](https://github.com/kpsc-informatics/PROTECT-RSF/blob/main/variable_selection_min_depth.R)<br />

**Step2**: Data cleaning <br />
**Step3**: Set up hyperparameters and build RSF model <br />
**Step4**: Apply model to a test dataset and calculate performance measurement 
