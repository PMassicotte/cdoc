# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         clean_data.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Remove outliers in the data.
# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

# *************************************************************************
# Cean the data with complete CDOM profils.
# *************************************************************************
rm(list = ls())

complete_dataset <- read_feather("dataset/clean/cdom_dataset.feather")
metrics <- read_feather("dataset/clean/cdom_metrics.feather")

`%ni%` <- Negate(`%in%`)

to_remove <- NULL

# Based on SUVA254 --------------------------------------------------------

threshold <- 6

to_remove <- metrics %>% filter(suva254 > threshold) %>% 
  select(study_id, unique_id) %>% 
  distinct() %>% 
  mutate(removal_reason = paste("SUVA254 greater than", threshold)) %>% 
  bind_rows(to_remove)

# Based on the spectral slope ---------------------------------------------

threshold <- 0.08

to_remove <- metrics %>% filter(s > threshold) %>% 
  select(study_id, unique_id) %>% 
  distinct() %>% 
  mutate(removal_reason = paste("S greater than", threshold)) %>% 
  bind_rows(to_remove)


# Based on poorly fited sample --------------------------------------------

threshold <- 0.95

to_remove <- metrics %>% filter(s_r2 < threshold) %>% 
  select(study_id, unique_id) %>% 
  distinct() %>%  
  mutate(removal_reason = paste("R2 smaller than", threshold)) %>% 
  bind_rows(to_remove)


# Based on absorbance at 440 < 0 ------------------------------------------

threshold <- 0

to_remove <- complete_dataset %>% 
  filter(wavelength == 440) %>%
  filter(absorption < 0) %>% 
  select(study_id, unique_id) %>% 
  distinct() %>%  
  mutate(removal_reason = paste("Absorption at 440 < ", threshold)) %>% 
  bind_rows(to_remove)

# Plot removed spectra ----------------------------------------------------

st <- "These samples have been removed during the cleaning process in 'clean_data.R'"
st <- paste0(strwrap(st, 70), sep = "", collapse = "\n")

df <- filter(complete_dataset, unique_id %in% to_remove$unique_id) %>% 
  left_join(., to_remove, by = c("unique_id", "study_id"))

p <- ggplot(df, aes(x = wavelength, y = absorption, group = unique_id)) +
  geom_line(aes(color = study_id), size = 0.1) +
  ggtitle("Complete spectra removed", subtitle = st) +
  facet_wrap(~removal_reason, scales = "free") +
  theme(legend.position = "right") +
  guides(colour = guide_legend(override.aes = list(size = 1)))

ggsave("graphs/removed_spectra.pdf", p, width = 15, height = 8)

# Remove outliers ---------------------------------------------------------

complete_dataset <- filter(complete_dataset, unique_id %ni% to_remove$unique_id)
metrics <- filter(metrics, unique_id %ni% to_remove$unique_id)

# Save cleaned data -------------------------------------------------------

write_feather(df, "dataset/clean/removed_samples.feather")
write_feather(complete_dataset, "dataset/clean/cdom_dataset.feather")
write_feather(metrics, "dataset/clean/cdom_metrics.feather")

# *************************************************************************
# Clean the literature data.
# *************************************************************************
# 
# rm(list = ls())
# 
# literature_dataset <- read_feather("dataset/clean/literature_datasets.feather")
# 
# 
# write_feather(literature_dataset, "dataset/clean/literature_datasets.feather")