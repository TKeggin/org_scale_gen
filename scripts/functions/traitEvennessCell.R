#
# calculate trait and evenness per cell (functional evenness, sensu Mouillot et al. (2005))
# outputs a data frame of cell IDs and 
# relies on traitValuesAbdCell.R and dplyr
# Thomas Keggin
#

traitEvennessCell <- function(species,trait){
  
  
  trait_values <- traitValuesAbdCell(species,trait)
  
  cells    <- unique(trait_values$cell_id) # vector of cell IDs
  evenness <- c()
  for(cell in cells){
    
    cell_data <- trait_values %>% filter(cell_id == cell) # test values
    cell_data <- arrange(cell_data, trait_vector) # arrange by trait values
    
    # find sum of all trait and abundance values (sum EW)
    EW <- c()
    for(i in 1:dim(cell_data)[1]-1){
      
      x  <- (cell_data$trait_vector[i+1]-cell_data$trait_vector[i]) / (cell_data$abd_vector[i+1]+cell_data$trait_vector[i])
      EW <- c(EW,x)
    }
    sum_EW <- sum(EW) # the bottom of the equation
    
    
    # find species_value
    species_values <- c()
    for(i in 1:dim(cell_data)[1]-1){
      
      top <- (cell_data$trait_vector[i+1]-cell_data$trait_vector[i]) / (cell_data$abd_vector[i+1]+cell_data$trait_vector[i])
      PEW <- top/sum_EW
      
      default <- 1/(dim(cell_data)[1]-1) # find default (1 / Sc - 1)
      
      species_values <- c(species_values,min(PEW,default))
    }
    
    # find evenness
    evenness <- c(evenness,sum(species_values))
  }
  
  trait_evenness <- evenness
  names(trait_evenness) <- cells
  
  return(trait_evenness)
}




