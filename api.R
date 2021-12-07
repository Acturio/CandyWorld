#* @apiTitle Predicción de enfermedad cardiaca

#* @apiDescription Introduce los datos que se piden a continuación para conocer a probabilidad que tienes de desarrollar una enfermedad cardiaca


library(plumber)
library(jsonlite)
library(tidyverse)
library(tidymodels)


##Lee el modelo
#model <- readRDS("logistic_model.Rds")

#* @post /prediccion_hd
prediccion_hd <- function(req){
  example <- req$postBody
  parsed_example <- jsonlite::fromJSON(example)
  model <- readRDS("logistic_model.Rds")
  recipe <- readRDS("recipe.Rds")
  resultado <- predict(model, bake(prep(recipe), parsed_example), type = 'prob')
  return(resultado)
}


#* @post /new_data
new_data<-function(req) {
  example <- req$postBody
  parsed_example <- jsonlite::fromJSON(example)
  con= DBI::dbConnect(
    drv = RPostgres::Postgres(),
    dbname = 'health',
    host = "localhost",
    user = 'postgres',
    password = 'postgres',
    port = 5432
  )
  dbWriteTable(con, "heart", value=parsed_example, append=TRUE, row.names=FALSE)
  data <- tbl(con, "heart")
  data_collect <- collect(data)

  return(data_collect)

}

#* @post /re_train
reentrenamiento <- function(req){
  con= DBI::dbConnect(
    drv = RPostgres::Postgres(),
    dbname = 'health',
    host = "localhost",
    user = 'postgres',
    password = 'postgres',
    port = 5432
  )
  DBI::dbListTables(conn = con)
  data <- tbl(con, "heart")
  data<-data %>% collect()
  heart = data %>% mutate(heartdisease = as_factor(heartdisease))
  heart_split <- initial_split(heart, prop = 0.80)
  heart_train <- training(heart_split)
  heart_test  <-  testing(heart_split)
  n_train<-nrow(heart_train)
  n_test<-nrow(heart_test)
  suma<-sum(n_train,n_test)
  heart_recipe <- recipe(heartdisease ~ ., data = heart_train) %>%
    step_mutate(cholesterol = ifelse(cholesterol== 0 , median (cholesterol), cholesterol) )%>%
    step_normalize(all_numeric_predictors()) %>%
    step_dummy(all_nominal_predictors())
  
  juice_train <- juice(prep(heart_recipe))
  bake_test <- bake(prep(heart_recipe), heart_test)
  
  # Specify the model
  logistic_model <- logistic_reg() %>% set_engine("glm")
  logistic_fit <- fit(logistic_model, heartdisease ~ ., juice_train)
  readr::write_rds(logistic_fit, "logistic_model.Rds")
  readr::write_rds(heart_recipe, "recipe.Rds")
  readr::write_rds(heart_test, "heart_test_dataset.Rds")
  print(paste("Reentrenamiento Completado. Entrenamiento:", n_train," Test:", n_test," Total:", suma))
}

#* @get /metrics
function(){
  model <- readRDS("logistic_model.Rds")
  recipe <- readRDS("recipe.Rds")
  heart_test <- readRDS("heart_test_dataset.Rds")
  bake_test <- bake(prep(recipe), heart_test)
  results_cla_logistico <- predict(model, bake_test, type = 'prob') %>%
    bind_cols(bake_test)
  roc_curve_cla_logistico <- roc_curve(results_cla_logistico, truth = heartdisease, estimate
                                       =.pred_1, event_level = 'second') 
 auc_roc<-roc_auc(results_cla_logistico,truth = heartdisease, .pred_1,event_level = 'second')
 print(auc_roc)
}



#* @serializer contentType list(type='image/png')
#* @get /roc_curve_plot
function(){
  model <- readRDS("logistic_model.Rds")
  recipe <- readRDS("recipe.Rds")
  heart_test <- readRDS("heart_test_dataset.Rds")
  bake_test <- bake(prep(recipe), heart_test)
  results_cla_logistico <- predict(model, bake_test, type = 'prob') %>%
    bind_cols(bake_test)
  roc_curve_cla_logistico <- roc_curve(results_cla_logistico, truth = heartdisease, estimate
                                       =.pred_1, event_level = 'second') %>%
    mutate(ID = 'Logit')
  plot <- autoplot(roc_curve_cla_logistico)
  file <- "curva_roc.png"
  ggsave(file, plot)
  readBin(file, "raw", n = file.info(file)$size)
}

#* @serializer contentType list(type='image/png')
#* @get /pr_curve_plot
function(){
  model <- readRDS("logistic_model.Rds")
  recipe <- readRDS("recipe.Rds")
  heart_test <- readRDS("heart_test_dataset.Rds")
  bake_test <- bake(prep(recipe), heart_test)
  results_cla_logistico <- predict(model, bake_test, type = 'prob') %>%
    bind_cols(bake_test)
  pr_curve_cla_logistico <- pr_curve(results_cla_logistico, truth = heartdisease, estimate
                                     =.pred_1, event_level = 'second') %>%
    mutate(ID = 'Logit')
  plot2 <- autoplot(pr_curve_cla_logistico)
  file2 <- "pr_plot.png"
  ggsave(file2, plot2)
  readBin(file2, "raw", n = file.info(file2)$size)
}

