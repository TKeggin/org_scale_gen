#
# creates a subset of extant species from a species object
# returns a vector of species IDs
# Thomas Keggin
#

speciesSubsetIndex <- function(species){
  
  species_subset_index <- c()
  for(sp in 1:length(species)){
    
    if(length(species[[sp]]$abundance) != 0){
      species_subset_index <- c(species_subset_index,
                                species[[sp]]$id)
    }
  }
  
  return(species_subset_index)
}
