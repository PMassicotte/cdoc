#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         compare_efficiency_prediction_a375.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Compare which method is best to predict a375 from other 
#               wavelengths. Here I am using a350 and I am testing method:
#               (1) which use S to predict a375 from a350
#               (2) use the relation between a375 and a350 
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
rm(list = ls())

metrics <- read_feather("dataset/clean/cdom_metrics.feather")

spectra <- read_feather("dataset/clean/cdom_dataset.feather")

a375_true <- filter(spectra, wavelength == 375)

a350 <- filter(spectra, wavelength == 350)

a375_s_method <- a350$absorption * exp(metrics$s * (350 - 375))

# Coefficients estimated in graphs_acdom350_vs_cdom_all_wl.R
a375_curve_method <- a350$absorption * 0.6454697 + -2.454391e-02


df <- data.frame(a375 = a375_true$absorption, a375_s_method, a375_curve_method) %>% 
  gather(method, value, a375_s_method, a375_curve_method)

ggplot(df, aes(x = a375, y = value)) +
  geom_point(size = 1, alpha = 0.5) +
  geom_smooth(method = "lm", size = 0.5) +
  facet_wrap(~method) +
  geom_abline(intercept = 0, slope = 1, color = "red", size = 0.1, lty = 2) +
  ylab("a350")

ggsave("graphs/compare_efficiency_prediction_a375.pdf", width = 8)
