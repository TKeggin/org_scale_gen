# set --------------------------------------------------------------------------
library(tidyverse)

# load -------------------------------------------------------------------------
region_id <-
  read_csv("./data_processed/ecoregions/01_region_ids.csv",
           show_col_types = FALSE) %>% 
  rename(Realm = REALM)

# plot -------------------------------------------------------------------------
plot_realm <- 
  ggplot() +
  geom_tile(data = region_id, aes(x=x,y=y,fill=Realm)) +
  ylab("Latitude") +
  xlab("Longitude") +
  coord_fixed() +
  scale_fill_manual(values = colours_tk$cb_tol[-1]) +
  theme_classic() +
  theme(text=element_text(family="serif"))

# export -----------------------------------------------------------------------
ggsave("./results/plots/realms.pdf",
       height = 170*0.75,
       width = 400*0.75,
       units = "mm",
       device = "pdf",
       dpi = 600,
       plot = plot_realm)
