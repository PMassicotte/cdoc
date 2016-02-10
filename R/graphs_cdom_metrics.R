#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         visualize_cdom_metrics.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Visualize metrics calculated in calculate_cdom_metrics.R
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
rm(list = ls())

cdom_doc <- readRDS("dataset/clean/complete_dataset.rds")
cdom_metrics <- readRDS("dataset/clean/cdom_metrics.rds") %>% 
  na.omit() %>% 
  mutate(study_id = str_match(unique_id, "(\\S+)_")[,2])

cdom_doc <- left_join(cdom_doc, cdom_metrics, by = "unique_id")

#---------------------------------------------------------------------
# Look at the histograms of SUVA metrics. This can serve as diagnostic
# tool to determine if some CDOM or DOC values are weird.
#---------------------------------------------------------------------
gather(cdom_metrics, suva_wl, suva, contains("suva")) %>% 
ggplot(aes(x = suva)) +
  geom_histogram(bins = 50) +
  facet_wrap(study_id ~ suva_wl, scales = "free", ncol = 3)

ggsave("graphs/histo_suva.pdf", width = 10, height = 15)

#---------------------------------------------------------------------
# Idea from Eero: look at relation between s_275_295 and SUVA
#---------------------------------------------------------------------
ggplot(cdom_metrics, aes(x = s_240_600, y = suva254)) +
  geom_point(aes(color = study_id)) +
  #scale_x_log10() +
  scale_y_log10() +
  annotation_logticks() +
  geom_smooth(method = "lm") +
  xlab(expression(S[240-600])) +
  ylab(expression(SUVA[254])) +
  labs(color = "Study")

ggsave("graphs/suva254_vs_s240_600.pdf")


#---------------------------------------------------------------------
# Look at the slope histograms (check for outliers).
#---------------------------------------------------------------------

gather(cdom_metrics, slope_range, s, contains("s_")) %>% 
  ggplot(aes(x = s)) +
  geom_histogram(bins = 50) +
  facet_wrap(study_id ~ slope_range, scales = "free", ncol = 3)

ggsave("graphs/histo_slope.pdf", width = 10, height = 15)
