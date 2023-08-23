#
# calculate trait vector
# outputs a species ID named vector of trait values 
# Thomas Keggin
#


traitValuesSpecies <- function(species,trait){
  
  # create vector of all trait values
  trait_vector <- c()
  for(sp in 1:length(species)){
    x            <- species[[sp]]$traits[,paste0(trait)]
    y            <- length(x)
    if(y>0){names(x) <- rep(species[[sp]]$id,y)}
    trait_vector <- c(trait_vector,x)
  }
  
  return(trait_vector)
  
}
