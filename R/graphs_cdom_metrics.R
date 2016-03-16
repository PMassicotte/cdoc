#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         visualize_cdom_metrics.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Visualize metrics calculated in calculate_cdom_metrics.R
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
rm(list = ls())

cdom_metrics <- readRDS("dataset/clean/cdom_metrics.rds")

#---------------------------------------------------------------------
# Look at the histograms of SUVA metrics. This can serve as diagnostic
# tool to determine if some CDOM or DOC values are weird.
#---------------------------------------------------------------------
gather(cdom_metrics, suva_wl, suva, contains("suva")) %>% 
ggplot(aes(x = suva)) +
  geom_histogram(bins = 50) +
  facet_wrap(study_id ~ suva_wl, scales = "free", ncol = 3)

ggsave("graphs/histo_suva.pdf", width = 10, height = 25)

#---------------------------------------------------------------------
# Look at the slope histograms (check for outliers).
#---------------------------------------------------------------------
gather(cdom_metrics, slope_range, s, contains("s_")) %>% 
  ggplot(aes(x = s)) +
  geom_histogram() +
  facet_wrap(study_id ~ slope_range, scales = "free", ncol = 3)

ggsave("graphs/histo_slope.pdf", width = 12, height = 25)

gather(cdom_metrics, metric, value, suva254:sr) %>% 
ggplot(aes(x = ecotype, y = value)) +
  geom_boxplot(size = 0.1, outlier.size = 0.1) +
  facet_wrap(~metric, scales = "free")

ggsave("graphs/histo_metrics_by_ecotype.pdf", width = 10, height = 8)


# ---------------------------------------------------------------------
# Look at the relation between s275_295 and salinity.
# ---------------------------------------------------------------------
filter(cdom_metrics, !is.na(salinity)) %>% 
ggplot(aes(y = s, x = salinity)) +
  geom_point(size = 0.5) +
  facet_wrap(~study_id, scales = "free") +
  geom_smooth(method = "loess", size = 0.5)

ggsave("graphs/slope_vs_salinity.pdf", width = 7, height = 5)
