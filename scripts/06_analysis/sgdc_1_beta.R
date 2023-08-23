# set session ----
data_global <- data_filtered %>% 
  filter(region.scale == "GLOBAL")

data_realm <- data_filtered %>% 
  filter(region.scale == "REALM")

betas <- c("beta_rich",
           "beta_PD",
           "beta_MPD")

runs <- unique(data_realm$run_id)

# richness ----
# species
run_div <- c()
for(i in 1:length(runs)){
  
  data_run <- data_realm %>%
    filter(run_id == runs[i]) %>% 
    dplyr::select(c(region.id,species.surviving)) %>% 
    filter(!is.na(species.surviving))
  
  cont <- data_run$species.surviving
  names(cont) <- data_run$region.id
  
  cont_beta <- mean(dist(cont))
  
  run_div <- c(run_div,cont_beta)
}

data_global$beta_species.surviving <- run_div

# clusters
run_div <- c()
for(i in 1:length(runs)){
  
  data_run <- data_realm %>%
    filter(run_id == runs[i]) %>% 
    dplyr::select(c(region.id,clusters.total)) %>% 
    filter(!is.na(clusters.total))
  
  cont <- data_run$clusters.total
  names(cont) <- data_run$region.id
  
  cont_beta <- mean(dist(cont))
  
  run_div <- c(run_div,cont_beta)
}

data_global$beta_clusters.total <- run_div

# pd ----
# species
run_div <- c()
for(i in 1:length(runs)){
  
  data_run <- data_realm %>%
    filter(run_id == runs[i]) %>% 
    dplyr::select(c(region.id,species.pd)) %>% 
    filter(!is.na(species.pd))
  
  cont <- data_run$species.pd
  names(cont) <- data_run$region.id
  
  cont_beta <- mean(dist(cont))
  
  run_div <- c(run_div,cont_beta)
}

data_global$beta_species.pd <- run_div

# clusters
run_div <- c()
for(i in 1:length(runs)){
  
  data_run <- data_realm %>%
    filter(run_id == runs[i]) %>% 
    dplyr::select(c(region.id,clusters.pd)) %>% 
    filter(!is.na(clusters.pd))
  
  cont <- data_run$clusters.pd
  names(cont) <- data_run$region.id
  
  cont_beta <- mean(dist(cont))
  
  run_div <- c(run_div,cont_beta)
}

data_global$beta_clusters.pd <- run_div


# mpd ----
# species
run_div <- c()
for(i in 1:length(runs)){
  
  data_run <- data_realm %>%
    filter(run_id == runs[i]) %>% 
    dplyr::select(c(region.id,species.mpd)) %>% 
    filter(!is.na(species.mpd))
  
  cont <- data_run$species.mpd
  names(cont) <- data_run$region.id
  
  cont_beta <- mean(dist(cont))
  
  run_div <- c(run_div,cont_beta)
}

data_global$beta_species.mpd <- run_div

# clusters
run_div <- c()
for(i in 1:length(runs)){
  
  data_run <- data_realm %>%
    filter(run_id == runs[i]) %>% 
    dplyr::select(c(region.id,clusters.mpd)) %>% 
    filter(!is.na(clusters.mpd))
  
  cont <- data_run$clusters.mpd
  names(cont) <- data_run$region.id
  
  cont_beta <- mean(dist(cont))
  
  run_div <- c(run_div,cont_beta)
}

data_global$beta_clusters.mpd <- run_div

# model ----
# richness
par(mfrow = c(2,2))
hist(data_global$beta_species.surviving)
hist(data_global$beta_clusters.total)

data_global$beta_species.surviving_log <- log(data_global$beta_species.surviving)
data_global$beta_clusters.total_log    <- log(data_global$beta_clusters.total)

data_rich <- data_global %>% 
  filter(!is.infinite(beta_clusters.total_log)) %>% 
  filter(!is.infinite(beta_species.surviving_log))

lm_rich <- lm(beta_species.surviving_log ~
                beta_clusters.total_log,
              data = data_rich)
summary(lm_rich)
plot(lm_rich)

data_rich$fitted <- lm_rich$fitted.values

# pd
par(mfrow = c(2,2))
hist(data_global$beta_species.pd)
hist(data_global$beta_clusters.pd)

data_global$beta_species.pd_log <- log(data_global$beta_species.pd)
data_global$beta_clusters.pd_log    <- log(data_global$beta_clusters.pd)

data_pd <- data_global %>% 
  filter(!is.infinite(beta_clusters.pd_log)) %>% 
  filter(!is.infinite(beta_species.pd_log))

lm_pd <- lm(beta_species.pd_log ~
                beta_clusters.pd_log,
              data = data_pd)
summary(lm_rich)
plot(lm_pd)

data_pd$fitted <- lm_pd$fitted.values

# mpd
par(mfrow = c(2,2))
hist(data_global$beta_species.mpd)
hist(data_global$beta_clusters.mpd)

data_global$beta_species.mpd_log <- log(data_global$beta_species.mpd)
data_global$beta_clusters.mpd_log    <- log(data_global$beta_clusters.mpd)

data_mpd <- data_global %>% 
  filter(!is.infinite(beta_clusters.mpd_log)) %>% 
  filter(!is.infinite(beta_species.mpd_log))

lm_mpd <- lm(beta_species.mpd_log ~
              beta_clusters.mpd_log,
            data = data_mpd)
summary(lm_rich)
plot(lm_mpd)

data_mpd$fitted <- lm_mpd$fitted.values

# plot ----
plots_beta <- list()
# richness
data_rich$skew <- data_rich$beta_species.surviving_log > data_rich$beta_clusters.total_log

plots_beta$rich <- ggplot(data_rich,
       aes(x = log(beta_clusters.total),
           y = log(beta_species.surviving))) +
  geom_abline(slope = 1,
              linetype = "dashed",
              colour = "grey") +
  geom_point(aes(colour = skew),
             alpha = plot_alpha) +
  geom_line(aes(y = fitted)) +
  scale_colour_manual(values = colours_tk$cb_tol[c(5,6)]) +
  xlab("β Population Richness") +
  ylab("β Species Richness") +
  xlim(c(-9,0)) +
  ylim(c(-9,0)) +
  theme_classic() +
  theme(legend.position = "none",
        text=element_text(family="serif"))
# pd
data_pd$skew <- data_pd$beta_species.pd > data_pd$beta_clusters.pd

plots_beta$pd <- ggplot(data_pd,
       aes(x = log(beta_clusters.pd),
           y = log(beta_species.pd))) +
  geom_abline(slope = 1,
              linetype = "dashed",
              colour = "grey") +
  geom_point(aes(colour = skew),
             alpha = plot_alpha) +
  geom_line(aes(y = fitted)) +
  scale_colour_manual(values = colours_tk$cb_tol[c(5,6)]) +
  xlab("β Population PD") +
  ylab("β Species PD") +
  xlim(c(-9,0)) +
  ylim(c(-9,0)) +
  theme_classic() +
  theme(legend.position = "none",
        text=element_text(family="serif"))

# mpd
data_mpd$skew <- data_pd$beta_species.mpd > data_pd$beta_clusters.mpd

plots_beta$mpd <- ggplot(data_mpd,
       aes(x = log(beta_clusters.mpd),
           y = log(beta_species.mpd))) +
  geom_abline(slope = 1,
              linetype = "dashed",
              colour = "grey") +
  geom_point(aes(colour = skew),
             alpha = plot_alpha) +
  geom_line(aes(y = fitted)) +
  scale_colour_manual(values = colours_tk$cb_tol[c(5,6)]) +
  xlab("β Population MPD") +
  ylab("β Species MPD") +
  xlim(c(-9,0)) +
  ylim(c(-9,0)) +
  theme_classic() +
  theme(legend.position = "none",
        text=element_text(family="serif"))












