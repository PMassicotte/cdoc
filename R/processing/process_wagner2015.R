# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>  
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Process raw data from: 
# 
# Wagner, Sasha, Rudolf Jaffé, Kaelin Cawley, Thorsten Dittmar, and 
# Aron Stubbins. 2015. “Associations Between the Molecular and Optical 
# Properties of Dissolved Organic Matter in the Florida Everglades, a Model 
# Coastal Wetland System.” Frontiers in Chemistry 3 (November): 1–14. 
# doi:10.3389/fchem.2015.00066.
# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())


# doc ---------------------------------------------------------------------

doc <- read_excel("dataset/raw/literature/wagner2015/wagner2015.xlsx", 
                  sheet = "doc", na = "NA") %>% 
  select(site = Site,
         year = Year, 
         month = Month, 
         doc = `DOC  (mg-C L-1)`,
         salinity = `Salinity (ppt)`) %>% 
  mutate(doc = doc / 12 * 1000) %>% 
  mutate(date = as.Date(paste0(year, "/", month, "/01"), "%Y/%b/%d")) %>% 
  select(-year, -month)
  
# absorption --------------------------------------------------------------

cdom <- read_excel("dataset/raw/literature/wagner2015/wagner2015.xlsx", 
                  sheet = "cdom", na = "NA") %>% 
  select(site = Site,
         year = Year,
         month = Month,
         a254 = `a254 (m-1)`,
         suva254 = `SUVA254 (mg-C L-1 m-1)`,
         s_275_295 = `S275-295 (nm-1)`,
         s_350_400 = `S350-400 (nm-1)`) %>% 
  mutate(date = as.Date(paste0(year, "/", month, "/01"), "%Y/%b/%d")) %>% 
  select(-year, -month) %>% 
  rename(absorption = a254) %>% 
  mutate(wavelength = 254)


# locations ---------------------------------------------------------------

loc <- read_excel("dataset/raw/literature/wagner2015/wagner2015.xlsx", "site")

# merging -----------------------------------------------------------------

wagner2015 <- inner_join(doc, cdom, by = c("site", "date")) %>% 
  inner_join(., loc, by = "site") %>% 
  mutate(study_id = "wagner2015") %>% 
  mutate(unique_id = paste(study_id, 1:nrow(.), sep = "_")) %>% 
  mutate(ecosystem = "wetland")

write_feather(wagner2015, "dataset/clean/literature/wagner2015.feather")  

# wagner2015 %>%
#   ggplot(aes(x = doc, y = absorption)) +
#   geom_point()
