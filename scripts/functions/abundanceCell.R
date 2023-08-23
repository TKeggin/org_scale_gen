#
# calculate the total of each cell
# returns a vector of abundances per cell
# Thomas Keggin
#

abundanceCell <- function(species){
  abundance <- c()
  for(sp in 1:length(species)){
    x        <- species[[sp]]$abundance
    abundance <- c(abundance,x)
  }
  
  # sum abundance per cell
  abundance_cell <- tapply(abundance,names(abundance),sum)
  
  return(abundance_cell)
}
