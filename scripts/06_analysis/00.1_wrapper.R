# set session ------------------------------------------------------------------
# custom functions
path_function <- "./scripts/functions"
functions     <- list.files(path = path_function,pattern = ".R")
invisible(lapply(paste(path_function,functions,sep = "/"),source))
source("./scripts/colour_palettes.R")

# packages
library(tidyverse)
library(viridis)
library(gridExtra)
library(ggExtra)
library(scales)
library(glmmTMB) # for model generation
library(DHARMa) # for model evaluation
library(lme4)
library(ggfortify)
library(ggcorrplot)
library(Hmisc)
library(raster)
library(ggnewscale)
library(gtools)
library(sf)
library(broom)
library(sjPlot)
library(factoextra)
library(Cairo) # to export Greek letters

# set parameters ---------------------------------------------------------------
# input
#input <- "2021_1d_2000m_17c"

# local storage
#local_data <- "E:"

# target batch
#batch <- "6.3_all"

# extant species
extant_species_min <- 20 # 0 is no filter # 20
# total species
total_species_min  <- 0 # 0 is no filter # 5
# richness discrepancy max
discrepancy_max <- 1 # 1 is maximum difference # 0.4
# export format
export_format <- "svg" # png / svg

# set realm colour scheme
realm_order <- c("Eastern Indo-Pacific",
                 "Tropical Eastern Pacific",
                 "Tropical Atlantic",
                 "Western Indo-Pacific",
                 "Central Indo-Pacific")

realm_colours <- viridis(n = 6, option = "D")
realm_colours <- colours_tk$cb_tol
plot_alpha    <- 0.7

# directories
dir_plot <- "./results/plots/"

# 00 summary data
dir_wrangle <- "./scripts/06_analysis/00.2_wrangle_data.R"
source(dir_wrangle)

length(retained_sims)
