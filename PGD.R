library(keras)
library(tidyverse)
library(tensorflow)
library(imager)

#define PGD attack 
pgdAttack <- function(image, class, model, epsilon, budget, iter) {
  #loss function
  loss <- function(image) {
    K$binary_crossentropy(class, model(image)$predictions)
  }
   
  #perturbation constraint 
  perturbCon <- function(adv, image, epsilon) {
    pmin(pmax(adv, image - epsilon), image + epsilon)
  }
  
  #PGD attack
  for (i in iter) {
    grad <- K$gradients(loss(image), image)$value #compute the gradient of input image
    perturb <- step * sign(grad) #compute the perturbation vector
    
    image <- image + perturbCon(image + perturb, image) #apply perturbation
    image <- pmin(pmax(image, 0), 1) #clip pixel values to [0, 1] range
  }

  advImage <- array_reshape(image * 255, dim(image))
  advImage <- as.im(advImage)
  
  return(advImage)
}


