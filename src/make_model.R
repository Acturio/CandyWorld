# load the dataset
dataset <- iris

# create the model
model <- lm(Petal.Length ~ Petal.Width + Sepal.Width, data = dataset)

# # example: run the model once
#prediction_data <- data.frame(Petal.Width=1, Sepal.Width=1)
#predict(model,prediction_data)
