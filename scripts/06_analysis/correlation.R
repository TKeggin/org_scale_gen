# set session ------------------------------------------------------------------
library(viridis)
library(ggfortify)
library(ggcorrplot)
library(Hmisc)

plots <- list()

# wrangle data -----------------------------------------------------------------
data_global <- data_filtered %>% filter(region.scale == "GLOBAL")
#data_global <- data_global %>% filter(run_id %in% sample(data_global$run_id,200))

# specify metrics --------------------------------------------------------------
parameters    <- c("dispRange",
                   "speciation",
                   "t_opt",
                   "n_width",
                   "mutationRate",
                   "initialAbundance")
metrics_cont  <- c("contRichness",
                   "contMPD",
                   "contPD")
metrics_const <- c("species.surviving",
                   "species.pd",
                   "species.mpd",
                   "clusters.total",
                   "clusters.pd",
                   "clusters.mpd")
metrics_other <- c(#"species.total",
                    "species.range",
                    #"t_opt.mean",
                    #"t_opt.max",
                    #"t_opt.min",
                    #"t_opt.range",
                    "t_opt.evenness",
                    "t_opt.diversity",
                    #"niche.mean",
                    #"niche.max",
                    #"niche.min",
                    #"niche.range",
                    #"niche.sd",
                    "niche.evenness",
                    "niche.diversity",
                    #"richness.avg",
                    #"richness.max",
                    #"richness.range",
                    #"richness.sd",
                    "endemism.weighted",
                    "species.turnover",
                   #"richness.discrepancy",
                    "diversification.rate")
                   #"landscape_distance",
                   #"landscape_size")
# transform metrics ------------------------------------------------------------
# predictors
par(mfrow = c(2,length(metrics_other)))

for(i in 1:length(metrics_other)){
hist(data_global[,metrics_other[i]],
     main = metrics_other[i])
}
for(i in 1:length(metrics_other)){
  hist(log(data_global[,metrics_other[i]]),
       main = metrics_other[i])
}

# continuity
par(mfrow = c(2,length(metrics_cont)))

for(i in 1:length(metrics_cont)){
  hist(data_global[,metrics_cont[i]],
       main = metrics_cont[i])
}
for(i in 1:length(metrics_cont)){
  hist(log(data_global[,metrics_cont[i]]),
       main = metrics_cont[i])
}

# carry out transformations
data_global$contRichness <- data_global$contRichness
data_global$contPD       <- data_global$contPD
data_global$contMPD      <- data_global$contMPD

data_global$contRichness_log <- log(data_global$contRichness)
data_global$contPD_log       <- log(data_global$contPD)
data_global$contMPD_log      <- log(data_global$contMPD)

data_global$t_opt.evenness_log        <- log(data_global$t_opt.evenness)
data_global$t_opt.diversity_log       <- log(data_global$t_opt.diversity)
data_global$niche.evenness_log        <- log(data_global$niche.evenness)
data_global$richness.avg_log          <- log(data_global$richness.avg)
data_global$endemism.weighted_log     <- log(data_global$endemism.weighted)
data_global$species.turnover_log      <- log(data_global$species.turnover)
data_global$diversification.rate_log  <- log(data_global$diversification.rate)

metrics_cont  <- c("contRichness_log",
                   "contPD_log",
                   "contMPD_log")

metrics_other <- c("species.range",
                   "t_opt.evenness_log",
                   "t_opt.diversity_log",
                   "niche.evenness_log",
                   "niche.diversity",
                   "endemism.weighted_log",
                   "species.turnover_log",
                   "diversification.rate_log")

metrics_all   <- c(metrics_cont,metrics_other)

# correlation ------------------------------------------------------------------
# filter data to metrics only
data_metrics <- data_global %>% dplyr::select(all_of(metrics_all))
data_metrics[,metrics_cont] <- data_metrics[,metrics_cont] # reverse metrics to make arrow point towards species

# create correlation matrix between metrics
cor_mat <- rcorr(as.matrix(data_metrics), type = "spearman")

# bonferroni correction of p-values
cor_mat$P <- cor_mat$P*((length(metrics_all)^2)-length(metrics_all))/2

# make asymmetrical
for(i in 1:length(cor_mat)){
  
  cor_mat[[i]] <- cor_mat[[i]][metrics_other,metrics_cont]
}

# plot correlation matrix
cor_mat_plot <- cor_mat

variable_names <- 
  c("Species range",
    "Thermal evenness",
    "Thermal diversity",
    "Competitive evenness",
    "Competitive diversity",
    "Weighted endemism",
    "Species turnover",
    "Diversification rate")
diversity_names <-
  c("Richness",
    "Phylogenetic diversity",
    "Mean pairwise distance")
  

row.names(cor_mat_plot$r) <- variable_names
row.names(cor_mat_plot$P) <- variable_names
colnames(cor_mat_plot$r)  <- diversity_names
colnames(cor_mat_plot$P)  <- diversity_names


plots$cor_plot <-
  ggcorrplot(cor_mat_plot$r,
             method = "square",
             outline.color = "black",
             show.diag = TRUE,
             p.mat = cor_mat_plot$P,
             #type = "lower",
             #insig = "blank",
             pch.cex = 15,
             colors = c(colours_tk$cb_tol[4],
                        "white",
                        colours_tk$cb_tol[2]),
             ggtheme = theme_void)
# pca --------------------------------------------------------------------------
# make colour matrix for pca
load_col <- cor_mat$r > 0
load_col[which(load_col == TRUE)]  <- colours_tk$cb_tol[2] # dark blue
load_col[which(load_col == FALSE)] <- colours_tk$cb_tol[4] # light blue
load_col[which(cor_mat$P > 0.05)]        <- "darkgrey"

lab_col <- cor_mat$r > 0
lab_col[which(lab_col == TRUE)]  <- "black"
lab_col[which(lab_col == FALSE)] <- "black"
lab_col[which(cor_mat$P > 0.05)] <- "darkgrey"



# loop for each continuity metric
data_pca <- list()
for(cont in 1:length(metrics_cont)){
  
  # set colours
  loading_colours <- data.frame(metric = c(metrics_cont[cont],
                                           metrics_other),
                                colour = c("black",
                                           load_col[,metrics_cont[cont]]))
  label_colours <- data.frame(metric = c(metrics_cont[cont],
                                         metrics_other),
                              colour = c("black",
                                         lab_col[,metrics_cont[cont]]))
  
  # subset dataset
  data_metrics <- data_global %>% dplyr::select(c(all_of(metrics_cont[cont]),
                                                  all_of(metrics_other)))
  data_metrics[,metrics_cont[cont]] <- data_metrics[,metrics_cont[cont]]
  
  # rename variables
  colnames(data_metrics) <-
    c("Continuity",
      variable_names)
  
  # calculate pca
  data_metrics <- na.omit(data_metrics) # remove na values
  data_pca[[metrics_cont[cont]]]     <- prcomp(data_metrics, scale = TRUE)
  
  plots[[metrics_cont[cont]]] <- 
    autoplot(data_pca[[metrics_cont[cont]]],
             x = 1, y = 2,
             data = data_metrics,
             colour = "grey",
             shape = 21,
             size = 2,
             alpha = 0.4,
             label = FALSE,
             loadings = TRUE,
             loadings.size = 10,
             loadings.label = TRUE,
             loadings.label.colour = label_colours$colour,
             loadings.colour = loading_colours$colour,
             loadings.label.size = 4,
             loadings.label.repel=T) +
    ggtitle(diversity_names[cont]) +
    theme_classic() +
    theme(plot.title = element_text(size = 17, face = "bold"),
          text=element_text(family="serif"))
}

# plot -------------------------------------------------------------------------

margin = theme(plot.margin = unit(rep(1.5,4), "cm"))
layout <- rbind(c(6,6,6,1,1,1,1,1,1,6,6,6),
                c(3,3,3,3,4,4,4,4,5,5,5,5)) 

svg("./results/plots/04_correlation.svg",
    width = 15*0.8,
    height = 9.75*0.8)
print(grid.arrange(grobs = plots,
                   layout_matrix = layout))
dev.off()

ggsave("./results/plots/correlation.pdf",
       height = 200,
       width = 400,
       units = "mm",
       device = "pdf",
       dpi = 600,
       grid.arrange(grobs = plots,
                    layout_matrix = layout))



# get pca information
pca_sum_rich <- get_pca_var(data_pca$contRichness_log)
pca_sum_pd   <- get_pca_var(data_pca$contPD_log)
pca_sum_mpd  <- get_pca_var(data_pca$contMPD_log)

# reformat pca information (first two PCs only)
pca_rich <- data.frame(pca_sum_rich$contrib[,1:2])
pca_pd   <- data.frame(pca_sum_pd$contrib[,1:2])
pca_mpd  <- data.frame(pca_sum_mpd$contrib[,1:2])

# rownames as column
pca_rich <- data.frame(Variable = row.names(pca_rich),
                       `Component 1` = pca_rich$Dim.1,
                       `Component 2` = pca_rich$Dim.2)

pca_pd <- data.frame(Variable = row.names(pca_pd),
                       `Component 1` = pca_pd$Dim.1,
                       `Component 2` = pca_pd$Dim.2)

pca_mpd <- data.frame(Variable = row.names(pca_mpd),
                       `Component 1` = pca_mpd$Dim.1,
                       `Component 2` = pca_mpd$Dim.2)

# export PCA component contribution tables
tab_dfs(list(pca_rich,
             pca_pd,
             pca_mpd),
        titles = c("Richness",
                   "PD",
                   "MPD"),
        file = "./results/tables/pca_contrib.doc")

# export summary table ---------------------------------------------------------
# convert to data frame
cor_mat_r <- data.frame(cor_mat_plot$r)
cor_mat_p <- data.frame(cor_mat_plot$P)

cor_mat_r$Trait <- row.names(cor_mat_r)
cor_mat_p$Trait <- row.names(cor_mat_p)

cor_mat_r <- data.frame(Trait = cor_mat_r$Trait,
                        cor_mat_r[,1:3])
cor_mat_p <- data.frame(Trait = cor_mat_p$Trait,
                        cor_mat_p[,1:3])

cor_tables <- list(`r values` = cor_mat_r,
                  `p values` = cor_mat_p)

# export
tab_dfs(cor_tables,
        titles = c("r values",
                   "p values"),
        CSS    = list(css.table = '+font-family: Calibri;'),
        file = "./results/tables/correlation.doc")




