#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         process_castillo1999.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Process raw data from:
#
# Del Castillo, C. E., Coble, P. G., Morell, J. M., López, J. M., and
# Corredor, J. E. (1999). Analysis of the optical properties of the Orinoco
# River plume by absorption and fluorescence spectroscopy. Mar. Chem. 66, 35–51.
# doi:10.1016/S0304-4203(99)00023-7.
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

castillo1999 <- read_csv("dataset/raw/literature/castillo1999/data.csv") %>%
  filter(!is.na(doc) & !is.na(absorption)) %>%
  mutate(date = as.Date(paste(date, "-01", sep = ""), format = "%b-%y-%d")) %>%
  mutate(study_id = "castillo1999") %>%
  mutate(longitude = -longitude) %>%
  separate(site, into = c("cruise", "station", "depth"), sep = c(5, 9)) %>%
  mutate(depth = extract_numeric(depth)) %>%
  filter(!is.na(doc) & !is.na(absorption)) %>%
  mutate(unique_id = paste("castillo1999", 1:nrow(.), sep = "_"))

saveRDS(castillo1999, "dataset/clean/literature/castillo1999.rds")
