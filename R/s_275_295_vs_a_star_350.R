# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>  
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Graph and data requested by Colin.
# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

acdom <- read_feather("dataset/clean/complete_data_350nm.feather") %>% 
  select(unique_id, wavelength, absorption, doc, ecosystem) %>% 
  mutate(a_star = absorption / doc)

metrics <- read_feather("dataset/clean/cdom_metrics.feather") %>% 
  select(unique_id, s_275_295)

res <- inner_join(acdom, metrics, by = "unique_id")

res %>% 
  ggplot(aes(x = a_star, y = s_275_295)) +
  geom_point(size = 1) +
  facet_wrap(~ecosystem, scales = "free") +
  xlab(bquote(a*"*"~(350)))

ggsave("graphs/s_275_295_vs_a_star_350.pdf", height = 5, width = 9)
embed_fonts("graphs/s_275_295_vs_a_star_350.pdf")

write_csv(res, "/home/pmassicotte/Desktop/data_colin.csv")
