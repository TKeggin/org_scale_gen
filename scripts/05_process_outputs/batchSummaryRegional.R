#
# This script generates the per run summary metrics of a batch of simulations in an output folder
# Each metric is also calculated per ecoregion as defined by Spalding et al. 2007.
# Thomas Keggin (thomaskeggin@hotmail.com)
#

# set session ------------------------------------------------------------------
library(tidyverse)
library(gen3sis)
library(ape)
library(raster)
library(PhyloMeasures)
library(phyloregion)
library(gtools)
library(picante)

# load config details
config <- read_csv("./data_processed/configs/config_parameters.csv",
                   show_col_types = F)

# load regional data ----
region_id  <- read_csv("data_processed/ecoregions/01_region_ids.csv",
                       show_col_types = F)
reg_scales <- c(#"ECOREGION",
                #"PROVINCE",
                "REALM",
                "GLOBAL")

# load functions ----
path_function <- "./scripts/functions"
functions     <- list.files(path = path_function,pattern = ".R")
invisible(lapply(paste(path_function,functions,sep = "/"),source))

# set up true richness df for comparison ----
load("./data_external/albouy_2019/MatPa_Final_ok.rdata") # load gaspar richness data
MatPa_Final_ok$richness <- rowSums(MatPa_Final_ok[,-c(1,2)])

MatPa_Final_ok <- MatPa_Final_ok[,c("Longitude","Latitude","richness")]
rich <- filter(MatPa_Final_ok, richness > 1)
rm(MatPa_Final_ok)

# mask with input landscape.
land    <- readRDS("./data_processed/seascapes/landscapes.rds")$temp[,c(1,2,3)] # trim landscape
#land <- filter(land, land[,3] > 1)
land.raster <- rasterFromXYZ(land) # input raster
rich.raster <- rasterFromXYZ(rich) # richness raster
rich.raster <- resample(rich.raster,land.raster) # match extents
rich.masked <- mask(rich.raster, land.raster) # mask richness by the input

rich.true <- as.data.frame(rich.masked, xy = TRUE)

# create vectors ----
run_id <- c() # run ID

region.scale <- c() # the scale of the geographic subset according to Spalding et al.
region.id    <- c() # the id of the geographic subset according to Spalding et al.
region.size  <- c() # the number of gen3sis cells contained in geographic subset
region.dist  <- c() # the mean distance between connected habitable cells in geographic subset

timestep_final <- c() # the most recent timestep in the simulation

species.total <- c() # the total number of species in the entire simulation
species.surviving <- c() # number of extant species in geographic subset
species.mpd <- c() # the mean mpd of extant species in a geographic subset
species.pd <- c() # the total distance in the phylogeny of a geographic subset
species.range <- c() # the mean species range of extant species in a geographic subset

t_opt.mean <- c() # the mean thermal optimum of extant species in a geographic subset
t_opt.max <- c() # max
t_opt.min <- c() # min
t_opt.range <- c() # range
t_opt.evenness <- c() # the evenness sensu Mouillot et al. (2005)
t_opt.diversity <- c() # the diversity sensu Leps et al. (2006)

niche.mean <- c()
niche.max <- c()
niche.min <- c()
niche.range <- c()
niche.sd <- c()
niche.diversity <- c()
niche.evenness <- c()

richness.avg <- c() # the mean species richness of all the cells in a geographic subset
richness.max <- c()
richness.min <- c()
richness.range <- c()
richness.sd <- c()
richness.discrepancy <- c()

clusters.total <- c() # the total number of clusters in a simulation
clusters.mpd <- c() # the mean mpd of all extant clusters in a geographic subset
clusters.pd <- c() # the mean clusters-level phylogenetic diversity of all species in a geographic subset

endemism.weighted <- c()

diversification.rate <- c()


# loop time ----
runs     <- list.files("./data_processed/genesis_output/")
run_IDs   <- runs[!is.na(as.integer(runs))] # NAs introduced by coercion is fine

for(i in 1:length(run_IDs)){
#for(i in 2265:length(run_IDs)){
  dir_run <- paste0("./data_processed/genesis_output/",run_IDs[i])
  
  # determine last time step
  timesteps      <- list.files(paste0(dir_run,"/richness/"))
  timestep       <- min(as.numeric(gsub(".*?([0-9]+).*", "\\1", timesteps)))  # this is bugged
  
  # two if statements: 1. skip runs that failed to reach the present.
  #                    2. skip runs that have no surviving species in present.
  # need to skip failed runs.
  if(timestep == 0){
    
    # load data ----
    richness  <- readRDS(paste0(dir_run,"/richness/richness_t_",timestep,".rds"))
    species   <- readRDS(paste0(dir_run,"/species/species_t_",timestep,".rds"))
    summary   <- readRDS(paste0(dir_run,"/sgen3sis.rds"))
    landscape <- readRDS(paste0(dir_run,"/landscapes/landscape_t_",timestep,".rds"))
    distances <- readRDS(paste0("./data_processed/seascapes/distances_full/distances_full_",timestep,".rds"))
    coords    <- landscape$coordinates
    
    # loop for each regional scale ----
    for(reg_scale in reg_scales){
      
      # select regional scale
      region_scale_subset <- data.frame(region_id[,1:3],
                                        region_id[,reg_scale])
      colnames(region_scale_subset) <- c("x","y","cell","region_name")
      region_scale_subset <- region_scale_subset %>% filter(!is.na(region_name))
      
      regions <- unique(region_scale_subset$region_name)
      
      # loop for each region ----
      for(region in regions){
        
        # region metrics ----
        region_name_subset <- filter(region_scale_subset, region_name == region)
        
        region.scale <- c(region.scale,
                          reg_scale)
        region.id    <- c(region.id,
                          region)
        region.size  <- c(region.size,
                          dim(region_name_subset)[1])
        
        distance_subset <- distanceSubset(distances,region_name_subset$cell) # subset dist matrix by cell ID
        distance_subset <- distance_subset[lower.tri(distance_subset)] # remove diagonal values
        distance_subset <- distance_subset[!is.infinite(distance_subset)] # remove unconnected cell distance values
        distance_mean   <- mean(distance_subset) # find the mean
        region.dist     <- c(region.dist,
                             distance_mean)
        
        species_total <- summary$summary$phylo_summary['0',][1]
        species.total <- c(species.total,species_total)
        
        if(dim(region_name_subset)[1] > 1){ # skip regions with fewer than 2 cells
          
          # subset each gen3sis object ----
          # richness
          richness_subset <- subset(richness, names(richness) %in% region_name_subset$cell)
          
          # species
          species_subset <- speciesSubset(species,region_name_subset$cell)
          species_extant <- speciesExtant(species_subset)
          species_subset <- species_subset[as.numeric(species_extant)]
          
          if(!is.null(species_extant)){ 
            
            # landscape
            landscape_subset <- subsetLandscape(landscape, region_name_subset$cell)
            coords_subset    <- landscape_subset$coordinates
            
            # metric calculations  ----
            species.surviving <- c(species.surviving,length(species_extant))
            
            current_i <- length(species.surviving)
            
            if(species.surviving[current_i] > 0){
              
              pa_dataframe        <- createPADF(species,landscape) # produce pa_dataframe for all species
              pa_dataframe_subset <- subset(pa_dataframe, # subset by extant species in region
                                            rownames(pa_dataframe) %in% region_name_subset$cell,
                                            select = c("x","y",species_extant))
              
              # species ----
              if(species.surviving[current_i] != 1){
                
                phylo                <- read.nexus(paste0(dir_run,"/phylogeny/phylogeny_t_",timestep,".nex")) # read in whole phylogeny
                species_subset_index <- paste0("species",
                                               species_extant)
                phylo_subset         <- keep.tip(phylo,species_subset_index)
                
                # species divergence
                species.mpd <- c(species.mpd,
                                 phyloDiversityMeanSim(pa_dataframe_subset,
                                                       phylo_subset))
                species.pd <- c(species.pd,
                                speciesPD(pa_dataframe_subset,
                                          phylo_subset))
                
                # species diversification rate
                div_rate             <- mean(1/evol_distinct(phylo_subset, type = c("fair.proportion"),scale = FALSE, use.branch.lengths = TRUE))
                diversification.rate <- c(diversification.rate,div_rate)
                
              } else {
                species.mpd   <- c(species.mpd,NA)
                species.pd    <- c(species.pd,NA)
                diversification.rate <- c(diversification.rate,NA)
              }
              
              species.range <- c(species.range,mean(speciesRange(pa_dataframe_subset))) # 
              
              
              # t_opt ----
              t_opt <- c()
              for(sp in 1:length(species_subset)){
                x     <- species_subset[[sp]]$traits[,'t_opt']
                t_opt <- c(t_opt,x)
              }
              t_opt.mean  <- c(t_opt.mean,mean(t_opt))
              t_opt.max   <- c(t_opt.max,range(t_opt)[2])
              t_opt.min   <- c(t_opt.min,range(t_opt)[1])
              t_opt.range <- c(t_opt.range,t_opt.max[current_i]-t_opt.min[current_i])
              t_opt_evenness <- traitEvennessCell(species_subset,"t_opt")
              t_opt.evenness <- c(t_opt.evenness, mean(t_opt_evenness[which(is.finite(t_opt_evenness))]))
              t_opt_diversity <- traitDiversity(species_subset,"t_opt")
              t_opt.diversity <- c(t_opt.diversity, mean(t_opt_diversity[which(is.finite(t_opt_diversity))]))
              
              # niche ----
              niche <- c()
              for(sp in 1:length(species_subset)){
                x     <- species_subset[[sp]]$traits[,'niche']
                niche <- c(niche,x)
              }
              
              niche.mean   <- c(niche.mean,mean(niche))
              niche.max   <- c(niche.max,range(niche)[2])
              niche.min   <- c(niche.min,range(niche)[1])
              niche.range <- c(niche.range,niche.max[current_i]-niche.min[current_i])
              niche.sd    <- c(niche.sd,sd(niche))
              niche_evenness <- traitEvennessCell(species_subset,"niche")
              niche.evenness <- c(niche.evenness, mean(niche_evenness[which(is.finite(niche_evenness))]))
              niche_diversity <- traitDiversity(species_subset,"niche")
              niche.diversity <- c(niche.diversity, mean(niche_diversity[which(is.finite(niche_diversity))]))
              
              # richness ----
              richness.avg   <- c(richness.avg,mean(richness_subset))
              richness.max   <- c(richness.max,max(richness_subset))
              richness.min   <- c(richness.min,min(richness_subset))
              richness.range <- c(richness.range,richness.max[current_i]-richness.min[current_i])
              richness.sd    <- c(richness.sd,sd(richness_subset))
              
              # richness discrepancy ----
              # load in output
              rich.out <- data.frame(coords_subset,richness_subset)
              
              # merge everything
              rich.all <- merge(rich.out,rich.true, by = "row.names", all.x = TRUE)
              rich.all <- rich.all[,c(1,2,3,4,7)]
              colnames(rich.all) <- c("cell","x","y","rich.out","rich.true")
              rich.all <- filter(rich.all, !is.na(rich.true))
              
              # normalise to 0-1 to make comparable
              rich.all$rich.true <- rich.all$rich.true/max(rich.all$rich.true)
              rich.all$rich.out  <- rich.all$rich.out/max(rich.all$rich.out)
              rich.all$discrepancy <- sqrt((rich.all$rich.true-rich.all$rich.out)^2)
              
              richness.discrepancy <- c(richness.discrepancy,mean(rich.all$discrepancy))
              
              # cluster ----
              # determine clusters
              dispRange      <- filter(config, run_id == run_IDs[i])$dispRange       # return run dispersal range
              species_subset <- clusterDetermine(dispRange,distances,species_subset) # find clusters and add them to the species object
              
              # total clusters
              clusters.sp <- c()
              for(sp in length(species_extant)){
                x        <- species_subset[[sp]]$populations
                clusters.sp <- c(clusters.sp,length(unique(x)))
              }
              
              clusters.total <- c(clusters.total,sum(clusters.sp))

              # cluster divergence
              clusters.mpd <- c(clusters.mpd,
                                       mean(clusterDivergenceSim(species_subset)))
              
              # cluster PD
              clusters.pd <- c(clusters.pd,
                               mean(clusterPDSim(species_subset)))
              
              # endemism ----
              pa_dataframe      <- createPADF(species,landscape)
              endemism_weighted <- endemismWeighted(richness_subset,pa_dataframe,landscape_subset)
              endemism_weighted <- mean(subset(endemism_weighted, !is.nan(endemism_weighted)))
              endemism.weighted <- c(endemism.weighted,endemism_weighted)

              
            } else { 
              species.surviving <- c(species.surviving,0)
              species.mpd <- c(species.mpd,NA)
              species.pd    <- c(species.pd,NA)
              species.range      <- c(species.range,NA)
              
              t_opt.mean  <- c(t_opt.mean,NA)
              t_opt.max <- c(t_opt.max,NA)
              t_opt.min <- c(t_opt.min,NA)
              t_opt.range <- c(t_opt.range,NA)
              t_opt.evenness <- c(t_opt.evenness,NA)
              t_opt.diversity <- c(t_opt.diversity,NA)
              
              niche.mean <- c(niche.mean,NA)
              niche.max <- c(niche.max,NA)
              niche.min <-  c(niche.min,NA)
              niche.range <-  c(niche.range,NA)
              niche.sd <-  c(niche.sd,NA)
              niche.evenness <- c(niche.evenness,NA)
              niche.diversity <- c(niche.diversity,NA)
              
              richness.avg <-  c(richness.avg,NA)
              richness.max <-  c(richness.max,NA)
              richness.min <-  c(richness.min,NA)
              richness.range <-  c(richness.range,NA)
              richness.sd <-  c(richness.sd,NA)
              richness.discrepancy <- c(richness.discrepancy, NA)
              
              clusters.total <-  c(clusters.total,NA)
              clusters.mpd <-  c(clusters.mpd,NA)
              clusters.pd <-  c(clusters.pd,NA)
              
              endemism.weighted <- c(endemism.weighted,NA)
              
              diversification.rate <- c(diversification.rate,NA)
            } 
          } else {
            species.surviving <- c(species.surviving,0)
            species.mpd <- c(species.mpd,NA)
            species.pd    <- c(species.pd,NA)
            species.range      <- c(species.range,NA)
            
            t_opt.mean  <- c(t_opt.mean,NA)
            t_opt.max <- c(t_opt.max,NA)
            t_opt.min <- c(t_opt.min,NA)
            t_opt.range <- c(t_opt.range,NA)
            t_opt.evenness <- c(t_opt.evenness,NA)
            t_opt.diversity <- c(t_opt.diversity,NA)
            
            niche.mean <- c(niche.mean,NA)
            niche.max <- c(niche.max,NA)
            niche.min <-  c(niche.min,NA)
            niche.range <-  c(niche.range,NA)
            niche.sd <-  c(niche.sd,NA)
            niche.evenness <- c(niche.evenness,NA)
            niche.diversity <- c(niche.diversity,NA)
            
            richness.avg <-  c(richness.avg,NA)
            richness.max <-  c(richness.max,NA)
            richness.min <-  c(richness.min,NA)
            richness.range <-  c(richness.range,NA)
            richness.sd <-  c(richness.sd,NA)
            richness.discrepancy <- c(richness.discrepancy, NA)
            
            clusters.total <-  c(clusters.total,NA)
            clusters.mpd <-  c(clusters.mpd,NA)
            clusters.pd <-  c(clusters.pd,NA)
            
            endemism.weighted <- c(endemism.weighted,NA)
            
            diversification.rate <- c(diversification.rate,NA)
          } 
        } else {
          species.surviving <- c(species.surviving,0)
          species.mpd <- c(species.mpd,NA)
          species.pd    <- c(species.pd,NA)
          species.range      <- c(species.range,NA)
          
          t_opt.mean  <- c(t_opt.mean,NA)
          t_opt.max <- c(t_opt.max,NA)
          t_opt.min <- c(t_opt.min,NA)
          t_opt.range <- c(t_opt.range,NA)
          t_opt.evenness <- c(t_opt.evenness,NA)
          t_opt.diversity <- c(t_opt.diversity,NA)
          
          niche.mean <- c(niche.mean,NA)
          niche.max <- c(niche.max,NA)
          niche.min <-  c(niche.min,NA)
          niche.range <-  c(niche.range,NA)
          niche.sd <-  c(niche.sd,NA)
          niche.evenness <- c(niche.evenness,NA)
          niche.diversity <- c(niche.diversity,NA)
          
          richness.avg <-  c(richness.avg,NA)
          richness.max <-  c(richness.max,NA)
          richness.min <-  c(richness.min,NA)
          richness.range <-  c(richness.range,NA)
          richness.sd <-  c(richness.sd,NA)
          richness.discrepancy <- c(richness.discrepancy, NA)
          
          clusters.total <-  c(clusters.total,NA)
          clusters.mpd <-  c(clusters.mpd,NA)
          clusters.pd <-  c(clusters.pd,NA)
          
          endemism.weighted <- c(endemism.weighted,NA)
          
          diversification.rate <- c(diversification.rate,NA)
        } 
        
        run_id         <- c(run_id, run_IDs[i])
        timestep_final <- c(timestep_final,timestep)
        
        print(paste0("Run: ",run_IDs[i],". Scale: ", reg_scale,". Region: ",region,"."))
        
      } # end of loop for each region
      
    } # end of loop for regional scale 
    gc()
  } # end of run skip if statement
}

# output summary table ----

summary_table <- data.frame(run_id,
                            region.scale,
                            region.id,
                            region.size,
                            region.dist,
                            timestep_final,
                            species.total,
                            species.surviving,
                            species.mpd,
                            species.pd,
                            species.range,
                            t_opt.mean,
                            t_opt.max,
                            t_opt.min,
                            t_opt.range,
                            t_opt.evenness,
                            t_opt.diversity,
                            niche.mean,
                            niche.max,
                            niche.min,
                            niche.range,
                            niche.sd,
                            niche.evenness,
                            niche.diversity,
                            richness.avg,
                            richness.max,
                            richness.min,
                            richness.range,
                            richness.sd,
                            richness.discrepancy,
                            clusters.total,
                            clusters.mpd,
                            clusters.pd,
                            endemism.weighted,
                            diversification.rate)
summary_table <- merge(config,summary_table)


write_csv(summary_table, "./data_processed/summary/summary_table.csv")
