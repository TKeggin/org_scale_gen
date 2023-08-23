#
# calculate weighted endemism from a species and a landscape object (Crisp et al 2001)
# requires speciesRange(), speciesPresent()
# returns a vector of weighted endemism (richness/total species ranges)
# Thomas Keggin
#

endemismWeighted <- function(richness, pa_dataframe, landscape){
  
  species_range   <- speciesRange(pa_dataframe) # find range size for each species
  species_present <- speciesPresent(pa_dataframe) # find which species are present in each cell
  
  names(species_present) <- rownames(pa_dataframe)
  
  # find total range size for each cell
  range_total <- c()
  for(cell in rownames(landscape$coordinates)){
    
    cell_range <- sum(species_range[species_present[[cell]]$speciesID])
    
    range_total <- c(range_total,cell_range)
  }
  names(range_total) <- rownames(landscape$coordinates)
  
  endemism_weighted <- richness/range_total # species richness / total range
  
  return(endemism_weighted)
}
