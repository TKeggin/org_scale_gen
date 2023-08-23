# Extract coefficient information ----
colours_tk$cb_tol[c(4,2)]

# richness
results_rich <- tidy(rich_none)

results <- results_rich

fit_cis_95 <- confint(rich_none, level = 0.95) %>% 
  data.frame() %>%
  rename("low_95" = "X2.5..",
         "high_95" = "X97.5..")

results_rich <- bind_cols(results_rich, 
                          fit_cis_95) %>%
  rename(Parameter = term,
         Coefficient = estimate,
         SE = std.error) %>%
  filter(Parameter != "(Intercept)")

results_rich$SE_max <- results_rich$Coefficient + results_rich$SE
results_rich$SE_min <- results_rich$Coefficient - results_rich$SE

results_rich$facet <- "richness"



# PD
results_PD <- tidy(PD_none)

fit_cis_95 <- confint(PD_none, level = 0.95) %>% 
  data.frame() %>%
  rename("low_95" = "X2.5..",
         "high_95" = "X97.5..")

results_PD <- bind_cols(results_PD, 
                        fit_cis_95) %>%
  rename(Parameter = term,
         Coefficient = estimate,
         SE = std.error) %>%
  filter(Parameter != "(Intercept)")

results_PD$SE_max <- results_PD$Coefficient + results_PD$SE
results_PD$SE_min <- results_PD$Coefficient - results_PD$SE

results_PD$facet <- "PD"

# MPD
results_MPD <- tidy(MPD_none)

fit_cis_95 <- confint(MPD_none, level = 0.95) %>% 
  data.frame() %>%
  rename("low_95" = "X2.5..",
         "high_95" = "X97.5..")

results_MPD <- bind_cols(results_MPD, 
                         fit_cis_95) %>%
  rename(Parameter = term,
         Coefficient = estimate,
         SE = std.error) %>%
  filter(Parameter != "(Intercept)")

results_MPD$SE_max <- results_MPD$Coefficient + results_MPD$SE
results_MPD$SE_min <- results_MPD$Coefficient - results_MPD$SE

results_MPD$facet <- "MPD"

# combine results
results <- rbind(results_rich,
                 results_PD,
                 results_MPD)

results$significant <- results$p.value < 0.05

# plot coefficients ----
# non-sig  = grey
# positive = colours_tk$cb_tol[2]
# negative = colours_tk$cb_tol[4]

results$colours <- NA
results$colours[which(results$Coefficient > 0)]      <- "positive"
results$colours[which(results$Coefficient < 0)]      <- "negative"
results$colours[which(results$significant == FALSE)] <- "non-sig"
results$colours <- as.factor(results$colours)

coef_colours <- c("grey",
                  colours_tk$cb_tol[2],
                  colours_tk$cb_tol[4])
names(coef_colours) <- c("non-sig",
                         "positive",
                         "negative")

# convert metric names for readability
results[results == "dispRange_log"]    <- "Dispersal range"
results[results == "t_opt"]            <- "Thermal optimum"
results[results == "n_width"]          <- "Competitive niche size"
results[results == "initialAbundance"] <- "Initial abundance"
results[results == "speciation_log"]   <- "Speciation threshold"
results[results == "mutationRate"]     <- "Mutation rate"

results[results == "richness"] <- "Richness"
results[results == "PD"]       <- "Phylogenetic diversity"
results[results == "MPD"]      <- "Mean pairwise distance"

results$facet <- factor(results$facet,
                        levels = c("Richness",
                                   "Phylogenetic diversity",
                                   "Mean pairwise distance"))

# coefficient plot
plot_coef <- ggplot(results, 
                    aes(x = Parameter,
                        y = Coefficient,
                        colour = colours)) +
  
  scale_colour_manual(values = coef_colours) +
  geom_hline(yintercept = 0, 
             colour = "black",
             lty = 2) +
  geom_point(size = 3) +
  geom_linerange(aes(ymin = low_95,
                     ymax = high_95),
                 size = 1) +
  facet_wrap(~facet,
             nrow = 3,
             scales = "free_y") +
  xlab("") +
  coord_flip() +
  theme_classic() +
  theme(legend.position = "none",
        text=element_text(family="serif"))


# plot speciation ----
data_sp <- data_global %>% 
  pivot_longer(cols = c(contRichness_log,
                        contPD_log,
                        contMPD_log),
               names_to = "facet",
               values_to = "Continuity")

data_sp$skew <- data_sp$Continuity > 0

data_sp[data_sp == "contRichness_log"] <- "Richness"
data_sp[data_sp == "contPD_log"]       <- "Phylogenetic diversity"
data_sp[data_sp == "contMPD_log"]      <- "Mean pairwise distance"

data_sp$facet <- factor(data_sp$facet,
                        levels = c("Richness",
                                   "Phylogenetic diversity",
                                   "Mean pairwise distance"))

plot_sp <-
  ggplot(data_sp) +
  geom_point(aes(x = speciation,
                 y = Continuity,
                 colour = skew),
             alpha = plot_alpha) + 
  scale_colour_manual(values = colours_tk$cb_tol[c(4,2)]) +
  geom_hline(yintercept = 0,
             linetype = "dashed",
             colour = "grey") +
  facet_wrap(~facet,
             nrow = 3) +
  scale_y_continuous(position = "right") +
  xlab("Speciation threshold") +
  ylab("Continuity") +
  theme_classic() +
  theme(legend.position = "none",
        text=element_text(family="serif"))



# export -----------------------------------------------------------------------
ggsave("./results/plots/continuity.pdf",
       height = 200,
       width = 170,
       units = "mm",
       device = "pdf",
       dpi = 600,
       plot = grid.arrange(grobs = list(plot_coef,
                                        plot_sp),
                           ncol = 2,
                           layout_matrix = rbind(c(rep(1,5),
                                                   rep(2,4)))))





























