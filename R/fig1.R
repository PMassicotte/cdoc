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

bbox <- readOGR("dataset/shapefiles/ne_110m_graticules_all/", 
                layer = "ne_110m_wgs84_bounding_box") 
bbox_df <- fortify(bbox)

grat_robin <- spTransform(grat, CRS("+proj=robin"))  # reproject graticule
grat_df_robin <- fortify(grat_robin)

bbox_robin <- spTransform(bbox, CRS("+proj=robin"))  # reproject bounding box
bbox_robin_df <- fortify(bbox_robin)

countries <- readOGR("dataset/shapefiles/ne_110m_admin_0_countries/",
                     layer = "ne_110m_admin_0_countries") 
countries_robin <- spTransform(countries, CRS("+init=esri:54030"))
countries_robin_df <- fortify(countries_robin)


# Calculate coordinate labels ---------------------------------------------

# Latitude ----------------------------------------------------------------

coord <- data_frame(
  longitude = seq(-180, 180, length.out = 5),
  latitude = seq(-90, 90, length.out = 5)
)

coordinates(coord) <- c("longitude", "latitude")
proj4string(coord) <- CRS("+proj=longlat +datum=WGS84")
coord <- spTransform(coord, CRS = CRS("+proj=robin"))
coord <- fortify(coord)

latitude <- data_frame(
  degree = seq(-90, 90, length.out = 5),
  robin = coord$lat)

# Longitude ---------------------------------------------------------------

coord <- data_frame(
  longitude = c(-180, -60, 0, 60, 180),
  latitude = seq(-90, 90, length.out = 5)
)

coordinates(coord) <- c("longitude", "latitude")
proj4string(coord) <- CRS("+proj=longlat +datum=WGS84")
coord <- spTransform(coord, CRS = CRS("+proj=robin"))
coord <- fortify(coord)

longitude <- data_frame(
  degree = c(-180, -60, 0, 60, 180),
  robin = coord$long)

# Plot --------------------------------------------------------------------

ggplot(bbox_robin_df, aes(long, lat, group = group)) +
  geom_polygon(fill = "white") +
  geom_polygon(data = wmap, aes(
    x = long,
    y = lat,
    group = group,
    fill = hole
  )) +
  geom_polygon(data = countries_robin_df, aes(
    long, 
    lat, 
    group = group, 
    fill = hole
  )) + 
  geom_path(
    data = countries_robin_df,
    aes(long, lat, group = group, fill = hole),
    color = "gray50",
    size = 0.05
  ) + 
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
  xlab("Longitude (degrees)") +
  ylab("Latitude (degrees)") +
  scale_x_continuous(breaks = longitude$robin,
                     labels = longitude$degree) +
  scale_y_continuous(breaks = latitude$robin,
                     labels = latitude$degree) +
  theme(panel.grid.minor = element_blank()) +
  theme(panel.grid.major = element_blank()) +
  theme(panel.background = element_blank()) +
  theme(plot.background = element_rect(fill = "white"))

ggsave("graphs/fig1.pdf", width = 5)
system("pdfcrop graphs/fig1.pdf graphs/fig1.pdf")
embed_fonts("graphs/fig1.pdf")
