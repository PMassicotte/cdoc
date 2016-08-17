rm(list = ls())

source("R/utils.R")

ll <- read_feather("dataset/clean/complete_data_350nm.feather") %>% 
  select(study_id, longitude, latitude, ecosystem, unique_id) %>% 
  mutate(region = coords2location(longitude, latitude))

any(is.na(ll$region))

hm <-
  list(
    "Asia" = "Asia",
    "North America" = "North America",
    "SouthAtlantic" = "South Atlantic Ocean",
    "SouthernOcean" = "Southern Ocean",
    "Europe" = "Europe",
    "NorthAtlantic" = "North Atlantic Ocean",
    "ArcticOcean" = "Arctic Ocean",
    "IndianOcean" = "Indian Ocean",
    "NorthPacific" = "North Pacific Ocean",
    "SouthPacific" = "South Pacific Ocean",
    "Australia" = "Australia",
    "Africa" = "Africa"
  )

res <- ll %>% 
  mutate(region = unlist(hm[region])) %>% 
  group_by(region, ecosystem) %>% 
  summarise(n = n()) %>% 
  ungroup() %>% 
  complete(region, ecosystem)


res %>% 
  ggplot(aes(x = region, y = n)) +
  geom_bar(aes(fill = ecosystem), stat = "identity") +
  facet_wrap(~ecosystem, scales = "free")
