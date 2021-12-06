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
  model <- read_rds("logistic_model.Rds")
  resultado <- predict(logistic_fit, bake(prep(heart_recipe), parsed_example), type = 'prob')
  return(resultado)

}


# 
# prediccion_prueba <- function(example){
#   #example <- req$postBody
#   parsed_example <- jsonlite::fromJSON(example)
#   model <- read_rds("logistic_model.Rds")
#   resultado <- predict(logistic_fit, bake(prep(heart_recipe), parsed_example), type = 'prob')
#   return(resultado)
# }

# prueba_df <- heart_test %>% head(1)
# pruebaJSON <- prueba_df %>% toJSON()
# 
# prediccion_prueba(pruebaJSON)
# 
# prediccion_prueba(pruebaJSON)

#prediccion_prueba()
