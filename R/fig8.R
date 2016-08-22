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
  mutate(model = purrr::map(data, ~cdom_spectral_curve(.$wavelength, .$absorption, r2threshold = 0.8))) %>% 
  unnest(model)

p <- cdom_complete %>%
  ggplot(aes(x = wl, y = s)) +
  geom_line(aes(color = r2)) +
  facet_wrap(~endmember, scales = "free_y") +
  scale_color_gradientn(
    colours = viridis(255, end = 0.75),
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

ggsave("graphs/fig8.pdf", p, height = 3, width = 7)
embed_fonts("graphs/fig8.pdf")
