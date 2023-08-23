#
# calculate trait vector
# outputs a cell ID named vector of trait values 
# Thomas Keggin
#


traitValuesCell <- function(species,trait){
  
  # create vector of all trait values
  trait_vector <- c()
  for(sp in 1:length(species)){
    x            <- species[[sp]]$traits[,paste0(trait)]
    trait_vector <- c(trait_vector,x)
  }
  
  return(trait_vector)

}
