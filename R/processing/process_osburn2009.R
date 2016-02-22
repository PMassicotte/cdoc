#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         process_osburn2009.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Process raw data from Osburn et al. 2009
# 
# Osburn, C. L., Retamal, L., and Vincent, W. F. (2009). 
# Photoreactivity of chromophoric dissolved organic matter transported by 
# the Mackenzie River to the Beaufort Sea. Mar. Chem. 115, 10–20. 
# doi:10.1016/j.marchem.2009.05.003.
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

osburn2009 <- read_csv("dataset/raw/literature/osburn2009/data_osburn2009.csv") %>% 
  mutate(unique_id = paste("osburn2009",
                           as.numeric(interaction(study_id, sample_id, drop = TRUE)),
                           sep = "_"))

stopifnot(nrow(osburn2009) == length(unique(osburn2009$unique_id)))

saveRDS(osburn2009, "dataset/clean/literature/osburn2009.rds")

ggplot(osburn2009, aes(x = doc, y = acdom)) +
  geom_point()
