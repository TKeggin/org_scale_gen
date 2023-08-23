# gamma and beta plots ----
plots <- list(plots_beta$rich,
              plots_gamma$rich,
              
              plots_beta$pd,
              plots_gamma$pd,
              
              plots_beta$mpd,
              plots_gamma$mpd)

main_plot <- grid.arrange(grobs  = plots,
                          nrow = 3)

# export ----
ggsave("./results/plots/sgdc.pdf",
       height = 200,
       width = 170,
       units = "mm",
       device = cairo_pdf,
       dpi = 600,
       plot = grid.arrange(grobs  = plots,
                           nrow = 3))
