#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         process_cdom_colin.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Read and format absorbance + DOC data from C. Stedmon.
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

# Antarctic ---------------------------------------------------------------

rm(list = ls())

antarctic_doc <- read_excel("dataset/raw/complete_profiles/stedmon/Antarctic/Antarctic.xls",
                            sheet = "sas_export") %>%
  select(Type:depth, doc = DOC, -Sample_No_, -density) %>%
  rename(unique_id = ID, longitude = Lat_W, latitude = Long_S) # lat/long inverted in the source file

antarctic_doc$unique_id <- tolower(antarctic_doc$unique_id)

names(antarctic_doc) <- tolower(names(antarctic_doc))

# Calculate longitude and latitude

res <- str_match(antarctic_doc$longitude, "(\\d+)o (\\d+).(\\d+)")[, 2:4] %>%
  apply(., 2, as.numeric)

longitude <- res[, 1] + res[, 2]/60 + res[, 3]/3600

res <- str_match(antarctic_doc$latitude, "(\\d+)o (\\d+).(\\d+)")[, 2:4] %>%
  apply(., 2, as.numeric)

latitude <- res[, 1] + res[, 2]/60 + res[, 3]/3600

# Both longitude and latitude are west.
antarctic_doc$longitude = -longitude
antarctic_doc$latitude = -latitude

antarctic_cdom <- read_sas("dataset/raw/complete_profiles/stedmon/Antarctic/Antarctic_abs.sas7bdat") %>%
  select(unique_id = label,
         wavelength = wave,
         absorption = acoef,
         date = Date)

antarctic_cdom$unique_id <- tolower(antarctic_cdom$unique_id)
antarctic_cdom$unique_id <- gsub(" ", "", antarctic_cdom$unique_id)

antarctic <- inner_join(antarctic_doc, antarctic_cdom, by = "unique_id") %>%
  mutate(study_id = "antarctic") %>%
  mutate(unique_id = unique_id) %>%
  mutate(unique_id = paste("antarctic",
                           as.numeric(interaction(unique_id, drop = TRUE)),
                           sep = "_")) %>%
  mutate(ecotype = "hyposaline")

saveRDS(antarctic, "dataset/clean/complete_profiles/antacrtic.rds")

write_csv(anti_join(antarctic_doc, antarctic_cdom, by = "unique_id"),
          "tmp/not_matched_antarctic_doc.csv")

ggplot(antarctic, aes(x = wavelength, y = absorption, group = unique_id)) +
  geom_line(size = 0.1) +
  ggtitle("Antartic CDOM")

ggsave("graphs/datasets/antartic.pdf")

# Arctic rivers -----------------------------------------------------------

rm(list = ls())

arctic_doc <- read_sas("dataset/raw/complete_profiles/stedmon/Arctic Rivers/partners_summary.sas7bdat") %>%
  select(river = River, date, doc, t, year = Year) %>%
  mutate(doc = extract_numeric(doc)) %>%
  mutate(t = extract_numeric(t)) %>%
  mutate(year = extract_numeric(year)) %>%
  mutate(doc = doc / 12 * 1000)

arctic_cdom <- read_sas("dataset/raw/complete_profiles/stedmon/Arctic Rivers/partners_abs.sas7bdat") %>%
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
                           sep = "_")) %>%
  mutate(ecotype = "river")

saveRDS(arctic, "dataset/clean/complete_profiles/arctic.rds")

ggplot(arctic, aes(x = wavelength,
                   y = absorption,
                   group = unique_id)) +
  geom_line(size = 0.1) +
  ggtitle("Arctic CDOM")

ggsave("graphs/datasets/arctic.pdf")

# Dana12 rivers -----------------------------------------------------------

rm(list = ls())

dana12_doc <- read_csv("dataset/raw/complete_profiles/stedmon/Dana12/Dana12.csv", na = "NaN") %>%
  select(Cruise:DOC, Salinity, Temperature) %>%
  rename(unique_id = SampleNo) %>%
  mutate(date = as.Date(paste(.$Year, .$Month, .$Day),
                 format = "%Y %m %d")) %>%
  select(-Year, -Month, -Day)

names(dana12_doc) <- tolower(names(dana12_doc))

dana12_cdom <- readMat("dataset/raw/complete_profiles/stedmon/Dana12/Dana2012ShimadzuAbsorbance.mat")

absorbance <- data.frame(dana12_cdom$AbsData)
names(absorbance) <-  dana12_cdom$CDOMid

absorbance$wavelength <- dana12_cdom$Wave

dana12_cdom <- gather(absorbance, unique_id, absorbance, -wavelength) %>%
  mutate(absorption = (absorbance * 2.303) / 0.01) %>%
  select(-absorbance) %>%
  mutate(unique_id = as.numeric(unique_id))

dana12 <- inner_join(dana12_doc, dana12_cdom, by = "unique_id") %>%
  mutate(study_id = "dana12",
         unique_id = as.character(unique_id),
         cruise = as.character(cruise),
         unique_id = as.character(unique_id)) %>%
  mutate(unique_id = paste("dana12",
                           as.numeric(interaction(unique_id, drop = TRUE)),
                           sep = "_")) %>%
  mutate(ecotype = "ocean")

saveRDS(dana12, "dataset/clean/complete_profiles/dana12.rds")

write_csv(anti_join(dana12_doc, dana12_cdom, by = "unique_id"),
          "tmp/not_matched_dana12_doc.csv")

ggplot(dana12, aes(x = wavelength, y = absorption, group = unique_id)) +
  geom_line(size = 0.1) +
  ggtitle("Dana12 CDOM")

ggsave("graphs/datasets/dana12.pdf")

# Greenland lakes ---------------------------------------------------------

# rm(list = ls())
#
# greenland_doc <- read_excel("dataset/raw/complete_profiles/stedmon/Greenland Lakes/GreelandLakesDOC.xls") %>%
#   select(-LONGITUDE, longitude = LONG, latitude = LAT) %>%
#   mutate(date = as.Date(paste(.$YEAR, .$month, "1"),
#                         format = "%Y %m %d")) %>%
#   select(-YEAR, -month) %>%
#   filter(format(date, "%Y") == 2003)
#
# names(greenland_doc) <- tolower(names(greenland_doc))
# greenland_doc$station <- tolower(greenland_doc$station)
#
# greenland_cdom <- read_sas("dataset/raw/complete_profiles/stedmon/Greenland Lakes/abs.sas7bdat") %>%
#   select(station, wavelength = wave, absorption = acoef)
#
# ggplot(greenland_cdom, aes(x = wavelength, y = absorption, group = station)) +
#   geom_line()
#
# greenland <- inner_join(greenland_doc, greenland_cdom) %>%
#   filter(!is.na(absorption) & !is.na(doc)) %>%
#   mutate(study_id = "greenland") %>%
#   mutate(unique_id = "")
#
# filter(greenland, wavelength == 254) %>%
#   ggplot(aes(x = absorption, y = doc)) +
#   geom_point() +
#   geom_smooth(method = "lm")

# Horsens -----------------------------------------------------------------

rm(list = ls())

horsens_doc <- read_sas("dataset/raw/complete_profiles/stedmon/Horsens/hf_doc.sas7bdat") %>%
  rename(doc = DOC_M) %>% 
  mutate(unique_id = paste("horsens", 1:nrow(.), sep = "_"))

horsens_cdom <- read_sas("dataset/raw/complete_profiles/stedmon/Horsens/hf_abs.sas7bdat") %>%
  select(wavelength = wave,
         station,
         date,
         depth,
         type,
         absorption = acdom) %>%
  filter(type == 0.2)

# Replace NA depth with 0
horsens_doc$depth[is.na(horsens_doc$depth)] <- 0
horsens_cdom$depth[is.na(horsens_cdom$depth)] <- 0

horsens <- inner_join(horsens_doc, horsens_cdom,
                     by = c("station", "depth", "date")) %>%
  mutate(study_id = "horsens") %>%
  distinct()

horsens$ecotype <- NA
horsens$ecotype[horsens$station <= 4] <- "coastal"
horsens$ecotype[horsens$station >= 5] <- "river"
horsens$ecotype[horsens$station == 16] <- "sewage"
horsens$ecotype[horsens$station %in% c(7, 9)] <- "lake"

saveRDS(horsens, "dataset/clean/complete_profiles/horsens.rds")

write_csv(anti_join(horsens_doc, horsens_cdom,
                    by = c("station", "depth", "date")),
          "tmp/not_matched_horsens_doc.csv")

ggplot(horsens, aes(x = wavelength, y = absorption, group = unique_id)) +
  geom_line(size = 0.1) +
  facet_wrap(~depth, scales = "free_y") +
  ggtitle("Horsens CDOM at various depths")

ggsave("graphs/datasets/horsens.pdf")

# Kattegat ----------------------------------------------------------------

rm(list = ls())

#http://bios.au.dk/videnudveksling/til-myndigheder-og-saerligt-interesserede/havmiljoe/togtrapporter/

# ********************************************************************
# DOC
# ********************************************************************

file_doc <- list.files("dataset/raw/complete_profiles/stedmon/Kattegat/", "*doc*",
                       full.names = TRUE)

kattegat_doc <- lapply(file_doc, read_sas) %>%
  lapply(., function(x){names(x) = tolower(names(x)); return(x)}) %>%
  bind_rows() %>%
  select(unique_id = sample_number, doc = doc, cruise = cruise) %>%
  na.omit()

kattegat_doc <- kattegat_doc[-which(kattegat_doc$unique_id == 213 &
                      kattegat_doc$cruise == "GT237"), ]

# ********************************************************************
# CDOM
# ********************************************************************

file_cdom <- list.files("dataset/raw/complete_profiles/stedmon/Kattegat/", "*abs*",
                       full.names = TRUE)

kattegat_cdom <- lapply(file_cdom, read_sas) %>%
  lapply(., function(x){names(x) = tolower(names(x)); return(x)}) %>%
  bind_rows() %>%
  select(unique_id = sample_number, wavelength = wave, absorption = acoef,
         cruise = cruise) %>%
  distinct(unique_id, wavelength, cruise)

# ********************************************************************
# Station information (salinity, depth, location, etc.)
# ********************************************************************

file_station <- list.files("dataset/raw/complete_profiles/stedmon/Kattegat/", "*combi*",
                        full.names = TRUE)

cruise <- extract_numeric(tools::file_path_sans_ext(file_station))

kattegat_stations <- lapply(file_station, read_sas) %>%
  lapply(., function(x){names(x) = tolower(names(x)); return(x)}) %>%
  Map(function(x, y){x$cruise = paste("GT", y, sep = ""); return(x)}, ., cruise) %>%
  bind_rows() %>%
  select(latitude,
         longitude,
         date,
         unique_id = sample_number,
         depth,
         temperature = temp,
         salinity,
         cruise) %>%
  mutate(date = as.Date(date, origin = "1960-01-01")) %>%
  mutate(longitude = floor(longitude / 100) + longitude %% 100 / 60) %>%
  mutate(latitude = floor(latitude / 100) + latitude %% 100 / 60)

# ********************************************************************
# Merging
# ********************************************************************

kattegat <- inner_join(kattegat_doc, kattegat_cdom, by = c("unique_id", "cruise")) %>%
  inner_join(., kattegat_stations, by = c("unique_id", "cruise")) %>%
  mutate(study_id = "kattegat",
         unique_id = as.character(unique_id),
         unique_id = paste(unique_id, cruise, sep = "_")) %>%
  mutate(unique_id = paste("kattegat",
                           as.numeric(interaction(unique_id, drop = TRUE)),
                           sep = "_")) %>%
  distinct() %>%
  mutate(ecotype = ifelse(salinity <= 25, "coastal", "ocean"))

saveRDS(kattegat, "dataset/clean/complete_profiles/kattegat.rds")

write_csv(anti_join(kattegat_doc, kattegat_cdom, by = c("unique_id", "cruise")),
          "tmp/not_matched_kattegat_doc.csv")

ggplot(kattegat, aes(x = wavelength, y = absorption, group = unique_id)) +
  geom_line(size = 0.1) +
  facet_wrap(~cruise, ncol = 2) +
  ggtitle("Kattegat CDOM")

ggsave("graphs/datasets/kattegat.pdf", width = 10, height = 7)


# Umeaa -------------------------------------------------------------------

rm(list = ls())

umeaa_doc <- read_sas("dataset/raw/complete_profiles/stedmon/Umeaa/parafac.sas7bdat") %>%
  select(unique_id = Station,
         place = Place,
         depth = Depth,
         doc = DOC) %>%
  na.omit() %>%
  filter(place == "water") %>%
  select(-place)

umeaa_cdom <- read_sas("dataset/raw/complete_profiles/stedmon/Umeaa/abs.sas7bdat") %>%
  select(place = sted,
         wavelength = wave,
         unique_id = station,
         depth = dybde,
         absorption = acdom) %>%
  mutate(depth = as.numeric(depth), unique_id = as.numeric(unique_id)) %>%
  filter(place == "water") %>%
  select(-place)

umeaa <- inner_join(umeaa_doc, umeaa_cdom, by = c("unique_id", "depth")) %>%
  mutate(study_id = "umeaa",
         unique_id = as.character(unique_id),
         unique_id = paste(unique_id, depth, sep = "_")) %>%
  mutate(unique_id = paste("umeaa",
                           as.numeric(interaction(unique_id, drop = TRUE)),
                           sep = "_")) %>% 
  mutate(ecotype = "coastal")

saveRDS(umeaa, "dataset/clean/complete_profiles/umeaa.rds")

write_csv(anti_join(umeaa_doc, umeaa_cdom, by = c("unique_id", "depth")),
          "tmp/not_matched_umeaa_doc.csv")

ggplot(umeaa, aes(x = wavelength, y = absorption, group = unique_id)) +
  geom_line(size = 0.1) +
  facet_grid(~depth) +
  ggtitle("Umeaa CDOM at 2 depths")

ggsave("graphs/datasets/umeaa.pdf")


# Nelson ------------------------------------------------------------------

rm(list = ls())

nelson <- readMat("dataset/raw/complete_profiles/stedmon/Neslon/CDOM-DOC-R.mat")

nelson_cdom <- data.frame(t(nelson$Abs)) %>% as_data_frame()

wavelength <- as.vector(nelson$Wave)

nelson_doc <- matrix(unlist(nelson$Data), ncol = 7, byrow = TRUE) %>%
  as.data.frame() %>%
  as_data_frame()

nelson_doc[nelson_doc == "NaN" ] = NA

names(nelson_doc) <- dimnames(nelson$Data)[[1]]

nelson_doc <- select(nelson_doc,
                     latitude = Lat,
                     longitude = Lon,
                     depth = Dep,
                     unique_id = index,
                     doc = DOC,
                     temperature = Tmp,
                     salinity = Sal) %>%

  mutate(unique_id = paste("nelson",
                           as.numeric(interaction(unique_id, drop = TRUE)),
                           sep = "_"),
         study_id = "nelson")

names(nelson_cdom) <- nelson_doc$unique_id
nelson_cdom$wavelength <- wavelength

nelson_cdom <- gather(nelson_cdom, unique_id, absorption, -wavelength)

# Remove NA in DOC
nelson_doc <- nelson_doc[!is.na(nelson_doc$doc), ]

nelson <- inner_join(nelson_doc, nelson_cdom) %>%
  mutate(ecotype = "ocean")

saveRDS(nelson, "dataset/clean/complete_profiles/nelson.rds")

ggplot(nelson, aes(x = wavelength, y = absorption, group = unique_id)) +
  geom_line(size = 0.1, alpha = 0.25)

ggsave("graphs/datasets/neslon.pdf")
