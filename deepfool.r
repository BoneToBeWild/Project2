library(tidyverse)
library(keras)
library(tensorflow)
library(reticulate)
library(deeplearning)

# Given trained model
model <- load_model_tf("/home/jupyter/332_data/dandelion_model")

# Image size
target_size <- c(224, 224)

# DeepFool parameters
max_iter <- 50
epsilon <- 0.02

# Define a function perform DeepFool on image
deepfool_attack <- function(image_array, model) {
  # Convert image to tensor
  image_tensor <- array_reshape(image_array, c(1, dim(image_array)))
  image_tensor <- image_tensor / 255
  
  # Perform DeepFool
  result <- deepfool(image_tensor, model, max_iter = max_iter, epsilon = epsilon)
  
  # Convert result back to array
  result_array <- array_reshape(result, dim(image_array))
  result_array <- result_array * 255
  
  # Return perturbed image array
  return(result_array)
}

# Define function to load and preprocess image
load_image <- function(image_path) {
  test_image <- image_load(image_path, target_size = target_size)
  image_array <- image_to_array(test_image)
  return(image_array)
}

# Perform DeepFool on grass images
f <- list.files("./grass")
for (i in f) {
  image_path <- paste("./grass/", i, sep = "")
  image_array <- load_image(image_path)
  perturbed_array <- deepfool_attack(image_array, model)
  pred <- model %>% predict(array_reshape(perturbed_array, c(1, dim(perturbed_array)) / 255))
  if (pred[1, 2] < 0.5) {
    print(i)
  }
}

# Perform DeepFool on dandelion images
f <- list.files("./dandelions")
for (i in f) {
  image_path <- paste("./dandelions/", i, sep = "")
  image_array <- load_image(image_path)
  perturbed_array <- deepfool_attack(image_array, model)
  pred <- model %>% predict(array_reshape(perturbed_array, c(1, dim(perturbed_array)) / 255))
  if (pred[1, 1] < 0.5) {
    print(i)
  }
}
