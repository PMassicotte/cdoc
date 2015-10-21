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

files <- list.files("dataset/raw/asmala2014/data/",
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
data <- mutate(data, 
               date = rep(date, each = 601), 
               sample_id = rep(sample_id, each = 601), 
               pathlength = rep(pathlength, each = 601),
               sample_type = rep(sample_type, each = 601))

#---------------------------------------------------------------------
# Plot data per date, this will help to select which miliq to use.
#---------------------------------------------------------------------

unique_date <- as.character(unique(interaction(data$date, data$pathlength))) %>% 
  str_split("\\.") 

for(i in unique_date){
  
  tmp <- filter(data, date == i[[1]] & pathlength == as.numeric(i[[2]]))
  
  p <- ggplot(tmp, aes(x = wavelength, 
                       y = absorbance, 
                       group = sample_id,
                       color = sample_id)) +
    
    geom_line(size = 0.25, aes(linetype = sample_type)) + 
    
    facet_wrap(~sample_type, scales = "free") +
    
    ggtitle(unique(tmp$date))
  
  ggsave(paste("graphs/eero/", i[[1]], i[[2]], ".pdf", sep = ""), p, height = 7, width = 15)
}

#---------------------------------------------------------------------
# Based on visual inspection we remove "strange" spectra.
#---------------------------------------------------------------------
id_remove <- c("2010-08-20_KI2-000_5",
               "2010-08-20_MQ22008_5",
               "2010-09-02_KY2-01A_5",
               "2010-09-02_KY2-000_5",
               "2010-09-02_MQ10209_1",
               "2010-09-02_MQ30209_5",
               "2010-09-03_MQ50309_1",
               "2010-09-03_MQ60309_1",
               "2010-09-03_MQ70309_1",
               "2010-09-03_MQ10309_5",
               "2010-09-03_MQ20309_5",
               "2010-09-03_MQ30309_5",
               "2010-10-08_MQ30810_1",
               "2010-10-08_MQ20810_1",
               "2010-10-15_MQ31510_1",
               "2010-10-15_MQ41510_1",
               "2010-10-29_MQ12910_1",
               "2010-10-29_MQ22910_1",
               "2010-11-12_MQ11211_1",
               "2011-04-28_MQ12804_1",
               "2011-04-28_MQ22804_1",
               "2011-04-28_MQ32804_1",
               "2011-05-10_MQ11005_1",
               "2011-05-10_MQ21005_1",
               "2011-05-10_MQ31005_1",
               "2011-05-20_MQ22005_1",
               "2011-05-20_MQ32005_1",
               "2011-05-20_MQ42005_1",
               "2011-05-20_MQ52005_1",
               "2011-05-20_MQ62005_1",
               "2011-08-25_MQ22508_1",
               "2011-08-25_MQ32508_1",
               "2011-08-25_MQ42508_1",
               "2011-08-25_MQ52508_1",
               "2011-10-07_MQ20710_1",
               "2011-10-14_MQ21410_1",
               "2011-10-21_MQ12110_1",
               "2010-09-02_KY2-01B_5",
               "2010-10-15_MQ21510_1",
               "2011-08-25_MQ62508_1")

`%ni%` = Negate(`%in%`) 
data <- filter(data, sample_id %ni% id_remove)

#---------------------------------------------------------------------
# Plot data again to see if everything is good.
#---------------------------------------------------------------------

unique_date <- as.character(unique(interaction(data$date, data$pathlength))) %>% 
  str_split("\\.") 

for(i in unique_date){
  
  tmp <- filter(data, date == i[[1]] & pathlength == as.numeric(i[[2]]))
  
  p <- ggplot(tmp, aes(x = wavelength, 
                       y = absorbance, 
                       group = sample_id,
                       color = sample_id)) +
    
    geom_line(size = 0.25, aes(linetype = sample_type)) + 
    
    facet_wrap(~sample_type, scales = "free") +
    
    ggtitle(unique(tmp$date))
  
  ggsave(paste("graphs/eero/", i[[1]], i[[2]], ".pdf", sep = ""), p, height = 7, width = 15)
}


#---------------------------------------------------------------------
# Blank correction
#---------------------------------------------------------------------
unique_date <- as.character(unique(interaction(data$date, data$pathlength))) %>% 
  str_split("\\.") 

res <- list()

for(i in unique_date){
  
  tmp <- filter(data, date == i[[1]] & pathlength == as.numeric(i[[2]]))
  
  ## Get the data
  samples <- filter(data, date == i[[1]] & pathlength == as.numeric(i[[2]]) & sample_type == "sample") %>% 
    spread(sample_id, absorbance)
  
  ## Get the mq sample
  mq <- filter(data, date == i[[1]] & pathlength == as.numeric(i[[2]]) & sample_type == "milliq")
  
  ## Blank subtraction
  samples[, 5:ncol(samples)] <- samples[, 5:ncol(samples)] - mq$absorbance
  
  samples <- gather(samples, sample_id, absorbance, matches("\\d{4}"), convert = TRUE)
  
  res <- bind_rows(res, samples)
  
}

#---------------------------------------------------------------------
# Absorbance to absorption
#---------------------------------------------------------------------
spectra_asmala2014 <- mutate(res, absorption = (absorbance * 2.303) / pathlength) %>% 
  select(-absorbance, -pathlength)

saveRDS(spectra_asmala2014, "dataset/clean/spectra_asmala2014.rds")
