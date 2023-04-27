#library(imager)
#library(tidyverse)
#library(torch)
#library(tensorflow)
#install_tensorflow(extra_packages="pillow")
#library(torchvision)
#library(keras)
#library(reticulate)

#convert keras model to torch 
modelpy <- import("torch")
model <- keras_to_pytorch(model, modelpy)
alpha <- budgetRatio
#convert image to torch
imageTensor <- torchvision::transforms::ToTensor()(image)
image <- torch::unsqueeze(image_tensor, 1)

#create BIM attack function
bimAttack <- function(model, image, epslion, alpha, iter){
  model$eval() #set model to evaluation mode
  imageTensor <- torch_tensor(image, dtype=torch_float())$unsqueeze(0) #convert image to tensor
  criterion <- nn_cross_entropy_loss() #define criterion
  optimizer <- optim_sgd(0.1) #define optimizer
  
  for(i in 1:iter){
    #add criterion to a copy of the image
    advImage <- imageTensor$clone()$detach()$requires_grad_(TRUE)
    advImage <- advImage + epsilon * sign(grad(criterion(model(advImage), torch_tensor(0, dtype=torch_long())))[[1]])
    advImage <- advImage$clamp(imageTensor - alpha, imageTensor + alpha)$clamp(0, 1)
    
    #perform backward pass
    optimizer$zero_grad()
    loss <- criterion(model(advImage), torch_tensor(0, dtype=torch_long()))
    loss$backward()
    optimizer$step()
  }
  
  advImage <- advImage$cpu()$detach()$numpy()[[1]] #convert back to image
  return(advImage)
}

ensemble <- function(model, image, budget, attacks, weights){
  numPixels <- round(budget * prod(dim(image))) #convert pixel budget to a number
  perturbations <- matrix(0, dim(image)) #store the adversarial perturbations
  
  for (i in seq_along(attacks)){
    numAttackPixels <- round(weights[i] * numPixels) #number of pixel to use based on weight
    
    #apply attack
    perturbations <- perturbations + bimAttack(model, image + perturbations, epsilon=0.1, alpha=0.01, iter=10) * numAttackPixels
  }
  
  perturbations <- pmin(pmax(perturbations, -budget), budget) #clip to make sure fall in budget
  advImage <- pmin(pmax(image + perturbations, 0), 1) #generate the adversarial image 
  
  return(advImage)
}
