#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         process_asmala2014.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Process raw data from Asmala et al. 2014.
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

asmala2014 <- read_excel("dataset/raw/asmala2014/data.xlsx", na = "NA") %>% 
  
  gather(wavelength, acdom, matches("a\\d+")) %>% 
  
  gather(range, S, matches("S\\d+")) %>% 
  
  arrange(sample_id)

asmala2014$wavelength <- as.numeric(unlist(str_extract_all(asmala2014$wavelength, "\\d+")))
  
saveRDS(asmala2014, "dataset/clean/asmala2014.rds")

