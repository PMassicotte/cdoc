#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         merge_cdom_datasets.R
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

cdom_doc <- list.files("dataset/clean/complete_profiles/",
                       "*.feather",
                       full.names = TRUE) %>% 
  lapply(., read_feather) %>%
  bind_rows()

# ********************************************************************
# Based on the following two lines of code I decided to keep only
# wavelengths between 250 and 600 nm.
# ********************************************************************
range(tapply(cdom_doc$wavelength, cdom_doc$unique_id, min))
range(tapply(cdom_doc$wavelength, cdom_doc$unique_id, max))

unique(unlist(tapply(cdom_doc$wavelength, cdom_doc$unique_id, diff)))

wl <- seq(250, 600, by = 1)

cdom_doc <- filter(cdom_doc, wavelength %in% wl) %>%
  arrange(study_id, wavelength)

# ********************************************************************
# Final data cleaning
# ********************************************************************

# Remove data without DOC values.
cdom_doc <- cdom_doc %>% 
  drop_na(doc, absorption)

# ********************************************************************
# Save the final result.
# ********************************************************************
write_feather(cdom_doc, "dataset/clean/cdom_dataset.feather")
