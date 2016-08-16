# Panel A -----------------------------------------------------------------

rm(list = ls())

cdom_complete <- read_feather("dataset/clean/cdom_dataset.feather") %>% 
  filter(wavelength <= 500) %>%
  filter(study_id != "nelson") %>% # Nelson is missing wl < 275
  filter(study_id != "greenland_lakes") %>%  # These had lamp problem at 360 nm
  filter(study_id != "horsen") %>% 
  filter(ecosystem != "brines") %>% 
  mutate(endmember = ifelse(ecosystem %in% c("lake", "river", "sewage", "pond", "wetland"),
                            "Freshwater", "Marine")) %>% 
  group_by(wavelength, endmember) %>% 
  nest() %>% 
  mutate(model = purrr::map(data, ~lm(.$doc ~ .$absorption, data = .))) %>% 
  unnest(model %>% purrr::map(broom::glance))

p <- cdom_complete %>% 
  ggplot(aes(x = wavelength, y = r.squared)) +
  geom_line(aes(color = endmember)) +
  xlab("Wavelength (nm)") +
  ylab(bquote(R^2)) +
  theme(legend.justification = c(0, 0), legend.position = c(0, 0)) +
  labs(color = "Ecosystem")

ggsave("graphs/fig5.pdf", width = 3.5, height = 3)
embed_fonts("graphs/fig5.pdf")
