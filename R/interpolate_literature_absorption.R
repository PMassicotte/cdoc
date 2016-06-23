# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         interpolate_literature_absorption.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Interpolate the absorption at 350 nm from the literature data.
#               The acdom of the literature data is presented at different
#               wavelenghts (254, 320, etc.) and need to be predicted at the 
#               targeted wavelenght (350 nm).
# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())


# Open the data -----------------------------------------------------------

literature_dataset <- read_feather("dataset/clean/literature_datasets.feather") %>% 
  arrange(wavelength) %>% 
  group_by(wavelength) %>%
  nest()

source_wl <- literature_dataset$wavelength
target_wl <- 350

cdom_doc <- read_feather("dataset/clean/cdom_dataset.feather") %>%
  filter(study_id != "nelson") %>% # Nelson is missing wl < 275
  filter(study_id != "greenland_lakes") %>%  # These had lamp problem at 360 nm
  filter(study_id != "horsen") %>% 
  select(unique_id, wavelength, absorption) %>%
  filter(wavelength %in% c(source_wl, target_wl)) %>% 
  group_by(wavelength) %>% 
  nest()

# do the models -----------------------------------------------------------

predict_acdom <- function(data, source_wl) {
  
  y <- filter(cdom_doc, wavelength == target_wl)
  y <- unnest(y)
  
  x <- filter(cdom_doc, wavelength == source_wl)
  x <- unnest(x)
  
  df <- data.frame(x = x$absorption, y = y$absorption)
  
  mod <- lm(y ~ x, data = df)
  
  predicted <- predict(mod, newdata = list(x = data$absorption))
  
  data <- mutate(data, 
                 predicted_absorption = predicted, 
                 wavelength = source_wl, 
                 target_wl = target_wl,
                 r2 = summary(mod)$r.squared)
  
  return(data)
}


literature_dataset <- map2(literature_dataset$data, source_wl, predict_acdom) %>% 
  bind_rows()

# ********************************************************************
# Some dataset have absorption at more than 1 wavelenght and we do not
# want to keep "duplicated" values.
# 
# http://stackoverflow.com/questions/36160170/sub-setting-by-group-closest-to-defined-value
# ********************************************************************

literature_dataset <- group_by(literature_dataset, study_id) %>% 
  mutate(max_r2 = max(r2)) %>% 
  filter(r2 == max_r2) %>% 
  mutate(delta_wl = abs(wavelength - target_wl)) %>% 
  # filter(delta_wl == min(delta_wl)) %>% 
  ungroup()

write_feather(literature_dataset, "dataset/clean/literature_datasets_estimated_absorption.feather")

