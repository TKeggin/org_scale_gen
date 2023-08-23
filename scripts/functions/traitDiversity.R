#
# calculate trait diversity per cell (sensu Leps et al 2006)
# this is essentially variance, but scaled by abundances
# relies on traitValuesAbdCell.R
# returns a named vector of trait diversities
# Thomas Keggin
#


traitDiversity <- function(species,trait){
  
  trait_df <- traitValuesAbdCell(species,trait) # return trait values
  cells    <- unique(trait_df$cell_id)
  trait_diversity <- c()
  
  for(cell in cells){
    
    cell_values <- trait_df %>% filter(cell_id == cell) # filter out target cell
    trait_mean  <- mean(cell_values$trait_vector) # find mean trait value
    trait_dist  <- (cell_values$trait_vector - trait_mean)^2 # find distance from mean
    trait_abd   <- trait_dist*cell_values$abd_vector # multiply by abundance
    trait_abd   <- trait_abd/sum(cell_values$abd_vector) # divide by total abundance
    diversity   <- sum(trait_abd) # sum values
    
    trait_diversity <- c(trait_diversity,diversity)
  }
  
  names(trait_diversity) <- cells
  
  return(trait_diversity)

  
}











