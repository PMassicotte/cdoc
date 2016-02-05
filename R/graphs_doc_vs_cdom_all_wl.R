#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         doc_vs_cdom_all_wl.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Look at the relationship between DOC vs aCDOM at various
#               wavelengths.
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

cdom_doc <- readRDS("dataset/clean/complete_dataset.rds") %>% 
  #filter(doc < 100) %>% 
  group_by(wavelength) %>% 
  nest() %>% 
  mutate(model = map(data, ~ lm(doc ~ absorption, data = .))) %>% 
  unnest(map(model, broom::glance)) %>% 
  unnest(map(model, broom::tidy))

p1 <- ggplot(cdom_doc, aes(x = wavelength, y = r.squared)) +
  geom_point(size = 0.5) +
  ylab(expression(R^2)) +
  ggtitle(expression(paste("DOC ~ ", aCDOM[lambda]))) +
  annotate("text", x = Inf, y = Inf, 
           label = "Based on 1676 CDOM profils", vjust = 2, hjust = 2)

p2 <- ggplot(cdom_doc[cdom_doc$term == "absorption", ], aes(x = wavelength, y = estimate)) +
  geom_point(size = 0.5) +
  geom_line(aes(y = estimate + std.error), col = "red", size = 0.1) +
  geom_line(aes(y = estimate - std.error), col = "red", size = 0.1) +
  ylab("Slope (umol C)")

p3 <- ggplot(cdom_doc[cdom_doc$term == "(Intercept)", ], aes(x = wavelength, y = estimate)) +
  geom_point(size = 0.5) +
  geom_line(aes(y = estimate + std.error), col = "red", size = 0.1) +
  geom_line(aes(y = estimate - std.error), col = "red", size = 0.1) +
  ylab("Intercept (umol C)") 



ggsave("graphs/doc_vs_cdom_all_wl.pdf", 
       gridExtra::grid.arrange(p1, p2, p3, ncol = 1), 
       height = 10)

#plotly::ggplotly()

# cdom_doc <- readRDS("dataset/clean/complete_dataset.rds") %>% 
#   filter(wavelength == 536)
# 
# ggplot(cdom_doc, aes(x = absorption, y = doc)) +
#   geom_point(aes(color = study_id)) 
# 
# summary(lm(doc ~ absorption, cdom_doc))
