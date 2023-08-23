# This script takes the ecoregions as defined by Spalding et al. 2007 and
# uses them to assign ecoregions to each cell in the genesis simulation
# outputs.
# Thomas Keggin
# thomaskeggin@hotmail.com


# set session ------------------------------------------------------------------
library(tidyverse)
library(raster)
library(sf)

# load and wrangle data --------------------------------------------------------
# ecoregions from Spalding et al (2007)
data_spalding <- st_read("./data_external/ecoregions/Marine_Ecoregions_Of_the_World_(MEOW)-shp/Marine_Ecoregions_Of_the_World__MEOW_.shp")
data_spalding <- st_transform(data_spalding, crs = "+proj=longlat +datum=WGS84") # convert crs
data_spalding <- data_spalding %>% filter(Lat_Zone == "Tropical") # filter out non-tropical

# habitable cells from simulation output
data_coord           <- readRDS("data_processed/genesis_output/1/landscapes/landscape_t_0.rds")
data_coord           <- data.frame(data_coord$coordinates,rownames(data_coord$coordinates))
colnames(data_coord) <- c("x","y","cell")

# assign regional IDs to cells -------------------------------------------------
# set scales
reg_scales <- c("ECOREGION",
                "PROVINCE",
                "REALM")

# filter out unused cells
coords_raster <- rasterFromXYZ(data_coord)
coords_new    <- as.data.frame(coords_raster, xy = T)

# loop cell assignments through each scale
region_id <- coords_new
for(reg_scale in reg_scales){
  
  data_geo            <- data_spalding[,reg_scale] # aggregate to scale
  data_geo_raster     <- rasterize(data_geo,raster()) # rasterise
  data_geo_raster     <- crop(data_geo_raster, coords_raster) # crop raster to sim extent
  data_geo_sim_raster <- mask(data_geo_raster,coords_raster) # mask by sim cells
  data_geo_df         <- as.data.frame(data_geo_sim_raster, xy = T) # convert to data frame
  region_id           <- merge(region_id,data_geo_df) # bind to master data frame
  
  print(paste(reg_scale,"done")) # progress report
}

region_id <- region_id %>% filter(!is.na(cell))
colnames(region_id) <- c("x","y","cell",reg_scales)

region_id$GLOBAL <- "global"

# output -----------------------------------------------------------------------
write_csv(region_id, "./data_processed/ecoregions/01_region_ids.csv")
