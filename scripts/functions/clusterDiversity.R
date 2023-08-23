#
# calculate cluster diversity per cell from a presence/absence dataframe
# returns a vector of the sums of all the clusters (across their range) of each species present in a cell
# dependent on speciesPresent()
# Thomas Keggin
#

clusterDiversity <- function(pa_dataframe, clusters_total){
  
  species_present <- speciesPresent(pa_dataframe)
  
  # determine the number of clusters each species has that is present in a cell
  no_cells          <- dim(pa_dataframe)[1] # number of cells
  cluster_diversity <- c()
  for(i in 1:no_cells){
    
    x <- mean(clusters_total[species_present[[i]]$speciesID]) # for all the species in a cell, sum up their numbers of clusters
    cluster_diversity <- c(cluster_diversity,x)
  }
  cluster_diversity[cluster_diversity == 0] <- NA
  return(cluster_diversity)
}