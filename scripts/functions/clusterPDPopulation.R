#
# calculate population PD within a species
# returns a PD value for a single species
# dependent on species edited by clusterDetermine()
# requires picante
# requires tidyr
# Thomas Keggin
#

# find pd instead of mean divergence -------------------------------------------

clusterPDPopulation <- function(species_single){
  
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
    cluster_PD_population <- 0
  } else {
    
    # find all comparisons
    comparisons <- expand.grid(populations,
                               populations)
    
    # find mean divergence between geographic populations
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
    
    # create population distance matrix
    comparisons <- as.data.frame(comparisons)
    comparisons$divergence <- population_divergences
    
    div_mat <- comparisons %>% 
      pivot_wider(names_from = Var1,
                  values_from = divergence) %>% 
      column_to_rownames(var="Var2") %>% 
      as.matrix %>% 
      as.dist
    
    # create phylogeny
    pop_phylo <- as.phylo(hclust(div_mat))
    
    
    # create dummy community matrix
    com_mat <- matrix(1,ncol = length(pop_phylo$tip.label))
    colnames(com_mat) <- 1:length(pop_phylo$tip.label)
    
    # calculate pd
    cluster_PD_population <- pd(com_mat,pop_phylo)[,1]
  }
  
  

  return(cluster_PD_population)
}

