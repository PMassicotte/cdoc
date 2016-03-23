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

f <- list.files("dataset/raw/literature/seabass/", ".txt", full.names = TRUE)

process_seabass <- function(file){

  print(file)

  headers <- read_lines(file)
  headers <- str_match(headers, "/fields=(.+)")[, 2] %>% na.omit() %>%
    str_split(., ",") %>%
    unlist()

  df <- read_delim(file,
                   delim = "\t",
                   na = "-999",
                   skip = 44,
                   col_names = headers) %>%
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
    mutate(study_id = tolower(tools::file_path_sans_ext(basename(file)))) %>%
    mutate(ecotype = "coastal")

  df[df == -999] <- NA

  df <- filter(df, !is.na(doc) & !is.na(absorption)) %>%
    mutate(unique_id = paste(study_id, 1:nrow(.), sep = "_"))

  return(df)
}

seabass <- lapply(f, process_seabass) %>%
  bind_rows() %>%
  filter(doc > 10) %>%
  filter(absorption > 0)

saveRDS(seabass, file = "dataset/clean/literature/seabass.rds")
