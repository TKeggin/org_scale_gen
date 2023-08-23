# output summary tables
# do the same as the wrangle script, but change the variable names

# Change variable names ----
colnames(data_global)[which(colnames(data_global) == "dispRange_log")]    <- "Dispersal range"
colnames(data_global)[which(colnames(data_global) == "t_opt")]            <- "Thermal optimum"
colnames(data_global)[which(colnames(data_global) == "n_width")]          <- "Competitive niche size"
colnames(data_global)[which(colnames(data_global) == "initialAbundance")] <- "Initial abundance"
colnames(data_global)[which(colnames(data_global) == "speciation_log")]   <- "Speciation threshold"
colnames(data_global)[which(colnames(data_global) == "mutationRate")]     <- "Mutation rate"

colnames(data_global)[which(colnames(data_global) == "contRichness_log")] <- "Richness Continuity"
colnames(data_global)[which(colnames(data_global) == "contPD_log")]       <- "PD Continuity"
colnames(data_global)[which(colnames(data_global) == "contMPD_log")]      <- "MPD Continuity"


# Richness ----
rich_none <- lm(`Richness Continuity` ~
                  `Dispersal range` +
                  `Speciation threshold` +
                  `Thermal optimum` +
                  `Competitive niche size` +
                  `Mutation rate` +
                  `Initial abundance`,
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
PD_none <- lm(`PD Continuity` ~
                `Dispersal range` +
                `Speciation threshold` +
                `Thermal optimum` +
                `Competitive niche size` +
                `Mutation rate` +
                `Initial abundance`,
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
MPD_none <- lm(`MPD Continuity` ~
                 `Dispersal range` +
                 `Speciation threshold` +
                 `Thermal optimum` +
                 `Competitive niche size`  +
                 `Mutation rate` +
                 `Initial abundance`,
               data = data_global)


# plot linear model
par(mfrow=c(2,2))
plot(MPD_none)
summary(MPD_none)

# variable selection
MPD_select <- step(MPD_none, direction="both", k=2)
summary(MPD_select)
plot(MPD_select)

# plot ----

# print model summary
tab_model(rich_select,PD_select,MPD_select,
          show.ci   = FALSE,
          show.stat = TRUE,
          CSS       = list(css.table = '+font-family: Calibri;'),
          file      = "./results/tables/continuity_summary.doc")

