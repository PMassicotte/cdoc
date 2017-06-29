# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Script to explore the effect of changing salinity thershold to
#               classify ocean sample from 30 to 32. Also explore the effect 
#               of sampling depth on the reported relationship.
# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

df <- read_feather("dataset/clean/complete_data_350nm.feather") %>% 
  filter(ecosystem == "ocean") %>% 
  filter(doc > 30) %>% 
  filter(absorption >= 3.754657e-05) %>% 
  select(ecosystem, doc, absorption, salinity, study_id, depth) %>% 
  mutate(ecosystem = str_to_title(ecosystem)) %>% 
  mutate(sal = ifelse(salinity <= 32 | is.na(salinity), "t", "f")) %>% 
  mutate(is_nelson = ifelse(study_id == "nelson", TRUE, FALSE)) %>% 
  mutate(is_deep = ifelse(depth >= 500 | is.na(depth), TRUE, FALSE))

mylabels <- c(
  "t" = "Salinity <= 32",
  "f" = "Salinity > 32"
)

df %>% 
  ggplot(aes(x = doc, y = absorption)) +
  geom_point(aes(color = is_nelson, shape = is_deep), size = 1) +
  geom_smooth(aes(group = interaction(is_nelson, is_deep)), method = "lm", formula = y ~ log(x), size = 0.5) +
  scale_x_log10() +
  scale_y_log10() +
  facet_wrap(~sal, scales = "free", labeller = labeller(sal = mylabels)) +
  annotation_logticks(size = 0.2) +
  xlab(bquote("Dissolved organic carbon"~(mu*mol~C%*%L^{-1}))) +
  ylab(bquote("Absorption at 350 nm"~(m^{-1}))) +
  labs(color = "Nelson data",
       shape = "Depth >= 500 m") +
  theme(legend.justification = c(0.95, 0),
        legend.position = c(0.99, 0.05)) +
  theme(legend.title = element_text(size = 10) ,
        legend.text = element_text(size = 9))

ggsave("graphs/review_stoten_c4.png", width = 10, height = 5)  
ggsave("graphs/appendix7.pdf", width = 10, height = 5)
