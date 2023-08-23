#
# subsets a species object to contain only the clusters occurring in a set of cells
# returns a subset species object
# Thomas Keggin
#

speciesSubset <- function(species,cell_vector){
  
  species_subset <- species
  
  for(sp in 1:length(species)){
  # subset abundances
    species_subset[[sp]]$abundance <- subset(species_subset[[sp]]$abundance,
                                   names(species_subset[[sp]]$abundance) %in% cell_vector)
  
  # subset traits
    species_subset[[sp]]$traits <- subset(species_subset[[sp]]$traits,
                                rownames(species_subset[[sp]]$traits) %in% cell_vector)
  
  # subset divergence objects
  # index
    species_subset[[sp]]$divergence$index <- subset(species_subset[[sp]]$divergence$index,
                                         names(species_subset[[sp]]$divergence$index) %in% cell_vector)
  
  # compressed matrix
    species_subset[[sp]]$divergence$compressed_matrix <- subset(species_subset[[sp]]$divergence$compressed_matrix,
                                                     rownames(species_subset[[sp]]$divergence$compressed_matrix) %in%
                                                       unique(species_subset[[sp]]$divergence$index),
                                                     select = unique(species_subset[[sp]]$divergence$index))
  }
  
  return(species_subset) 
}
