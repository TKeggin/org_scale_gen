#
# This script attempts to tease apart the relationships between the parameters
# and the continuity metrics
# since contPD/MPD/Compare are all correlated.
# Using negative cont metrics to make larger values species skewed
# Thomas Keggin
#

# wrangle data ----
# global only
data_global <- data_filtered %>% filter(region.scale == "GLOBAL")

cont_metrics <- c("contRichness",
                  "contPD",
                  "contMPD")

params <- c("dispRange",
            "speciation",
            "t_opt",
            "n_width",
            "mutationRate",
            "initialAbundance")

# check for correlations
data_params <- data_global %>% 
  dplyr::select(all_of(params))
data_cont <- data_global %>% 
  dplyr::select(all_of(cont_metrics))

plot(data_params)
plot(log(data_cont))

# explore variables
par(mfrow=c(2,6))
for(i in c(params)){
  hist(data_global[,i],
       main = i)
}

for(i in c(params)){
  hist(log(data_global[,i]),
       main = paste("log",i))
}

# transform continuity
# this is actually not a transformation, it gives the variable direction/
# This should not be back transformed.
data_global$contRichness_log <- log(data_global$contRichness)
data_global$contPD_log       <- log(data_global$contPD)
data_global$contMPD_log      <- log(data_global$contMPD)

# transform parameters
data_global$dispRange_log  <- log(data_global$dispRange)
data_global$speciation_log <- log(data_global$speciation)


# scale parameter values
for(i in which(colnames(data_global) %in% params)){
  
  data_global[,i] <- scale(data_global[,i])
}


# Richness ----
rich_none <- lm(contRichness_log ~
                  dispRange_log +
                  speciation_log +
                  t_opt +
                  n_width +
                  mutationRate +
                  initialAbundance,
                data = data_global)

# plot linear model
par(mfrow=c(2,2))
plot(rich_none)
summary(rich_none)

# variable selection
rich_select <- step(rich_none, direction="both", k=2)
summary(rich_select)
plot(rich_select)

# PD ----
# create linear model
PD_none <- lm(contPD_log ~
                dispRange_log +
                speciation_log +
                t_opt +
                n_width +
                mutationRate +
                initialAbundance,
              data = data_global)

# plot linear model
par(mfrow=c(2,2))
plot(PD_none)
summary(PD_none)

# variable selection
PD_select <- step(PD_none, direction="both", k=2)
summary(PD_select)
plot(PD_select)


# MPD ----
MPD_none <- lm(contMPD_log ~
                 dispRange_log +
                 speciation_log +
                 t_opt +
                 n_width  +
                 mutationRate +
                 initialAbundance,
               data = data_global)


# plot linear model
par(mfrow=c(2,2))
plot(MPD_none)
summary(MPD_none)

# variable selection
MPD_select <- step(MPD_none, direction="both", k=2)
summary(MPD_select)
plot(MPD_select)


