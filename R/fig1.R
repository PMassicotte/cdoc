#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Plot a map with location of sampling sites.
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
rm(list = ls())

cdom_complete <- read_feather("dataset/clean/cdom_dataset.feather") %>% 
  filter(wavelength == 350) %>%
  select(study_id, unique_id, longitude, latitude) %>% 
  mutate(source = "complete")

cdom_literature <- read_feather("dataset/clean/literature_datasets.feather") %>%
  select(study_id, unique_id, longitude, latitude) %>% 
  mutate(source = "literature")

df <- bind_rows(cdom_complete, cdom_literature) 
  
# world <- cshp(date = as.Date("2008-1-1"))
# world.points <- fortify(world, region = 'COWCODE')

map.world <- map_data(map = "world")

ggplot() + 
  geom_map(data = map.world, 
           map = map.world, 
           aes(map_id = region, x = long, y = lat), fill = "gray25") +
  geom_point(data = df, aes(x = longitude,
                            y = latitude, 
                            group = NULL),
                            color = "firebrick1",
             alpha = 1, size = 0.05) +
  guides(colour = guide_legend(override.aes = list(size = 2))) +
  theme(legend.position = "none") +
  coord_fixed(1.3) +
  xlab("Longitude (degree decimal)") +
  ylab("Latitude (degree decimal)")

ggsave("graphs/fig1.pdf")
embed_fonts("graphs/fig1.pdf")