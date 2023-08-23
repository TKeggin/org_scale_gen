#
# calculate trait and abundance per cell
# outputs a data frame of trait and abundance values
# Thomas Keggin
#


traitValuesAbdCell <- function(species,trait){
  
  # create vectors of all trait and abundance values
  cell_id      <- c()
  trait_vector <- c()
  abd_vector   <- c()
  
  for(sp in 1:length(species)){
    c            <- names(species[[sp]]$abundance)
    cell_id      <- c(cell_id,c)
    
    x            <- species[[sp]]$traits[,paste0(trait)]
    trait_vector <- c(trait_vector,x)
    
    a            <- species[[sp]]$abundance
    abd_vector   <- c(abd_vector,a)
  }
  
  trait_abd_df <- data.frame(cell_id,trait_vector,abd_vector)
  
  return(trait_abd_df)

}
