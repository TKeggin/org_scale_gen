#
# make a list of the species present from each cell from a landscape and a species object
# returns a list of cells with their constituent species
# Thomas Keggin
#


speciesPresent <- function(pa_dataframe){
  no_cells        <- dim(pa_dataframe)[1] # number of cells
  species_present <- list() # create a list to store cell species lists
  pa_dataframe <- as.matrix(pa_dataframe)
  for(i in 1:no_cells){
    cell <- which(pa_dataframe[i,] == 1)-2 # retrieve species IDs for each cell
    species_present[[i]] <- list(cellID   = rownames(pa_dataframe)[i], # store cell ID
                                 speciesID = cell) # store vector of species IDs
  }
  return(species_present)
}

# this original version is super slow as it uses a dataframe. It is benig kept as the new
# version outputs the same, but the speciesID vectors are named. It shouldn't matter though.
speciesPresent_original <- function(pa_dataframe){
  no_cells        <- dim(pa_dataframe)[1] # number of cells
  species_present <- list() # create a list to store cell species lists
  for(i in 1:no_cells){
    cell <- which(pa_dataframe[i,] == 1)-2 # retrieve species IDs for each cell
    species_present[[i]] <- list(cellID   = rownames(pa_dataframe)[i], # store cell ID
                                 speciesID = cell) # store vector of species IDs
  }
  
  return(species_present)
}

