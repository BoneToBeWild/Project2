#install.packages("imager")
#install.packages("tidyverse")
#install.packages("torch")
#install.packages("torchvision")
#install.packages("tensorflow")
#install.packages("keras")
#install.packages("reticulate")
library(imager)
library(tidyverse)
library(torch)
library(tensorflow)
install_tensorflow(extra_packages="pillow")
library(torchvision)
library(keras)
library(reticulate)

setwd("C:/Purdue/IE 332")

model <- load_model_tf("/home/jupyter/332_data/dandelion_model")

width <- 224
height<- 224
target_size <- c(width, height)
rgb <- 3

gu = list.files("/home/jupyter/332_data/data-for-332/grass")
du = list.files("/home/jupyter/332_data/data-for-332/dandelions")

guFile <- "/home/jupyter/332_data/data-for-332/grass"
duFile <- "/home/jupyter/332_data/data-for-332/dandelions"
guAdvFile <- "/home/jupyter/332_data/data-for-332/advgrass"
duAdvFile <- "/home/jupyter/332_data/data-for-332/advdandelions"

for (i in gu){
  test_image <- image_load(paste("/home/jupyter/332_data/data-for-332/grass/",i,sep=""),
                           target_size = target_size)
  imageGrass <- image_to_array(test_image)
  imageGrass <- array_reshape(imageGrass, c(1, dim(imageGrass)))
  imageGrass <- imageGrass/255
  pred <- model %>% predict(x)
}

#define variables
iter <- 10
step <- 2/255
epsilon <- 8/255
budgetRatio <- 0.01
budget <- ceiling(prod(dim(image)) * budgetRatio)

#run FGSM
#calculate performance
countFGSM <- 0
#delete adv images

#run BIM
source('/home/jupyter/BIM.R')
#perform attack
for(i in gu){
  advImage <- bimAttack(model, imageGrass, epsilon, budget, iter) #run BIM attack
  save.image(advImage, file.path(guAdvFile, paste0(i, "_adv.png")))
}

#calculate performance
countBIM <- 0
gm <- list.files("/home/jupyter/332_data/data-for-332/advgrass")
for (i in gm){
  test_image <- image_load(paste("/home/jupyter/332_data/data-for-332/advgrass/",i,sep=""),
                           target_size = target_size)
  x <- image_to_array(test_image)
  x <- array_reshape(x, c(1, dim(x)))
  x <- x/255
  pred <- model %>% predict(x)
  if(pred[1,2]<0.50){
    countBIM <- countBIM + 1
    print(i)
  }
}
#deleate adv images
fileList <- list.files(guAdvFile, pattern = "\\.(png|jpe?g)$", full.names = TRUE)
for (file in fileList) {
  unlink(file)
}

#run DF
#calculate performance
countDF <- 0
#delete adv images

#run CW
#calculate performance
countCW <- 0 
#delete adv images

#run PGD
class <- pred
source('/home/jupyter/PGD.R')
#perform attack
for (i in gu) {
  advImage <- pgdAttack(image, class, model, epsilon, budget, iter) #apply PGD attack to test image
  save.image(advImage, file.path(guAdvFile, paste0(i, "_adv.png")))#save modified image
}

#calculate performance
countPGD <- 0
gm <- list.files("/home/jupyter/332_data/data-for-332/advgrass")
for (i in gm){
  test_image <- image_load(paste("/home/jupyter/332_data/data-for-332/advgrass/",i,sep=""),
                           target_size = target_size)
  x <- image_to_array(test_image)
  x <- array_reshape(x, c(1, dim(x)))
  x <- x/255
  pred <- model %>% predict(x)
  if(pred[1,2]<0.50){
    countBIM <- countBIM + 1
    print(i)
  }
}

#deleate adv images
fileList <- list.files(guAdvFile, pattern = "\\.(png|jpe?g)$", full.names = TRUE)
for (file in fileList) {
  unlink(file)
}

iter <- 20
countFGSM <- 100
countDF <- 100
countCW <- 100
if (countFGSM <= countBIM & countFGSM <= countDF & countFGSM <= countCW & countFSGM <= countPGD) {
  #run FGSM 
} else if (countBIM <= countDF & countBIM <= countCW & countBIM <= countPGD) {
  #run BIM 
  for(i in gu){
    advImage <- bimAttack(model, imageGrass, epsilon, budget, iter) #run BIM attack
    save.image(advImage, file.path(guAdvFile, paste0(i, "_adv.png")))
  }
} else if (countDF <= countCW & countDF <= countPGD) {
  #run DF
} else if (countCW <= countPGD) {
  #run CW
} else {
  #run PGD
  for (i in gu) {
    advImage <- pgdAttack(image, class, model, epsilon, budget, iter) #apply PGD attack to test image
    save.image(advImage, file.path(guAdvFile, paste0(i, "_adv.png")))#save modified image
  }
}
