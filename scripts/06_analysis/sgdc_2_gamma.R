#
# This script aims to model the relationship between cluster and species level
# diversity metrics at the global scale
#

# wrangle data ----
data_global <- data_filtered %>%
  filter(region.scale == "GLOBAL")

# model richness ----
# check variables
par(mfrow=c(2,2))
hist(data_global$species.surviving)
hist(data_global$clusters.total)
hist(log(data_global$species.surviving))
hist(log(data_global$clusters.total))

# transform variables
data_global$species.surviving_log <- log(data_global$species.surviving)
data_global$clusters.total_log    <- log(data_global$clusters.total)

# fit model
model_rich <- lm(species.surviving_log ~
                   clusters.total_log,
                 data = data_global)


summary(model_rich)
plot(model_rich)

# plot relationship
plot(species.surviving_log ~
       clusters.total_log,
     data = data_global)
abline(model_rich)

data_global$fitted_rich <- model_rich$fitted.values


# model PD ----
# check variables
par(mfrow=c(2,2))
hist(data_global$species.pd)
hist(data_global$clusters.pd)
hist(log(data_global$species.pd))
hist(log(data_global$clusters.pd))

# transform variables
data_global$species.pd_log  <- log(data_global$species.pd)
data_global$clusters.pd_log <- log(data_global$clusters.pd)

# fit model
model_pd <- lm(species.pd_log ~
                   clusters.pd_log,
                 data = data_global)


summary(model_pd)
plot(model_pd)

# plot relationship
plot(species.pd_log ~ clusters.pd_log,
     data = data_global)
abline(model_pd)

data_global$fitted_pd <- model_pd$fitted.values



# model mpd ----
# check variables
par(mfrow=c(2,2))
hist(data_global$species.mpd)
hist(data_global$clusters.mpd)
hist(log(data_global$species.mpd))
hist(log(data_global$clusters.mpd))

# transform variables
data_global$species.mpd_log  <- log(data_global$species.mpd)
data_global$clusters.mpd_log <- log(data_global$clusters.mpd)

# fit model
model_mpd <- lm(species.mpd ~
                 clusters.mpd_log,
               data = data_global)


summary(model_mpd)
plot(model_mpd)

# plot relationship
plot(species.mpd ~ clusters.mpd_log,
     data = data_global)
abline(model_mpd)

data_global$fitted_mpd <- model_mpd$fitted.values
# plot----
plots_gamma <- list()

# richness
plots_gamma$rich <- ggplot(data_global) +
  geom_abline(slope = 1,
              intercept = 0,
              linetype = "dashed",
              colour = "grey") +
  geom_point(aes(x = clusters.total_log,
                 y = species.surviving_log,
                 colour = skew_richness),
             alpha = plot_alpha) + 
  scale_colour_manual(values = colours_tk$cb_tol[c(4,2)]) +
  #geom_line(aes(x = clusters.total_log,
  #              y = fitted_rich)) +
  xlab("\u03B3 Population Richness") +
  ylab("\u03B3 Species Richness") +
  xlim(c(-5,0)) +
  ylim(c(-5,0)) +
  theme_classic() +
  theme(legend.position = "none",
        text=element_text(family="serif"))

# PD
plots_gamma$pd <- ggplot(data_global) +
  geom_abline(slope = 1,
              intercept = 0,
              linetype = "dashed",
              colour = "grey") +
  geom_point(aes(x = clusters.pd_log,
                 y = species.pd_log,
                 colour = skew_PD),
             alpha = plot_alpha) + 
  scale_colour_manual(values = colours_tk$cb_tol[c(4,2)]) +
  geom_line(aes(x = clusters.pd_log,
                y = fitted_pd)) +
  xlab("\u03B3 Population PD") +
  ylab("\u03B3 Species PD") +
  xlim(c(-5,0)) +
  ylim(c(-5,0)) +
  theme_classic() +
  theme(legend.position = "none",
        text=element_text(family="serif"))

# MPD
plots_gamma$mpd <- ggplot(data_global) +
  geom_abline(slope = 1,
              intercept = 0,
              linetype = "dashed",
              colour = "grey") +
  geom_point(aes(x = clusters.mpd_log,
                 y = species.mpd_log,
                 colour = skew_MPD),
             alpha = plot_alpha) + 
  scale_colour_manual(values = colours_tk$cb_tol[c(4,2)]) +
  geom_line(aes(x = clusters.mpd_log,
                y = log(fitted_mpd))) +
  xlab("\u03B3 Population MPD") +
  ylab("\u03B3 Species MPD") +
  xlim(c(-5,0)) +
  ylim(c(-5,0)) +
  theme_classic() +
  theme(legend.position = "none",
        text=element_text(family="serif"))


