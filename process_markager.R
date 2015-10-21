#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         process_markager.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Process raw data from from spss file given by Stiig.
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

markager <- read_sas("../../project astar/astar/data/lit2.sas7bdat") %>% 
  select(sample_id = Sample_ID,
         acdom = abs,
         wavelength = Wave,
         doc = DOC_mol) %>% 
  mutate(doc_unit = "µmol/l") %>% 
  na.omit()


saveRDS(markager, "dataset/clean/markager.rds")

## Test

ggplot(markager, aes(x = doc, y = acdom)) +
  geom_point() +
  facet_wrap(~wavelength, nrow = 4, scales = "free")
