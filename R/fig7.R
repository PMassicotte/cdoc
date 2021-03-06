# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>  
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Exploring CDOM absorption spectra to underline differences
#               between freshwater and marine ecosystems.
# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())


cdom_complete <- read_feather("dataset/clean/cdom_dataset.feather") %>% 
  filter(wavelength <= 500) %>%
  filter(study_id != "nelson") %>% # Nelson is missing wl < 275
  filter(study_id != "greenland_lakes") %>%  # These had lamp problem at 360 nm
  filter(study_id != "horsen")

## Normalize to maximum value
cdom_complete <- cdom_complete %>% 
  group_by(unique_id) %>% 
  mutate(absorption = absorption / max(absorption)) %>% 
  ungroup()

cdom_complete_by_endmember <- cdom_complete %>% 
  mutate(endmember = ifelse(ecosystem %in% c("lake", "river"), "Freshwater", "Marine")) %>%
  group_by(wavelength, endmember) %>%
  summarise(absorption = mean(absorption)) %>% 
  ungroup() %>% 
  group_by(endmember) %>% 
  nest() %>%  
  mutate(model = purrr::map(data, ~cdom_spectral_curve(.$wavelength, .$absorption, r2threshold = 0.8))) %>% 
  unnest(model)

cdom_complete_by_ecosystem <- cdom_complete %>% 
  group_by(wavelength, ecosystem) %>%
  summarise(absorption = mean(absorption)) %>% 
  ungroup() %>% 
  mutate(endmember = ifelse(ecosystem %in% c("lake", "river"), "Freshwater", "Marine")) %>% 
  group_by(ecosystem, endmember) %>% 
  nest() %>%  
  mutate(model = purrr::map(data, ~cdom_spectral_curve(.$wavelength, .$absorption, r2threshold = 0.8))) %>% 
  unnest(model)

df <- tibble(
  ymin = c(rep(0.0082, 6)),
  xmin = c(260.5, 295.5, 365, 260.5, 292, 350),
  xmax = c(295, 365, 475, 292, 350, 475),
  endmember = c(rep("Freshwater", 3), rep("Marine", 3)),
  label = c("I", "II", "III", "IV", "V", "VI")
)

p <- cdom_complete_by_endmember %>% 
  ggplot(aes(x = wl, y = s)) +
  geom_line(aes(color = r2)) +
  facet_wrap(~endmember) +
  scale_color_gradientn(
    colours = viridis(255, end = 0.75),
    guide = guide_colorbar(
      direction = "vertical", 
      tick = TRUE,
      barwidth = 0.75, 
      barheight = 2,
      label.theme = element_text(size = 8, angle = 0))
  ) +
  geom_line(data = cdom_complete_by_ecosystem, aes(x = wl, y = s, linetype = ecosystem), color = "gray75") +
  geom_segment(
    data = df,
    aes(
      x = xmin,
      xend = xmax,
      y = ymin,
      yend = ymin
    ),
    arrow = arrow(
      ends = "both",
      angle = 90,
      length = unit(0.1, "cm")
    ), size = 0.25
  ) +
  geom_text(
    data = df,
    aes(
      x = xmin + (xmax - xmin) / 2,
      y = -Inf,
      label = label
    ),
    inherit.aes = F,
    fontface = 2,
    vjust = -3
  ) +
  geom_text(data = df, aes(
    x = xmin + (xmax - xmin) / 2,
    y = -Inf,
    label = paste(xmin, xmax, sep = " - ")
  ), inherit.aes = F, size = 2, vjust = -1.5, fontface = 3) +
  xlab("Wavelength (nm)") +
  ylab(bquote(S[lambda]~(nm^{-1}))) +
  labs(color = bquote(italic(R^2)),
       linetype = "Ecosystems") +
  theme(legend.justification = c(1, 1), legend.position = c(0.48, 0.98)) +
  scale_x_continuous(expand = c(0.08, 0)) +
  theme(legend.box = "horizontal") +
  ylim(0.0075, 0.028)

ggsave("graphs/fig7.pdf", height = 4, width = 8)
embed_fonts("graphs/fig7.pdf")

