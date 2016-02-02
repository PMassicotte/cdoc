#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         process_cdom_colin.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Read and format absorbance + DOC data from C. Stedmon.
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>


# Antarctic ---------------------------------------------------------------

rm(list = ls())

antarctic_doc <- read_excel("dataset/raw/stedmon/Antarctic/Antarctic.xls", 
                            sheet = "sas_export") %>% 
  select(Type:depth, doc = DOC, -Sample_No_, -density) %>% 
  rename(sample_id = ID, longitude = Long_S, latitude = Lat_W)

antarctic_doc$sample_id <- tolower(antarctic_doc$sample_id)

names(antarctic_doc) <- tolower(names(antarctic_doc))

# Calculate longitude and latitude

res <- str_match(antarctic_doc$longitude, "(\\d+)o (\\d+).(\\d+)")[, 2:4] %>%
  apply(., 2, as.numeric)

longitude <- res[, 1] + res[, 2]/60 + res[, 3]/3600

res <- str_match(antarctic_doc$latitude, "(\\d+)o (\\d+).(\\d+)")[, 2:4] %>%
  apply(., 2, as.numeric)

latitude <- res[, 1] + res[, 2]/60 + res[, 3]/3600

antarctic_doc$longitude = longitude
antarctic_doc$latitude = latitude

antarctic_cdom <- read_sas("dataset/raw/stedmon/Antarctic/Antarctic_abs.sas7bdat") %>%
  select(sample_id = label,
         wavelength = wave,
         absorption = acoef,
         date = Date,
         m_date = m_date)

antarctic_cdom$sample_id <- tolower(antarctic_cdom$sample_id)
antarctic_cdom$sample_id <- gsub(" ", "", antarctic_cdom$sample_id )

antarctic <- inner_join(antarctic_doc, antarctic_cdom, by = "sample_id") %>% 
  mutate(study_id = "antarctic") %>% 
  mutate(unique_id = sample_id) %>% 
  mutate(unique_id = paste("antarctic",
                           as.numeric(interaction(unique_id, drop = TRUE)),
                           sep = "_"))

saveRDS(antarctic, "dataset/clean/stedmon/antacrtic.rds")

write_csv(anti_join(antarctic_doc, antarctic_cdom, by = "sample_id"), 
          "tmp/not_matched_antarctic_doc.csv")

ggplot(antarctic, aes(x = wavelength, y = absorption, group = unique_id)) +
  geom_line(size = 0.1) +
  ggtitle("Antartic CDOM")

ggsave("graphs/colin/antartic.pdf")

# Arctic rivers -----------------------------------------------------------

rm(list = ls())

arctic_doc <- read_sas("dataset/raw/stedmon/Arctic Rivers/partners_summary.sas7bdat") %>% 
  select(river = River, date, doc, t, year = Year)

arctic_doc$doc <- as.numeric(arctic_doc$doc)
arctic_doc$t <- as.numeric(arctic_doc$t)
arctic_doc$year <- as.numeric(arctic_doc$year)

arctic_doc <- mutate(arctic_doc, doc = doc / 12 * 1000)

arctic_cdom <- read_sas("dataset/raw/stedmon/Arctic Rivers/partners_abs.sas7bdat") %>% 
  mutate(year = extract_numeric(year) + 2000) %>%
  select(wavelength = wave,
         absorption = acoef,
         year = year,
         river = river,
         t = t)

arctic_cdom$t <- as.numeric(arctic_cdom$t)

arctic <- inner_join(arctic_doc, arctic_cdom, by = c("river", "t", "year"))

write_csv(anti_join(arctic, arctic, c("river", "t", "year")), 
          "tmp/not_matched_arctic_doc.csv")

arctic <- select(arctic, -year) %>% 
  mutate(study_id = "arctic") %>% 
  mutate(unique_id = paste(date, river, t, sep = "_")) %>% 
  mutate(unique_id = paste("arctic",
                           as.numeric(interaction(unique_id, drop = TRUE)),
                           sep = "_"))

saveRDS(arctic, "dataset/clean/stedmon/arctic.rds")

ggplot(arctic, aes(x = wavelength, 
                   y = absorption, 
                   group = unique_id)) +
  geom_line(size = 0.1) +
  ggtitle("Arctic CDOM")

ggsave("graphs/colin/arctic.pdf")

# Dana12 rivers -----------------------------------------------------------

rm(list = ls())

dana12_doc <- read_csv("dataset/raw/stedmon/Dana12/Dana12.csv", na = "NaN") %>% 
  select(Cruise:DOC, Salinity, Temperature) %>% 
  rename(sample_id = SampleNo) %>% 
  mutate(date = as.Date(paste(.$Year, .$Month, .$Day),
                 format = "%Y %m %d")) %>% 
  select(-Year, -Month, -Day)

names(dana12_doc) <- tolower(names(dana12_doc))

dana12_cdom <- readMat("dataset/raw/stedmon/Dana12/Dana2012ShimadzuAbsorbance.mat")

absorbance <- data.frame(dana12_cdom$AbsData)
names(absorbance) <-  dana12_cdom$CDOMid

absorbance$wavelength <- dana12_cdom$Wave

dana12_cdom <- gather(absorbance, sample_id, absorbance, -wavelength) %>% 
  mutate(absorption = (absorbance * 2.303) / 0.01) %>% 
  select(-absorbance) %>% 
  mutate(sample_id = as.numeric(sample_id))

dana12 <- inner_join(dana12_doc, dana12_cdom, by = "sample_id") %>% 
  mutate(study_id = "dana12", 
         sample_id = as.character(sample_id),
         cruise = as.character(cruise),
         unique_id = as.character(sample_id)) %>% 
  mutate(unique_id = paste("dana12",
                           as.numeric(interaction(unique_id, drop = TRUE)),
                           sep = "_"))

saveRDS(dana12, "dataset/clean/stedmon/dana12.rds")

write_csv(anti_join(dana12_doc, dana12_cdom, by = "sample_id"), 
          "tmp/not_matched_dana12_doc.csv")

ggplot(dana12, aes(x = wavelength, y = absorption, group = unique_id)) +
  geom_line(size = 0.1) +
  ggtitle("Dana12 CDOM")

ggsave("graphs/colin/dana12.pdf")

# Greenland lakes ---------------------------------------------------------

rm(list = ls())

greenland_doc <- read_excel("dataset/raw/stedmon/Greenland Lakes/GreelandLakesDOC.xls") %>% 
  select(-LONGITUDE, longitude = LONG, latitude = LAT) %>% 
  mutate(date = as.Date(paste(.$YEAR, .$month, "1"),
                        format = "%Y %m %d")) %>% 
  select(-YEAR, -month)

names(greenland_doc) <- tolower(names(greenland_doc))

greenland_cdom <- read_sas("dataset/raw/stedmon/Greenland Lakes/abs.sas7bdat") %>% 
  select(station, wavelength = wave, absorption = acoef) 

ggplot(greenland_cdom, aes(x = wavelength, y = absorption, group = station)) +
  geom_line()

# dana12 <- left_join(dana12_doc, dana12_cdom, by = c("sampleno"  = "sample_id")) 
# 
# saveRDS(dana12, "dataset/clean/stedmon/dana12.rds")
# 
# write_csv(anti_join(dana12_doc, dana12_cdom, by = c("sampleno"  = "sample_id")), 
#           "tmp/not_matched_dana12_doc.csv")


# Horsens -----------------------------------------------------------------

rm(list = ls())

horsens_doc <- read_sas("dataset/raw/stedmon/Horsens/hf_doc.sas7bdat") %>%
  rename(sample_id = station, doc = DOC_M)

horsens_cdom <- read_sas("dataset/raw/stedmon/Horsens/hf_abs.sas7bdat") %>% 
  select(wavelength = wave,
         sample_id = station,
         date,
         depth,
         type,
         absorption = acdom) %>% 
  filter(type == 0.2)

# Replace NA depth with 0
horsens_doc$depth[is.na(horsens_doc$depth)] <- 0
horsens_cdom$depth[is.na(horsens_cdom$depth)] <- 0

horsens <- inner_join(horsens_doc, horsens_cdom, 
                     by = c("sample_id", "depth", "date")) %>% 
  mutate(study_id = "horsens", 
         sample_id = as.character(sample_id),
         unique_id = paste(sample_id, date, type, depth, sep = "_")) %>% 
  mutate(unique_id = paste("horsens",
                           as.numeric(interaction(unique_id, drop = TRUE)),
                           sep = "_")) %>% 
  distinct()


saveRDS(horsens, "dataset/clean/stedmon/horsens.rds")

write_csv(anti_join(horsens_doc, horsens_cdom, 
                    by = c("sample_id", "depth", "date")),
          "tmp/not_matched_horsens_doc.csv")

ggplot(horsens, aes(x = wavelength, y = absorption, group = unique_id)) +
  geom_line(size = 0.1) +
  facet_wrap(~depth, scales = "free_y") +
  ggtitle("Horsens CDOM at various depths")

ggsave("graphs/colin/horsens.pdf")

# Kattegat ----------------------------------------------------------------

rm(list = ls())

file_doc <- list.files("dataset/raw/stedmon/Kattegat/", "*doc*",
                       full.names = TRUE)

kattegat_doc <- lapply(file_doc, read_sas) %>% 
  lapply(., function(x){names(x) = tolower(names(x)); return(x)}) %>% 
  bind_rows() %>% 
  select(sample_id = sample_number, doc = doc, cruise = cruise) %>%  
  na.omit()

kattegat_doc <- kattegat_doc[-which(kattegat_doc$sample_id == 213 & 
                      kattegat_doc$cruise == "GT237"), ]

file_cdom <- list.files("dataset/raw/stedmon/Kattegat/", "*abs*",
                       full.names = TRUE)

kattegat_cdom <- lapply(file_cdom, read_sas) %>% 
  lapply(., function(x){names(x) = tolower(names(x)); return(x)}) %>% 
  bind_rows() %>% 
  select(sample_id = sample_number, wavelength = wave, absorption = acoef,
         cruise = cruise) %>% 
  distinct(sample_id, wavelength, cruise)

kattegat <- inner_join(kattegat_doc, kattegat_cdom, 
                       by = c("sample_id", "cruise")) %>% 
  mutate(study_id = "kattegat", 
         sample_id = as.character(sample_id),
         unique_id = paste(sample_id, cruise, sep = "_")) %>% 
  mutate(unique_id = paste("kattegat",
                           as.numeric(interaction(unique_id, drop = TRUE)),
                           sep = "_"))

saveRDS(kattegat, "dataset/clean/stedmon/kattegat.rds")

write_csv(anti_join(kattegat_doc, kattegat_cdom, by = c("sample_id", "cruise")),
          "tmp/not_matched_kattegat_doc.csv")

ggplot(kattegat, aes(x = wavelength, y = absorption, group = unique_id)) +
  geom_line(size = 0.1) +
  facet_wrap(~cruise, ncol = 2) +
  ggtitle("Kattegat CDOM")

ggsave("graphs/colin/kattegat.pdf", width = 10, height = 7)


# Umeaa -------------------------------------------------------------------

rm(list = ls())

umeaa_doc <- read_sas("dataset/raw/stedmon/Umeaa/parafac.sas7bdat") %>% 
  select(sample_id = Station,
         place = Place,
         depth = Depth,
         doc = DOC) %>% 
  na.omit() %>% 
  filter(place == "water") %>% 
  select(-place)

umeaa_cdom <- read_sas("dataset/raw/stedmon/Umeaa/abs.sas7bdat") %>% 
  select(place = sted,
         wavelength = wave,
         sample_id = station,
         depth = dybde,
         absorption = acdom) %>%
  mutate(depth = as.numeric(depth), sample_id = as.numeric(sample_id)) %>% 
  filter(place == "water") %>% 
  select(-place)

umeaa <- inner_join(umeaa_doc, umeaa_cdom, by = c("sample_id", "depth")) %>% 
  mutate(study_id = "umeaa", 
         sample_id = as.character(sample_id),
         unique_id = paste(sample_id, depth, sep = "_")) %>% 
  mutate(unique_id = paste("umeaa",
                           as.numeric(interaction(unique_id, drop = TRUE)),
                           sep = "_"))

saveRDS(umeaa, "dataset/clean/stedmon/umeaa.rds")

write_csv(anti_join(umeaa_doc, umeaa_cdom, by = c("sample_id", "depth")),
          "tmp/not_matched_umeaa_doc.csv")

ggplot(umeaa, aes(x = wavelength, y = absorption, group = unique_id)) +
  geom_line(size = 0.1) +
  facet_grid(~depth) +
  ggtitle("Umeaa CDOM at 2 depths")

ggsave("graphs/colin/umeaa.pdf")
