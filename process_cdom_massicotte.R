rm(list = ls())

wl <- seq(250, 450, by = 1)

# Data JF -----------------------------------------------------------------

base_dir <- "/media/persican/Philippe Massicotte/Phil/Doctorat/PARAFAC/PARAFAC Files/Raw Data/JF/"
files <- list.files(base_dir, "*.txt", full.names = TRUE, recursive = TRUE)


jf <- lapply(files, read_delim, delim = "\t", skip = 1) %>% 
  bind_cols() 

jf <- jf[, c(1, seq(2, ncol(jf), by = 2))]

names(jf) <- c("wavelength", 
                    paste("jf", 1:(ncol(jf) - 1)))

jf <- filter(jf, wavelength >= 250 & wavelength <= 450) %>% 
  gather(sample, absorbance, -wavelength) %>%
  mutate(dataset = "jf")


# Data Newzeland ----------------------------------------------------------

base_dir <- "/media/persican/Philippe Massicotte/Phil/Doctorat/PARAFAC/PARAFAC Files/Raw Data/NZ/aCDOM/"
files <- list.files(base_dir, "*.txt", full.names = TRUE, recursive = TRUE)


nz <- lapply(files, read_delim, delim = "\t", skip = 0) %>% 
  bind_cols() 

nz <- nz[, c(1, seq(2, ncol(nz), by = 2))]

names(nz) <- c("wavelength", 
               paste("nz", 1:(ncol(nz) - 1)))




nz <- filter(nz, wavelength >= 250 & wavelength <= 450) %>% 
  gather(sample, absorbance, -wavelength) %>%
  mutate(dataset = "nz")

## Some weird sample at hight absorbance
nz <- nz[!nz$sample %in% unique(nz$sample[which(nz$absorbance > 3)]), ] 


# Lampsilis C1-2006 -------------------------------------------------------

base_dir <- "/media/persican/Philippe Massicotte/Phil/Doctorat/PARAFAC/PARAFAC Files/Raw Data/Lampsilis/C1-2006/aCDOM/"
files <- list.files(base_dir, "*.txt", full.names = TRUE, recursive = TRUE)


c1_2006 <- lapply(files, read_delim, delim = "\t", skip = 0) %>% 
  lapply(., na.omit) %>% 
  bind_cols() 

c1_2006 <- c1_2006[, c(1, seq(2, ncol(c1_2006), by = 2))]

names(c1_2006) <- c("wavelength", 
               paste("c1", 1:(ncol(c1_2006) - 1)))

c1_2006 <- filter(c1_2006, wavelength >= 250 & wavelength <= 450) %>% 
  filter(wavelength %in% wl) %>% 
  gather(sample, absorbance, -wavelength) %>%
  mutate(dataset = "c1")
  

# Lampsilis C2-2006 -------------------------------------------------------

base_dir <- "/media/persican/Philippe Massicotte/Phil/Doctorat/PARAFAC/PARAFAC Files/Raw Data/Lampsilis/C2-2006/aCDOM/"
files <- list.files(base_dir, "*.txt", full.names = TRUE, recursive = TRUE)


c2_2006 <- lapply(files, read_delim, delim = "\t", skip = 0) %>% 
  lapply(., na.omit) %>% 
  bind_cols() 

c2_2006 <- c2_2006[, c(1, seq(2, ncol(c2_2006), by = 2))]

names(c2_2006) <- c("wavelength", 
                    paste("c2", 1:(ncol(c2_2006) - 1)))

c2_2006 <- filter(c2_2006, wavelength >= 250 & wavelength <= 450) %>% 
  filter(wavelength %in% wl) %>% 
  gather(sample, absorbance, -wavelength) %>%
  mutate(dataset = "c2")

# Lampsilis C3-2006 -------------------------------------------------------

base_dir <- "/media/persican/Philippe Massicotte/Phil/Doctorat/PARAFAC/PARAFAC Files/Raw Data/Lampsilis/C3-2006/aCDOM/"
files <- list.files(base_dir, "*.txt", full.names = TRUE, recursive = TRUE)


c3_2006 <- lapply(files, read_delim, delim = "\t", skip = 0) %>% 
  lapply(., na.omit) %>% 
  bind_cols() 

c3_2006 <- c3_2006[, c(1, seq(2, ncol(c3_2006), by = 2))]

names(c3_2006) <- c("wavelength", 
                    paste("c3", 1:(ncol(c3_2006) - 1)))

c3_2006 <- filter(c3_2006, wavelength >= 250 & wavelength <= 450) %>% 
  filter(wavelength %in% wl) %>% 
  gather(sample, absorbance, -wavelength) %>%
  mutate(dataset = "c3")



# Merge everything --------------------------------------------------------
spectra_massicotte <- bind_rows(jf, nz, c1_2006, c2_2006, c3_2006) %>% 
  rename(sample_id = sample) %>% 
  mutate(absorption = (absorbance * 2.303) / 0.01)

## Save
saveRDS(spectra_massicotte, "dataset/clean/spectra_massicotte.rds")
