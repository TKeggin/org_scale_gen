#
# calculate trait and abundance per species
# outputs a data frame of trait and abundance values
# Thomas Keggin
#


traitValuesAbdSpecies <- function(species,landscape,trait){
  
  # create vector of all trait values
  sp_id        <- c()
  trait_vector <- c()
  abd_vector   <- c()
  
  for(sp in 1:length(species)){
    x            <- species[[sp]]$traits[,paste0(trait)]
    y            <- length(x)
    trait_vector <- c(trait_vector,x)
    
    if(y>0){
      s     <- rep(species[[sp]]$id,y)
      sp_id <- c(sp_id,s)
      }
    
    a            <- species[[sp]]$abundance
    abd_vector   <- c(abd_vector,a)
  }
  
  trait_abd_df <- data.frame(sp_id,trait_vector,abd_vector)
  
  return(trait_abd_df)
  
}
