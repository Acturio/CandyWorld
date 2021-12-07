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

#* @serializer contentType list(type='image/png')
#* @get /plot
function(){
  model <- readRDS("logistic_model.Rds")
  plot <- autoplot(roc_curve_cla_logistico)
  file <- "plot.png"
  ggsave(file, plot)
  readBin(file, "raw", n = file.info(file)$size)
}

#* @serializer contentType list(type='image/png')
#* @get /plot2
function(){
  model <- readRDS("logistic_model.Rds")
  plot2 <- autoplot(pr_curve_cla_logistico)
  file2 <- "plot2.png"
  ggsave(file2, plot2)
  readBin(file2, "raw", n = file.info(file2)$size)
}

#* @plumber 
function(pr) {
  pr %>% 
    pr_set_docs(docs = "rapidoc")
}