#
# calculate trait variance per species
# returns a vector of the mean trait variance of each species
# Thomas Keggin
#


traitVarianceSpecies <- function(species,trait){
  
  # calculate average trait variance per species
  trait_variance <- c()
  for(sp in 1:length(species)){
    
    # calculate metrics per species (each datum is a cell)
    trait_values <- species[[sp]]$traits[,trait]
    variance <- var(trait_values)
    
    trait_variance <- c(trait_variance,variance)
    
  }
  names(trait_variance) <- 1:length(species)
  
  return(trait_variance_species)
}
