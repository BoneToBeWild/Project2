library(keras)
library(tidyverse)
library(tensorflow)
library(imager)

pgdAttack <- function(image, class, model, epsilon, alpha, iter) {
  x <- image_to_array(image)
  x <- array_reshape(x, c(1, dim(x)))
  x <- x/255
  
  #loss function
  loss <- function(x) {
    K$binary_crossentropy(class, model(x)$predictions)
  }
  
  #perturbation constraint 
  perturbCon <- function(x_adv, x, epsilon) {
    pmin(pmax(x_adv, x - epsilon), x + epsilon)
  }
  
  #PGD attack
  for (i in 1:iter) {
    grad <- K$gradients(loss(x), x)$value #compute the gradient of input image
    perturb <- step * sign(grad) #compute the perturbation vector
    
    x <- x + perturbCon(x + perturb, x) #apply perturbation
    x <- pmin(pmax(x, 0), 1) #clip pixel values to [0, 1] range
  }

  advImage <- array_reshape(x * 255, dim(image))
  advImage <- as.im(advImage)
  
  return(advImage)
}


