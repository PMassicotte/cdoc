# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>  
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Various figures for the supplementary materials.
# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>


# Appendix 1 --------------------------------------------------------------

rm(list = ls())

df <- read_feather("dataset/clean/complete_data_350nm.feather") %>% 
  group_by(ecosystem) %>% 
  summarise(n = n())

df %>% 
  ggplot(aes(x = reorder(str_to_title(ecosystem), -n), y = n)) +
  geom_bar(stat = "identity") +
  geom_text(aes(label = n), vjust = -1) +
  ylab("Number of observation") +
  xlab("Ecosystems") +
  ylim(0, 5000)

ggsave("graphs/appendix1.pdf")
embed_fonts("graphs/appendix1.pdf")