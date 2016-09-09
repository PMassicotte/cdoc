#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Explore the relation between aCDOM350 and aCDOM at various
#               wavelengths.
#               
#               This script produces figure 2 for the manuscript.
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

data350 <- read_feather("dataset/clean/cdom_dataset.feather") %>% 
  filter(wavelength == 350) %>% 
  filter(study_id != "nelson") %>% # Nelson is missing wl < 275
  filter(study_id != "greenland_lakes") %>%  # These had lamp problem at 360 nm
  filter(study_id != "horsen")

cdom_doc <- read_feather("dataset/clean/cdom_dataset.feather") %>%
  filter(study_id != "nelson") %>% # Nelson is missing wl < 275
  filter(study_id != "greenland_lakes") %>%  # These had lamp problem at 360 nm
  filter(study_id != "horsen") %>% 
  filter(wavelength <= 500) %>% 
  group_by(wavelength) %>% 
  nest() %>% 
  mutate(model = purrr::map(data, ~lm(data350$absorption ~ .$absorption)))

f <- function(x) {
  
  df <- as.data.frame(confint(x)) 
  df$term = rownames(df)
  return(df)
  
}

res <- cdom_doc %>% 
  mutate(tt = purrr::map(model, f)) %>%
  unnest(tt) %>% 
  filter(term == "(Intercept)")


cdom_doc %>% 
  unnest(model %>% purrr::map(broom::glance)) %>% 
  filter(wavelength %in% c(250, 500))

cdom_doc %>% 
  unnest(model %>% purrr::map(broom::tidy)) %>% 
  filter(wavelength %in% c(250, 500))

# R2 panel ----------------------------------------------------------------

p1 <- cdom_doc %>% 
  filter(wavelength != 416) %>% #instrument error
  unnest(model %>% purrr::map(broom::glance)) %>% 
  ggplot(aes(x = wavelength, y = r.squared)) +
  geom_line(size = 0.5) +
  ylab(expression(R^2)) +
  theme(axis.ticks.x = element_blank()) +
  theme(axis.title.x = element_blank()) +
  theme(axis.text.x = element_blank()) +
  annotate("text", Inf, Inf, label = "A",
           vjust = 1.5, hjust = 1.5, size = 5, fontface = "bold") +
  scale_x_continuous(breaks = seq(250, 500, length.out = 6), limits = c(250, 515)) +
  scale_y_continuous(limits = c(0.85, 1)) +
  geom_vline(xintercept = 350, lty = 2, size = 0.25)

p1

# Slope panel -------------------------------------------------------------

ci <- cdom_doc %>% 
  mutate(tt = purrr::map(model, f)) %>%
  unnest(tt) %>% 
  filter(term == ".$absorption")

slope <- cdom_doc %>% 
  unnest(model %>% purrr::map(broom::tidy)) %>% 
  filter(term == ".$absorption")

p2 <- ggplot() + 
  geom_ribbon(data = ci, aes(x = wavelength, ymin = `2.5 %`, ymax = `97.5 %`),
              fill = "gray75") +
  geom_line(data = slope, aes(x = wavelength, y = estimate), size = 0.5) +
  ylab("Slope") +
  theme(axis.ticks.x = element_blank()) +
  theme(axis.title.x = element_blank()) +
  theme(axis.text.x = element_blank()) +
  annotate("text", Inf, Inf, label = "B",
           vjust = 1.5, hjust = 1.5, size = 5, fontface = "bold") +
  scale_x_continuous(breaks = seq(250, 500, length.out = 6), limits = c(250, 515)) +
  geom_vline(xintercept = 350, lty = 2, size = 0.25)

p2

# Intercept panel ---------------------------------------------------------

ci <- cdom_doc %>% 
  mutate(tt = purrr::map(model, f)) %>%
  unnest(tt) %>% 
  filter(term == "(Intercept)")

intercept <- cdom_doc %>% 
  unnest(model %>% purrr::map(broom::tidy)) %>% 
  filter(term == "(Intercept)")

p3 <-  ggplot() +
  geom_ribbon(data = ci, aes(x = wavelength, ymin = `2.5 %`, ymax = `97.5 %`),
              fill = "gray") +
  geom_line(data = intercept, aes(x = wavelength, y = estimate), size = 0.5) +
  ylab(bquote(Intercept~(m^{-1}))) +
  xlab("Wavelengths (nm)") +
  annotate("text", Inf, Inf, label = "C",
           vjust = 1.5, hjust = 1.5, size = 5, fontface = "bold") +
  scale_x_continuous(breaks = seq(250, 500, length.out = 6),
                     limits = c(250, 515)) +
  geom_vline(xintercept = 350, lty = 2, size = 0.25)

p3

# Combine plots -----------------------------------------------------------

p <- cowplot::plot_grid(p1, p2, p3, ncol = 1, 
                        align = "v", rel_heights = c(1,1,1.2))

cowplot::save_plot("graphs/fig2.pdf", 
                   p, 
                   base_height = 5,
                   base_width = 3.5)

embed_fonts("graphs/fig2.pdf")

# Raster plot -------------------------------------------------------------

f <- function(x, y) {
  
  df <- data.frame(x = x$absorption, y = y$absorption)
  
  fit <- biglm::biglm(y ~ x, data = df)
  
  return(list(fit))
}

cdom_doc <- read_feather("dataset/clean/cdom_dataset.feather") %>%
  filter(study_id != "nelson") %>% # Nelson is missing wl < 275
  filter(study_id != "greenland_lakes") %>%  # These had lamp problem at 360 nm
  filter(study_id != "horsen") %>% 
  filter(wavelength <= 500) %>% 
  group_by(wavelength) %>% 
  nest()

# Take ~ 1-2 minute(s)
models <- outer(cdom_doc$data, cdom_doc$data, Vectorize(f))

r2 <- lapply(models, function(x) summary(x)$rsq) %>% 
  unlist() %>% 
  pracma::Reshape(., 251, 251) %>% 
  data.frame() %>% 
  mutate(wavelength = 250:500)

names(r2) <- c(paste("W", 250:500, sep = ""), "wavelength")

r2 <- gather(r2, wavelength2, r2, -wavelength) %>% 
  mutate(wavelength2 = parse_number(wavelength2))

# Plot --------------------------------------------------------------------

ggplot(r2, aes(x = wavelength, wavelength2, fill = r2)) +
  geom_raster() +
  scale_fill_viridis() +
  scale_x_continuous(expand = c(0, 0)) +
  scale_y_continuous(expand = c(0, 0)) +
  coord_equal() +
  ylab("Wavelength (nm)") +
  xlab("Wavelength (nm)") +
  labs(fill = bquote(R^2)) +
  guides(fill = guide_colorbar(barwidth = 1.5)) 

ggsave("graphs/appendix2.pdf")

# CSV file for the appendix -----------------------------------------------

wl <- 250:500

coefs <- lapply(models, function(x) round(coef(x), digits = 6)) %>% 
  do.call(rbind, .) %>% 
  data.frame() %>% 
  setNames(c("intercept", "slope")) %>% 
  mutate(from = rep(wl, length(wl))) %>% 
  mutate(to = rep(wl, each = length(wl))) %>% 
  mutate(r2 = round(as.numeric(r2$r2), digits = 6)) %>% 
  arrange(from) %>% 
  select(from, to, intercept, slope, r2)

write_csv(coefs, "dataset/supplementary_coef.csv")

  
