# http://stackoverflow.com/questions/27697504/ocean-latitude-longitude-point-distance-from-shore

rm(list = ls())

source("R/utils.R")

cdom_complete <- read_feather("dataset/clean/complete_data_350nm.feather")
cdom_complete <- cdom_complete %>%
  filter(!is.na(longitude) & !is.na(latitude)) %>%
  filter(ecosystem %in% c("river"))

wgs.84 <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
mollweide <- "+proj=moll +lon_0=0 +x_0=0 +y_0=0 +ellps=WGS84 +datum=WGS84 +units=m +no_defs"

sp.points <- SpatialPoints(cdom_complete[, c("longitude", "latitude")],
                           proj4string = CRS(wgs.84))

# coast  <- readOGR(dsn="ne_10m_coastline/",layer="ne_10m_coastline")
coast  <- readOGR(dsn = "dataset/shapefiles/ne_110m_ocean/",layer = "ne_110m_ocean")
coast.moll <- spTransform(coast, CRS(mollweide))
point.moll <- spTransform(sp.points, CRS(mollweide))

plot(point.moll, col = "red")
plot(coast.moll, add = T)
axis(1)
axis(2)
points(point.moll[c(72), ], col = "blue")

test   <- 1:nrow(cdom_complete)
result <- sapply(test, function(i) gDistance(point.moll[i],coast.moll))

result / 1000

text(coordinates(point.moll),labels =  round(result / 1000))

plot(result / 1000,cdom_complete$doc)

cdom_complete$distance = result / 1000

# Plot --------------------------------------------------------------------

res <- cdom_complete %>%
  filter(distance > 0 & distance <= 1500) %>%
  mutate(absorbance = (absorption * 0.01) / 2.303) %>%
  mutate(suva350 = absorbance / (doc / 1000) * 12)

# mybreaks <- seq(min(log(res$distance)), max(log(res$distance)), len = 10)
# mybreaks <- exp(mybreaks)

mybreaks <- seq(min((res$distance)), max((res$distance)), len = 10)
mybreaks <- seq(0, 1500, by = 150)

ints <- findInterval(res$distance, mybreaks, all.inside = T)
xx <- (mybreaks[ints] + mybreaks[ints + 1]) / 2

res <- res %>%
  mutate(bin_distance = cut(
    distance,
    breaks = mybreaks,
    include.lowest = TRUE,
    dig.lab = 4
  )) %>%
  mutate(distance2 = xx) %>%
  group_by(bin_distance, distance2) %>%
  summarise(
    mean_suva350 = mean(suva350),
    sd_suva350 = sd(suva350),
    n = n()
  )

model1 <- lm(mean_suva350 ~ distance2, data = res) 
model1

r2 <- paste("R^2== ", round(summary(model1)$r.squared, digits = 2))

res %>%
  ggplot(aes(x = distance2, y = mean_suva350)) +
  geom_point() +
  geom_pointrange(aes(ymin = mean_suva350 - sd_suva350,
                      ymax = mean_suva350 + sd_suva350)) +
  geom_smooth(method = "lm") +
  scale_x_continuous(
    breaks = res$distance2,
    labels = as.character(res$bin_distance),
    expand = c(0.06, 0)
  ) +
  xlab("Distance to the closest ocean (km)") +
  ylab(bquote("Averaged"~SUVA[350]~(L%*%mgC^{-1}%*%m^{-1}))) +
  theme(axis.text.x = element_text(angle = 25, hjust = 1)) +
  annotate(
    "text",
    x = -Inf,
    y = Inf,
    label = lm_eqn(model1),
    parse = TRUE,
    vjust = 2,
    hjust = -0.05
  ) +
  annotate(
    "label",
    x = res$distance2,
    y = 0.25,
    label = res$n,
    fontface = "bold",
    size = 3
  )

ggsave("graphs/fig9.pdf")
embed_fonts("graphs/fig9.pdf")



# Appendix ----------------------------------------------------------------

map.world <- map_data(map = "world")

ggplot() + 
  geom_map(data = map.world, 
           map = map.world, 
           aes(map_id = region, x = long, y = lat), fill = "gray25") +
  geom_point(data = cdom_complete , aes(x = longitude,
                                        y = latitude, 
                                        group = NULL),
             color = "firebrick1",
             alpha = 1, size = 0.05) +
  guides(colour = guide_legend(override.aes = list(size = 2))) +
  theme(legend.position = "none") +
  coord_fixed(1.4) +
  xlab("Longitude (degree decimal)") +
  ylab("Latitude (degree decimal)") +
  scale_x_continuous(breaks = seq(-150, 150, by = 50), limits = c(-180, 180)) +
  scale_y_continuous(breaks = seq(-75, 75, by = 25))

ggsave("graphs/appendix5.pdf")
embed_fonts("graphs/appendix5.pdf")
