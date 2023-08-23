
######################################
###            METADATA            ###
######################################
# Version: 1.3
#
# Author: Thomas Keggin
#
# Date: 17.08.2021
#
# Landscape: 2021_1d_17c_2000m
#
# Publications: NA
#
# Description: parameter exploration of marine diversification using the full range of functions
#
######################################


# config generator parameters ####
t_opt             <- params$t_opt
dispRange         <- params$dispRange
speciation        <- params$speciation
seed              <- params$seed
start             <- NA
initialAbundance  <- params$initialAbundance
mutationRate      <- params$mutationRate
n_width           <- params$n_width

########################
### General settings ###
########################
# set the random seed for the simulation
random_seed = seed

# set the starting time step or leave NA to use the earliest/highest timestep
start_time = start

# set the end time step or leave as NA to use the lates/lowest timestep (0)
end_time = NA

# maximum total number of species in the simulation before it is aborted
max_number_of_species = 15000

# maximum number of species within one cell before the simulation is aborted
max_number_of_coexisting_species = 1e6

# a list of traits to include with each species
# a "dispersion" trait is implictly added in any case
#trait_names = c("t_opt", "a_min", "competition", "dispersion")
trait_names = c("dispersal",
                "t_opt",
                "niche",
                "n_width",
                "neutral_1",
                "neutral_2",
                "neutral_3",
                "neutral_4")

# ranges to scale the input environemts with:
# not listed variable:         no scaling takes place
# listed, set to NA:           the environmental variable will be scaled from [min, max] to [0, 1]
# lsited with a given range r: the environmental variable will be scaled from [r1, r2] to [0, 1]
environmental_ranges = list(temp = NA)

# a place to inspect the internal state of the simulation and collect additional information if desired
end_of_timestep_observer = function(data, vars, config){
  save_richness()
  save_landscape()
  save_species()
  save_abundance()
  save_traits()
  save_phylogeny()
  save_divergence()
}


######################
### Initialization ###
######################
# the intial abundace of a newly colonized cell, both during setup and later when colonizing a cell during the dispersal
initial_abundance = initialAbundance

# place species within rectangle:
create_ancestor_species <- function(landscape, config) {
  range <- c(-180, 180, -90, 90)
  co <- landscape$coordinates
  selection <- co[, "x"] >= range[1] &
    co[, "x"] <= range[2] &
    co[, "y"] >= range[3] &
    co[, "y"] <= range[4]
  initial_cells <- rownames(co)[selection]
  new_species <- create_species(initial_cells, config)
  new_species$traits[ , "dispersal"] <- 1
  new_species$traits[ , "t_opt"]     <- t_opt
  new_species$traits[ , "niche"]     <- 0.5
  new_species$traits[ , "n_width"]   <- n_width
  new_species$traits[ , "neutral_1"]   <- 0.5
  new_species$traits[ , "neutral_2"]   <- 0.5
  new_species$traits[ , "neutral_3"]   <- 0.5
  new_species$traits[ , "neutral_4"]   <- 0.5
  return(list(new_species))
  
}


#################
### Dispersal ###
#################
# returns n dispersal values
get_dispersal_values <- function(num_draws, species, landscape, config) {
  dispersal_range = c(0, dispRange)
  disp_factor <- 1
  scale <- ((dispersal_range[2] - dispersal_range[1]) * disp_factor ) + dispersal_range[1]
  values <- rweibull(num_draws, shape = 2.5, scale = scale) # 2.5
  
  return(values)
}


##################
### Speciation ###
##################
# threshold for genetic distance after which a speciation event takes place
# speciation after every timestep : 0.9
divergence_threshold = speciation

# factor by which the genetic distance is increased between geographically isolated population of a species
# can also be a matrix between the different population clusters
get_divergence_factor <- function(species, cluster_indices, landscape, config) {
  return(1)
}


################
### Mutation ###
################
# mutate the traits of a species and return the new traits matrix
apply_evolution <- function(species, cluster_indices, landscape, config){
  
  traits <- species[["traits"]]
  
  # mutate traits randomly
  traits[,"t_opt"]     <- c(traits[,"t_opt"]) + rnorm(length(c(traits[,"t_opt"])), mean=0,sd=mutationRate)
  traits[,"niche"]     <- c(traits[,"niche"]) + rnorm(length(c(traits[,"niche"])), mean=0,sd=mutationRate)
  traits[,"neutral_1"] <- c(traits[,"neutral_1"]) + rnorm(length(c(traits[,"neutral_1"])), mean=0,sd=mutationRate)
  traits[,"neutral_2"] <- c(traits[,"neutral_2"]) + rnorm(length(c(traits[,"neutral_2"])), mean=0,sd=mutationRate)
  traits[,"neutral_3"] <- c(traits[,"neutral_3"]) + rnorm(length(c(traits[,"neutral_3"])), mean=0,sd=mutationRate)
  traits[,"neutral_4"] <- c(traits[,"neutral_4"]) + rnorm(length(c(traits[,"neutral_4"])), mean=0,sd=mutationRate)
  
  # homogenise traits by geographic cluster
  t_means  <- by(traits[,"t_opt"], cluster_indices, mean)     # temp mean of each cluster
  n_means  <- by(traits[,"niche"], cluster_indices, mean)     # niche mean of each cluster
  n1_means <- by(traits[,"neutral_1"], cluster_indices, mean) # neutral mean of each cluster
  n2_means <- by(traits[,"neutral_2"], cluster_indices, mean) # neutral mean of each cluster
  n3_means <- by(traits[,"neutral_3"], cluster_indices, mean) # neutral mean of each cluster
  n4_means <- by(traits[,"neutral_4"], cluster_indices, mean) # neutral mean of each cluster
  
  for(x in unique(cluster_indices)){
    traits[,"t_opt"][cluster_indices == x]     <- t_means[as.character(x)]  # replace t_opt values with means of each cluster
    traits[,"niche"][cluster_indices == x]     <- n_means[as.character(x)]  # replace niche values with means of each cluster
    traits[,"neutral_1"][cluster_indices == x] <- n1_means[as.character(x)] # replace niche values with means of each cluster
    traits[,"neutral_2"][cluster_indices == x] <- n2_means[as.character(x)] # replace niche values with means of each cluster
    traits[,"neutral_3"][cluster_indices == x] <- n3_means[as.character(x)] # replace niche values with means of each cluster
    traits[,"neutral_4"][cluster_indices == x] <- n4_means[as.character(x)] # replace niche values with means of each cluster
  }
  return(traits)
}


###############
### Ecology ###
###############
# called for every cell with all occuring species, this function calculates who survives in the current cells
# returns a vector of abundances
# set the abundance to 0 for every species supposed to die
apply_ecology <- function(abundance, traits, local_environment, config) {

  # temperature suitability ####
  t_sp     <- traits[,"t_opt"]                          # species temp
  t_env    <- local_environment[,"temp"]                # environmental temp
  opt      <- dnorm(t_sp, mean = t_sp, sd = 0.18)          # find the maximum value (when the species perfectly matches the environment) - sd of 0.18 ~ sd of 2C.
  abd_temp <- (abundance/opt)*dnorm(t_sp, mean = t_env, sd = 0.18) # find the difference and normalise to 0-100
  
  # competition ####
  niche_comp    <- c() # nice vector house to put the competitive penalties in
  niche_trans   <- c() # same as above, but for the transgressions
  niche_trait   <- traits[,"niche"]
  niche_width   <- traits[,"n_width"]
  
  # loop to calculate competition for each species in a cell
  for(i in 1:length(niche_trait)){
    sp_i        <- niche_trait[i] # niche trait of the species
    comp_range  <- c(sp_i-niche_width[i],sp_i+niche_width[i]) # find the range of competition
    abd_comp    <- abd_temp[niche_trait>comp_range[1] & niche_trait<comp_range[2]] # the abundances of the competing species
    comp_i      <- abd_temp[i]/sum(abd_comp) # competitive penalty is the proportion of abundance that species has in the competitive space

    # proportion out-of-bounds (assuming niche space is 0-1)
    if(comp_range[2] > 1){
      trans         <- comp_range[2]-1
      trans_penalty <- trans/(comp_range[2]-comp_range[1])
    } else {if(comp_range[1] < 0){
      trans         <- -comp_range[1]
      trans_penalty <- trans/(comp_range[2]-comp_range[1])
    } else {
      trans_penalty <- 0
    }}
    
    niche_trans <- c(niche_trans, trans_penalty) # store transgression in the trans vector
    niche_comp  <- c(niche_comp,comp_i)          # store penalty in the penalty vector
  }
  
  # calculate abundance ####
  abd_comp <- abd_temp*(1-niche_trans) # apply transgression penalty
  abd_comp <- abd_comp*niche_comp      # apply competition penalty
  abd_comp <- ifelse(abd_comp < 0.1, 0, abd_comp) # drive to extinction if under 0.1
  
  return(abd_comp)
}




