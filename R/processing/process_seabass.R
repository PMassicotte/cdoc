#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         process_seabass.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Process raw data from:
#
# http://seabass.gsfc.nasa.gov/seabasscgi/search.cgi
#
# Search information:
#   Data type = Pigment
#   Keyword = doc
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

process_seabass <- function(file){

  print(file)

  data <- read_lines(file)
  headers <- str_match(data, "/fields=(.+)")[, 2] %>% na.omit() %>%
    str_split(., ",") %>%
    unlist()

  # At which line the data starts
  index <- which(str_detect(data, "/end_header"))
  
  df <- data.table::fread(file,
                   sep = "\t",
                   na.strings =  "-999",
                   skip = index,
                   col.names = headers) %>%
    as_data_frame() %>% 
    select(date,
           station,
           latitude = lat,
           longitude = lon,
           depth = depth,
           doc = DOC,
           absorption355 = ag355,
           absorption380 = ag380,
           absorption412 = ag412,
           absorption443 = ag443) %>%
    mutate(date = as.Date(as.character(date), format = "%Y%m%d")) %>%
    mutate(station = as.character(station)) %>%
    gather(wavelength, absorption, contains("absorption")) %>%
    mutate(wavelength = extract_numeric(wavelength)) %>%
    mutate(study_id = tolower(tools::file_path_sans_ext(basename(file))))
    
  df[df == -999] <- NA

  df <- filter(df, !is.na(doc) & !is.na(absorption)) %>%
    mutate(unique_id = paste(study_id, 1:nrow(.), sep = "_"))

  return(df)
}

f <- list.files("dataset/raw/literature/seabass/", ".txt", full.names = TRUE)

seabass <- lapply(f, process_seabass) %>%
  bind_rows() %>%
  filter(doc > 10) %>%
  filter(absorption > 0) %>% 
  mutate(ecosystem = "estuary")

write_feather(seabass, "dataset/clean/literature/seabass.feather")


# Salinity is found in only one file. Based on the histogram, most values are
# between 5 and 12. Hence, I decided to classify these data as "estuary".

# salinity <- data.table::fread("dataset/raw/literature/seabass/GEOCAPE_OM_pigments.txt",
#                               skip = 45, na = "-999", sep = "\t") %>% 
#   as_data_frame()
# 
# hist(salinity$V8)
