#
# subsets an input distance object using a cell id vector
# returns a subset distance matrix
# Thomas Keggin
#

distanceSubset <- function(distance_matrix, cell_vector){
  
  # convert cell ids to character to match matrix names
  cell_vector <- as.character(cell_vector)
  
  # subset the matrix
  distance_subset <- distance_matrix[cell_vector,cell_vector]
  
  return(distance_subset)
}

