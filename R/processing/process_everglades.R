#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         process_everglades.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Process raw data from: 
# http://sofia.usgs.gov/exchange/aiken/aikenchem.html
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
rm(list = ls())

#---------------------------------------------------------------------
# Surface water
#---------------------------------------------------------------------

everglades1 <- read_excel("dataset/raw/literature/everglades/DOC-data-SOFIA-5-02.xls", 
                   skip = 2, 
                   col_names = rep(c("sample_id", "date", "doc", "suva254"), 2),
                   sheet = 1) %>% 
  bind_rows(.[, 1:4], .[, 5:8]) %>% 
  filter(complete.cases(.)) %>% 
  mutate(suva254 = extract_numeric(suva254),
         acdom = extract_numeric(doc) * suva254, # convert suva to acdom
         doc = extract_numeric(doc) / 12 * 1000,
         wavelength = 254,
         date = as.Date(extract_numeric(date), origin = "1899-12-30"),
         depth = 0,
         study_id = "everglades_sw")

#---------------------------------------------------------------------
# Pore water
#---------------------------------------------------------------------

everglades2 <- read_excel("dataset/raw/literature/everglades/DOC-data-SOFIA-5-02.xls", 
                         skip = 2, 
                         col_names = rep(c("sample_id", "date", "depth", "doc", "suva254"), 2),
                         sheet = 2) %>% 
  bind_rows(.[, 1:5], .[, 6:10]) %>% 
  fill(sample_id, date) %>% 
  filter(complete.cases(.) & sample_id != "Site ID") %>% 
  mutate(suva254 = extract_numeric(suva254),
         acdom = extract_numeric(doc) * suva254, # convert suva to acdom
         doc = extract_numeric(doc) / 12 * 1000,
         wavelength = 254,
         depth = extract_numeric(depth),
         date = as.Date(extract_numeric(date), origin = "1899-12-30"),
         study_id = "everglades_pw")

everglades <- bind_rows(everglades1, everglades2) %>% 
  mutate(unique_id = paste("everglades",
                           as.numeric(interaction(study_id, 
                                                  date, 
                                                  depth,
                                                  sample_id,
                                                  drop = TRUE)),
                           sep = "_"))


# table5d -----------------------------------------------------------------

table5d <- read_csv("dataset/raw/literature/everglades/table5d.csv")
table5d <- table5d[, 1:4]
names(table5d) <- c("lab_id", "sample_id", "doc", "suva254")

table5d <- mutate(table5d,
                  acdom = doc / suva254,
                  doc = doc / 12 * 1000, 
                  wavelength = 254,
                  study_id = "table5d",
                  unique_id = paste("table5d",
                                    as.numeric(interaction(study_id, 
                                                           sample_id,
                                                           drop = TRUE)),
                                    sep = "_"))

everglades <- bind_rows(everglades, table5d)

saveRDS(everglades, file = "dataset/clean/literature/everglades.rds")

ggplot(everglades, aes(x = doc, y = acdom)) +
  geom_point() +
  facet_wrap(~study_id, scales = "free", ncol = 2)

ggsave("graphs/datasets/everglades.pdf", height = 5)
