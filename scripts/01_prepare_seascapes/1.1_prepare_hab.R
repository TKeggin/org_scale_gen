# Compilation of GaSM input for use in the marine environment ------------------
# This creates an all_geo_hab object for gasm input containing sea surface temperature and depth.
# Thomas Keggin and Alex Skeels
# 11/08/2021

# 00. set the session ----------------------------------------------------------
library("tidyverse")
library("raster")
library("readxl")
library("ncdf4")

# set variables
resolution  <- 1 # this cannot be less than 1
smoothing   <- TRUE # T/F to determine geographic smoothing of koeppen bands using focal()
smooth_size <- 81 # set the geographic smoothing window size for focal() # 81 is based on comparison to copernicus sst (compareFocalWindow.R)
timeInterval<- 200/1200 # set the timestep duration in millions of years 
geoPeriod   <- 200 # in millions of years

# create blank rasters to aggregate/resample into
resTemplate            <- raster(nrow=180/resolution, ncol=360/resolution, crs=NA)
resTemplateOne         <- raster(nrow=180, ncol=360, crs=NA)
extent(resTemplate)    <- c(-180, 180, -90, 90)
extent(resTemplateOne) <- c(-180, 180, -90, 90)

# function: linear equation function
find.delta <- function(time){
  y <- m*time+b
  y
}

# function: raster to elevation (stolen from Oskar's compilation script)
convert.grey.to.elev <- function(grey_elev_raster){
  elevation <- grey_elev_raster
  values(elevation) <- (values(grey_elev_raster)-155)*40
  values(elevation)[values(grey_elev_raster) > 230] <- 3000 + ((values(grey_elev_raster)[values(grey_elev_raster) > 230]-230)*300)
  values(elevation)[values(grey_elev_raster) < 5] <- -6000 - ((5-values(grey_elev_raster)[values(grey_elev_raster) < 5])*1000)
  return(elevation)
}

# function: glacial scaling
glacial.scale <- function(input,step,factor){
  
 input[[step]]+(lgm*factor)
}

# 01. TEMP load in all koeppen raster files ------------------------------------
koeppenNames <- list.files("./data_external/seascapes/raw_koeppen_temperature_200-0Ma/", pattern = "*.asc")     # names of all the data files

koeppenList <- c()                                # set a blank list in which to put the imported data files

for(i in koeppenNames){                           # import all the data files and store them in dataList
  
  koeppen <- raster(paste("data_external/seascapes/raw_koeppen_temperature_200-0Ma/",i, sep = ""))
  koeppenList <- c(koeppenList,koeppen)
  
}

# 02. TEMP replace koeppen band numbers with temperature values ----------------
# data from Scotese 2021 and Legates & Willmott 1990
temp <- c(26,  # 1. equitorial rainy belt
          22,  # 2. subtropical arid belt
          16,  # 3. warm temperate
          22,  # 4. boreotropical - only present in hothouse climate
          5,   # 5. cool temperate
          -20, # 6. polar (N)
          -20) # 7. polar (S)
bands <- c(1:7)                                          # Koeppen bands

koeppenTimesteps <- c(1:length(koeppenList))             # make a sequence; 1 to the number of number files, to use in the nested for loop

for(d in koeppenTimesteps){                              # replace Koeppen band numbers with temperature values in all imported rasters
  
  extent(koeppenList[[d]]) <- extent(-180, 180, -90, 90) # fix the extent
  
  for(b in bands){
    
    values(koeppenList[[d]])[values(koeppenList[[d]]) == b] = temp[b]
    
  }
}

# 03. TEMP smooth the interface between koeppen zones --------------------------
koeppenListSmooth <- koeppenList

# check variables at start to decide whether or not to smooth koeppen zones
if(smoothing == TRUE){
  for(k in koeppenTimesteps){
    
    koeppenListSmooth[[k]] <- focal(koeppenList[[k]], w = matrix(1,smooth_size,smooth_size), # focal window size set in variables
                                    fun = mean,
                                    pad = TRUE, padValue = -20)  # add this to arbitrarily replace edge NAs - crop the image
    
  }
}
# focal na.rm = TRUE

#rm(koeppenList)

# 04. TEMP create temperature raster for each geo time step --------------------
# categorise geo timesteps into koeppen timestep bins

geoTimes     <- seq(0, geoPeriod, timeInterval)   # sequence of times in ka from present
geoTimesteps <- seq(1,length(geoTimes))           # serial id for timesteps

koeppenStack  <- stack(koeppenListSmooth)
geoTempList   <- calc(koeppenStack,
                      fun=function(y) approx(seq(from=0,
                                                 to=geoPeriod,
                                                 by=5),
                                             y,
                                             n=1201)$y)

# 05. TEMP find the delta temp from present for each geo time step -------------
# this could be done before 04. ----
# import data from Scotese 2021 supplementary
deltaTemp.df   <- read_excel("./data_external/seascapes/scotese_2021_temp/1-s2.0-S0012825221000027-mmc1/tk_extract.xlsx",
                             sheet = 3)

# categorise geo timesteps into koeppen timestep bins
geoTimes     <- seq(0, geoPeriod, timeInterval)   # sequence of times in ka from present
geoTimesteps <- seq(1,length(geoTimes))           # serial id for timesteps
deltaTemp    <- deltaTemp.df$deltaT      # vector of delta temp data at 1 million year intervals

geoDeltaTemp <- approx(seq(from=0, to=geoPeriod),
                       deltaTemp[1:(geoPeriod+1)],
                       n= 1201)$y

# 06. TEMP update geo step temperature rasters with delta temp from present ----
for(t in geoTimesteps){
  
  geoTempList[[t]] <- geoTempList[[t]] + geoDeltaTemp[t]
  
}


# 07. TEMP correct temperature for glaciation events ---------------------------
lgm            <- raster("./data_external/seascapes/glacial/sat.nc")                               # load glacial data
lgmRes         <- res(lgm)[1]                                               # find the extent of glacial data

# some filthy if statements to match the lgm resolution and extent to that of the temperature rasters
if(lgmRes == resolution){                                 # if the resolution matches do nothing
} else {if(lgmRes > resolution){                          
  lgm <- resample(lgm, resTemplate, method = 'bilinear')  # if the lgm res is higher, resample to target res
} else { if(lgmRes < resolution){                         
  lgm <- aggregate(resample(lgm, resTemplateOne, method = 'bilinear'), fact = resolution)}}                   # if the lgm res is lower, aggregate to half the target res (starts at 2)
}

scaleFactor <- read_csv("./data_external/seascapes/glacial/frame_table_constant_rate.csv") %>% filter(intensity > 0) # load glacial scaling factors

for(i in seq(1:length(scaleFactor$timestep))){
  
  geoTempList[[scaleFactor$timestep[i]+1]] <-  glacial.scale(geoTempList,
                                                    scaleFactor$timestep[i]+1,
                                                    scaleFactor$intensity[i])
}


# 08. DEPTH load in all elevation raster files ---------------------------------
geoDepthListRaw <- c()                               # set a blank list in which to put the imported data files
depthExt <- extent(-180, 180, -90, 90)               # set the extent to match temp rasters
depthTemplate <- raster(nrow=180, ncol=360, crs=NA)  # set a blank raster to resample into

depthNames <- list.files("./data_external/seascapes/elevation/all/", pattern = "*.tif")     # names of all the data files
  
for(d in depthNames){                           # import all the data files and store them in geoDepthListRAW
  
  depth <- raster(paste("./data_external/seascapes/elevation/all/",d, sep = ""))
  extent(depth) <- depthExt
  depth <- resample(depth, depthTemplate, method = "bilinear") # how does this resampling affect the accuracy of the data? # check before and after reef zones
  depth <- aggregate(depth, fact=resolution)                   # set the resolution to target resolution
  geoDepthListRaw <- c(geoDepthListRaw,depth)
  print(d)
}

#rm(depth, depthExt, depthTemplate)

# 09. DEPTH interpolate depth to fit geo time steps ----------------------------
# The raw elevation data are in rasters (.tiff) that don't follow a consistent time step,
# so using the smallest time step as the constant and interpolating between rasters.
elevationTimes <- read_excel("./data_external/seascapes/elevation/elevation_times.xlsx")   # adapted from Cris Scotese's "Animation FrameAge_v8 .xls" file (headers changed)
elevationStart <- filter(elevationTimes, cum_frame == 1)               # save the present day raster
elevationTimes <- filter(elevationTimes, age != 0 & age <= 200)        # filter out present day and rasters beyond 200 million years
elevationTimes <- rbind(elevationStart, elevationTimes)

# filter imported rasters by elevationTimes
targetElevations <- c()
for(raster in c(elevationTimes$cum_frame)){
  
  rasteri <- geoDepthListRaw[[raster]]
  targetElevations <- c(targetElevations, rasteri)
}

targetElevations <- stack(targetElevations)

geoDepthList <- calc(targetElevations,
                     fun=function(y) approx(elevationTimes$age,
                                            y,
                                            n=1201)$y)

# 10. DEPTH convert to real elevation values -----------------------------------
for(t in geoTimesteps){
  
  geoDepthList[[t]] <- convert.grey.to.elev(geoDepthList[[t]])
  
}

# 11. DEPTH filter out terrestrial habitat -------------------------------------
for(s in geoTimesteps){
  
  values(geoDepthList[[s]])[values(geoDepthList[[s]]) >= 0] <- NA
  
}

# 12. output data to temporary file --------------------------------------------
# want to keep geoTempList and geoDepthList
save(geoTempList, geoDepthList, geoTimes, geoTimesteps, file = "./data_processed/seascapes/temp.Rdata")

