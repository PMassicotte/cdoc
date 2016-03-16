# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         clean_data.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Remove outliers in the data.
# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

complete_dataset <- readRDS("dataset/clean/cdom_dataset.rds")
literature_dataset <- readRDS("dataset/clean/literature_datasets.rds")
metrics <- readRDS("dataset/clean/cdom_metrics.rds")

`%ni%` <- Negate(`%in%`)

to_remove <- NULL

# Based on SUVA254 --------------------------------------------------------

threshold <- 6

to_remove <- metrics %>% filter(suva254 > threshold) %>% 
  mutate(removal_reason = paste("SUVA254 greater than", threshold)) %>% 
  bind_rows(to_remove)

# Based on the spectral slope ---------------------------------------------

threshold <- 0.08

to_remove <- metrics %>% filter(s > threshold) %>% 
  mutate(removal_reason = paste("S greater than", threshold)) %>% 
  bind_rows(to_remove)


# Based on poorly fited sample --------------------------------------------

threshold <- 0.95

tmp <- complete_dataset %>% 
  group_by(unique_id) %>% 
  nest() %>% 
  mutate(r2 = map(data, ~ cdom_fit_exponential(absorbance = .$absorption,
                                               wl = .$wavelength,
                                               startwl = min(.$wavelength),
                                               endwl = max(.$wavelength))$r2)) %>% 
  unnest(r2) %>% 
  select(-data) %>% 
  filter(r2 < threshold) %>% 
  mutate(removal_reason = paste("R2 smaller than", threshold))

to_remove <- bind_rows(to_remove, tmp)

st <- "These samples have been removed during the cleaning process in 'clean_data.R'"
st <- paste0(strwrap(st, 70), sep = "", collapse = "\n")

p <- ggplot(filter(complete_dataset, unique_id %in% tmp$unique_id), aes(x = wavelength, y = absorption, group = unique_id)) +
  geom_line(aes(color = unique_id)) +
  ggtitle("Complete spectra removed", subtitle = st)

ggsave("graphs/removed_spectra.pdf", p)

# Remove outliers ---------------------------------------------------------

complete_dataset <- filter(complete_dataset, unique_id %ni% to_remove$unique_id)
metrics <- filter(metrics, unique_id %ni% to_remove$unique_id)

# Save cleaned data -------------------------------------------------------

saveRDS(complete_dataset, file = "dataset/clean/cdom_dataset.rds")
saveRDS(literature_dataset, file = "dataset/clean/literature_datasets.rds")
saveRDS(metrics, file = "dataset/clean/cdom_metrics.rds")
