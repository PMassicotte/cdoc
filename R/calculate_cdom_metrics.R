#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         calculate_cdom_metrics.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Calculate various metrics (SR, s275_295, etc.) from CDOM
#               spectra.
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

cdom_metrics <- read_feather("dataset/clean/cdom_dataset.feather") %>%
  mutate(doc_mg = doc * 12 / 1000, absorbance = absorption / 2.303) %>% 
  select(doc, doc_mg, wavelength, absorption, absorbance, unique_id) %>% 
  group_by(unique_id) %>% 
  nest() %>% 
  
  mutate(suva254 = purrr::map(data, ~ ifelse(any(254 %in% .$wavelength), .$absorbance[.$wavelength == 254] / 
                      .$doc_mg[.$wavelength == 254], NA))) %>% 
  
  mutate(suva350 = purrr::map(data, ~ .$absorbance[.$wavelength == 350] / 
                         .$doc_mg[.$wavelength == 350])) %>% 
  
  mutate(suva440 = purrr::map(data, ~ .$absorbance[.$wavelength == 440] / 
                         .$doc_mg[.$wavelength == 440])) %>% 
  
  mutate(s_275_295 = purrr::map(data, 
                         ~ cdom_exponential(absorbance = .$absorption,
                                                wl = .$wavelength,
                                                startwl = 275,
                                                endwl = 295))) %>% 
  mutate(s_350_400 = purrr::map(data, 
                         ~ cdom_exponential(absorbance = .$absorption,
                                                wl = .$wavelength,
                                                startwl = 350,
                                                endwl = 400))) %>% 
  
  mutate(s = purrr::map(data,
                 ~ cdom_exponential(absorbance = .$absorption,
                                                wl = .$wavelength,
                                                startwl = min(.$wavelength),
                                                endwl = max(.$wavelength))))

get_s <- function(df) {
  
  mycoefs <- coef(df)
  
  if(is.null(mycoefs)) {
    
    return(data.frame(S = NA, K = NA, a0 = NA))
    
  }
  
  return(data.frame(t(mycoefs)))
  
}

tt <- cdom_metrics %>% 
  unnest(s %>% purrr::map(get_s)) %>% 
  select(-s, -K, -a0) %>% 
  rename(s = S) %>% 
  unnest(s_350_400 %>% purrr::map(get_s)) %>% 
  select(-s_350_400, -K, -a0) %>% 
  rename(s_350_400 = S) %>% 
  unnest(s_275_295 %>% purrr::map(get_s)) %>% 
  select(-s_275_295, -K, -a0) %>% 
  rename(s_275_295 = S) %>% 
  unnest(suva254) %>% 
  unnest(suva350) %>% 
  unnest(suva440) %>% 
  mutate(sr = s_275_295 / s_350_400) %>% 
  select(-data)

cdom_metrics <- cdom_metrics %>% 
  unnest(s %>% purrr::map(get_s)) %>% 
  mutate(s_r2 = purrr::map(s, ~.$r2)) %>% 
  select(-s, -K, -a0) %>% 
  rename(s = S) %>% 
  unnest(s_350_400 %>% purrr::map(get_s)) %>% 
  select(-s_350_400, -K, -a0) %>% 
  rename(s_350_400 = S) %>% 
  unnest(s_275_295 %>% purrr::map(get_s)) %>% 
  select(-s_275_295, -K, -a0) %>% 
  rename(s_275_295 = S) %>% 
  unnest(suva254) %>% 
  unnest(suva350) %>% 
  unnest(suva440) %>%
  unnest(s_r2) %>% 
  mutate(sr = s_275_295 / s_350_400) %>% 
  select(-data)

# ********************************************************************
# Merge calculated metrics with other basic information.
# ********************************************************************

df <- read_feather("dataset/clean/cdom_dataset.feather") %>% 
  select(-wavelength, -absorption) %>% 
  distinct(unique_id, .keep_all = TRUE)

cdom_metrics <- left_join(cdom_metrics, df, by = "unique_id")

write_feather(cdom_metrics, "dataset/clean/cdom_metrics.feather")
