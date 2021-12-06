library(tidyverse)
library(tidymodels)
library(workflows)

# load the dataset of heart
heart <- read_csv("data/heart.csv")

# Read variable heartdisease as a factor
heart = heart %>% mutate(heartdisease = as_factor(heartdisease))

# Split data into train and test set
heart_split <- initial_split(heart, prop = 0.80)
heart_train <- training(heart_split)
heart_test  <-  testing(heart_split)

# Fold train data for evaluation
heart_vfcv <- vfold_cv(heart_train, v = 10)

#Process the data
heart_recipe <- recipe(heartdisease ~ ., data = heart_train) %>%
  step_mutate(cholesterol = ifelse(cholesterol== 0 , median (cholesterol), cholesterol) )%>%
  step_normalize(all_numeric_predictors()) %>%
  step_dummy(all_nominal_predictors())

juice_train <- juice(prep(heart_recipe))
bake_test <- bake(prep(heart_recipe), heart_test)

# Specify the model
logistic_model <- logistic_reg() %>% set_engine("glm")

# Fit the model to the train data
logistic_fit <- fit(logistic_model, heartdisease ~ ., juice_train)

results_cla_logistico <- predict(logistic_fit, bake_test, type = 'prob') %>%
  bind_cols(bake_test)

roc_curve_cla_logistico <- roc_curve(results_cla_logistico, truth = heartdisease, estimate
                                     =.pred_1, event_level = 'second') %>%
  mutate(ID = 'Logit')

pr_curve_cla_logistico <- pr_curve(results_cla_logistico, truth = heartdisease, estimate
                                   =.pred_1, event_level = 'second') %>%
  mutate(ID = 'Logit')

# Save the model
readr::write_rds(logistic_fit, "logistic_model.Rds")
readr::write_rds(heart_recipe, "recipe.Rds")







