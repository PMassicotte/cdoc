#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         process_tanana.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Process raw data from:
# http://pubs.usgs.gov/of/2007/1390/section4.html (tables 4 and 5)
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
rm(list = ls())

tanana2004 <- read_excel("dataset/raw/literature/tanana/ofr20071390_Table04.xls", skip = 4)
tanana2004 <- tanana2004[, c(2, 3, 10, 11)]
names(tanana2004) <- c("sample_id", "date", "suva254", "doc")

tanana2004$date <- as.Date(extract_numeric(tanana2004$date), origin = "1899-12-30")

tanana2005 <- read_excel("dataset/raw/literature/tanana/ofr20071390_Table05.xls", skip = 3)
tanana2005 <- tanana2005[, c(2, 3, 10, 11)]
names(tanana2005) <- c("sample_id", "date", "suva254", "doc")
tanana2005$date <- as.Date(tanana2005$date)

tanana <- bind_rows(tanana2004, tanana2005) %>% 
  mutate(suva254 = extract_numeric(suva254),
         doc = extract_numeric(doc),
         acdom = suva254 * doc,
         doc = doc / 12 * 1000,
         wavelength = 254,
         study_id = "tanana") %>% 
  na.omit() %>% 
  mutate(unique_id = paste("tanana",
                           as.numeric(interaction(study_id, 
                                                  date, 
                                                  sample_id,
                                                  drop = TRUE)),
                           sep = "_"))

stopifnot(nrow(tanana) == length(unique(tanana$unique_id)))

saveRDS(tanana, file = "dataset/clean/literature/tanana.rds")

ggplot(tanana, aes(x = doc, acdom)) +
  geom_point()

ggsave("graphs/datasets/tanana.pdf")
