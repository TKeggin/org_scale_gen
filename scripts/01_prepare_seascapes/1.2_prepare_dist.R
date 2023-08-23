##################################################
## Description: Creates distance matrices
##
## Date: 2018-03-16 15:26:39
## Author: Oskar Hagen (oskar@hagen.bio)
##
## Update Lydian Boschman 2019-07-23
## Update Thomas Keggin   2019-10-18
## 
##################################################

# load libraries ---------------------------------------------------------------
lib <- c("raster","matrixStats","sp","gdistance","geosphere","parallel", "dplyr")
sapply(lib,library, character.only=TRUE)

# load data from previous step -------------------------------------------------
load("./data_processed/seascapes/temp.Rdata")

# set variables ----------------------------------------------------------------
OutputDir   <- paste0("./data_processed/seascapes/")
crossing_NA <- 0     # Set to 0 (conductance) making land impassible. See gdistance package documentation.
depth_cut   <- -20000    # set the depth cut-off
temp_cut    <- -100    # set lower temperature limit cut-off

# check, or create, output directories -----------------------------------------
# create dirs if they don't exist
if (!dir.exists(paste0(OutputDir,"/distances_full"))){
  dir.create(file.path(OutputDir, "distances_full"))
}

# create plot dir if it doesn't exist
if (!file.exists(file.path(OutputDir, "/plot"))) {
  dir.create(file.path(OutputDir, "plot"))
}

# create landscapes ------------------------------------------------------------
# filter out uninhabitable cells by environmental cut offs
cutTemp  <- stack(geoTempList)
cutDepth <- stack(geoDepthList)

cutDepth[cutDepth < depth_cut] <- NA
cutTemp[cutTemp < temp_cut] <- NA
cutTemp[is.na(cutDepth)] <- NA
cutDepth[is.na(cutTemp)] <- NA

# merge all temperature rasters into a single dataframe
masterTemp <- as.data.frame(cutTemp[[1]], xy=T)
masterTemp <- masterTemp[,-3]

for(raster in seq(1,dim(cutTemp)[3])){
  
  raster.df <- as.data.frame(cutTemp[[raster]], xy=T)
  masterTemp <- cbind(masterTemp,raster.df[,3])
  
}

colnames(masterTemp) <- c("x","y",format(round(geoTimes, 2), nsmall = 2))

# merge all depth rasters into a single dataframe
masterDepth <- as.data.frame(cutDepth[[1]], xy=T)
masterDepth <- masterDepth[,-3]

for(raster in seq(1,dim(cutDepth)[3])){
  
  raster.df <- as.data.frame(cutDepth[[raster]], xy=T)
  masterDepth <- cbind(masterDepth,raster.df[,3])
  
}

colnames(masterDepth) <- c("x","y",format(round(geoTimes, 2), nsmall = 2))

# explicitly assign rownames
rownames(masterTemp)  <- 1:dim(masterTemp)[1]
rownames(masterDepth) <- 1:dim(masterDepth)[1]

# create and save landscapes object
landscapes <- list(temp = masterTemp, depth = masterDepth)
saveRDS(landscapes, file = file.path(OutputDir, paste0("landscapes.rds",sep="")))


# create distance matrices -----------------------------------------------------
t_start <- dim(geoDepthList)[3]  # the starting raster index
t_end   <- 1                     # the final raster index (present day)

for (i in t_start:t_end){
  
  raster_i <- geoDepthList[[i]]
  crs(raster_i) <- "+proj=longlat +datum=WGS84"
  age      <- geoTimes[i]
  
  conductObj                     <- raster_i      # this is setting up the conductance (cost of dispersal) values for all marine cells in the raster
  conductObj[!is.na(conductObj)] <- 1             # this gives habitable cells a cost for crossing (1 = no change in cost)
  conductObj[is.na(conductObj)]  <- crossing_NA   # this gives the NA valued cells a cost for crossing (land)
  
  # create a transition object (based on conductance)
  transObj <- transition(conductObj, transitionFunction=min, directions=8) # create matrix with least cost values between each pair of cells (symmetrical?)
  transObj <- geoCorrection(transObj, type = "r", scl = F) * 1000          # correct for map distortion. The output values are in m, the "*1000" converts to km
  # filter by out cells by environmental cut offs
  raster_i        <- mask(raster_i, cutDepth[[i]])                  # filter buy cut offs implemented in the landscapes step
  df_i            <- as.data.frame(raster_i, xy=TRUE, na.rm = TRUE) # this will remove NA cells
  colnames(df_i)  <- c("x","y","depth")
  mat_i_habitable <- data.matrix(df_i)[, 1:2] # convert to matrix of habitable coordinates
  
  # calculate the least-cost distance between points using the transition object and target (habitable) cells
  dist_mat <- costDistance(transObj,
                                mat_i_habitable,
                                mat_i_habitable)
  
  # number rows and columns
  rownames(dist_mat) <- rownames(masterDepth)[which(!is.na(masterDepth[,i+2]))]
  colnames(dist_mat) <- rownames(masterDepth)[which(!is.na(masterDepth[,i+2]))]
  
  # save the distance matrix
  saveRDS(dist_mat,file=file.path(paste0(OutputDir,"/distances_full/distances_full_",i-1,".rds",sep="")))
  
  cat("Done with", round(age, digits = 2), "\n")
  
}



