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
