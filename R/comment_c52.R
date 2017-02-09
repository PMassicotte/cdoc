# https://en.wikipedia.org/wiki/Deep_sea

df <- read_feather("dataset/clean/complete_data_350nm.feather") %>% 
  filter(ecosystem == "ocean") %>% 
  select(depth) %>% 
  drop_na()

sum(df$depth <= 1800) / nrow(df)
