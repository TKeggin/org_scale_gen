#
# subsets a landscape object to contain only the clusters occurring in a set of cells
# returns a subset landscape object
# requires raster package
# cannot subset extent when there is only one cell
# Thomas Keggin
#

subsetLandscape <- function(landscape,cell_vector){
  
  subset_landscape <- landscape
  
  # environment
  subset_landscape$environment <- subset(landscape$environment,
                                         rownames(landscape$environment) %in% cell_vector)
  
  # coordinates
  subset_landscape$coordinates <- subset(landscape$coordinates,
                                         rownames(landscape$coordinates) %in% cell_vector)
  
  # extent
  #subset_landscape$extent <- extent(rasterFromXYZ(subset_landscape$coordinates))

  
  return(subset_landscape) 
}
