#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         process_cdom_asmala2014.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Process raw cdom data from Asmala et al. 2014.
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

#---------------------------------------------------------------------
# Read all files.
#---------------------------------------------------------------------

files <- list.files("dataset/raw/complete_profiles/asmala2014/data/",
                    pattern = "*.asc", 
                    full.names = TRUE, 
                    recursive = TRUE)

data <- lapply(files, 
               read_delim, 
               skip = 86,
               delim = "\t",
               col_names = c("wavelength", "absorbance")) %>% 
  bind_rows()

#---------------------------------------------------------------------
# Extract pathlength
#---------------------------------------------------------------------
pathlength <- str_match_all(files, "_(\\d{1})") %>% 
  sapply("[", i = 2) %>% 
  as.numeric()

pathlength <- pathlength / 100

#---------------------------------------------------------------------
# Extract sample type (sample vs miliq)
#---------------------------------------------------------------------
sample_type <- ifelse(grepl("MQ", files), "milliq", "sample")

#---------------------------------------------------------------------
# Extract date
#---------------------------------------------------------------------
date <- str_match_all(files, "(\\d{4}-\\d{2}-\\d{2})") %>% 
  sapply("[", i = 2) %>% 
  as.Date()

#---------------------------------------------------------------------
# Build sample_id based on date and filename
#---------------------------------------------------------------------
sample_id <- basename(files) %>% 
  str_sub(start = 1, end = -5) %>% 
  paste(date, "_", ., sep = "")

#---------------------------------------------------------------------
# Bind everything together
#---------------------------------------------------------------------
n <- 601 # Number wavelengths used for CDOM measurements

data <- mutate(data, 
               date = rep(date, each = n), 
               sample_id = rep(sample_id, each = n), 
               pathlength = rep(pathlength, each = n),
               sample_type = rep(sample_type, each = n),
               file_name = rep(basename(files), each = n))

#---------------------------------------------------------------------
# Blank correction
#---------------------------------------------------------------------
spc <- filter(data, sample_type == "sample")
mq <- filter(data, sample_type == "milliq") %>% 
  select(wavelength, mq = absorbance, date, mqfile = file_name)

res <- inner_join(spc, mq) %>% 
  mutate(absorbance = absorbance - mq)

#---------------------------------------------------------------------
# Absorbance to absorption
#---------------------------------------------------------------------
spectra_asmala2014 <- mutate(res, absorption = (absorbance * 2.303) / pathlength) %>% 
  select(-absorbance, -pathlength, -sample_type, -date) %>% 
  mutate(dataset = "eero2014") %>% 
  select(sample_id, wavelength, file_name, absorption)

#---------------------------------------------------------------------
# Format sample_id so it matches sample_id in the DOC Excel sheet
#---------------------------------------------------------------------

spectra_asmala2014$sample_id <- str_replace(spectra_asmala2014$sample_id,
                                            "TV", "KA")

spectra_asmala2014 <- filter(spectra_asmala2014, grepl("K", sample_id))

spectra_asmala2014$sample_id <- unlist(str_extract_all(spectra_asmala2014$sample_id, "(K\\S{6})"))


#---------------------------------------------------------------------
# Now the DOC data
#---------------------------------------------------------------------
doc_asmala2014 <- read_excel("dataset/raw/complete_profiles/asmala2014/data.xlsx") %>% 
  select(sample_id:doc) %>% 
  mutate(date = as.Date(date, origin = "1899-12-30"),
         doc = as.numeric(doc),
         salinity = as.numeric(salinity),
         temperature = as.numeric(temperature),
         secchi = as.numeric(secchi)) %>% 
  distinct()

#---------------------------------------------------------------------
# Merge CDOM and DOC
#---------------------------------------------------------------------
asmala2014 <- inner_join(doc_asmala2014, spectra_asmala2014, by = "sample_id")


asmala2014 <- mutate(asmala2014, study_id = "asmala2014") %>% 
  mutate(unique_id = paste("asmala2014",
                           as.numeric(interaction(sample_id, drop = TRUE)),
                           sep = "_"))

saveRDS(asmala2014, "dataset/clean/complete_profiles/asmala2014.rds")

write_csv(anti_join(doc_asmala2014, spectra_asmala2014, by = "sample_id"), 
          "tmp/not_matched_asmala2014_doc.csv")

#---------------------------------------------------------------------
# Plot the cleaned data
#---------------------------------------------------------------------

ggplot(asmala2014, aes(x = wavelength, y = absorption, group = unique_id)) +
  geom_line(size = 0.1) + 
  ggtitle("Asmala 2014")

ggsave("graphs/datasets/asmala2014.pdf")
