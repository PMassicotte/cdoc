# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><> 
# AUTHOR:       Philippe Massicotte
# 
# DESCRIPTION:  Process raw data from:
# 
# Braun, K, M Drikas, R. Fabris, and L. Ho. 2015. “Water Research Australia
# Project 1008 (WRA 1008) DOC-UV, SA Water.”
# https://data.unisa.edu.au/Dataset.aspx?DatasetID=46019. 
# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())


# DOC ---------------------------------------------------------------------

df <- read_excel("dataset/raw/literature/braun2015//WRA 1008 DOC-UV.xlsx",
                 sheet = "DOC", skip = 4)

names(df)[1] <- "period"
df <- df %>%
  fill(period)

df1 <- df[, 1:8] %>% 
  mutate(location = "water_feeds") %>% 
  mutate(`Sample Date` = as.Date(`Sample Date`))

df2 <- df[, c(1, 11, 13:16)] %>% 
  mutate(location = "pds_outlet") %>% 
  mutate(`Sample Date` = as.Date(`Sample Date`, origin = "1899-12-30")) %>% 
  mutate(Conventional = parse_number(Conventional))

doc <- bind_rows(df1, df2) %>% 
  mutate(longitude = 139.048792, latitude = -34.773659) %>% 
  gather(type, doc, 3:8) %>% 
  mutate(doc = doc / 12 * 1000)

# Absorption --------------------------------------------------------------

df <- read_excel("dataset/raw/literature/braun2015/WRA 1008 DOC-UV.xlsx",
                 sheet = "UV", skip = 4)

names(df)[1] <- "period"
df <- df %>%
  fill(period)

df1 <- df[, 1:8] %>% 
  mutate(location = "water_feeds") %>% 
  mutate(`Sample Date` = as.Date(`Sample Date`))

df2 <- df[, c(1, 10, 12:15)] %>% 
  mutate(location = "pds_outlet") %>% 
  mutate(`Sample Date` = as.Date(`Sample Date`, origin = "1899-12-30")) %>% 
  mutate(Conventional = parse_number(Conventional))

cdom <- bind_rows(df1, df2) %>% 
  gather(type, absorption, 3:8) %>% 
  mutate(absorption = absorption * 2.303 / 0.01) %>% 
  mutate(wavelength = 254)

# Combine -----------------------------------------------------------------

braun2015 <- inner_join(doc, cdom) %>% 
  na.omit() %>% 
  mutate(date = `Sample Date`) %>% 
  mutate(study_id = "braun2015") %>% 
  mutate(unique_id = paste(study_id, 1:nrow(.), sep = "_")) %>% 
  mutate(ecosystem = "sewage")

write_feather(braun2015, "dataset/clean/literature/braun2015.feather")

# australia %>% 
#   ggplot(aes(x = doc, y = absorption)) +
#   geom_point()
