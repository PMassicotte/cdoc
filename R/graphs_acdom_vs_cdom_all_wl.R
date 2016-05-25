#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         graphs_acdom_vs_cdom_all_wl.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Explore the relation between aCDOM350 and aCDOM at various
#               wavelengths.
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
rm(list = ls())

cdom_doc <- read_feather("dataset/clean/cdom_dataset.feather") %>%
  filter(study_id != "nelson") %>% # Nelson is missing wl < 275
  select(unique_id, wavelength, absorption) %>%
  spread(wavelength, absorption) %>% 
  select(-unique_id)

get_data <- function(wl, cdom_doc) {
  
  y <- select(cdom_doc, contains(as.character(wl)))
  
  
  res <- map2(y, cdom_doc, ~ lm(.y ~ .x)) 
  
  
  stats <- res %>% map(broom::glance) %>% 
    bind_rows() %>% 
    mutate(wavelength = extract_numeric(names(cdom_doc))) %>% 
    mutate(type = wl)
  
  coefs <- res %>% map_df(~ as.data.frame(t(as.matrix(coef(.)))))
  names(coefs) <- c("intercept", "slope")
  
  df <- bind_cols(stats, coefs)
  
  return(df)
}

res254 <- get_data(wl = 254, cdom_doc)
res350 <- get_data(wl = 350, cdom_doc) 
res440 <- get_data(wl = 440, cdom_doc)

res <- bind_rows(res254, res350, res440)

p1 <- ggplot(res, aes(x = wavelength, y = r.squared, color = factor(type))) +
  geom_point(size = 0.5) +
  ylab(expression(R^2)) +
  labs(color = "Target wl") +
  geom_vline(xintercept = c(254, 350, 440), lty = 2, size = 0.1, color = c("red", "green", "blue")) +
  scale_x_continuous(breaks = seq(240, 600, length.out = 10))

p2 <- ggplot(res, aes(x = wavelength, y = slope, color = factor(type))) +
  geom_point(size = 0.5) +
  ylab("slope") +
  labs(color = "Target wl") +
  geom_vline(xintercept = c(254, 350, 440), lty = 2, size = 0.1, color = c("red", "green", "blue")) +
  scale_x_continuous(breaks = seq(240, 600, length.out = 10))

p3 <- ggplot(res, aes(x = wavelength, y = intercept, color = factor(type))) +
  geom_point(size = 0.5) +
  ylab("intercept") +
  labs(color = "Target wl") +
  geom_vline(xintercept = c(254, 350, 440), lty = 2, size = 0.1, color = c("red", "green", "blue")) +
  scale_x_continuous(breaks = seq(240, 600, length.out = 10))

p <- cowplot::plot_grid(p1, p2, p3, ncol = 1)
cowplot::save_plot("graphs/acdom_vs_cdom_all_wl.pdf", 
                   p, 
                   base_height = 10,
                   base_width = 7)

# Raster plot -------------------------------------------------------------

rm(list = ls())

f <- function(x, y) {
  
  fit <- RcppArmadillo::fastLm(x$absorption, y$absorption)
  
  return(summary(fit)$r.squared )
}

cdom_doc <- read_feather("dataset/clean/cdom_dataset.feather") %>%
  filter(study_id != "nelson") %>% # Nelson is missing wl < 275
  select(unique_id, wavelength, absorption) %>%
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

ggplot(res, aes(x = wavelength, wavelength2, fill = r2)) +
  geom_raster() +
  scale_fill_gradientn(colours = rev(jet.colors(255))) +
  scale_x_continuous(expand = c(0, 0)) +
  scale_y_continuous(expand = c(0, 0)) +
  ggtitle("Prediction of acdom at different wavelength", subtitle = st) +
  coord_equal()

ggsave("graphs/acdom_vs_cdom_all_wl.png")
