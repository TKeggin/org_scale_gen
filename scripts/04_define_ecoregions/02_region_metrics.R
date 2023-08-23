# set session ------------------------------------------------------------------
library(tidyverse)

# load data --------------------------------------------------------------------
distances      <- readRDS("./data_processed/seascapes/distances_full/distances_full_0.rds")
region_IDs_raw <- read_csv("./data_processed/ecoregions/01_region_ids.csv")

# wrangle data -----------------------------------------------------------------
# reformate and clean
region_IDs <- region_IDs_raw %>%
  pivot_longer(cols = c(REALM,PROVINCE,ECOREGION,GLOBAL),
               names_to = "scale",
               values_to = "region") %>% 
  filter(!is.na(region))

# create vectors of region IDs
ecoregions <- region_IDs %>%  filter(scale == "ECOREGION")
ecoregions <- unique(ecoregions$region)

provinces <- region_IDs %>%  filter(scale == "PROVINCE")
provinces <- unique(provinces$region)

realms <- region_IDs %>%  filter(scale == "REALM")
realms <- unique(realms$region)

globals <- region_IDs %>%  filter(scale == "GLOBAL")
globals <- unique(globals$region)

# calculate mean distances for each region ----
# ecoregions
dist_ecoregion <- c()
size_ecoregion <- c()
for(ecoregion in ecoregions){
  
  # subset by ecoregion to find cell IDs
  id_subset <- region_IDs %>% filter(scale == "ECOREGION" &
                                     region == ecoregion)
  cell_subset <- id_subset$cell
  
  # subset the distance matrix
  dist <- distances[rownames(distances) %in% cell_subset,
                    colnames(distances) %in% cell_subset]
  
  # remove self comparisons from symmetrical matrix
  if(class(dist)[1] == "numeric"){
  } else{
    dist <- dist[upper.tri(dist)]
  }
  
  # remove infinite values (isolated cells)
  dist <- dist[!is.infinite(dist)]
  
  # calculate mean
  dist_ecoregion <- c(dist_ecoregion, mean(dist))
  
  # region size
  size_ecoregion <- c(size_ecoregion, length(dist))
  
}

# provinces
dist_province <- c()
size_province <- c()
for(province in provinces){
  
  # subset by province to find cell IDs
  id_subset <- region_IDs %>% filter(scale == "PROVINCE" &
                                       region == province)
  cell_subset <- id_subset$cell
  
  # subset the distance matrix
  dist <- distances[rownames(distances) %in% cell_subset,
                    colnames(distances) %in% cell_subset]
  
  # remove self comparisons from symmetrical matrix
  if(class(dist)[1] == "numeric"){
  } else{
    dist <- dist[upper.tri(dist)]
  }
  
  # remove infinite values (isolated cells)
  dist <- dist[!is.infinite(dist)]
  
  # calculate mean
  dist_province <- c(dist_province, mean(dist))
  
  # region size
  size_province <- c(size_province, length(dist))
}

# realms
dist_realm <- c()
size_realm <- c()
for(realm in realms){
  
  # subset by realm to find cell IDs
  id_subset <- region_IDs %>% filter(scale == "REALM" &
                                       region == realm)
  cell_subset <- id_subset$cell
  
  # subset the distance matrix
  dist <- distances[rownames(distances) %in% cell_subset,
                    colnames(distances) %in% cell_subset]
  
  # remove self comparisons from symmetrical matrix
  if(class(dist)[1] == "numeric"){
  } else{
    dist <- dist[upper.tri(dist)]
  }
  
  # remove infinite values (isolated cells)
  dist <- dist[!is.infinite(dist)]
  
  # calculate mean
  dist_realm <- c(dist_realm, mean(dist))
  
  # region size
  size_realm <- c(size_realm, length(dist))
}

# globals
dist_global <- c()
size_global <- c()
for(global in globals){
  
  # subset by global to find cell IDs
  id_subset <- region_IDs %>% filter(scale == "GLOBAL" &
                                       region == global)
  cell_subset <- id_subset$cell
  
  # subset the distance matrix
  dist <- distances[rownames(distances) %in% cell_subset,
                    colnames(distances) %in% cell_subset]
  
  # remove self comparisons from symmetrical matrix
  if(class(dist)[1] == "numeric"){
  } else{
    dist <- dist[upper.tri(dist)]
  }
  
  # remove infinite values (isolated cells)
  dist <- dist[!is.infinite(dist)]
  
  # calculate mean
  dist_global <- c(dist_global, mean(dist))
  
  # region size
  size_global <- c(size_global, length(dist))
}

# compile results ----
dist_ecoregion <- data.frame(scale = "ECOREGION",
                             region = ecoregions,
                             distance = dist_ecoregion,
                             size = size_ecoregion)

dist_province <- data.frame(scale = "PROVINCE",
                            region = provinces,
                            distance = dist_province,
                            size = size_province)

dist_realm <- data.frame(scale = "REALM",
                         region = realms,
                         distance = dist_realm,
                         size = size_realm)

dist_global <- data.frame(scale = "GLOBAL",
                          region = globals,
                          distance = dist_global,
                          size = size_global)

region_metrics <- rbind(dist_ecoregion,
                       dist_province,
                       dist_realm,
                       dist_global)

# output results ----

write_csv(region_metrics, "./data_processed/ecoregions/02_region_metrics.csv")













