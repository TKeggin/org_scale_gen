# This script is to plot a demo of populations and clusters


# wrangle data ----
land_all <- readRDS("./data_processed/seascapes/landscapes.rds")
coords   <- land_all$depth[,c(1:3)]
colnames(coords) <- c("x",
                      "y",
                      "depth")

dist_mat <-
  readRDS("./data_processed/seascapes/distances_full/distances_full_0.rds")

data_global <-
  data_filtered %>% 
  filter(region.scale == "GLOBAL")

simulation <- 1958

# load in a high cluster simulation
species   <- readRDS(paste0("data_processed/genesis_output/",simulation,"/species/species_t_0.rds"))
dispersal <- data_global$dispRange[which(data_global$run_id == simulation)]
species   <- clusterDetermine(dispersal,
                              dist_mat,
                              species)
speciesExtant(species)

species_chosen <- species[[23]] # 15 / 20 / 23

c(length(species_chosen$populations),
  length(unique(species_chosen$populations)))

# assign clusters


# wrangle contour data
contour_breaks     <- c(seq(from = 1000, to = -8000, by = -1000)) # set depth bins
contour_breaks     <- c(1000,0,-8000)

plot_all           <- coords 
colnames(plot_all) <- c("x","y","depth") # rename
plot_all$depth     <- cut(x = plot_all$depth, # bin depth values - this is janky
                          breaks = contour_breaks,
                          labels = contour_breaks[-3])
plot_all$depth     <- as.numeric(levels(plot_all$depth))[plot_all$depth] # convert depth levels as numeric values
plot_all$depth[is.na(plot_all$depth)] <- 1 # set land to 1 to include it in the colour scale



# plot ----
# merge landscape and populations
populations <-
  data.frame(cluster = factor(species_chosen$populations)) %>% 
  rownames_to_column()

coords_plot <- 
  coords %>% 
  rownames_to_column()

data_plot <- left_join(populations,
                       coords_plot)



# load landscape
print_me <- 
  ggplot() +
  geom_contour_filled(data = plot_all,
                      aes(x=x,y=y,
                          z = depth),
                      alpha = 0.2,
                      breaks = contour_breaks,
                      na.rm = TRUE) +
  
  geom_contour(data = plot_all,
               aes(x=x,y=y,
                   z = depth),
               size = 0.3,
               lineend = "round",
               colour = "black",
               alpha = 0.2,
               breaks = contour_breaks,
               na.rm = TRUE) +
  
  scale_fill_manual(values = c("#D9AD77",
                               "#04B2D9")) +
  
  new_scale_fill() +
  
  geom_tile(data = data_plot,
            aes(x=x,y=y,
                fill = cluster),
            colour = "black",
            size = 0.2) +
  geom_tile(data = data_plot,
            aes(x=x,y=y,
                fill = cluster),
            colour = "transparent",
            size = 0.2) +
  
  scale_x_continuous(limits = c(-120,30), expand = c(0, 0)) +
  scale_y_continuous(limits = c(-30,30), expand = c(0, 0)) +
  
  scale_fill_manual(values = colours_tk$cb_tol[c(3,5,4)]) +
  coord_fixed() +
  theme_void() +
  theme(legend.position = "none")


# export ----
ggsave("./results/plots/cluster_plot.pdf",
       height = 50,
       width = 85,
       units = "mm",
       device = "pdf",
       dpi = 600,
       plot = print_me)
