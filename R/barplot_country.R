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

ll %>% 
  mutate(region = unlist(hm[region])) %>% 
  group_by(region) %>% 
  summarise(n = n())


# Map ---------------------------------------------------------------------

wm <- readOGR("dataset/shapefiles/world/", "All_Merge")
wm <- fortify(wm)

wm %>% 
  ggplot(aes(x = long, y = lat, group = group)) +
  geom_polygon(aes(fill = hole)) +
  scale_fill_manual(values = c("gray25", "white"), guide = "none") 

plot(wm)
