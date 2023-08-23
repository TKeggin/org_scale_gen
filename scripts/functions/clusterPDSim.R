#
# calculate the PD of all surviving species
# returns a single mean value
# requires population object be added by clusterDetermine()
# requires clusterDivergencePopulations()
# requires gtools
# Thomas Keggin
#


clusterPDSim <- function(species,species_extant){
  
  div_pop <- c()
  
  for(sp in as.numeric(species_extant)){
    
    div_pop <- c(div_pop, clusterPDPopulation(species[[sp]]))
    
  }
  
  return(div_pop)
}
  
  
clusterPDSim <- function(species){
  
  div_pop <- c()
  
  for(sp in 1:length(species)){
    
    div_pop <- c(div_pop, clusterPDPopulation(species[[sp]]))
    
  }
  
  return(div_pop)
}
