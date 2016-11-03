#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Explore the relationship between SUVA254 and the distance 
#               to the closest ocean.
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

cdom_complete <- read_feather("dataset/clean/complete_data_350nm.feather")
cdom_complete <- cdom_complete %>%
  filter(!is.na(longitude) & !is.na(latitude)) %>%
  filter(ecosystem %in% c("ocean", "river"))

wgs.84 <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
mollweide <- "+proj=moll +lon_0=0 +x_0=0 +y_0=0 +ellps=WGS84 +datum=WGS84 +units=m +no_defs"

sp.points <- SpatialPoints(cdom_complete[, c("longitude", "latitude")],
                           proj4string = CRS(wgs.84))

# coast  <- readOGR(dsn="ne_10m_coastline/",layer="ne_10m_coastline")
coast <- readOGR(dsn = "dataset/shapefiles/ne_110m_ocean/",layer = "ne_110m_ocean")
coast <- as(coast, "SpatialLines")
coast.moll <- spTransform(coast, CRS(mollweide))
point.moll <- spTransform(sp.points, CRS(mollweide))


plot(point.moll, col = "red")
plot(coast.moll, add = T)
axis(1)
axis(2)
points(point.moll[c(89, 2766, 3218), ], col = "blue")

test   <- 1:nrow(cdom_complete)
result <- sapply(test, function(i) gDistance(point.moll[i], coast.moll))
result

cdom_complete <- cdom_complete %>%
  mutate(distance_to_ocean = result / 1000) %>%
  mutate(distance_to_ocean = ifelse(ecosystem == "ocean", 
                                    -distance_to_ocean, 
                                    distance_to_ocean)) %>% 
  mutate(absorbance = (absorption * 0.01) / 2.303) %>%
  mutate(suva350 = absorbance / (doc / 1000) * 12)

lm1 <- lm(suva254 ~ suva350, data = cdom_complete)

plot(cdom_complete$suva254 ~ cdom_complete$suva350)
abline(lm1, col = "red")

cdom_complete <- cdom_complete %>% 
  mutate(suva254 = predict(lm1, newdata = list(suva350 = suva350)))


# Breaks ------------------------------------------------------------------

mybreaks <- seq(min(cdom_complete$distance_to_ocean), 
                max(cdom_complete$distance_to_ocean), 
                by = 150)

ints <- findInterval(cdom_complete$distance_to_ocean, 
                     mybreaks, 
                     all.inside = TRUE, 
                     rightmost.closed = TRUE)

res2 <- cdom_complete %>%
  # filter(suva254 < 6) %>%
  mutate(bin_distance = mybreaks[ints] + 75) %>% 
  mutate(distance2 = bin_distance) %>%
  group_by(distance2) %>%
  summarise(
    mean_suva254 = unname(mean(suva254, na.rm = TRUE)),
    sd_suva254 = unname(sd(suva254, na.rm = TRUE)),
    n = n()
  ) %>% 
  ungroup()

tail(res2)

# Plot --------------------------------------------------------------------

pA <- res2 %>%
  ggplot(aes(x = distance2, y = mean_suva254)) +
  geom_point() +
  geom_pointrange(aes(ymin = mean_suva254 - sd_suva254,
                      ymax = mean_suva254 + sd_suva254)) +
  # geom_smooth(span = 0.5) +
  scale_x_reverse()

pA

# Is there a trend at km < 0?

# res2 %>%
#   filter(distance2 < 0) %>%
#   filter(mean_suva254 < 2) %>% 
#   ggplot(aes(x = distance2, y = mean_suva254)) +
#   geom_point() +
#   geom_pointrange(aes(ymin = mean_suva254 - sd_suva254,
#                       ymax = mean_suva254 + sd_suva254)) +
#   scale_x_reverse() +
#   geom_vline(xintercept = -360, lty = 2)

# Segmented ---------------------------------------------------------------

lm1 <- lm(mean_suva254 ~ distance2, res2)
summary(lm1)

o <- segmented::segmented(lm1, seg.Z = ~distance2)
segmented::slope(o)

t <- summary(o)
t

r2 = paste("R^2== ", round(summary(o)$r.squared, digits = 2))

df <- data_frame(distance2 = seq(min(res2$distance2), max(res2$distance2), length.out = 2000)) %>%
  mutate(mean_suva254 = predict(o, newdata = .))

# Some stats for the paper

df %>% 
  filter(distance2 >= -360) %>% 
  summarise(min(mean_suva254), max(mean_suva254))

df %>% 
  filter(distance2 < -360) %>% 
  summarise(min(mean_suva254), max(mean_suva254))

# What is the everage of the "flat" line after the identified brakepoint
res2 %>% 
  filter(distance2 < o$psi[2]) %>% 
  summarise(mean(mean_suva254))

# Panel A -----------------------------------------------------------------

pA <- ggplot() +
  geom_rect(aes(
    ymin = -Inf,
    ymax = Inf,
    xmax = t$psi[2] - t$psi[3],
    xmin = t$psi[2] + t$psi[3]),
    fill = "gray",
    alpha = 0.5
  ) +
  geom_pointrange(data = res2, aes(x = distance2, y = mean_suva254, ymin = mean_suva254 - sd_suva254,
                      ymax = mean_suva254 + sd_suva254),
                  size = 0.25,
                  color = "gray25") +
  scale_x_reverse(breaks = seq(-3000, 1500, by = 500)) +
  geom_line(
    data = df,
    aes(x = distance2, y = mean_suva254),
    col = "#3366ff",
    size = 1
  ) +
  geom_vline(xintercept = o$psi[2], lty = 2, size = 0.25) +
  xlab("Distance from shoreline (km)") +
  ylab(bquote(SUVA[254]~(m^2%*%gC^{-1}))) +
  scale_y_continuous(sec.axis = sec_axis(~. * 12, 
                                         name = bquote(a^"*"*~(m^2%*%molC^{-1})))) +
  annotate("text", -Inf, Inf, label = r2, vjust = 2, hjust = 2, parse = TRUE) +
  annotate(
    "text",
    x = round(o$psi[, 2], digits = 2),
    y = c(2),
    label = paste(round(o$psi[, 2], digits = 0), "±", round(o$psi[, 3], digits = 0), "km"),
    hjust = -0.25,
    size = 3,
    fontface = "italic"
  )

pA

# Panel B -----------------------------------------------------------------

pB <- data.frame(x = 0:1, y = c(0.5, 0.5)) %>%
  ggplot(aes(x = x, y = y)) +
  geom_path(size = 2,
            arrow = arrow(type = "closed", length = unit(0.25, "inches"))) +
  annotate(
    "text",
    x = 0,
    y = 0.51,
    label = "High",
    hjust = -0.05,
    # fontface = "bold",
    size = 5
  ) +
  annotate(
    "text",
    x = 1,
    y = 0.51,
    label = "Low",
    hjust = 2,
    # fontface = "bold",
    size = 5
  ) +
  annotate(
    "text",
    x = 0.5,
    y = 0.493,
    label = "DOM reactivity",
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

pB


# Save plots --------------------------------------------------------------

p1 <- cowplot::plot_grid(pA, pB, ncol = 2, align = "hv")

p <- cowplot::ggdraw() +
  cowplot::draw_plot(pA, 0, 0.25, 1, 0.75) +
  cowplot::draw_plot(pB, 0, 0, 1, 0.25)

cowplot::save_plot("graphs/fig6.pdf", p, base_width = 6)
embed_fonts("graphs/fig6.pdf")
