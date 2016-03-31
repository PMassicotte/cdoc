#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         process_ferrari2000.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Process raw data from:
#
# Ferrari, G. M. (2000). The relationship between chromophoric dissolved
# organic matter and dissolved organic carbon in the European Atlantic coastal
# area and in the West Mediterranean Sea (Gulf of Lions).
# Mar. Chem. 70, 339–357. doi:10.1016/S0304-4203(00)00036-0.
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

ferrari2000 <- read_csv("dataset/raw/literature/ferrari2000/data.csv") %>%
  gather(wavelength, absorption, matches("a\\d+")) %>%
  gather(range, s, matches("S\\d+")) %>%
  mutate(date = as.Date(paste(year, month, "01", sep = "-"), format = "%Y-%B-%d")) %>%
  select(-year, -month) %>%
  mutate(wavelength = extract_numeric(wavelength)) %>%
  filter(!is.na(doc) & !is.na(absorption)) %>%
  mutate(unique_id = paste("ferrari2000", 1:nrow(.), sep = "_"))
  
# based on Fig. 2
ferrari2000$longitude <- -10
ferrari2000$latitude <- 40

ferrari2000$longitude[ferrari2000$ecosystem == "Gulf of Lion"] <- 4
ferrari2000$latitude[ferrari2000$ecosystem == "Gulf of Lion"] <- 43

saveRDS(ferrari2000, "dataset/clean/literature/ferrari2000.rds")
