rm(list = ls())

cdom_complete <- read_feather("dataset/clean/cdom_dataset.feather") %>% 
  filter(wavelength <= 500) %>%
  filter(study_id != "nelson") %>% # Nelson is missing wl < 275
  filter(study_id != "greenland_lakes") %>%  # These had lamp problem at 360 nm
  filter(study_id != "horsen") %>% 
  group_by(unique_id) %>% 
  mutate(absorption = absorption / max(absorption)) %>% 
  ungroup() %>% 
  group_by(wavelength, ecosystem) %>%
  summarise(absorption = mean(absorption)) %>% 
  ungroup() %>% 
  group_by(ecosystem) %>% 
  nest() %>%  
  mutate(model = purrr::map(data, ~cdom_spectral_curve(.$wavelength, .$absorption))) %>% 
  unnest(model)


# Plot --------------------------------------------------------------------

jet.colors <-
  colorRampPalette(
    c(
      "#00007F",
      "blue",
      "#007FFF",
      "cyan",
      "#7FFF7F",
      "yellow",
      "#FF7F00",
      "red",
      "#7F0000"
    )
  )

p <- cdom_complete %>%
  mutate(ecosystem = factor(
    ecosystem,
    levels = c(
      "wetland",
      "pond",
      "lake",
      "river",
      "coastal",
      "estuary",
      "ocean"
    ),
    labels = c(
      "Wetland",
      "Pond",
      "Lake",
      "River",
      "Coastal",
      "Estuary",
      "Ocean"
    )
  )) %>% 
  ggplot(aes(x = wl, y = s)) +
  geom_line(aes(color = r2)) +
  facet_wrap(~ecosystem) +
  scale_color_gradientn(
    colours = jet.colors(255),
    guide = guide_colorbar(
      direction = "vertical", 
      tick = FALSE,
      barwidth = 1, barheight = 5)
  ) +
  xlab("Wavelength (nm)") +
  ylab(bquote("Spectral slope"~(nm^{-1}))) +
  labs(color = bquote(italic(R^2))) +
  theme(legend.justification = c(0.75, 0), legend.position = c(0.42, -0.005))
 
ggsave("graphs/spectra_curves.pdf", p, height = 5, width = 7)
