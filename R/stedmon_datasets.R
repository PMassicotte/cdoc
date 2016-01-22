#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         stedmon_datasets.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Read and format absorbance + DOC data from C. Stedmon.
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

#---------------------------------------------------------------------
# Antarctic
#---------------------------------------------------------------------
rm(list = ls())

antarctic_doc <- read_excel("dataset/raw/stedmon/Antarctic/Antarctic.xls", 
                            sheet = "sas_export") %>% 
  select(Type:DON) %>% 
  rename(sample_id = ID)

names(antarctic_doc) <- tolower(names(antarctic_doc))

antarctic_doc$sample_id <- tolower(antarctic_doc$sample_id)


antarctic_cdom <- read_sas("dataset/raw/stedmon/Antarctic/Antarctic_abs.sas7bdat") %>%
  select(sample_id = label,
         wavelength = wave,
         absorption = acoef)

antarctic_cdom$sample_id <- tolower(antarctic_cdom$sample_id)
antarctic_cdom$sample_id <- gsub(" ", "", antarctic_cdom$sample_id )


antarctic <- left_join(antarctic_doc, antarctic_cdom, by = "sample_id")

saveRDS(antarctic, "dataset/clean/stedmon/antacrtic.rds")

write_csv(anti_join(antarctic_doc, antarctic_cdom, by = "sample_id"), 
          "/home/persican/Desktop/not_matched_antarctic_doc.csv")

ggplot(antarctic, aes(x = wavelength, y = absorption, group = sample_id)) +
  geom_line()


#---------------------------------------------------------------------
# Arctic rivers
#---------------------------------------------------------------------
rm(list = ls())

arctic_doc <- read_sas("dataset/raw/stedmon/Arctic Rivers/partners_summary.sas7bdat") %>% 
  select(river = River, date, doc, t, year = Year)

arctic_doc$doc <- as.numeric(arctic_doc$doc)
arctic_doc$t <- as.numeric(arctic_doc$t)
arctic_doc$year <- as.numeric(arctic_doc$year)

arctic_cdom <- read_sas("dataset/raw/stedmon/Arctic Rivers/partners_abs.sas7bdat") %>% 
  mutate(year = extract_numeric(year) + 2000) %>% 
  select(wavelength = wave,
         absorption = acoef,
         year = year,
         river = river,
         t = t)

arctic_cdom$t <- as.numeric(arctic_cdom$t)

arctic <- left_join(arctic_doc, arctic_cdom, by = c("river", "t", "year")) %>% 
  na.omit()

saveRDS(arctic, "dataset/clean/stedmon/arctic.rds")

write_csv(anti_join(arctic, arctic, c("river", "t", "year")), 
          "/home/persican/Desktop/not_matched_arctic_doc.csv")

ggplot(arctic, aes(x = wavelength, 
                   y = absorption, 
                   group = interaction(date, t))) +
  geom_line()


#---------------------------------------------------------------------
# Arctic rivers
#---------------------------------------------------------------------
rm(list = ls())

dana12_doc <- read_csv("dataset/raw/stedmon/Dana12/Dana12.csv", na = "NaN") %>% 
  select(Cruise:DOC, Salinity, Temperature)

names(dana12_doc) <- tolower(names(dana12_doc))


dana12_cdom <- readMat("dataset/raw/stedmon/Dana12/Dana2012ShimadzuAbsorbance.mat")

absorbance <- data.frame(dana12_cdom$AbsData)
names(absorbance) <-  dana12_cdom$CDOMid

absorbance$wavelength <- dana12_cdom$Wave

dana12_cdom <- gather(absorbance, sample_id, absorbance, -wavelength) %>% 
  mutate(absorption = (absorbance * 2.303) / 0.01) %>% 
  select(-absorbance) %>% 
  mutate(sample_id = as.numeric(sample_id))

ggplot(dana12_cdom, aes(x = wavelength, y = absorption, group = sample_id)) +
  geom_line()

dana12 <- left_join(dana12_doc, dana12_cdom, by = c("sampleno"  = "sample_id")) 

saveRDS(dana12, "dataset/clean/stedmon/dana12.rds")

write_csv(anti_join(dana12_doc, dana12_cdom, by = c("sampleno"  = "sample_id")), 
          "/home/persican/Desktop/not_matched_dana12_doc.csv")

#---------------------------------------------------------------------
# Greenland lakes
#---------------------------------------------------------------------
rm(list = ls())

greenland_doc <- read_excel("dataset/raw/stedmon/Greenland Lakes/GreelandLakesDOC.xls") %>% 
  select(-LONGITUDE)

names(greenland_doc) <- tolower(names(greenland_doc))


greenland_cdom <- read_sas("dataset/raw/stedmon/Greenland Lakes/abs.sas7bdat") %>% 
  rename(absorption = acoef,
         wavelength = wave)

ggplot(greenland_cdom, aes(x = wavelength, y = absorption, group = station)) +
  geom_line()

# dana12 <- left_join(dana12_doc, dana12_cdom, by = c("sampleno"  = "sample_id")) 
# 
# saveRDS(dana12, "dataset/clean/stedmon/dana12.rds")
# 
# write_csv(anti_join(dana12_doc, dana12_cdom, by = c("sampleno"  = "sample_id")), 
#           "/home/persican/Desktop/not_matched_dana12_doc.csv")

#---------------------------------------------------------------------
# Horsens
#---------------------------------------------------------------------
rm(list = ls())

horsens_cdom <- read_sas("dataset/raw/stedmon/Horsens/hf_abs.sas7bdat") %>% 
  select(wavelength = wave,
         sample_id = station,
         date,
         depth,
         type,
         absorption = acdom)

ggplot(horsens_cdom, aes(x = wavelength, y = absorption, group = interaction(sample_id, date, depth))) +
  geom_line(size = 0.05) +
  facet_grid(depth~type, scale = "free")

horsens_doc <- read_sas("dataset/raw/stedmon/Horsens/hf_doc.sas7bdat") %>%
  rename(sample_id = station, doc = DOC_M)

horsens <- left_join(horsens_doc, horsens_cdom, by = c("sample_id", "depth", "date"))

saveRDS(horsens, "dataset/clean/stedmon/horsens.rds")

write_csv(anti_join(horsens_doc, horsens_cdom, by = c("sample_id", "depth", "date")),
          "/home/persican/Desktop/not_matched_horsens_doc.csv")

#---------------------------------------------------------------------
# Kattegat
#---------------------------------------------------------------------
rm(list = ls())

#---------------------------------------------------------------------
# Umeaa
#---------------------------------------------------------------------
rm(list = ls())

umeaa_cdom <- read_sas("dataset/raw/stedmon/Umeaa/abs.sas7bdat") %>% 
  select(place = sted,
         wavelength = wave,
         sample_id = station,
         depth = dybde,
         absorption = acdom) %>%
  mutate(depth = as.numeric(depth), sample_id = as.numeric(sample_id)) %>% 
  filter(place == "water")

umeaa_doc <- read_sas("dataset/raw/stedmon/Umeaa/parafac.sas7bdat") %>% 
  select(sample_id = Station,
         place = Place,
         depth = Depth,
         doc = DOC) %>% 
  na.omit() %>% 
  filter(place == "water")

ggplot(umeaa_cdom, aes(x = wavelength, y = absorption, group = sample_id)) +
  geom_line() +
  facet_grid(depth ~ place)

umeaa <- left_join(umeaa_doc, umeaa_cdom, by = c("sample_id", "depth", "place"))

saveRDS(umeaa, "dataset/clean/stedmon/umeaa.rds")

write_csv(anti_join(umeaa_doc, umeaa_cdom, by = c("sample_id", "depth", "place")),
          "/home/persican/Desktop/not_matched_umeaa_doc.csv")
