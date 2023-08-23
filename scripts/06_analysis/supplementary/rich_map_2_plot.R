# set session ----
plots <- c()

# remove tailing low Richness from sim
data_1$rich_sim[data_1$rich_sim < 1000] <- 1000

# wrangle map ----
data_rich <- data_1



# normalise Richness values
data_rich$rich_true <- rescale(data_rich$rich_true, to = c(0,1))
data_rich$rich_sim  <- rescale(data_rich$rich_sim, to = c(0,1))

# pivot to allow facet wrap
data_rich <- data_rich %>% 
  pivot_longer(cols = c(rich_sim,rich_true),
               values_to = "Richness",
               names_to = "source")

# rename for readability
data_rich[data_rich == "rich_sim"]  <- "Simulated"
data_rich[data_rich == "rich_true"] <- "Observed"

# convert to factor to control order
data_rich$source <- factor(data_rich$source,
                           levels = c("Simulated",
                                      "Observed"))

# wrangle longitudal ----
data_long <- data_1
#data_long$rich_sim <- 1

# rescale values
data_long$rich_sim  <- rescale(data_long$rich_sim, to = c(0,1))
data_long$rich_true <- rescale(data_long$rich_true, to = c(0,1))

# aggregate by x
data_long <- data_long %>% 
  group_by(x) %>% 
  summarise(rich_sim = mean(rich_sim, na.rm = TRUE),
            rich_true = mean(rich_true, na.rm = TRUE))

# pivot for plotting
data_long <- data_long %>% 
  pivot_longer(cols = c(rich_sim,rich_true),
               names_to = "source",
               values_to = "Richness")

# wrangle latitude ----
data_lat <- data_1
#data_long$rich_sim <- 1

# rescale values
data_lat$rich_sim  <- rescale(data_lat$rich_sim, to = c(0,1))
data_lat$rich_true <- rescale(data_lat$rich_true, to = c(0,1))

# aggregate by x
data_lat <- data_lat %>% 
  group_by(y) %>% 
  summarise(rich_sim = mean(rich_sim, na.rm = TRUE),
            rich_true = mean(rich_true, na.rm = TRUE))

# pivot for plotting
data_lat <- data_lat %>% 
  pivot_longer(cols = c(rich_sim,rich_true),
               names_to = "source",
               values_to = "Richness")

# plot map ----
background_alpha <- 0.5

plots$map <- ggplot() +
  # entire landscape
  geom_contour_filled(data = plot_all,
                      aes(x=x,y=y,
                          z = depth),
                      alpha = background_alpha,
                      breaks = contour_breaks,
                      na.rm = TRUE) +
  
  geom_contour(data = plot_all,
               aes(x=x,y=y,
                   z = depth),
               size = 0.5,
               lineend = "round",
               colour = "black",
               alpha = background_alpha,
               breaks = contour_breaks,
               na.rm = TRUE) +
  
  scale_fill_manual(values = c("#D9AD77",
                               "#04B2D9")) +
  
  # set new colour scales
  new_scale_fill() +
  
  # equator
  geom_hline(yintercept = 0,
             alpha = background_alpha+0.05) +
  
  # Richness_sim
  geom_tile(data = data_rich,
            aes(x=x,y=y),
            fill = "transparent",
            colour = "black",
            size = 0.2) + 
  
  geom_tile(data = data_rich,
            aes(x=x,y=y,
                fill = Richness),
            colour = "transparent",
            size = 0.2) + 
  
  scale_fill_viridis_c() +
  
  # split into obs and sim
  facet_wrap(~source,
             nrow = 2) +
  
  # other
  coord_fixed() +
  scale_x_continuous(limits = c(-180,180), expand = c(0, 0)) +
  scale_y_continuous(limits = c(-30,30), expand = c(0, 0)) +
  xlab("Longitude") +
  ylab("Latitude") +
  theme_classic()  +
  theme(text=element_text(family="serif"))
  #theme(legend.position = "none")

# plot Longitude ----

plots$long <- ggplot(data_long, aes(x = x, y = Richness)) +
  #geom_point(aes(colour = source)) +
  geom_smooth(aes(colour = source,
                  fill = source),
              alpha = 0.1,
              se = TRUE,
              method = "gam") +
  scale_colour_manual(values = realm_colours[c(3,1)]) +
  scale_fill_manual(values = realm_colours[c(3,1)]) +
  scale_x_continuous(limits = c(-180,180), expand = c(0, 0)) +
  theme_classic() +
  theme(legend.position = "none",
        axis.title.x=element_blank(),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank(),
        axis.line.x = element_blank()) +
  theme(text=element_text(family="serif"))

# plot latitude ----
# simulated
data_lat_sim <- data_lat %>% filter(source == "rich_sim")

plots$lat_sim <- ggplot(data_lat_sim, aes(x = y, y = Richness)) +
  #geom_point(aes(colour = source)) +
  geom_smooth(aes(colour = source,
                  fill = source),
              alpha = 0.1,
              se = TRUE,
              method = "gam") +
  xlab("Latitude") +
  coord_flip() +
  scale_colour_manual(values = realm_colours[c(3)]) +
  scale_fill_manual(values = realm_colours[c(3)]) +
  theme_void() +
  theme(legend.position = "none") +
  theme(text=element_text(family="serif"))

# observed
data_lat_sim <- data_lat %>% filter(source == "rich_true")

plots$lat_obv <- ggplot(data_lat_sim, aes(x = y, y = Richness)) +
  #geom_point(aes(colour = source)) +
  geom_smooth(aes(colour = source,
                  fill = source),
              alpha = 0.1,
              se = TRUE,
              method = "gam") +
  xlab("Latitude") +
  coord_flip() +
  scale_colour_manual(values = realm_colours[c(1)]) +
  scale_fill_manual(values = realm_colours[c(1)]) +
  theme_classic() +
  theme(legend.position = "none",
        axis.title.y=element_blank(),
        axis.text.y=element_blank(),
        axis.ticks.y=element_blank(),
        axis.line.y = element_blank()) +
  theme(text=element_text(family="serif"))

# export ----
# map
ggsave("./results/plots/map_heatmaps.pdf",
       height = 60*2,
       width = 135*2,
       units = "mm",
       device = "pdf",
       dpi = 600,
       plot = plots$map)

# longitude
ggsave("./results/plots/map_long.pdf",
       height = 20*2,
       width = 180*2,
       units = "mm",
       device = "pdf",
       dpi = 600,
       plot = plots$long)

# latitude
ggsave("./results/plots/map_lat_sim.pdf",
       height = 30*2,
       width = 10*2,
       units = "mm",
       device = "pdf",
       dpi = 600,
       plot = plots$lat_sim)

ggsave("./results/plots/map_lat_obv.pdf",
       height = 30*2,
       width = 10*2,
       units = "mm",
       device = "pdf",
       dpi = 600,
       plot = plots$lat_obv)


grid.arrange(grobs = plots)
