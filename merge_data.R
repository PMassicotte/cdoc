#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         merge_data.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Merge all datasets cleaned by files starting with "process_*.R"
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

massicotte2011 <- readRDS("data/clean/massicotte2011.rds")
asmala2014 <- readRDS("data/clean/asmala2014.rds")
ferrario2010 <- readRDS("data/clean/ferrari2000.rds")
lonboeg2010 <- readRDS("data/clean/lonborg2010.rds")
osburn2010 <- readRDS("data/clean/osburn2010.rds")

#---------------------------------------------------------------------
# For now, just select common variables.
#---------------------------------------------------------------------

mynames <- intersect(names(massicotte2011), names(asmala2014)) %>% 
  intersect(names(ferrario2010)) %>% 
  intersect(names(lonboeg2010)) %>% 
  intersect(names(osburn2010))

massicotte2011 <- select(massicotte2011, one_of(mynames))
asmala2014 <- select(asmala2014, one_of(mynames))
ferrario2010 <- select(ferrario2010, one_of(mynames))
lonboeg2010 <- select(lonboeg2010, one_of(mynames))
osburn2010 <- select(osburn2010, one_of(mynames))

data_all <- bind_rows(massicotte2011,
                      asmala2014,
                      ferrario2010,
                      lonboeg2010,
                      osburn2010)

saveRDS(data_all, "data/clean/data_all.rds")