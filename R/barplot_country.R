source("R/utils.R")

ll <- read_feather("dataset/clean/complete_data_350nm.feather") %>% 
  mutate(country = coords2continent(longitude, latitude)) %>% 
  mutate(country = ifelse(is.na(country), "Ocean", country)) %>% 
  group_by(country) %>% 
  summarise(n = n())


ll %>% 
  ggplot(aes(x = reorder(country, n), y = n)) +
  geom_bar(stat = "identity") +
  theme(axis.text.x = element_text(angle = 25, hjust = 1)) +
  xlab("Continent")

ggsave("graphs/barplot_country.pdf")

