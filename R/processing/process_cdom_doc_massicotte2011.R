#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         process_cdom_doc_massicotte2011.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Process raw data from Massicotte et al. 2011.
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

#---------------------------------------------------------------------
# CDOM
#---------------------------------------------------------------------

base_dir <- "/media/persican/Philippe Massicotte/Phil/Doctorat/PARAFAC/PARAFAC Files/Raw Data/Lampsilis/C2-2006/aCDOM/"

files <- list.files(base_dir, "*.txt", full.names = TRUE, recursive = TRUE)

c2_2006 <- lapply(files, read_delim, delim = "\t", skip = 0) %>% 
  lapply(., na.omit) %>% 
  bind_cols() 

c2_2006 <- c2_2006[, c(1, seq(2, ncol(c2_2006), by = 2))]

sample_id <- str_sub(basename(files), 1, -5)

names(c2_2006)[2:105] <- sample_id
names(c2_2006)[1] <- "wavelength"


c2_2006 <- gather(c2_2006, sample_id, absorbance, -wavelength) %>% 
  mutate(absorption = (absorbance * 2.303) / 0.01) %>% 
  filter(grepl("[a-z]", sample_id)) %>% 
  mutate(depth_position = str_sub(sample_id, -1, -1)) %>% 
  mutate(sample_id = str_sub(sample_id, 1, -2)) %>% 
  select(-absorbance)

#---------------------------------------------------------------------
# DOC
#---------------------------------------------------------------------

station <- read_csv("dataset/raw/massicotte2011/data/station.csv") %>% 
  select(Date, StationID, Longitude_Decimal, Latitude_Decimal)

ysi <- read_csv("dataset/raw/massicotte2011/data/ysi.csv") %>% 
  select(StationID, Temp_S, Temp_D, Sal_S, Sal_D)

doc <- read_csv("dataset/raw/massicotte2011/data/doc.csv") %>% 
  select(StationID, DOC_S, DOC_D)

data <- left_join(station, ysi) %>% 
  
  left_join(doc) %>% 
  
  arrange(StationID) %>%  
  
  select(sample_id = StationID,
         date = Date,
         doc_s = DOC_S,
         doc_d = DOC_D) %>% 
  
  filter(grepl("C2-2006", sample_id)) %>% 
  
  gather(depth_position, doc, -date, -sample_id) %>% 
  
  separate(depth_position, into = c("junk", "depth_position")) %>% 
  
  select(-junk)

data$date <- as.Date(data$date, format = "%m/%d/%Y")
data$depth_position[data$depth_position == "d"] <- "f"
data$sample_id <- str_sub(data$sample_id, 10, -1)

# Remove 2 outliers (they have s_350_400 ~ 1, see graphics)
data <- data[!(data$sample_id %in% c("13", "44") & data$depth_position == "s"), ]

data <- data[!data$sample_id == "02", ]

doc <- mutate(data,
               doc = doc / 12 * 1000) %>%
  filter(doc <= 1000)

massicotte2011 <- inner_join(doc, c2_2006) %>% 
  mutate(study_id = "massicotte2011") %>% 
  mutate(unique_id = paste("massicotte2011",
                           as.numeric(interaction(sample_id, depth_position, drop = TRUE)),
                           sep = "_"))

saveRDS(massicotte2011, "dataset/clean/massicotte2011/massicotte2011.rds")

ggplot(massicotte2011, aes(x = wavelength, y = absorption, 
                           group = sample_id)) +
  geom_line(size = 0.1) +
  facet_wrap(~depth_position)

ggsave("graphs/massicotte2011.pdf")
