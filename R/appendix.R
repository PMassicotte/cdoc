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


# Appendix 4 --------------------------------------------------------------

# ***************************************************************************
# Map showing the buffer area identified by the segmentation analysis around
# the continents.
# ***************************************************************************

# http://rpsychologist.com/working-with-shapefiles-projections-and-world-maps-in-ggplot

rm(list = ls())
graphics.off()

wmap <- readOGR("dataset/shapefiles/ne_110m_land/", "ne_110m_land")


wmap <- spTransform(wmap, CRS = CRS("+proj=robin"))
res <- gBuffer(wmap, width = 359.31 * 1000)

wmap <- fortify(wmap)
res <- fortify(res)

grat <- readOGR("dataset/shapefiles/ne_110m_graticules_all/", 
                layer = "ne_110m_graticules_15") 
grat_df <- fortify(grat)

bbox <- readOGR("dataset/shapefiles/ne_110m_graticules_all/", layer = "ne_110m_wgs84_bounding_box") 
bbox_df <- fortify(bbox)
grat_robin <- spTransform(grat, CRS("+proj=robin"))  # reproject graticule
grat_df_robin <- fortify(grat_robin)
bbox_robin <- spTransform(bbox, CRS("+proj=robin"))  # reproject bounding box
bbox_robin_df <- fortify(bbox_robin)

countries <- readOGR("dataset/shapefiles/ne_110m_admin_0_countries/",
                     layer = "ne_110m_admin_0_countries") 
countries_robin <- spTransform(countries, CRS("+init=esri:54030"))
countries_robin_df <- fortify(countries_robin)

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


ggplot(bbox_robin_df, aes(long, lat, group = group)) +
  geom_polygon(fill = "white") +
  geom_polygon(data = res,
               aes(x = long, y = lat, group = group),
               fill = "#E41A1C") +
  geom_polygon(data = wmap, aes(
    x = long,
    y = lat,
    group = group,
    fill = hole
  )) +
  # geom_polygon(data = countries_robin_df, aes(
  #   long, 
  #   lat, 
  #   group = group, 
  #   fill = hole
  # )) + 
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

ggsave("graphs/appendix4.pdf")
system("pdfcrop graphs/appendix4.pdf graphs/appendix4.pdf")
embed_fonts("graphs/appendix4.pdf")

