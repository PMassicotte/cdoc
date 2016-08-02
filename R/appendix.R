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


# Appendix 5 --------------------------------------------------------------

# http://rpsychologist.com/working-with-shapefiles-projections-and-world-maps-in-ggplot

rm(list = ls())
graphics.off()

wmap <- readOGR("dataset/shapefiles/ne_110m_land/", "ne_110m_land")
# plot(countriesSP)

wmap <- spTransform(wmap, CRS = CRS("+proj=robin"))
res <- gBuffer(wmap, width = 359.31 * 1000)

theme_opts <- list(
  theme(
    panel.grid.minor = element_blank(),
    panel.grid.major = element_blank(),
    panel.background = element_blank(),
    plot.background = element_rect(fill = "white"),
    # panel.border = element_blank(),
    # axis.line = element_blank(),
    # axis.text.x = element_blank(),
    # axis.text.y = element_blank(),
    # axis.ticks = element_blank(),
    # axis.title.x = element_blank(),
    # axis.title.y = element_blank(),
    plot.title = element_text(size = 22)
  )
)


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
  geom_path(
    data = grat_df_robin,
    aes(long, lat, group = group, fill = NULL),
    lty = 2,
    color = "grey50",
    size = 0.1
  ) +
  coord_equal() +
  theme_opts +
  scale_fill_manual(values = c("gray25", "white"), guide = "none") +
  xlab("Longitude") +
  ylab("Latitude") 

ggsave("graphs/appendix5.pdf")
system("pdfcrop graphs/appendix5.pdf graphs/appendix5.pdf")
embed_fonts("graphs/appendix5.pdf")

