# This script is just pulled from plotrichness_sim_4.R and plotInputContour.R
# load data ----
# load landscape
land_all <- readRDS("./data_processed/seascapes/landscapes.rds")
coords <- land_all$depth[,c(1:2)]

# load real data
load("./data_external/albouy_2019/MatPa_Final_ok.rdata") # load gaspar richness data
MatPa_Final_ok$richness <- rowSums(MatPa_Final_ok[,-c(1,2)])

MatPa_Final_ok <- MatPa_Final_ok[,c("Longitude","Latitude","richness")]
rich <- filter(MatPa_Final_ok, richness > 1)
rm(MatPa_Final_ok)

land <- land_all$temp[,c(1,2,3)]
#land <- filter(land, land[,3] > 1)
land.raster <- rasterFromXYZ(land) # input raster
rich.raster <- rasterFromXYZ(rich) # richness raster
rich.raster <- resample(rich.raster,land.raster) # match extents
rich.masked <- mask(rich.raster, land.raster) # mask richness by the input

rich.true <- as.data.frame(rich.masked, xy = TRUE)

# load simulated data
richs_sim <- list()
for(i in retained_sims){
  
  richs_sim[[i]] <- readRDS(paste0("./data_processed/genesis_output/",i,"/richness/richness_t_0.rds"))
  print(i)
}

# wrangle data ----
# wrangle contour data
contour_breaks     <- c(seq(from = 1000, to = -8000, by = -1000)) # set depth bins
contour_breaks     <- c(1000,0,-8000)

plot_all           <- land_all$depth[,c(1:3)] # select timestep
colnames(plot_all) <- c("x","y","depth") # rename
plot_all$depth     <- cut(x = plot_all$depth, # bin depth values - this is janky
                          breaks = contour_breaks,
                          labels = contour_breaks[-3])
plot_all$depth     <- as.numeric(levels(plot_all$depth))[plot_all$depth] # convert depth levels as numeric values
plot_all$depth[is.na(plot_all$depth)] <- 1 # set land to 1 to include it in the colour scale

# wrangle simulated richness_sim data
richs_sim <- as.data.frame(do.call(cbind, richs_sim))

#richs_sim$rich_sim <- rowMeans(richs_sim)
richs_sim$rich_sim <- rowSums(richs_sim) 
#richs_sim$median <- apply(richs_sim, 1, median, na.rm=T)
#richs_sim$rich_sim <- apply(richs_sim, 1, median, na.rm=T)

richness_sim <- merge(coords,richs_sim, by=0)

# richness data merge
rich.true$cell_id    <- row.names(rich.true)
richness_sim$cell_id <- richness_sim$Row.names


# set low values to NA
richness_sim$rich_sim[richness_sim$rich_sim < 2] <- NA

data_1 <- merge(richness_sim,rich.true)
data_1 <- data_1[,c("cell_id",
                "x",
                "y",
                "rich_sim",
                "richness")]

colnames(data_1) <- c("cell_id",
                    "x",
                    "y",
                    "rich_sim",
                    "rich_true")


