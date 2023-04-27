#install.packages("imager")
#install.packages("tidyverse")
#install.packages("torch")
#install.packages("torchvision")
#install.packages("tensorflow")
install.packages("keras")
install.packages("reticulate")
#library(imager)
#library(tidyverse)
#library(torch)
#library(tensorflow)
#install_tensorflow(extra_packages="pillow")
#library(torchvision)
library(keras)
library(reticulate)

setwd("C:/Purdue/IE 332")

model<-load_model_tf("./dandelion_model")
image <- image_load(paste("./grass/",i,sep=""),target_size = c(224,224))
budgetRatio <- 0.01
#for PGD
#class <- pred
#budget <- ceiling(prod(dim(image)) * budgetRatio)
#epsilon <- 8/255
#step <- 2/255
#iter <- 10
#for (i in gu) {
#  test_image <- image_load(paste("/home/jupyter/332_data/data-for-332/grass/",i,sep=""),
#                           target_size = target_size) #load test image
  
#  advImage <- pgdAttack(test_image, class, model, epsilon, step, iter) #apply PGD attack to test image
  
#  save_image(advImage, file.path("/home/jupyter/332_data/data-for-332/modified_grass/", paste0("modified_", image_files[i]))) #save modified image
#}

#source('FGSM.R')
source('C:/Purdue/IE 332/Project2/BIM.R')
#source('DF.R')
#source('PGD.R')
#source('CW.R')
