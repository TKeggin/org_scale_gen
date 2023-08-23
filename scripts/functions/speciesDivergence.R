#
# calculate cluster divergence per species
# returns a vector of the mean divergence of each species
# Thomas Keggin
#


speciesDivergence <- function(species){
  
  # calculate average divergence per species (~ global Fst)
  species_divergence <- c()
  for(sp in 1:length(species)){
    
    divergence_matrix <- species[[i]]$divergence$compressed_matrix # compressed divergence object for only inter-cluster comparisons
    #mean_divergence <- sum(divergence_matrix)/(length(divergence_matrix)-dim(divergence_matrix)[1]) # mean divergence (remove self comparisons)
    mean_divergence <- mean(divergence_matrix[upper.tri(divergence_matrix, diag = FALSE)]) # mean divergence (remove self comparisons)
    species_divergence <- c(species_divergence,mean_divergence)
  }
  names(species_divergence) <- 1:length(species)
  
}
?gen3sis
