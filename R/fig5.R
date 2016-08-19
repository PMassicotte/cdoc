#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Script exploring the relationship between aCDOM at various
#               wavelengths and DOC concentration.
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

endmember <- function(ecosystem) {
  
  hm <- list(
    "lake" = "Freshwater", 
    "river" = "Freshwater", 
    "sewage" = "Freshwater", 
    "pond" = "Freshwater", 
    "wetland" = "Freshwater",
    "estuary" = "Coastal",
    "coastal" = "Coastal",
    "ocean" = "Ocean"
  )
  
  return(unlist(hm[ecosystem], use.names = FALSE))
  
}

cdom_complete <- read_feather("dataset/clean/cdom_dataset.feather") %>% 
  filter(wavelength <= 500) %>%
  filter(study_id != "nelson") %>% # Nelson is missing wl < 275
  filter(study_id != "greenland_lakes") %>%  # These had lamp problem at 360 nm
  filter(study_id != "horsen") %>% 
  filter(ecosystem != "brines") %>% 
  mutate(endmember = endmember(ecosystem)) %>% 
  group_by(wavelength, endmember) %>% 
  nest() %>% 
  mutate(model = purrr::map(data, ~lm(.$doc ~ .$absorption, data = .))) %>% 
  unnest(model %>% purrr::map(broom::glance)) %>% 
  mutate(endmember = factor(endmember, c("Freshwater", "Coastal", "Ocean"))) %>% 
  mutate(signif = ifelse(p.value <= 0.05, TRUE, FALSE))

p <- cdom_complete %>% 
  ggplot(aes(x = wavelength, y = r.squared)) +
  geom_line(aes(color = endmember)) +
  xlab("Wavelength (nm)") +
  ylab(bquote(R^2)) +
  theme(legend.justification = c(0, 0), legend.position = c(0, 0)) +
  labs(color = "Ecosystem")

ggsave("graphs/fig5.pdf", width = 3.5, height = 3)
embed_fonts("graphs/fig5.pdf")


# Some stats for the paper ------------------------------------------------

cdom_complete %>% 
  filter(wavelength <= 400) %>% 
  group_by(endmember) %>% 
  summarise(mean(r.squared))


cdom_complete %>% filter(wavelength %in% c(250, 500))

