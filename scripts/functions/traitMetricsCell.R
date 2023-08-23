#
# calculates trait metrics per cell
# requires tidyverse
# outputs a data frame of trait metrics
# Thomas Keggin
#


traitMetricsCell <- function(species,landscape,trait){
  
  # create vector of all trait values
  trait_vector <- c()
  for(sp in 1:length(species)){
    x            <- species[[sp]]$traits[,paste0(trait)]
    trait_vector <- c(trait_vector,x)
  }
  
  # create a data frame of trait values and their associated cell ID
  trait_df           <- data.frame(names(trait_vector),trait_vector)
  colnames(trait_df) <- c("cell","trait")
  
  # calculate trait metrics per cell
  trait_mean   <- trait_df %>% group_by(cell) %>% summarise(mean = mean(trait))
  trait_min    <- trait_df %>% group_by(cell) %>% summarise(min  = min(trait))
  trait_max    <- trait_df %>% group_by(cell) %>% summarise(max  = max(trait))
  trait_sd     <- trait_df %>% group_by(cell) %>% summarise(sd   = sd(trait))
  
  # amalgamate into a data frame
  trait_df       <- trait_mean
  trait_df$min   <- trait_min$min
  trait_df$max   <- trait_max$max
  trait_df$range <- trait_df$max - trait_df$min
  trait_df$sd    <- trait_sd$sd
  
  columns            <- paste0(trait,c(".mean",".min",".max",".range",".sd"), sep="")
  colnames(trait_df) <- c("cell",columns)
  
  # add coordinate data to each cell
  coords_trait <- data.frame(rownames(landscape$coordinates), landscape$coordinates)
  colnames(coords_trait) <- c("cell","x","y")
  
  trait_metrics <- left_join(coords_trait,trait_df)
  
  return(trait_metrics)

}
