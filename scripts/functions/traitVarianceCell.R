#
# calculate trait variance per cell (ignores abundances)
# returns a vector of the mean trait variance of each cell
# Thomas Keggin
#


traitVarianceCell <- function(species,trait){
  
  trait_df <- traitValuesAbdCell(species,"t_opt") # return trait values
  cells    <- unique(trait_df$cell_id) # vector of cells
  cell_var <- c()
  
  for(cell in cells){
    
    cell_df  <- filter(trait_df, cell_id == cell) # filter for target cell
    c        <- var(cell_df$trait_vector) # find variance
    cell_var <- c(cell_var,c) # add to vector
  }
  
  names(cell_var) <- cells # assign cell names
  trait_variance_cell <- cell_var
  
  return(trait_variance_cell)
  
}
