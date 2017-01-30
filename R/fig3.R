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
  theme(legend.key.size = unit(0.5, "cm")) +
  theme(legend.text = element_text(size = 8)) +
  theme(legend.title = element_text(size = 10)) +
  labs(color = "Ecosystem") +
  geom_vline(xintercept = 350, lty = 2, size = 0.25)

ggsave("graphs/fig3.pdf", width = 3.5, height = 3)
embed_fonts("graphs/fig3.pdf")


# Some stats for the paper ------------------------------------------------

cdom_complete %>% 
  filter(wavelength <= 400) %>% 
  group_by(endmember) %>% 
  summarise(mean(r.squared))


cdom_complete %>% filter(wavelength %in% c(250, 500))

