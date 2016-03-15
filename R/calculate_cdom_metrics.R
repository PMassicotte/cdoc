#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         calculate_cdom_metrics.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Calculate various metrics (SR, s275_295, etc.) from CDOM
#               spectra.
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

cdom_metrics <- readRDS("dataset/clean/cdom_dataset.rds") %>%
  mutate(doc_mg = doc * 12 / 1000, absorbance = absorption / 2.303) %>% 
  group_by(unique_id) %>% 
  nest() %>% 
  
  mutate(suva254 = map(data, ~ ifelse(any(254 %in% .$wavelength), .$absorbance[.$wavelength == 254] / 
                      .$doc_mg[.$wavelength == 254], NA))) %>% 
  
  mutate(suva350 = map(data, ~ .$absorbance[.$wavelength == 350] / 
                         .$doc_mg[.$wavelength == 350])) %>% 
  
  mutate(suva440 = map(data, ~ .$absorbance[.$wavelength == 440] / 
                         .$doc_mg[.$wavelength == 440])) %>% 
  
  mutate(s_275_295 = map(data, 
                         ~ cdom_fit_exponential(absorbance = .$absorption,
                                                wl = .$wavelength,
                                                startwl = 275,
                                                endwl = 295)$params$estimate[1])) %>% 
  mutate(s_350_400 = map(data, 
                         ~ cdom_fit_exponential(absorbance = .$absorption,
                                                wl = .$wavelength,
                                                startwl = 350,
                                                endwl = 400)$params$estimate[1])) %>% 
  
  mutate(s = map(data,
                 ~ cdom_fit_exponential(absorbance = .$absorption,
                                                wl = .$wavelength,
                                                startwl = min(.$wavelength),
                                                endwl = max(.$wavelength))$params$estimate[1]))

cdom_metrics <- mutate(cdom_metrics, 
                       suva254 = unlist(cdom_metrics$suva254),
                       suva350 = unlist(cdom_metrics$suva350),
                       suva440 = unlist(cdom_metrics$suva440),
                       s_275_295 = unlist(cdom_metrics$s_275_295),
                       s_350_400 = unlist(cdom_metrics$s_350_400),
                       s = unlist(cdom_metrics$s),
                       sr = s_275_295 / s_350_400) %>% 
  select(-data)

saveRDS(cdom_metrics, file = "dataset/clean/cdom_metrics.rds")
