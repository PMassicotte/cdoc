#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         acdom350_vs_cdom_all_wl.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Explore the relation between aCDOM350 and aCDOM at various
#               wavelengths.
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
rm(list = ls())

tmp <- readRDS("dataset/clean/complete_dataset.rds") %>% 
  filter(wavelength == 350) %>% 
  select(absorption)

cdom_doc <- readRDS("dataset/clean/complete_dataset.rds") %>% 
  group_by(wavelength) %>% 
  nest() %>% 
  mutate(model = map(data, ~ lm(tmp$absorption ~ .$absorption))) %>% 
  unnest(map(model, broom::glance)) %>% 
  unnest(map(model, broom::tidy))

p1 <- ggplot(cdom_doc, aes(x = wavelength, y = r.squared)) +
  geom_point(size = 0.5) +
  ylab(expression(R^2))

p2 <- ggplot(cdom_doc[cdom_doc$term == ".$absorption", ], aes(x = wavelength, y = estimate)) +
  geom_point(size = 0.5) +
  geom_line(aes(y = estimate + std.error), col = "red", size = 0.1) +
  geom_line(aes(y = estimate - std.error), col = "red", size = 0.1) +
  ylab("Slope (m-1)")

p3 <- ggplot(cdom_doc[cdom_doc$term == "(Intercept)", ], aes(x = wavelength, y = estimate)) +
  geom_point(size = 0.5) +
  geom_line(aes(y = estimate + std.error), col = "red", size = 0.1) +
  geom_line(aes(y = estimate - std.error), col = "red", size = 0.1) +
  ylab("Intercept (m-1)") 

ggsave("graphs/acdom350_vs_cdom_all_wl.pdf", 
       gridExtra::grid.arrange(p1, p2, p3, ncol = 1), 
       height = 10)
