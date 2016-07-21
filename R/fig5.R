
rm(list = ls())

# Panel A -----------------------------------------------------------------

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

plot(result / 1000, cdom_complete$suva254)

cdom_complete$distance = result / 1000


# Predict SUVA254 ---------------------------------------------------------

# suva350 <- ((cdom_complete$absorption * 0.01) / 2.303) / (cdom_complete$doc / 1000) * 12
# 
# plot(cdom_complete$suva254 ~ suva350)
# 
# lm1 <- lm(cdom_complete$suva254 ~ suva350)
# abline(lm1)
# 
# cdom_complete$suva254 <- predict(lm1)

# Plot --------------------------------------------------------------------

res <- cdom_complete %>%
  filter(distance > 0 & distance <= 1500) %>%
  mutate(absorbance = (absorption * 0.01) / 2.303) %>%
  mutate(suva350 = absorbance / (doc / 1000) * 12)

lm1 <- lm(suva254 ~ suva350, data = res)

plot(res$suva254 ~ res$suva350)

res <- res %>% mutate(suva254 = predict(lm1, newdata = list(suva350 = suva350)))

# res %>% 
#   filter(suva254 < 6) %>% 
#   ggplot(aes(x = distance, y = suva254)) +
#   geom_point(aes(color = study_id)) +
#   # scale_x_log10() +
#   scale_x_reverse() + 
#   geom_smooth() 

# mybreaks <- seq(min(log(res$distance)), max(log(res$distance)), len = 10)
# mybreaks <- exp(mybreaks)

mybreaks <- seq(min((res$distance)), max((res$distance)), len = 10)
mybreaks <- seq(0, 1500, by = 150)

ints <- findInterval(res$distance, mybreaks, all.inside = T)
xx <- (mybreaks[ints] + mybreaks[ints + 1]) / 2

res2 <- res %>%
  # filter(suva254 < 6) %>% 
  mutate(bin_distance = cut(
    distance,
    breaks = mybreaks,
    include.lowest = TRUE,
    dig.lab = 4
  )) %>%
  mutate(distance2 = xx) %>%
  group_by(bin_distance, distance2) %>%
  summarise(
    # mean_suva350 = mean(suva350, na.rm = TRUE),
    # sd_suva350 = sd(suva350, na.rm = TRUE),
    mean_suva254 = mean(suva254, na.rm = TRUE),
    sd_suva254 = sd(suva254, na.rm = TRUE),
    n = n()
  )

# model1 <- lm(mean_suva254 ~ distance2, data = res2) 
# model1
# 
# r2 <- paste("R^2== ", round(summary(model1)$r.squared, digits = 2))

pA <- res2 %>%
  ggplot(aes(x = distance2, y = mean_suva254)) +
  geom_point() +
  geom_pointrange(aes(ymin = mean_suva254 - sd_suva254,
                      ymax = mean_suva254 + sd_suva254)) +
  geom_smooth(method = "lm") +
  scale_x_reverse(
    breaks = res2$distance2,
    labels = as.character(res2$bin_distance),
    expand = c(0.06, 0)
  ) +
  ylim(0, 6) + 
  xlab("Distance to the closest ocean (km)") +
  ylab(bquote(SUVA[254]~(L%*%mgC^{-1}%*%m^{-1}))) +
  theme(axis.text.x = element_text(angle = 25, hjust = 1)) +
  # annotate(
  #   "text",
  #   x = -Inf,
  #   y = Inf,
  #   label = lm_eqn(model1),
  #   parse = TRUE,
  #   vjust = 2,
  #   hjust = -0.05
  # ) +
  annotate(
    "label",
    x = res2$distance2,
    y = 0.25,
    label = res2$n,
    fontface = "bold",
    size = 2
  ) +
  annotate("text", -Inf, Inf, label = "A",
           vjust = 2, hjust = 2, size = 5, fontface = "bold")

pA

# Panel B -----------------------------------------------------------------


metrics <- read_feather('dataset/clean/cdom_metrics.feather')

metrics <- metrics %>% 
  filter(salinity < 50) %>% 
  # filter(salinity > 0) %>%
  filter(!is.na(suva254))

plot(metrics$suva254 ~ metrics$salinity, xlim = c(0, 40))

lm1 <- lm(suva254 ~ salinity, metrics)
summary(lm1)

o <- segmented::segmented(lm1, seg.Z = ~salinity, psi = c(7, 30))
segmented::slope(o)

plot(o, add = TRUE, col = "red")

r2 = paste("R^2== ", round(summary(o)$r.squared, digits = 2))

df <- data_frame(salinity = seq(min(metrics$salinity), max(metrics$salinity), 
                                length.out = 20000)) %>% 
  mutate(predicted = predict(o, newdata = .))

pB <- metrics %>% 
  ggplot(aes(x = salinity, y = suva254)) +
  geom_point(color = "gray25", size = 1) +
  geom_line(data = df, aes(x = salinity, y = predicted), 
            color = "#3366ff", size = 1) +
  theme(legend.position = "none") +
  annotate("text", 15, Inf, label = r2,
           vjust = 2, hjust = 0, parse = TRUE) +
  geom_vline(xintercept = o$psi[, 2], lty = 2, size = 0.25) +
  annotate("text", 
           x = round(o$psi[, 2], digits = 2), 
           y = c(0, 0), 
           label = round(o$psi[, 2], digits = 2),
           hjust = 1.25,
           size = 3,
           fontface = "italic") +
  xlab("Salinity") +
  ylab(bquote(SUVA[254]~(L%*%mgC^{-1}%*%m^{-1}))) +
  scale_x_continuous(breaks = seq(0, 35, by = 5)) +
  ylim(0, 6) +
  theme(axis.title.y = element_blank()) +
  theme(axis.text.y = element_blank()) +
  annotate("text", Inf, Inf, label = "B",
           vjust = 2, hjust = 2, size = 5, fontface = "bold")

pB


# Panel C -----------------------------------------------------------------

pC <- data.frame(x = 0:1, y = c(0.5, 0.5)) %>%
  ggplot(aes(x = x, y = y)) +
  geom_path(size = 2,
            arrow = arrow(type = "closed", length = unit(0.25, "inches"))) +
  annotate(
    "text",
    x = 0,
    y = 0.51,
    label = "New",
    hjust = -0.05,
    # fontface = "bold",
    size = 5
  ) +
  annotate(
    "text",
    x = 1,
    y = 0.51,
    label = "Old",
    hjust = 2,
    # fontface = "bold",
    size = 5
  ) +
  annotate(
    "text",
    x = 0.5,
    y = 0.493,
    label = "DOM processing history",
    hjust = 0.5,
    fontface = "bold",
    size = 5
  ) +
  theme(
    axis.line = element_blank(),
    axis.text.x = element_blank(),
    axis.text.y = element_blank(),
    axis.ticks = element_blank(),
    axis.title.x = element_blank(),
    axis.title.y = element_blank(),
    legend.position = "none",
    panel.background = element_blank(),
    panel.border = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    plot.background = element_blank()
  ) +
  coord_cartesian(ylim = c(0.49, 0.52))

pC

# Save plot ---------------------------------------------------------------

p1 <- cowplot::plot_grid(pA, pB, ncol = 2, align = "hv")

p <- cowplot::ggdraw() +
  cowplot::draw_plot(p1, 0, 0.25, 1, 0.75) +
  cowplot::draw_plot(pC, 0, 0, 1, 0.25)

cowplot::save_plot("graphs/fig5.pdf", p, base_width = 7)
embed_fonts("graphs/fig5.pdf")

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
