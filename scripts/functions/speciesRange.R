#
# find the range of each species from a pa_dataframe
# returns a vector of species ranges as cell counts
# Thomas Keggin
#

speciesRange <- function(pa_dataframe){
  
  species_range <- colSums(data.frame(pa_dataframe[,-c(1,2)]))
  names(species_range) <- colnames(pa_dataframe)[-c(1,2)]
  return(species_range)
}
