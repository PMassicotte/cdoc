df <- read_feather("dataset/clean/cdom_dataset.feather") %>% 
  filter(wavelength == 350) %>% 
  select(wavelength, absorption, doc)


# convert -----------------------------------------------------------------

df <- df %>% 
  mutate(absorbance = absorption / 2.303) %>% 
  mutate(doc_mg = doc * 12 / 1000) %>% 
  mutate(suva = absorbance / doc_mg) %>% 
  mutate(a_star = absorption / doc * 1000)


df %>% 
  ggplot(aes(x = suva, y = a_star)) +
  geom_point()

lm(a_star ~ suva, data = df)

df <- df %>% 
  mutate(a_star_estimated = suva * 27.64 )

ggsave("/home/pmassicotte/Desktop/suva_a_star.pdf")
