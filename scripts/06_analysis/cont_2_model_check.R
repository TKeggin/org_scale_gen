
# richness ----
# plot fitted vs observed
data_global$fitted <- rich_select$fitted.values
plot(log(data_global$contRichness),data_global$fitted)
plot(data_global$speciation,data_global$fitted)

data_fit <- data_global
data_fit <- data_fit %>% pivot_longer(cols = c(contRichness_log,fitted),
                                      names_to = "type",
                                      values_to = "continuity")

data <- data_fit %>% pivot_longer(names_to = "metric",
                                  cols = all_of(params))

ggplot(data, aes(x = value,
                 y = continuity,
                 colour = type)) +
  geom_point(#shape = 21,
    size = 2) +
  geom_hline(yintercept = 0,
             linetype = "dashed") +
  facet_wrap(vars(metric), scales = "free") +
  scale_colour_manual(values = realm_colours[c(1,3)]) +
  theme_classic()


# PD ----

# plot fitted vs real
data_global$fitted <- PD_select$fitted.values
plot(log(data_global$contPD),data_global$fitted)


data_fit <- data_global
data_fit <- data_fit %>% pivot_longer(cols = c(contPD_log,fitted),
                                      names_to = "type",
                                      values_to = "continuity")

data <- data_fit %>% pivot_longer(names_to = "metric",
                                  cols = all_of(params))

ggplot(data, aes(x = value,
                 y = continuity,
                 colour = type)) +
  geom_point() +
  facet_wrap(vars(metric), scales = "free") +
  scale_colour_manual(values = realm_colours[c(1,4)]) +
  theme_classic()

# MPD ----

# plot fitted vs real
data_global$fitted <- MPD_select$fitted.values
plot(log(data_global$contMPD),data_global$fitted)


data_fit <- data_global
data_fit <- data_fit %>% pivot_longer(cols = c(contMPD_log,fitted),
                                      names_to = "type",
                                      values_to = "continuity")

data <- data_fit %>% pivot_longer(names_to = "metric",
                                  cols = all_of(params))

ggplot(data, aes(x = value,
                 y = continuity,
                 colour = type)) +
  geom_point() +
  geom_hline(yintercept = 0,
             linetype = "dashed") +
  facet_wrap(vars(metric), scales = "free") +
  scale_colour_manual(values = realm_colours[c(1,4)]) +
  theme_classic()

