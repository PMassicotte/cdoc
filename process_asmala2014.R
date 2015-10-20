#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         process_asmala2014.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Process raw data from Asmala et al. 2014.
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

asmala2014 <- read_excel("data/raw/asmala2014/data.xlsx", na = "NA") %>% 
  
  gather(wavelength, acdom, matches("a\\d+")) %>% 
  
  gather(range, S, matches("S\\d+")) %>% 
  
  arrange(sample_id)


saveRDS(asmala2014, "data/clean/asmala2014.rds")

