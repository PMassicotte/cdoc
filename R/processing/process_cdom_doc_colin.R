#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         process_cdom_colin.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Read and format absorbance + DOC data from C. Stedmon.
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

# Arctic rivers -----------------------------------------------------------

# Stedmon, C.A., R.M.W. Amon, A.J. Rinehart, and S.A. Walker. 2011. 
# “The Supply and Characteristics of Colored Dissolved Organic Matter (CDOM) 
# in the Arctic Ocean: Pan Arctic Trends and Differences.” 
# Marine Chemistry 124 (1–4). Elsevier B.V.: 108–18. 
# doi:10.1016/j.marchem.2010.12.007.

rm(list = ls())

arctic_doc <- read_sas("dataset/raw/complete_profiles/stedmon/Arctic Rivers/partners_summary.sas7bdat") %>%
  select(river = River, date, doc = DOC_uM, t, year = Year) %>%
  mutate(doc = parse_number(doc)) %>%
  mutate(t = parse_number(t)) %>%
  mutate(year = parse_number(year)) 

arctic_cdom <- read_sas("dataset/raw/complete_profiles/stedmon/Arctic Rivers/partners_abs.sas7bdat") %>%
  mutate(year = parse_number(year) + 2000) %>%
  select(wavelength = wave,
         absorption = acoef,
         year = year,
         river = river,
         t = t)

arctic_cdom$t <- as.numeric(arctic_cdom$t)

# Using same coordinates as those found in the "agro_partners" dataset
arctic_location <- read_csv("dataset/raw/complete_profiles/stedmon/Arctic Rivers/locations.csv")

arctic <- inner_join(arctic_doc, arctic_cdom, by = c("river", "t", "year")) %>% 
  left_join(arctic_location)

write_csv(anti_join(arctic, arctic, c("river", "t", "year")),
          "tmp/not_matched_arctic_doc.csv")

arctic <- select(arctic, -year) %>%
  mutate(study_id = "arctic") %>%
  mutate(unique_id = paste(date, river, t, sep = "_")) %>%
  mutate(unique_id = paste("arctic",
                           as.numeric(interaction(unique_id, drop = TRUE)),
                           sep = "_")) %>% 
  mutate(ecosystem = "river")

write_feather(arctic, "dataset/clean/complete_profiles/arctic.feather")

# Dana12 rivers -----------------------------------------------------------

# Stedmon, Colin A., Mats A. Granskog, and Paul A Dodd. 2015. “An Approach 
# to Estimate the Freshwater Contribution from Glacial Melt and Precipitation 
# in East Greenland Shelf Waters Using Colored Dissolved Organic Matter (CDOM).” 
# Journal of Geophysical Research: Oceans 120 (2): 1107–17. 
# doi:10.1002/2014JC010501.

rm(list = ls())

source("R/salinity2ecosystem.R")

dana12_doc <- read_csv("dataset/raw/complete_profiles/stedmon/Dana12/Dana12.csv", na = "NaN") %>%
  select(Cruise:DOC, Salinity, Temperature) %>%
  rename(unique_id = SampleNo) %>%
  mutate(date = as.Date(paste(.$Year, .$Month, .$Day),
                 format = "%Y %m %d")) %>%
  select(-Year, -Month, -Day) %>% 
  filter(!is.na(Salinity))

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
  mutate(station = as.character(station)) %>% 
  mutate(ecosystem = salinity2ecosystem(salinity))

write_feather(dana12, "dataset/clean/complete_profiles/dana12.feather")

write_csv(anti_join(dana12_doc, dana12_cdom, by = "unique_id"),
          "tmp/not_matched_dana12_doc.csv")


# Greenland lakes ---------------------------------------------------------

# Anderson, N. John, and Colin A. Stedmon. 2007. “The Effect of 
# Evapoconcentration on Dissolved Organic Carbon Concentration and Quality 
# in Lakes of SW Greenland.” Journal Article. 
# Freshwater Biology 52 (2): 280–89. doi:10.1111/j.1365-2427.2006.01688.x.

rm(list = ls())

greenland_doc <- read_excel("dataset/raw/complete_profiles/stedmon/Greenland Lakes/GreelandLakesDOC.xls") %>%
  select(station = STATION,
         year = YEAR,
         id = ID,
         depth = DEPTH,
         ph = PH,
         longitude = LONG, 
         latitude = LAT,
         month,
         doc = DOC) %>%
  fill(latitude) %>% # For some (good) reasons some have no latitude...
  mutate(longitude = -longitude) %>% 
  mutate(date = as.Date(paste(.$year, .$month, "1"), format = "%Y %m %d")) %>%
  select(-year, -month) %>% 
  mutate(station = tolower(station)) %>% 
  mutate(id = tolower(id)) %>% 
  mutate(station = trimws(station)) %>% 
  mutate(id = trimws(id)) %>% 
  mutate(study_id = "greenland_lakes") %>% 
  mutate(unique_id = paste0(study_id, "_", 1:nrow(.))) %>% 
  mutate(doc = doc / 12 * 1000)

greenland_cdom_2002 <- read_sas("dataset/raw/complete_profiles/stedmon/Greenland Lakes/abs.sas7bdat") %>%
  select(station, wavelength = wave, absorption = acoef) %>% 
  mutate(date = as.Date("2002-06-01")) %>% 
  mutate(station = tolower(station)) %>% 
  mutate(station = trimws(station))

greenland_cdom_2003 <- read_sas("dataset/raw/complete_profiles/stedmon/Greenland Lakes/abs_03.sas7bdat") %>%
  select(station, wavelength = wave, absorption = acoef) %>% 
  mutate(date = as.Date("2003-06-01")) %>% 
  mutate(station = tolower(station)) %>% 
  mutate(station = trimws(station))

greenland_cdom <- bind_rows(greenland_cdom_2002, greenland_cdom_2003) %>% 
  filter(wavelength <= 358 | wavelength >= 362) %>% # Lamp change was problematic 
  filter(wavelength <= 410 | wavelength >= 420)

greenland <- inner_join(greenland_doc, greenland_cdom, by = c("station", "date")) %>% 
  mutate(ecosystem = "lake")

write_feather(greenland, "dataset/clean/complete_profiles/greenland_lakes.feather")

# anti_join(greenland_doc, greenland_cdom, by = c("station", "date"))

# greenland %>%
#   filter(wavelength == 254) %>%
#   ggplot(aes(x = doc, y = absorption)) +
#   geom_point(aes(color = format(date, "%Y")))
# 
# greenland %>%
#   ggplot(aes(x = wavelength, y = absorption, group = unique_id)) +
#   geom_line() +
#   xlim(358, 362)

# Horsens -----------------------------------------------------------------

rm(list = ls())

horsens_doc <- read_sas("dataset/raw/complete_profiles/stedmon/Horsens/hf_doc.sas7bdat") %>%
  rename(doc = DOC_M) %>%
  mutate(unique_id = paste("horsens", 1:nrow(.), sep = "_")) %>% 
  filter(DOC_FLAG == 0)

horsens_cdom <- read_sas("dataset/raw/complete_profiles/stedmon/Horsens/hf_abs.sas7bdat") %>%
  select(wavelength = wave,
         station,
         date,
         depth,
         type,
         absorption = acdom) %>%
  filter(type == 0.2) %>% 
  filter(wavelength <= 535 | wavelength >= 540) # Lamp switch was problemetic

# Replace NA depth with 0
horsens_doc$depth[is.na(horsens_doc$depth)] <- 0
horsens_cdom$depth[is.na(horsens_cdom$depth)] <- 0

# Station

horsens_station <- read_csv("dataset/raw/complete_profiles/stedmon/Horsens/stations.csv")

horsens <- inner_join(horsens_doc, horsens_cdom,
                     by = c("station", "depth", "date")) %>%
  mutate(study_id = "horsens") %>%
  distinct() %>% 
  left_join(horsens_station, by = "station") %>% 
  fill(longitude, latitude)

horsens$ecosystem <- "NA"
horsens$ecosystem[horsens$station <= 5] <- "coastal"
horsens$ecosystem[horsens$station >= 6] <- "river"
horsens$ecosystem[horsens$station == 16] <- "sewage"
horsens$ecosystem[horsens$station %in% c(7, 9)] <- "lake"

horsens <- mutate(horsens, station = as.character(station))

horsens <- horsens %>% 
  filter(ecosystem != "sewage")

write_feather(horsens, "dataset/clean/complete_profiles/horsens.feather")

write_csv(anti_join(horsens_doc, horsens_cdom,
                    by = c("station", "depth", "date")),
          "tmp/not_matched_horsens_doc.csv")


# Kattegat ----------------------------------------------------------------

rm(list = ls())

source("R/salinity2ecosystem.R")

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
  distinct(unique_id, wavelength, cruise, .keep_all = TRUE)

# ********************************************************************
# Station information (salinity, depth, location, etc.)
# ********************************************************************

file_station <- list.files("dataset/raw/complete_profiles/stedmon/Kattegat/", "*combi*",
                        full.names = TRUE)

cruise <- parse_number(tools::file_path_sans_ext(file_station))

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
  mutate(ecosystem = salinity2ecosystem(salinity))

write_feather(kattegat, "dataset/clean/complete_profiles/kattegat.feather")

write_csv(anti_join(kattegat_doc, kattegat_cdom, by = c("unique_id", "cruise")),
          "tmp/not_matched_kattegat_doc.csv")


# Umeaa -------------------------------------------------------------------

# Stedmon, Colin A, David N Thomas, Mats Granskog, Hermanni Kaartokallio, 
# Stathys Papadimitriou, and Harri Kuosa. 2007. “Characteristics of Dissolved 
# Organic Matter in Baltic Coastal Sea Ice: Allochthonous or Autochthonous 
# Origins?” Journal Article. 
# Environmental Science & Technology 41 (21): 7273–79. doi:10.1021/es071210f.

rm(list = ls())

umeaa_doc <- read_sas("dataset/raw/complete_profiles/stedmon/Umeaa/parafac.sas7bdat") %>%
  select(unique_id = Station,
         place = Place,
         depth = Depth,
         doc = DOC) %>%
  na.omit() %>%
  mutate(date = as.Date("2004-03-18")) %>% # information ofund in the paper
  filter(place == "water") %>%
  select(-place) %>% 
  mutate(latitude = 63.526350) %>% 
  mutate(longitude = 19.860153) # coords derivated from the paper

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
  mutate(ecosystem = "coastal")

write_feather(umeaa, "dataset/clean/complete_profiles/umeaa.feather")

write_csv(anti_join(umeaa_doc, umeaa_cdom, by = c("unique_id", "depth")),
          "tmp/not_matched_umeaa_doc.csv")


# Nelson ------------------------------------------------------------------

rm(list = ls())

source("R/salinity2ecosystem.R")

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
  fill(salinity) %>% 

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
  mutate(ecosystem = salinity2ecosystem(salinity))

write_feather(nelson, "dataset/clean/complete_profiles/nelson.feather")
