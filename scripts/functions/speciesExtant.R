#
# identify extant species from a species object
# returns a vector of species IDs
# Thomas Keggin
#

speciesExtant <- function(species){
  
  species_extant <- c()
  
  for(sp in 1:length(species)){
    if(length(species[[sp]]$abundance) > 0){
      #species_extant <- c(species_extant,species[[sp]]$id)
      species_extant <- c(species_extant,as.numeric(species[[sp]]$id))
    }
  }
  
  return(species_extant)
}
