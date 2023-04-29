library(imager)
library(keras)

#create BIM attack function
bimAttack <- function(model, image, epsilon, budget, iter){
  perturbation <- array(0, dim = dim(image))#define perturbation
  
  for(i in iter){
    gradient <- gradient(model, image) #find gradient
    gradientSign <- sign(gradient) #find sign of gradient
    perturbation <- perturbation + budget * gradientSign #update perturbation
    perturbation <- pmin(pmax(perturbation, -epsilon), epsilon) #clip perturbation 
    
    advImage <- image + perturbation #generate adversarial image
    advImage <- pmin(pmax(advImage, 0), 1) #clip adversarial image
    
  }
  return(advImage)
}
