#
# calculate mean cluster divergence of all surviving species
# returns a single mean value
# requires population object be added by clusterDetermine()
# requires clusterDivergencePopulation()
# requires gtools
# Thomas Keggin
#


clusterDivergenceSim <- function(species,species_extant){
  
  div_pop <- c()
  
  for(sp in as.numeric(species_extant)){
    
    div_pop <- c(div_pop, mean(clusterDivergencePopulation(species[[sp]])))
    
  }
  
  return(div_pop)
}

clusterDivergenceSim <- function(species){
  
  div_pop <- c()
  
  for(sp in 1:length(species)){
    
    div_pop <- c(div_pop, mean(clusterDivergencePopulation(species[[sp]])))
    
  }
  
  return(div_pop)
}
