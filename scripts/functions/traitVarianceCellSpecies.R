#
# calculate trait cell variance per cell from a presence/absence dataframe
# returns a vector of the means of all trait variances of each species present in a cell
# similar to the cluster_ functions
# dependent on speciesPresent() and traitVariance()
# Thomas Keggin
#

traitVarianceCellSpecies <- function(pa_dataframe,species,landscape,trait){
  
  # find species present in each cell
  species_present <- speciesPresent(pa_dataframe)
  
  # calculate variance per species
  trait_variance <- traitVariance(species,"niche")
  
  # determine the average variance of all the species present in a cell
  no_cells           <- dim(landscape$coordinates)[1] # number of cells
  trait_variance_cell <- c()
  for(i in 1:no_cells){
    
    # for all the species in a cell, mean their variances
    x <- mean(trait_variance[species_present[[i]]$speciesID])
    trait_variance_cell <- c(trait_variance_cell,x)
  }
  names(trait_variance_cell) <- rownames(landscape$coordinates)
  
  return(trait_variance_cell_species)
}


