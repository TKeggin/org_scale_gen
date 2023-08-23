#
# calculate population divergences within a species
# returns a vector of the means of all divergences between all populations in a single species
# dependent on species edited by clusterDetermine()
# requires gtools
# Thomas Keggin
#

# find pd instead of mean divergence -------------------------------------------

clusterDivergencePopulation <- function(species_single){
  
  # check if there is a population object
  if(is.null(species_single$populations)){
    print("No populations found in species object.")
    stop()
  }
  
  # decompress divergence matrices
  decompressed <- species_single$divergence$compressed_matrix[as.character(species_single$divergence$index),
                                                                   as.character(species_single$divergence$index),
                                                                   drop = F]
  
  #decompressed <- get_divergence_matrix(species_single) # this doesn't work when there is no differentiation
  
  cell_ids <- names(species_single$divergence$index)
  dimnames(decompressed) <- list(cell_ids,cell_ids)
  
  
  # find mean of each interpopulation comparison
  # find population IDs
  populations <- unique(species_single$populations)
  
  # find mean of each comparison
  population_divergences <- c()
  
  # set mean to 0 if there are no comparisons
  if(length(populations) < 2){
    population_divergences <- c(population_divergences,0)
  } else {
    
    # find all comparisons
    comparisons <- combinations(n = length(populations),
                                r = 2,
                                v = populations)

    for(comp in 1:dim(comparisons)[1]){
      
      pop_a <- comparisons[comp,1] # first pop id
      pop_b <- comparisons[comp,2] # second pop id
      
      pop_all <- species_single$populations # all population ids
      
      # subset cells by populations
      pop_a_cells <- names(pop_all[pop_all == pop_a])
      pop_b_cells <- names(pop_all[pop_all == pop_b])
      
      decompressed_subset <- as.matrix(decompressed[pop_a_cells,pop_b_cells]) # create asymmetrical distance matrix
      
      comparison_mean <- mean(decompressed_subset)
      
      population_divergences <- c(population_divergences,comparison_mean)
    }
  }
  
  cluster_divergence_population <- population_divergences

  return(cluster_divergence_population)
}

