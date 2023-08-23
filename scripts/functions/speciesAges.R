#
# calculates ages of all extant species
# returns a dataframe of extant species ages
# requires picante package
# requires speciesExtant
# Thomas Keggin
#

speciesAges <- function(phylo, species){
  
  # find extant species
  spp_extant <- speciesExtant(species)
  spp_extant <- paste0("species",spp_extant)
  
  phy_extant <- keep.tip(phylo,spp_extant)
  
  # taken from the simTree package
  species_ages<-data.frame(matrix(data=NA,nrow=length(phy_extant$tip.label),ncol=2))
  colnames(species_ages)<-c("species","age")
  max<-max(branching.times(phy_extant))
  for (j in 1:length(phy_extant$tip.label)){
    Spp<-phy_extant$tip.label[j]
    species_ages$age[j] <- phy_extant$edge.length[which.edge(phy_extant,Spp)]
    species_ages$species[j]<-Spp
  }
  
  return(species_ages)
  
}
