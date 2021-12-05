
library(tidyverse)
library(tidymodels)


heart <- read_csv("data/heart.csv")
#heart %>% DataExplorer::create_report()


heart = heart %>% mutate(HeartDisease = as_factor(HeartDisease))

heart_split <- initial_split(heart, prop = 0.80)
heart_train <- training(heart_split)
heart_test  <-  testing(heart_split)

heart_vfcv <- vfold_cv(heart_train, v = 5)


heart %>%
    select(Cholesterol) %>%
    mutate(Cholesterol = ifelse(Cholesterol== 0 , median (Cholesterol), Cholesterol) )%>%
    summary()


#### Recipe  ####
heart_recipe <- recipe(HeartDisease ~ ., data = heart_train) %>%
    step_mutate(Cholesterol = ifelse(Cholesterol== 0 , median (Cholesterol), Cholesterol) )%>%
    # step_mutate(AgeQ = )
    # step_interact(~ AgeQ:Sex) %>%
    step_normalize(all_numeric_predictors()) %>%
    step_dummy(all_nominal_predictors())
    # step_rm(Oldpeak ) %>%
    # step_nzv(all_predictors())

juice(prep(heart_recipe)) %>% glimpse()
bake(prep(heart_recipe), heart_test) %>% glimpse()

juice_train <- juice(prep(heart_recipe))
bake_test <- bake(prep(heart_recipe), heart_test)


##### Logit ####

logistic_model <- logistic_reg() %>% set_engine("glm")

logistic_fit <- fit(logistic_model, HeartDisease ~ ., juice_train)

results_cla_logistico <- predict(logistic_fit, bake_test, type = 'prob') %>%
    bind_cols(bake_test)

roc_curve_cla_logistico <- roc_curve(results_cla_logistico, truth = HeartDisease, estimate
                                     =.pred_1, event_level = 'second') %>%
    mutate(ID = 'Logit')

pr_curve_cla_logistico <- pr_curve(results_cla_logistico, truth = HeartDisease, estimate
                                   =.pred_1, event_level = 'second') %>%
    mutate(ID = 'Logit')

##### Random ####

rforest_model <- rand_forest(
    mode = "classification",
    trees = 3000,
    mtry = tune(),
    min_n = tune()) %>%
    set_engine(
        "ranger",
        importance = "impurity"
    )

rforest_workflow <- workflow() %>%
    add_model(rforest_model) %>%
    add_recipe(heart_recipe)

rforest_param_grid <- grid_regular(
    mtry(range = c(8,15)),
    min_n(range = c(2,10)),
    levels = c(10, 15)
)

ctrl_grid <- control_grid(save_pred = T, verbose = T)

heart_folds <- vfold_cv(heart_train, v = 3)

rforest_tune_result <- tune_grid(
    rforest_workflow,
    resamples = heart_folds,
    grid = rforest_param_grid,
    metrics = metric_set(roc_auc, pr_auc, sens),
    control = ctrl_grid
)

best_rforest_model <- select_best(rforest_tune_result, metric = "pr_auc")

best_rforest_model_1se <- select_by_one_std_err(
    rforest_tune_result, metric = "pr_auc", "pr_auc")

final_rforest_model <- rforest_workflow %>%
    finalize_workflow(best_rforest_model_1se) %>%
    fit(data = heart_train)

results_rforest_clas <- predict(final_rforest_model, heart_test, type = 'prob') %>%
    dplyr::bind_cols(bake_test)


roc_curve_cla_random <- roc_curve(results_rforest_clas, truth = HeartDisease, estimate
                                     =.pred_1, event_level = 'second') %>%
    mutate(ID = 'RF')

pr_curve_cla_random<- pr_curve(results_rforest_clas, truth = HeartDisease, estimate
                                   =.pred_1, event_level = 'second') %>%
    mutate(ID = 'RF')






#### Curvas pecision recall y ROC compararación ####

results_pr_curve <- rbind( pr_curve_cla_logistico , pr_curve_cla_random)
results_roc_curve <- rbind(roc_curve_cla_logistico , roc_curve_cla_random )



pr_curve_plot <- results_pr_curve %>%
    ggplot(aes(x = recall, y = precision, color = ID)) +
    geom_path(size = 1) +
    coord_equal() +
    ggtitle("Precision vs Recall")+
    theme_minimal()


roc_curve_plot <- results_roc_curve %>%
    ggplot(aes(x = 1 - specificity, y = sensitivity, color = ID)) +
    geom_path(size = 1) +
    geom_abline() +
    coord_equal() +
    ggtitle("ROC Curve")+
    theme_minimal()


pr_curve_plot
roc_curve_plot









