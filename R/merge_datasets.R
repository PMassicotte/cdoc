#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         merge_datasets.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Merge all datasets containing CDOM and DOC data from
#               Colin, Eero and Philippe.
#               
#               Additionally, interpolate CDOM data so we have 1 nm increment
#               in wavelengths for each spectra. This will ensure that all
#               metrics are calculated using the same spectral ranges.
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

colin <- list.files("dataset/clean/stedmon/", "*.rds", full.names = TRUE) %>% 
  lapply(., readRDS) %>% 
  bind_rows()

asmala2014 <- readRDS("dataset/clean/asmala2014/asmala2014.rds")

massicotte2011 <- readRDS("dataset/clean/massicotte2011/massicotte2011.rds")

cdom_doc <- bind_rows(colin, massicotte2011, asmala2014)

#---------------------------------------------------------------------
# Based on the following two lines of code I decided to keep only
# wavelengths between 240 and 600 nm.
#---------------------------------------------------------------------
range(tapply(cdom_doc$wavelength, cdom_doc$unique_id, min))
range(tapply(cdom_doc$wavelength, cdom_doc$unique_id, max))

cdom_doc <- filter(cdom_doc, wavelength >= 240 & wavelength <= 600) %>% 
  arrange(study_id, wavelength)

#---------------------------------------------------------------------
# Lets interpolate CDOM between 240 mm and 600 mm by 1 nm.
#---------------------------------------------------------------------
res <- group_by(cdom_doc, unique_id) %>% 
  do(interpolated = pracma::interp1(x = .$wavelength,
                                    y = .$absorption,
                                    xi = seq(240, 600, by = 1),
                                    method = "spline"))

res2 <- data.frame(do.call("cbind", res$interpolated))
names(res2) <- res$unique_id
res2$wavelength <- seq(240, 600, by = 1)

res2 <- gather(res2, unique_id, absorption, -wavelength)

#---------------------------------------------------------------------
# Remove "old" wavelengths and absorption and replace with 
# interpolated ones.
#---------------------------------------------------------------------
cdom_doc <- select(cdom_doc, -wavelength, -absorption) %>% 
  distinct() %>% 
  left_join(., res2)

#---------------------------------------------------------------------
# Save the final result.
#---------------------------------------------------------------------
saveRDS(cdom_doc, file = "dataset/clean/complete_dataset.rds")
