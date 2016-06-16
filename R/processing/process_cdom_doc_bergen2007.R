# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>  
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Process raw spectra from:
# 
# Conan, P., Søndergaard, M., Kragh, T., Thingstad, F., Pujo-Pay, M., Williams,
# P. J. le B., et al. (2007). Partitioning of organic production in marine
# plankton communities: The effects of inorganic nutrient ratios and community
# composition on new dissolved organic matter. Limnol. Oceanogr. 52, 753–765.
# doi:10.4319/lo.2007.52.2.0753.
# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

bergen_cdom <- read_sas("../../project filter/filter/datasets/bergen/bergen02abs.sas7bdat") %>%
  select(bag,
         wavelength = wave,
         absorption = acdom,
         bag,
         date,
         type) %>%
  filter(type == 0.2) %>% # keep only 0.2 um filter data
  mutate(treatment = NA)

bergen_cdom$treatment[bergen_cdom$bag == 1] <- "p50_n3200_si0"
bergen_cdom$treatment[bergen_cdom$bag == 2] <- "p50_n1600_si0"
bergen_cdom$treatment[bergen_cdom$bag == 3] <- "p50_n800_si0"
bergen_cdom$treatment[bergen_cdom$bag == 4] <- "p100_n800_si0"
bergen_cdom$treatment[bergen_cdom$bag == 5] <- "p200_n800_si0"

bergen_cdom$treatment[bergen_cdom$bag == 6] <- "p50_n3200_si1"
bergen_cdom$treatment[bergen_cdom$bag == 7] <- "p50_n1600_si1"
bergen_cdom$treatment[bergen_cdom$bag == 8] <- "p50_n800_si1"
bergen_cdom$treatment[bergen_cdom$bag == 9] <- "p100_n800_si1"
bergen_cdom$treatment[bergen_cdom$bag == 10] <- "p200_n800_si1"

bergen_cdom$treatment[bergen_cdom$bag == 11] <- "control"


bergen_doc <- read_excel("../../project filter/filter/datasets/time series data.xls") %>%
  select(bag = BAG, date = DATE, doc = DOC) %>% 
  mutate(date = as.Date(date)) %>% 
  mutate(study_id = "bergen2007") %>%
  mutate(ecosystem = "estuary") %>%
  mutate(unique_id = paste(study_id, 1:nrow(.), sep = "_")) %>% 
  na.omit() %>% 
  mutate(longitude = 5.311659) %>% 
  mutate(latitude = 60.385725) 

# https://www.google.dk/maps/search/Raunefjord+bergen/@60.3839862,5.3112295,14z/data=!3m1!4b1

bergen2007 <- inner_join(bergen_doc, bergen_cdom, by = c("bag", "date"))

write_feather(bergen2007, "dataset/clean/complete_profiles/bergen2007.feather")

# bergen2007 %>% 
#   ggplot(aes(x = wavelength, y = absorption, group = unique_id)) +
#   geom_line(size = 0.1)
