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
           acdom355 = ag355,
           acdom380 = ag380,
           acdom412 = ag412,
           acdom443 = ag443) %>%
    mutate(date = as.Date(as.character(date), format = "%Y%m%d")) %>%
    mutate(station = as.character(station)) %>% 
    gather(wavelength, acdom, contains("acdom")) %>%
    mutate(wavelength = extract_numeric(wavelength)) %>%
    mutate(study_id = tolower(tools::file_path_sans_ext(basename(file))))

  df[df == -999] <- NA

  df <- filter(df, !is.na(doc) & !is.na(acdom)) %>% 
    mutate(sample_id = paste(study_id, 1:nrow(.), sep = "_"))

  return(df)
}

seabass <- lapply(f, process_seabass) %>%
  bind_rows() %>% 
  filter(doc > 10) %>% 
  filter(acdom > 0)

saveRDS(seabass, file = "dataset/clean/literature/seabass.rds")
