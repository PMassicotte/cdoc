# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>  
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Exploring CDOM absorption spectra to underline differences
#               between freshwater and marine ecosystems.
# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

# Panel A -----------------------------------------------------------------

cdom_complete <- read_feather("dataset/clean/cdom_dataset.feather") %>% 
  filter(wavelength <= 500) %>%
  filter(study_id != "nelson") %>% # Nelson is missing wl < 275
  filter(study_id != "greenland_lakes") %>%  # These had lamp problem at 360 nm
  filter(study_id != "horsen") %>% 
  filter(ecosystem != "brines") %>% 
  mutate(endmember = ifelse(ecosystem %in% c("lake", "river", "sewage", "pond"),
                            "Freshwater", "Marine")) %>% 
  group_by(wavelength, endmember) %>% 
  nest() %>% 
  mutate(model = purrr::map(data, ~lm(.$doc ~ .$absorption, data = .))) %>% 
  unnest(model %>% purrr::map(broom::glance))

pA <- cdom_complete %>% 
  ggplot(aes(x = wavelength, y = r.squared)) +
  geom_line() +
  xlab("Wavelength (nm)") +
  ylab(bquote(R^2)) +
  facet_wrap(~endmember)

cdom_complete %>% filter(wavelength == 250)
cdom_complete %>% filter(wavelength == 350)
cdom_complete %>% filter(wavelength == 500)

# Panel B -----------------------------------------------------------------

cdom_complete <- read_feather("dataset/clean/cdom_dataset.feather") %>% 
  filter(wavelength <= 500) %>%
  filter(study_id != "nelson") %>% # Nelson is missing wl < 275
  filter(study_id != "greenland_lakes") %>%  # These had lamp problem at 360 nm
  filter(study_id != "horsen") %>% 
  group_by(unique_id) %>% 
  mutate(absorption = absorption / max(absorption)) %>% 
  ungroup() %>% 
  filter(ecosystem != "brines") %>% 
  mutate(endmember = ifelse(ecosystem %in% c("lake", "river", "sewage"),
                            "Freshwater", "Marine")) %>% 
  group_by(wavelength, endmember) %>%
  summarise(absorption = mean(absorption)) %>% 
  ungroup() %>% 
  group_by(endmember) %>% 
  nest() %>%  
  mutate(model = purrr::map(data, ~cdom_spectral_curve(.$wavelength, .$absorption))) %>% 
  unnest(model)

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
      "red"
    )
  )

pB <- cdom_complete %>%
  ggplot(aes(x = wl, y = s)) +
  geom_line(aes(color = r2)) +
  facet_wrap(~endmember, scales = "free_y") +
  scale_color_gradientn(
    colours = jet.colors(255),
    guide = guide_colorbar(
      direction = "vertical", 
      tick = TRUE,
      barwidth = 0.75, 
      barheight = 2,
      label.theme = element_text(size = 8, angle = 0))
  ) +
  xlab("Wavelength (nm)") +
  ylab(bquote(S[lambda]~(nm^{-1}))) +
  labs(color = bquote(italic(R^2))) +
  theme(legend.justification = c(1, 1), legend.position = c(1, 1)) +
  scale_x_continuous(expand = c(0.08, 0)) 

cdom_complete %>% filter(wl == min(wl))
cdom_complete %>% filter(wl == 280.5)
cdom_complete %>% filter(wl == max(wl))

# Combine plots -----------------------------------------------------------

p <-
  cowplot::plot_grid(
    pA,
    pB,
    ncol = 1,
    rel_heights = c(1, 1),
    labels = "AUTO",
    align = "hv"
  )
cowplot::save_plot("graphs/fig7.pdf",
                   p,
                   base_height = 5,
                   base_width = 6)

embed_fonts("graphs/fig7.pdf")
