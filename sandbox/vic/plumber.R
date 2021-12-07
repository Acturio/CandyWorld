#* @apiTitle Predicción de enfermedad cardiaca

#* @apiDescription Introduce los datos que se piden a continuación para conocer a probabilidad que tienes de desarrollar una enfermedad cardiaca


library(plumber)
library(jsonlite)
library(tidyverse)
library(tidymodels)


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
    host = "db",
    user = 'postgres',
    password = 'postgres',
    port = 5432
  )
  dbWriteTable(con, "heart", value=parsed_example, append=TRUE, row.names=FALSE)
  data <- tbl(con, "heart")
  data_collect <- collect(data)

  return(data_collect)

}



#* @serializer contentType list(type='image/png')
#* @get /plot
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
  file <- "plot.png"
  ggsave(file, plot)
  readBin(file, "raw", n = file.info(file)$size)
}

#* @serializer contentType list(type='image/png')
#* @get /plot2
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
  file2 <- "plot2.png"
  ggsave(file2, plot2)
  readBin(file2, "raw", n = file.info(file2)$size)
}

# #* @plumber 
# function(pr) {
#   pr %>% 
#     pr_set_docs(docs = "rapidoc")
# }