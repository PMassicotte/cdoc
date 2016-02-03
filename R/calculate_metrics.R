rm(list = ls())

cdom_metrics <- readRDS("dataset/clean/complete_dataset.rds") %>%
  mutate(doc_mg = doc * 12 / 1000, absorbance = absorption / 2.303) %>% 
  group_by(unique_id) %>% 
  nest() %>% 
  
  mutate(suva254 = map(data, ~ .$absorbance[.$wavelength == 254] / 
                      .$doc_mg[.$wavelength == 254])) %>% 
  
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
  
  mutate(s_240_600 = map(data, 
                         ~ cdom_fit_exponential(absorbance = .$absorption,
                                                wl = .$wavelength,
                                                startwl = 240,
                                                endwl = 600)$params$estimate[1]))

cdom_metrics <- mutate(cdom_metrics, 
                       suva254 = unlist(cdom_metrics$suva254),
                       s_275_295 = unlist(cdom_metrics$s_275_295),
                       s_350_400 = unlist(cdom_metrics$s_350_400),
                       s_240_600 = unlist(cdom_metrics$s_240_600),
                       sr = s_275_295 / s_350_400) %>% 
  select(-data)

saveRDS(cdom_metrics, file = "dataset/clean/cdom_metrics.rds")
