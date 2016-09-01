#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Process raw data from:
# 
# Heinz, M., Graeber, D., Zak, D., Zwirnmann, E., Gelbrecht, J., & Pusch, M. T.
# (2015). Comparison of Organic Matter Composition in Agricultural versus Forest
# Affected Headwaters with Special Emphasis on Organic Nitrogen. Environmental
# Science & Technology, 49(4), 2081–2090. http://doi.org/10.1021/es505146h
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())


# DOC ---------------------------------------------------------------------

mn <- setNames(1:12, month.name)

doc <- read_excel("dataset/raw/complete_profiles/heinz2015/Abs_data_Heinz et al15.xlsx", sheet = "DOC") %>% 
  fill(stream, Lat, Lon) %>% 
  select(
    stream,
    sample,
    site, 
    month = campaign,
    doc = CDOC, 
    longitude = Lon,
    latitude = Lat
  ) %>% 
  mutate(site = as.character(site)) %>% 
  mutate(doc = doc / 12 * 1000) %>%
  na.omit() %>% 
  mutate(month = as.numeric(ifelse(str_detect(month, "\\d"), month, mn[month]))) %>% 
  mutate(ecosystem = "river") %>% 
  mutate(study_id = "heinz2015") %>% 
  mutate(unique_id = paste(study_id, 1:nrow(.), sep = "_"))


# CDOM and interpolation --------------------------------------------------

f <- function(df) {
  
  xx <- 250:500
  
  yy <- splinefun(df$wavelength, df$absorption)(xx)
  
  df <- tibble(wavelength = xx, absorption = yy)
  
  return(df)
}

cdom <- read_excel("dataset/raw/complete_profiles/heinz2015/Abs_data_Heinz et al15.xlsx", sheet = "ABS") %>%
  gather(wavelength, absorption, -stream, -month) %>% 
  mutate(wavelength = parse_number(wavelength)) %>% 
  group_by(stream, month) %>% 
  nest() %>% 
  mutate(interpolated = map(data, f)) %>% 
  unnest(interpolated) %>% 
  mutate(absorption = absorption * 2.303 / 0.01) # assume pathlenghgt of 1 cm


# Merge -------------------------------------------------------------------

heinz2015 <- inner_join(doc, cdom, by = c("stream", "month"))

write_feather(heinz2015, "dataset/clean/complete_profiles/heinz2015.feather")

# heinz2015 %>% 
#   ggplot(aes(x = wavelength, y = absorption, group = unique_id)) +
#   geom_line(size = 0.1)
