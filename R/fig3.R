rm(list = ls())

df <- read_feather("dataset/clean/complete_data_350nm.feather") %>% 
  filter(absorption >= 3.754657e-05) %>% # Clear outlier
  mutate(ecosystem = factor(ecosystem,
                            levels = c("wetland",
                                       "pond",
                                       "lake",
                                       "river",
                                       "sewage",
                                       "coastal",
                                       "brines",
                                       "estuary",
                                       "ocean"
                                       ),
                            labels = c("Wetland",
                                       "Pond",
                                       "Lake",
                                       "River",
                                       "Sewage",
                                       "Coastal",
                                       "Brines",
                                       "Estuary",
                                       "Ocean")
                            )
         )

# Plot --------------------------------------------------------------------

p1 <- df %>% 
  ggplot(aes(x = ecosystem, y = absorption)) +
  geom_boxplot(size = 0.1, outlier.size = 0.5, fill = "grey75") +
  xlab("Ecosystem") +
  scale_y_log10() +
  annotation_logticks(side = "l") +
  ylab(bquote(a[CDOM](350)~(m^{-1}))) +
  theme(axis.ticks.x = element_blank()) +
  theme(axis.title.x = element_blank()) +
  theme(axis.text.x = element_blank()) +
  annotate("text", Inf, Inf, label = "A",
           vjust = 2, hjust = 2, size = 5, fontface = "bold")

p2 <- df %>% 
  ggplot(aes(x = ecosystem, y = doc)) +
  geom_boxplot(size = 0.1, outlier.size = 0.5, fill = "grey75") +
  xlab("Ecosystem") +
  scale_y_log10() +
  annotation_logticks(side = "l") +
  ylab(bquote(DOC~(mu*mC%*%L^{-1}))) +
  theme(axis.ticks.x = element_blank()) +
  theme(axis.title.x = element_blank()) +
  theme(axis.text.x = element_blank()) +
  annotate("text", Inf, Inf, label = "B",
           vjust = 2, hjust = 2, size = 5, fontface = "bold")

df <- df %>% 
  mutate(a_star = absorption / doc)

p3 <- df %>% 
  ggplot(aes(x = ecosystem, y = a_star)) +
  geom_boxplot(size = 0.1, outlier.size = 0.5, fill = "grey75") +
  xlab("Ecosystems") +
  scale_y_log10() +
  annotation_logticks(side = "l") +
  ylab(bquote(a^{"*"})) +
  annotate("text", Inf, Inf, label = "C",
           vjust = 2, hjust = 2, size = 5, fontface = "bold")


p4 <- data.frame(x = 0:1, y = c(0.5, 0.5)) %>% 
  ggplot(aes(x = x, y = y)) +
  geom_path(size = 2, arrow = arrow(type = "closed", length = unit(0.25, "inches"))) +
  annotate("text", x = 0, y = 0.51, label = "Freshwater", hjust = -0.05,
           fontface = "bold", size = 5) +
  annotate("text", x = 1, y = 0.51, label = "Marine water", hjust = 1.25, 
           fontface = "bold", size = 5) +
  theme(axis.line=element_blank(),
        axis.text.x=element_blank(),
        axis.text.y=element_blank(),
        axis.ticks=element_blank(),
        axis.title.x=element_blank(),
        axis.title.y=element_blank(),
        legend.position="none",
        panel.background=element_blank(),
        panel.border=element_blank(),
        panel.grid.major=element_blank(),
        panel.grid.minor=element_blank(),
        plot.background=element_blank()) +
  coord_cartesian(ylim = c(0.49,0.52))


p <- cowplot::plot_grid(p1, p2, p3, p4, ncol = 1, 
                        align = "hv", rel_heights = c(1,1,1,0.35))
cowplot::save_plot("graphs/fig3.pdf", p, base_height = 10, base_width = 6)
embed_fonts("graphs/fig3.pdf")
