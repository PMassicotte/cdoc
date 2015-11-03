#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         merge_data.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Merge all datasets cleaned by files starting with "process_*.R"
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

massicotte2011 <- readRDS("dataset/clean/massicotte2011.rds")
asmala2014 <- readRDS("dataset/clean/asmala2014.rds")
ferrari2010 <- readRDS("dataset/clean/ferrari2000.rds")
lonborg2010 <- readRDS("dataset/clean/lonborg2010.rds")
osburn2010 <- readRDS("dataset/clean/osburn2010.rds")
osburn2011 <- readRDS("dataset/clean/osburn2011.rds")

#---------------------------------------------------------------------
# For now, just select common variables.
#---------------------------------------------------------------------

mynames <- intersect(names(massicotte2011), names(asmala2014)) %>% 
  intersect(names(ferrari2010)) %>% 
  intersect(names(lonborg2010)) %>% 
  intersect(names(osburn2010)) %>% 
  intersect(names(osburn2011))

massicotte2011 <- select(massicotte2011, one_of(mynames))
asmala2014 <- select(asmala2014, one_of(mynames))
ferrari2010 <- select(ferrari2010, one_of(mynames))
lonborg2010 <- select(lonborg2010, one_of(mynames))
osburn2010 <- select(osburn2010, one_of(mynames))
osburn2011 <- select(osburn2011, one_of(mynames))

data_all <- bind_rows(massicotte2011,
                      asmala2014,
                      ferrari2010,
                      lonborg2010,
                      osburn2010,
                      osburn2011)


saveRDS(data_all, "dataset/clean/data_all.rds")


#---------------------------------------------------------------------
# Graph with all data.
#---------------------------------------------------------------------

ggplot(data_all, aes(x = doc, y = acdom)) +
  geom_point() +
  facet_grid(wavelength ~ study_id, scales = "free")

ggsave("graphs/data_all.pdf", width = 10, height = 15)
