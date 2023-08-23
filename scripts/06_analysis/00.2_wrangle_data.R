# load and wrangle data --------------------------------------------------------
# load in all summary tables
summaries <-
  list.files("./data_processed/summary/")
summaries <-
  summaries[grep("summary_table",summaries)]

data_raw <- list()
for(i in 1:length(summaries)){
  data_raw[[i]] <-
    read_csv(paste0("./data_processed/summary/",summaries[i]),
             show_col_types = F)
}

data_raw <-
  do.call(rbind.data.frame,data_raw)

missing_runs <- 
  which((1:15000 %in% unique(data_raw$run_id)) == FALSE)

# load in seascape metrics
data_land <- read_csv("./data_processed/ecoregions/02_region_metrics.csv",
                      show_col_types = F) 

# merge landscape metrics ------------------------------------------------------
# create unique label for each region and merge
data_raw$scale_region  <- paste0(data_raw$region.scale,"_",data_raw$region.id)
data_land$scale_region <- paste0(data_land$scale,"_",data_land$region)
data_land              <- data_land %>% dplyr::select(scale_region,distance,size)
colnames(data_land)    <- c("scale_region","landscape_distance","landscape_size")

data_raw <- merge(data_raw,data_land)

# apply quality filters --------------------------------------------------------
# these quality filters are only applied to global simulation metrics

data_filtered <- 
  data_raw %>%
  filter(region.scale == "GLOBAL") %>%
  filter(species.surviving  >= extant_species_min) %>% 
  filter(species.total >= total_species_min) %>% 
  filter(richness.discrepancy <= discrepancy_max)
# there is an argument that speciation thresholds above 100 steps is unrealistic
# and keeping those data is erroneous. The counter argument is that in a modelling
# exercise exploring process, it's still interesting to explore the entire 
# parameter space regardless of whether parts of that space are present in 
# the real world.

retained_sims <- data_filtered$run_id

# refilter to include lower regional scales
data_filtered <- data_raw %>% filter(run_id %in% retained_sims)

# scale diversity metrics ------------------------------------------------------
# scaling first between 0.01 and 1 to keep 0 values and allow consistent comparisons
# between vastly different scales in the metrics
# this scaling needs to be done separately for global and regional
# global
data_filtered_global <- data_filtered %>% filter(region.scale == "GLOBAL")

for(i in which(colnames(data_filtered_global) %in% c("species.surviving",
                                                     "species.mpd",
                                                     "species.pd",
                                                     "clusters.total",
                                                     "clusters.mpd",
                                                     "clusters.pd"))){
  
  data_filtered_global[,i] <- rescale(data_filtered_global[,i], to = c(0.01,1))
}
# realm
data_filtered_realm <- data_filtered %>% filter(region.scale == "REALM")

for(i in which(colnames(data_filtered_realm) %in% c("species.surviving",
                                                     "species.mpd",
                                                     "species.pd",
                                                     "clusters.total",
                                                     "clusters.mpd",
                                                     "clusters.pd"))){
  
  data_filtered_realm[,i] <- rescale(data_filtered_realm[,i], to = c(0.01,1))
}

data_filtered <- rbind(data_filtered_global,
                       data_filtered_realm)

# calculate continuity metrics -------------------------------------------------
# These are reversed so that species skewed are positive
# number of clusters / number of species
data_filtered$contRichness  <- data_filtered$species.surviving/data_filtered$clusters.total

# cluster mpd / species mpd
data_filtered$contMPD   <- data_filtered$species.mpd/data_filtered$clusters.mpd
#data_filtered$contDivergence   <- data_filtered$species.divergence/data_filtered$clusters.divergence

# cluster pd / species pd
data_filtered$contPD  <- data_filtered$species.pd/data_filtered$clusters.pd

# turnover
data_filtered$species.turnover <- data_filtered$species.surviving/data_filtered$species.total

# put regions in order as factors
data_filtered$region.id <- factor(data_filtered$region.id, levels = realm_order)

# calculate skews --------------------------------------------------------------
# richness
data_filtered$skew_richness <- data_filtered$clusters.total < data_filtered$species.surviving

# pd
data_filtered$skew_PD       <- data_filtered$clusters.pd < data_filtered$species.pd

# mpd
data_filtered$skew_MPD      <- data_filtered$clusters.mpd < data_filtered$species.mpd

# create dummy variables -------------------------------------------------------
# create dummy speciation variable
data_filtered$speciation_dummy <- data_filtered$speciation > 100

# create dummy dispersal variable
data_filtered$dispersal_dummy <- data_filtered$dispRange > 1000











