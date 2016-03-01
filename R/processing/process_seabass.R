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
           sample_id = station,
           latitude = lat,
           longitude = lon,
           depth = depth,
           doc = DOC,
           acdom355 = ag355,
           acdom380 = ag380,
           acdom412 = ag412,
           acdom443 = ag443) %>%
    mutate(date = as.Date(as.character(date), format = "%Y%m%d")) %>%
    gather(wavelength, acdom, contains("acdom")) %>%
    mutate(wavelength = extract_numeric(wavelength)) %>%
    mutate(study_id = basename(file)) %>%
    mutate(sample_id = as.character(sample_id))

  df[df == -999] <- NA

  df <- filter(df, !is.na(doc) & !is.na(acdom))

  return(df)
}

seabass <- lapply(f, process_seabass) %>%
  bind_rows()

saveRDS(seabass, file = "dataset/clean/literature/seabass.rds")
