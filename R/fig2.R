#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Explore the relation between aCDOM350 and aCDOM at various
#               wavelengths.
#               
#               This script produces figure 2 for the manuscript.
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

f <- function(x, y) {
  
  fit <- lm(y$absorption ~ x$absorption)
  
  s <- summary(fit)
  
  df <- data_frame(intercept = coef(fit)[1], 
                   slope = coef(fit)[2],
                   r.squared = s$r.squared)
  
  return(df)
}

cdom_doc <- read_feather("dataset/clean/cdom_dataset.feather") %>%
  filter(study_id != "nelson") %>% # Nelson is missing wl < 275
  filter(study_id != "greenland_lakes") %>%  # These had lamp problem at 360 nm
  filter(study_id != "horsen") %>% 
  filter(wavelength <= 500) %>% 
  group_by(wavelength) %>% 
  nest()

target_wl <- filter(cdom_doc, wavelength == 350)

models <- map2(cdom_doc$data, target_wl$data, f) %>% 
  bind_rows() %>% 
  mutate(wavelength = cdom_doc$wavelength)

# Plot --------------------------------------------------------------------

p1 <- ggplot(models, aes(x = wavelength, y = r.squared)) +
  geom_point(size = 0.5) +
  ylab(expression(R^2)) +
  theme(axis.ticks.x = element_blank()) +
  theme(axis.title.x = element_blank()) +
  theme(axis.text.x = element_blank()) +
  annotate("text", Inf, Inf, label = "A",
           vjust = 1.5, hjust = 1.5, size = 5, fontface = "bold") +
  scale_x_continuous(breaks = seq(250, 500, length.out = 6), limits = c(250, 515)) +
  scale_y_continuous(limits = c(0.85, 1))

p2 <- ggplot(models, aes(x = wavelength, y = slope)) +
  geom_point(size = 0.5) +
  ylab("Slope") +
  theme(axis.ticks.x = element_blank()) +
  theme(axis.title.x = element_blank()) +
  theme(axis.text.x = element_blank()) +
  annotate("text", Inf, Inf, label = "B",
           vjust = 1.5, hjust = 1.5, size = 5, fontface = "bold") +
  scale_x_continuous(breaks = seq(250, 500, length.out = 6), limits = c(250, 515))

p3 <- ggplot(models, aes(x = wavelength, y = intercept)) +
  geom_point(size = 0.5) +
  ylab(bquote("Intercept "*(m^{-1}))) +
  xlab("Wavelength (nm)") +
  annotate("text", Inf, Inf, label = "C",
           vjust = 1.5, hjust = 1.5, size = 5, fontface = "bold") +
  scale_x_continuous(breaks = seq(250, 500, length.out = 6), limits = c(250, 515))

p <- cowplot::plot_grid(p1, p2, p3, ncol = 1, 
                        align = "v", rel_heights = c(1,1,1.2))
cowplot::save_plot("graphs/fig2.pdf", 
                   p, 
                   base_height = 5,
                   base_width = 3.5)
embed_fonts("graphs/fig2.pdf")

# Raster plot -------------------------------------------------------------

f <- function(x, y) {
  
  fit <- RcppArmadillo::fastLm(x$absorption, y$absorption)
  
  return(summary(fit)$r.squared )
}

cdom_doc <- read_feather("dataset/clean/cdom_dataset.feather") %>%
  filter(study_id != "nelson") %>% # Nelson is missing wl < 275
  filter(study_id != "greenland_lakes") %>%  # These had lamp problem at 360 nm
  filter(study_id != "horsen") %>% 
  filter(wavelength <= 500) %>% 
  group_by(wavelength) %>% 
  nest()

# Take ~ 1-2 minute(s)
res <- outer(cdom_doc$data, cdom_doc$data, Vectorize(f)) %>% 
  data.frame() %>% 
  mutate(wavelength = 250:500)

names(res) <- c(paste("W", 250:500, sep = ""), "wavelength")

res <- gather(res, wavelength2, r2, -wavelength) %>% 
  mutate(wavelength2 = extract_numeric(wavelength2))

jet.colors <- colorRampPalette(c("#00007F", "blue", "#007FFF", "cyan", "#7FFF7F", "yellow", "#FF7F00", "red", "#7F0000"))

st <- "This shows the R2 of the linear regression between acdom at wl 1 against acdom at wl 2"
st <- paste0(strwrap(st, 70), sep = "", collapse = "\n")


# Plot --------------------------------------------------------------------

ggplot(res, aes(x = wavelength, wavelength2, fill = r2)) +
  geom_raster() +
  scale_fill_gradientn(colours = rev(jet.colors(255))) +
  scale_x_continuous(expand = c(0, 0)) +
  scale_y_continuous(expand = c(0, 0)) +
  # ggtitle("Prediction of acdom at different wavelength", subtitle = st) +
  coord_equal() +
  ylab("Wavelength (nm)") +
  xlab("Wavelength (nm)") +
  labs(fill = bquote(R^2)) +
  guides(fill = guide_colorbar(barwidth = 0.5)) 

ggsave("graphs/appendix2.pdf", dpi = 300)

