#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Explore the relationship between SUVA254 and salinity.
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

# Panel A -----------------------------------------------------------------

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
t <- summary(o)

plot(o, add = TRUE, col = "red")

r2 = paste("R^2== ", round(summary(o)$r.squared, digits = 2))

df <- data_frame(salinity = seq(min(metrics$salinity), max(metrics$salinity),
                                length.out = 20000)) %>%
  mutate(predicted = predict(o, newdata = .))

myrect <- data_frame(
  xmin = t$psi[, 2] - t$psi[, 3],
  xmax = t$psi[, 2] + t$psi[, 3],
  ymin = rep(-Inf, 2),
  ymax = rep(Inf, 2)
)

# Data for the conservative mixing curve

# mixing <- tibble(
#   x1 = min(df$salinity),
#   xend = max(df$salinity),
#   y1 = max(df$predicted),
#   yend = min(df$predicted)
# )

cdom <- read_feather("dataset/clean/complete_data_350nm.feather")
spectra <- read_feather("dataset/clean/cdom_dataset.feather")

mean(spectra$absorption[spectra$wavelength == 254 & spectra$salinity == 0], na.rm = TRUE) / 2.303
mean(spectra$absorption[spectra$wavelength == 254 & spectra$salinity >= 35], na.rm = TRUE) / 2.303

mean(metrics$doc[metrics$salinity == 0], na.rm = TRUE) * 0.001 * 12
mean(metrics$doc[metrics$salinity >= 35], na.rm = TRUE) * 0.001 * 12

n <- 200

mixing <- data_frame(
  salinity = seq(min(metrics$salinity), max(metrics$salinity), length.out = n),
  mix = seq(1, 0, length.out = n),
  a254 = (mix * 60.82237) + ((1 - mix) * 0.7986602),
  doc = (mix * 14.24677) + ((1 - mix) * 0.8509993),
  suva = a254 / doc 
) 


pA <- metrics %>%
  ggplot(aes(x = salinity, y = suva254)) +
  geom_rect(
    data = myrect,
    aes(
      ymin = ymin,
      ymax = ymax,
      xmax = xmax,
      xmin = xmin
    ),
    inherit.aes = F,
    fill = "gray",
    alpha = 0.5
  ) +
  geom_point(color = "gray50", size = 1) +
  geom_line(data = df, aes(x = salinity, y = predicted),
            color = "#3366ff", size = 1) +
  theme(legend.position = "none") +
  annotate("text", Inf, Inf, label = r2,
           vjust = 2, hjust = 2, parse = TRUE) +
  geom_vline(xintercept = o$psi[, 2], lty = 2, size = 0.25) +
  annotate("text",
           x = round(o$psi[, 2], digits = 1),
           y = c(0, 0),
           label = paste(round(o$psi[, 2], digits = 1), "±", round(o$psi[, 3], digits = 1)),
           hjust = -0.25,
           size = 3,
           fontface = "italic") +
  xlab("Salinity") +
  ylab(bquote(SUVA[254]~(m^2%*%gC^{-1}))) +
  scale_x_continuous(breaks = seq(0, 35, by = 5)) +
  scale_y_continuous(sec.axis = sec_axis(~. * 27.64, 
                                         name = bquote(a^"*"*~(m^2%*%molC^{-1})))) +
  annotate("text", -Inf, Inf, label = r2, vjust = 2, hjust = 2, parse = TRUE) +
  geom_line(data = mixing, aes(x = salinity, y = suva), color = "red")

pA


# Conceptual plot ---------------------------------------------------------

vars <- c(
  "Photodegradation",
  "Biodegradation",
  "Primary production",
  "Freshwater residence time",
  "Flocculation"
)

vars <- forcats::as_factor(vars)
vars <- reorder(vars, c(1, 3, 4, 5, 2))

# 1st segment
df1 <- data_frame(
  key = vars,
  value = c(1, 1, 0.4, 0.1, 1)
)

# 2nd segment
df2 <- data_frame(
  key = vars,
  value = c(0.25, 0.35, 0.7, 0.3, 0.1)
)

# 3rd segment
df3 <- data_frame(
  key = vars,
  value = c(0.15, 0.1, 0.2, 1, 0.05)
)

# df1$key <-
#   factor(df1$key, rev(
#     c(
#       "Water age",
#       "Primary production",
#       "Biodegradation",
#       "Photodegradation",
#       "Flocculation"
#     )
#   ))
# 
# df2$key <-
#   factor(df2$key, rev(
#     c(
#       "Water age",
#       "Primary production",
#       "Biodegradation",
#       "Photodegradation",
#       "Flocculation"
#     )
#   ))
# 
# df3$key <-
#   factor(df3$key, rev(
#     c(
#       "Water age",
#       "Primary production",
#       "Biodegradation",
#       "Photodegradation",
#       "Flocculation"
#     )
#   ))

myplot <- function(df) {
  
  p <- df %>%
    ggplot(aes(x = key, y = value, fill = key)) +
    geom_bar(stat = "identity",
             position = position_dodge(width = .8),
             width = 0.8,
             alpha = 0.5) +
    scale_y_continuous(
      breaks = c(0.2, 0.8),
      labels = c("Low", "High"),
      limits = c(0, 1)
    ) +
    coord_flip() +
    theme_bw(base_size = 8, base_family = "Open Sans") +
    theme(axis.title.x = element_blank()) +
    theme(axis.title.y = element_blank()) +
    theme(axis.ticks = element_blank()) +
    theme(axis.text.y = element_blank()) +
    theme(panel.grid.major = element_blank()) +
    theme(panel.grid.minor = element_blank()) +
    # theme(axis.text.x = element_text(margin = margin(-10, 0, 0, 0))) +
    theme(axis.text.x = element_text(color = "gray50")) +
    geom_text(
      y = 0.03,
      aes(label = key),
      hjust = 0,
      size = 2,
      color = "gray50"
    ) +
    scale_fill_manual(
      values = c(
        "Freshwater residence time" = "#a6bddb",
        "Primary production" = "#a1d99b",
        "Biodegradation" = "#EA6763",
        "Photodegradation" = "#EA6763",
        "Flocculation" = "#EA6763"
      )
    ) +
    theme(legend.position = "none")

  invisible(p)
}

p1 <- myplot(df1)
p2 <- myplot(df2)
p3 <- myplot(df3)

# Save plot ---------------------------------------------------------------

p <- ggdraw() +
  draw_plot(p1, 0.08, 0.75, 0.21, .2) +
  draw_plot(p2, 0.38, 0.75, 0.21, .2) +
  draw_plot(p3, 0.67, 0.75, 0.21, .2) +
  draw_plot(pA, 0, 0, 1, 0.75)

cowplot::save_plot("graphs/fig6.pdf", p, base_height = 5, base_width = 6)
embed_fonts("graphs/fig6.pdf")
