#
# calculate the mean phylogenetic diversity per simulation
# outputs a global simulation MPD value
# requires the phyloMeasures package
# Thomas Keggin
#

phyloDiversityMeanSim <- function(pa_dataframe, phylo){

  # create a presence/absence vector of extant species
  pa_vector <- colSums(pa_dataframe)
  pa_vector <- pa_vector[-c(1,2)]
  pa_vector[pa_vector > 0] <- 1
  
  # create a presence/absence community matrix where the community is the entire globe
  pa_matrix <- matrix(nrow = 1, ncol = length(pa_vector))
  pa_matrix[1,] <- pa_vector
  colnames(pa_matrix) <- paste0("species",names(pa_vector))
  rownames(pa_matrix) <- 1
  
  # calculate global MPD
  phylo_diversity_mean_sim <- mpd.query(phylo,pa_matrix)
  
  return(phylo_diversity_mean_sim)
}
