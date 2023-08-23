#
# calculate the phylogenetic diversity per cell
# outputs a
# requires the phyloMeasures package
# Thomas Keggin
#

phyloFaith <- function(pa_dataframe, phylo){

  # create community matrix for pd calculation (cells x species)
  pa_matrix <- as.matrix(pa_dataframe[,-c(1,2)])
  
  # match the pa_matrix column names to the phy species naming format (1..n to species1...speciesn)
  colnames(pa_matrix) <- paste("species",colnames(pa_matrix), sep = "")
  
  phy_faith <- pd.query(phylo,pa_matrix)
  names(phy_faith) <- rownames(pa_dataframe)
  
  return(phy_faith)
}
