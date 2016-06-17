rm(list = ls())

df <- read_feather("dataset/clean/complete_data_350nm.feather")

# Plot --------------------------------------------------------------------

p1 <- df %>% 
  ggplot(aes(x = reorder(ecosystem, absorption, FUN = median), y = absorption)) +
  geom_boxplot(size = 0.1, outlier.size = 0.5, fill = "grey75") +
  xlab("Ecosystem") +
  scale_y_log10() +
  annotation_logticks(side = "l") +
  ylab(bquote(a[CDOM](350)~(m^{-1}))) +
  annotate("text", -Inf, Inf, label = "A",
           vjust = 2.0, hjust = -1, size = 5, fontface = "bold")

p2 <- df %>% 
  ggplot(aes(x = reorder(ecosystem, doc, FUN = median), y = doc)) +
  geom_boxplot(size = 0.1, outlier.size = 0.5, fill = "grey75") +
  xlab("Ecosystem") +
  scale_y_log10() +
  annotation_logticks(side = "l") +
  ylab(bquote(DOC~(mu*m~C~L^{-1}))) +
  annotate("text", -Inf, Inf, label = "B",
           vjust = 2.0, hjust = -1, size = 5, fontface = "bold")

df <- df %>% 
  mutate(a_star = absorption / doc)

p3 <- df %>% 
  ggplot(aes(x = reorder(ecosystem, a_star, FUN = median), y = a_star)) +
  geom_boxplot(size = 0.1, outlier.size = 0.5, fill = "grey75") +
  xlab("Ecosystem") +
  scale_y_log10() +
  annotation_logticks(side = "l") +
  ylab(bquote(a^{"*"})) +
  annotate("text", -Inf, Inf, label = "C",
           vjust = 2.0, hjust = -1, size = 5, fontface = "bold")

p <- cowplot::plot_grid(p1, p2, p3, ncol = 1)
cowplot::save_plot("graphs/fig3.pdf", p, base_height = 10, base_width = 7)
embed_fonts("graphs/fig3.pdf")
