#
# calculate cluster divergence per cell from a presence/absence dataframe
# returns a vector of the means of all divergences of each species present in a cell
# dependent on speciesPresent() and speciesDivergence
# Thomas Keggin
#

clusterDivergenceCell <- function(pa_dataframe,species,landscape){
  
  # find species present in each cell
  species_present <- speciesPresent(pa_dataframe)
  
  # calculate average divergence per species (~ global Fst)
  species_divergence <- speciesDivergence(species)
  
  # determine the average divergence per cell
  no_cells           <- dim(landscape$coordinates)[1] # number of cells
  cluster_divergence <- c()
  for(i in 1:no_cells){
    
    x <- mean(species_divergence[species_present[[i]]$speciesID]) # for all the species in a cell, mean their divergences
    cluster_divergence <- c(cluster_divergence,x)
  }

  return(cluster_divergence_cell)
}
