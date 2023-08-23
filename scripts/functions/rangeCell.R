#
# calculate the summed ranges of all species in a cell
# requires speciesRange()
# outputs a vector of cell ranges
# Thomas keggin
#

rangeCell <- function(pa_dataframe,landscape){
  
  # find species ranges
  species_range <- speciesRange(pa_dataframe)
  
  # find species present in each cell
  species_present <- speciesPresent(pa_dataframe)
  
  no_cells <- dim(landscape$coordinates)[1]
  range_cell <- c()
  
  for(i in 1:no_cells){
    
    # for all the species in a cell, sum their ranges
    x <- mean(species_range[species_present[[i]]$speciesID])
    range_cell <- c(range_cell,x)
  }
  names(range_cell) <- rownames(landscape$coordinates)
  
  return(range_cell)
  
}
