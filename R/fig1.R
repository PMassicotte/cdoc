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
coordinates(df) <- c("longitude", "latitude")
proj4string(df) <- CRS("+proj=longlat +datum=WGS84")
df <- spTransform(df, CRS = CRS("+proj=robin"))
df <- fortify(df)

wmap <- readOGR("dataset/shapefiles/ne_110m_land/", "ne_110m_land")
wmap <- spTransform(wmap, CRS = CRS("+proj=robin"))
wmap <- fortify(wmap)


grat <- readOGR("dataset/shapefiles/ne_110m_graticules_all/", 
                layer = "ne_110m_graticules_15") 
grat_df <- fortify(grat)

bbox <- readOGR("dataset/shapefiles/ne_110m_graticules_all/", layer = "ne_110m_wgs84_bounding_box") 
bbox_df <- fortify(bbox)
grat_robin <- spTransform(grat, CRS("+proj=robin"))  # reproject graticule
grat_df_robin <- fortify(grat_robin)
bbox_robin <- spTransform(bbox, CRS("+proj=robin"))  # reproject bounding box
bbox_robin_df <- fortify(bbox_robin)

ggplot(bbox_robin_df, aes(long, lat, group = group)) +
  geom_polygon(fill = "white") +
  geom_polygon(data = wmap, aes(
    x = long,
    y = lat,
    group = group,
    fill = hole
  )) +
  geom_path(
    data = grat_df_robin,
    aes(long, lat, group = group, fill = NULL),
    lty = 2,
    color = "grey50",
    size = 0.1
  ) +
  geom_point(
    data = df,
    aes(x = long,
        y = lat,
        group = NULL),
    color = "firebrick1",
    alpha = 1,
    size = 0.01
  ) +
  coord_equal() +
  scale_fill_manual(values = c("gray25", "white"), guide = "none") +
  xlab("Longitude") +
  ylab("Latitude") +
  theme(panel.grid.minor = element_blank()) +
  theme(panel.grid.major = element_blank()) +
  theme(panel.background = element_blank()) +
  theme(plot.background = element_rect(fill = "white"))

ggsave("graphs/fig1.pdf")
system("pdfcrop graphs/fig1.pdf graphs/fig1.pdf")
embed_fonts("graphs/fig1.pdf")
