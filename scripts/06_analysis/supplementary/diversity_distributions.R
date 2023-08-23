# set session ------------------------------------------------------------------

# wrangle data -----------------------------------------------------------------
# species
data_dist_rich <- data_filtered %>%
  filter(region.scale == "GLOBAL") %>% 
  pivot_longer(cols = c(species.surviving),
               values_to = "diversity",
               names_to = "metric") %>% 
  dplyr::select(c(run_id,
                  diversity,
                  metric))
data_dist_rich$facet <- "Richness"

data_dist_pd <- data_filtered %>%
  filter(region.scale == "GLOBAL") %>% 
  pivot_longer(cols = c(species.pd),
               values_to = "diversity",
               names_to = "metric") %>% 
  dplyr::select(c(run_id,
                  diversity,
                  metric))
data_dist_pd$facet <- "Phylogenetic diversity"

data_dist_mpd <- data_filtered %>%
  filter(region.scale == "GLOBAL") %>% 
  pivot_longer(cols = c(species.mpd),
               values_to = "diversity",
               names_to = "metric") %>% 
  dplyr::select(c(run_id,
                  diversity,
                  metric))
data_dist_mpd$facet <- "Mean pairwise distance"

data_dist_spp <- rbind(data_dist_rich,
                       data_dist_pd,
                       data_dist_mpd)

data_dist_spp$level <- "species"

# cluster
data_dist_rich <- data_filtered %>%
  filter(region.scale == "GLOBAL") %>% 
  pivot_longer(cols = c(clusters.total),
               values_to = "diversity",
               names_to = "metric") %>% 
  dplyr::select(c(run_id,
                  diversity,
                  metric))
data_dist_rich$facet <- "Richness"

data_dist_pd <- data_filtered %>%
  filter(region.scale == "GLOBAL") %>% 
  pivot_longer(cols = c(clusters.pd),
               values_to = "diversity",
               names_to = "metric") %>% 
  dplyr::select(c(run_id,
                  diversity,
                  metric))
data_dist_pd$facet <- "Phylogenetic diversity"

data_dist_mpd <- data_filtered %>%
  filter(region.scale == "GLOBAL") %>% 
  pivot_longer(cols = c(clusters.mpd),
               values_to = "diversity",
               names_to = "metric") %>% 
  dplyr::select(c(run_id,
                  diversity,
                  metric))
data_dist_mpd$facet <- "Mean pairwise distance"

data_dist_pop <- rbind(data_dist_rich,
                       data_dist_pd,
                       data_dist_mpd)

data_dist_pop$level <- "population"

# merge levels
data_dist <- rbind(data_dist_spp,
                   data_dist_pop)

# set metrics as factors for the order
data_dist$facet <- factor(data_dist$facet,
                          levels = c("Richness",
                                     "Phylogenetic diversity",
                                     "Mean pairwise distance"))

data_dist$diversity_log <- log(data_dist$diversity)

# compare runs -----------------------------------------------------------------
data_run <-
  data_dist %>% 
  dplyr::select(-c(diversity_log,metric)) %>% 
  pivot_wider(names_from = level,
              values_from = diversity) %>% 
  mutate(more_species = species > population) %>% 
  group_by(facet, more_species) %>% 
  summarise(n = n(), .groups = "keep") %>% 
  pivot_wider(names_from = more_species,
              values_from = n) %>% 
  rename(more_species = `TRUE`,
         more_populations = `FALSE`) %>% 
  mutate(per_more_sp = (more_species/(more_species+more_populations))*100)

# plot -------------------------------------------------------------------------
# normal
plot_dist <- ggplot(data_dist, aes(x = diversity)) +
  geom_density(aes(fill = level),
               alpha = 0.5) +
  scale_fill_manual(values = c(colours_tk$cb_tol[c(4,2)])) +
  facet_wrap(~facet,
             nrow = 3,
             scales = "free_y") +
  theme_classic()

# logged
plot_dist_log <- ggplot(data_dist, aes(x = diversity_log)) +
  geom_density(aes(fill = level),
               alpha = 0.5) +
  scale_fill_manual(values = c(colours_tk$cb_tol[c(4,2)])) +
  facet_wrap(~facet,
             nrow = 3,
             scales = "free_y") +
  theme_classic()

# export -----------------------------------------------------------------------
svg(paste0(dir_plot,"diversity_distributions.svg"),
    height = 10,
    width = 5)

print(plot_dist)

dev.off()
