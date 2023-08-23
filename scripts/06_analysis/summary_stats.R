# summary of diversity across simulations
# run manually and skip the scaling part
# input data are from the chapter 1 wrangle data script.

# set session ----
library(tidyverse)

metrics <-
  c("species.surviving",
    "species.pd",
    "species.mpd",
    "clusters.total",
    "clusters.pd",
    "clusters.mpd")

metrics_other <-
  c("species.range",
    #"t_opt.mean",
    #"t_opt.max",
    #"t_opt.min",
    #"t_opt.range",
    "t_opt.evenness",
    "t_opt.diversity",
    #"niche.mean",
    #"niche.max",
    #"niche.min",
    #"niche.range",
    #"niche.sd",
    "niche.evenness",
    "niche.diversity",
    "richness.avg",
    #"richness.max",
    #"richness.range",
    #"richness.sd",
    "endemism.weighted",
    "species.turnover",
    "diversification.rate")

# wrangle data ----
data_global <-
  data_filtered %>%
  filter(region.scale == "GLOBAL")

data_realm <-
  data_filtered %>% 
  filter(region.scale == "REALM")

data_realm$region.id <- factor(data_realm$region.id,
                               levels = realm_order)

# create global summaries ----
range_global <-
  data_global %>%
  reframe(across(all_of(metrics),range))

median_global <-
  data_global %>%
  summarise(across(all_of(c(metrics,metrics_other)),
                   median,
                   na.rm = TRUE))


# create realm summaries ----
median_realm <-
  data_realm %>%
  group_by(region.id) %>% 
  summarise(across(all_of(c(metrics,metrics_other)),
                   median,
                   na.rm = TRUE))

# combine ----
merge_me <- data.frame(region.id = "Global",
                       median_global)

median_all <- rbind(median_realm,
                    merge_me)

median_all[,2:dim(median_all)[2]] <- round(median_all[,2:dim(median_all)[2]],
                        digits = 4)

# change names ----

colnames(median_all)[which(colnames(median_all) == "region.id")]            <- "Region"
colnames(median_all)[which(colnames(median_all) == "species.surviving")]    <- "Species surviving"
colnames(median_all)[which(colnames(median_all) == "species.pd")]           <- "Species PD"
colnames(median_all)[which(colnames(median_all) == "species.mpd")]          <- "Species MPD"
colnames(median_all)[which(colnames(median_all) == "clusters.total")]       <- "Population richness"
colnames(median_all)[which(colnames(median_all) == "clusters.pd")]          <- "Population PD"
colnames(median_all)[which(colnames(median_all) == "clusters.mpd")]         <- "Population MPD"
colnames(median_all)[which(colnames(median_all) == "species.range")]        <- "Species Range"
colnames(median_all)[which(colnames(median_all) == "t_opt.evenness")]       <- "Thermal evenness"
colnames(median_all)[which(colnames(median_all) == "t_opt.diversity")]      <- "Thermal diversity"
colnames(median_all)[which(colnames(median_all) == "niche.evenness")]       <- "Competitive evenness"
colnames(median_all)[which(colnames(median_all) == "niche.diversity")]      <- "Competitive diversity"
colnames(median_all)[which(colnames(median_all) == "richness.avg")]         <- "Mean species richness"
colnames(median_all)[which(colnames(median_all) == "endemism.weighted")]    <- "Weighted endemism"
colnames(median_all)[which(colnames(median_all) == "species.turnover")]     <- "Species turnover"
colnames(median_all)[which(colnames(median_all) == "diversification.rate")] <- "Diversification rate"

# export ----
tab_df(median_all,
       digits = 4,
       CSS    = list(css.table = '+font-family: Calibri;'),
       file   = "./results/tables/metric_summary.doc")




