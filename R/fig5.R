# metrics %>% 
#   filter(salinity < 50) %>% 
#   select(s, s_350_400, s_275_295, sr, suva254, temperature,
#          salinity, longitude, latitude) %>% 
#   languageR::pairscor.fnc()

rm(list = ls())

metrics <- read_feather('dataset/clean/cdom_metrics.feather')

metrics <- metrics %>% 
  filter(salinity < 50) %>% 
  # filter(salinity > 0) %>%
  filter(!is.na(suva254))

# Segmentation regression -------------------------------------------------

plot(metrics$suva254 ~ metrics$salinity)

lm1 <- lm(suva254 ~ salinity, metrics)
summary(lm1)

o <- segmented::segmented(lm1, seg.Z = ~salinity, psi = c(7, 30))
plot(o, add = TRUE, col = "red")

r2 = paste("R^2== ", round(summary(o)$r.squared, digits = 2))

breaks <- c(0, o$psi[, 2], max(metrics$salinity)) %>% 
  as.vector()

df <- data_frame(salinity = seq(min(metrics$salinity), max(metrics$salinity), 
                                length.out = 20000)) %>% 
  mutate(predicted = predict(o, newdata = .)) %>% 
  mutate(segments = cut(salinity, breaks, include.lowest = TRUE))

p <- metrics %>% 
  ggplot(aes(x = salinity, y = suva254)) +
  geom_point(color = "gray25", size = 1) +
  geom_line(data = df, aes(x = salinity, y = predicted), 
            color = "#F8766D", size = 1) +
  theme(legend.position = "none") +
  annotate("text", Inf, Inf, label = r2,
           vjust = 2, hjust = 1.5, parse = TRUE) +
  geom_vline(xintercept = o$psi[, 2], lty = 2, size = 0.25) +
  annotate("text", 
           x = round(o$psi[, 2], digits = 2), 
           y = c(0, 0), 
           label = round(o$psi[, 2], digits = 2),
           hjust = 1.25,
           size = 3,
           fontface = "italic") +
  xlab("Salinity") +
  ylab(bquote(SUVA[254]~(L%*%mgC^{-1}%*%m^{-1})))

ggsave("graphs/fig5.pdf")
embed_fonts("graphs/fig5.pdf")