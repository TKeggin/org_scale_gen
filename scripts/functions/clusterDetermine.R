#
# determines geographic cluster identity based on geographic distance matrix and dispersal distance
# outputs the species object with an appended populations vector
# relies on gen3sis
# Thomas Keggin
#

clusterDetermine <- function(dispRange, distance_matrix, species){
  
  cluster_determine   <- species
  species_alive       <- 1:length(cluster_determine)
  
  for(s in species_alive){
    
    sp <- cluster_determine[[s]]
    
    # subset landscape cells to those occupied
    occupied_cells  <- names(sp$abundance)
    
    distance_subset <- as.matrix(distance_matrix[occupied_cells,occupied_cells])
    
    clusters        <- gen3sis:::Tdbscan(distance_subset,dispRange,1)
    names(clusters) <- occupied_cells

    cluster_determine[[s]]$populations <- clusters
  }
  
  return(cluster_determine)
}
