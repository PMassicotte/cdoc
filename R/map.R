library(cshapes)
library(gpclib)
library(maptools)
library(rgeos)

rm(list = ls())

literature <- readRDS("dataset/clean/literature_datasets.rds") %>% 
  filter(!is.na(longitude))

world <- cshp(date = as.Date("2008-1-1"))
world.points <- fortify(world, region = 'COWCODE')

p <- ggplot(world.points, aes(long, lat, group = group)) + 
  geom_polygon() +
  geom_point(data = literature, aes(x = longitude, 
                                    y = latitude, 
                                    group = NULL,
                                    color = study_id), 
             alpha = I(0.5), size = 1) +
  theme_bw() +
  xlab("Longitude") +
  ylab("Latitude") 

p

svglite::svglite("graphs/map.svg", width = 10, height = 5)
p
dev.off()

#ggsave("graphs/map.svg", width = 10, height = 5)
