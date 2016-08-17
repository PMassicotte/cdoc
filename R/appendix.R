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


# Supplementary table 1 ---------------------------------------------------


# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>  
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Script producing a latex table with the coefficients of the 
#               linear regressions
# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

f <- function(x, y) {
  
  fit <- lm(y$absorption ~ x$absorption)
  
  return(fit)
}

literature_wl <- read_feather("dataset/clean/literature_datasets.feather") %>% 
  group_by(wavelength) %>% 
  summarise(n = n())

wl <- literature_wl$wavelength

cdom_doc <- read_feather("dataset/clean/cdom_dataset.feather") %>%
  filter(study_id != "nelson") %>% # Nelson is missing wl < 275
  filter(study_id != "greenland_lakes") %>%  # These had lamp problem at 360 nm
  filter(study_id != "horsen") %>% 
  filter(wavelength %in% wl) %>% 
  group_by(wavelength) %>% 
  nest()

source_wl <- filter(cdom_doc, wavelength != 350)
target_wl <- filter(cdom_doc, wavelength == 350)

models <- map2(source_wl$data, target_wl$data, f)

coefs <- models %>% purrr::map(broom::tidy) %>%
  bind_rows() %>%
  select(term, estimate) %>% 
  mutate(wavelength = rep(source_wl$wavelength, each = 2)) %>% 
  spread(term, estimate) %>% 
  mutate(r2 = models %>% purrr::map(summary) %>% map_dbl("r.squared")) %>% 
  left_join(literature_wl)

colnames(coefs) <- c("Wavelength (nm)", "Intercept", "Slope", "$R^2$", "$n$")

caption = "Coefficients of the linear regressions between absorption 
coefficents at 350 nm and other wavelengths. Each regression includes a total 
of 2321 observations. All regression have p-value < 0.00001.  $n$ represents 
the number of observations that were reported at this wavelength."

print(
  xtable::xtable(
    coefs,
    align = c("cccccr"),
    caption = caption,
    digits = c(0, 0, 2, 2, 4, 0)
  ),
  file = "article/tables/sup_table1.tex",
  include.rownames = FALSE,
  sanitize.text.function = function(x) {
    x
  }
)



