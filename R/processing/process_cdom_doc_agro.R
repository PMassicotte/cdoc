#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         process_cdom_doc_agro.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Process raw data downloaded from:
#
#               http://www.arcticgreatrivers.org/data.html
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

# ********************************************************************
# Agro 2 data
# ********************************************************************

doc_agro2 <- read_excel("dataset/raw/complete_profiles/arctic-GRO/Arctic-GRO Dataset.xls",
                  sheet = "A-GRO II Data 1", skip = 9)

doc_agro2 <- doc_agro2[, c(1:3, 10)]

names(doc_agro2) <- c("river", "date", "temperature", "doc")

doc_agro2 <- mutate(doc_agro2,
              date = as.Date(date),
              doc = doc / 12 * 1000)

cdom_agro2 <- read_excel("dataset/raw/complete_profiles/arctic-GRO/Arctic-GRO Dataset.xls",
                        sheet = "AGRO II Data 2", skip = 7)

cdom_agro2 <- cdom_agro2[ , colSums(is.na(cdom_agro2)) == 0]

dates <- as.numeric(t(cdom_agro2[1, 2:ncol(cdom_agro2)])) %>%
  as.Date(origin = "1899-12-30")

col_names <- c("wavelength", paste(names(cdom_agro2[2:ncol(cdom_agro2)]),
                                   dates, sep = "_"))

cdom_agro2 <- cdom_agro2[-1, ]

names(cdom_agro2) <- col_names

cdom_agro2 <- mutate(cdom_agro2, wavelength = extract_numeric(wavelength)) %>%
  gather(unique_id, absorption, -wavelength) %>%
  separate(unique_id, into = c("river", "date"), sep = "_") %>%
  mutate(date = as.Date(date)) %>%
  mutate(absorption = 2.303 * absorption / 0.01)

agro2 <- inner_join(doc_agro2, cdom_agro2)

# Data in the excel file
coords <- data.frame(river = c("Kolyma", "Lena", "Mackenzie", "Ob'", "Yenisey", "Yukon"),
                     longitude = c(161.30, 123.37, -133.75, 66.6, 86.15, -162.87),
                     latitude = c(68.75, 66.77, 67.43, 66.52, 69.38, 61.93),
                     stringsAsFactors = FALSE)

agro2 <- inner_join(agro2, coords)

# ********************************************************************
# Agro 1 data
# ********************************************************************

doc_agro1 <- read_excel("dataset/raw/complete_profiles/arctic-GRO/Arctic-GRO Dataset.xls",
                        sheet = "A-GRO I Comprehensive Data 1", skip = 8)

doc_agro1 <- doc_agro1[, c(1:3, 8)]

names(doc_agro1) <- c("river", "date", "temperature", "doc")

doc_agro1 <- mutate(doc_agro1,
                    date = as.Date(date),
                    doc = doc / 12 * 1000)

cdom_agro1 <- read_excel("dataset/raw/complete_profiles/arctic-GRO/Arctic-GRO Dataset.xls",
                         sheet = "A-GRO I Comprehensive Data 2", skip = 6)

cdom_agro1 <- cdom_agro1[ , colSums(is.na(cdom_agro1)) == 0]

dates <- as.numeric(t(cdom_agro1[1, 2:ncol(cdom_agro1)])) %>%
  as.Date(origin = "1899-12-30")

col_names <- c("wavelength", paste(names(cdom_agro1[2:ncol(cdom_agro1)]),
                                   dates, sep = "_"))

cdom_agro1 <- cdom_agro1[-1, ]

names(cdom_agro1) <- col_names

cdom_agro1 <- mutate(cdom_agro1, wavelength = extract_numeric(wavelength)) %>%
  gather(unique_id, absorption, -wavelength) %>%
  separate(unique_id, into = c("river", "date"), sep = "_") %>%
  mutate(date = as.Date(date)) %>%
  mutate(absorption = 2.303 * absorption / 0.01)

agro1 <- inner_join(doc_agro1, cdom_agro1)

# Data in the excel file
coords <- data.frame(river = c("Kolyma", "Lena", "Mackenzie", "Ob'", "Yenisey", "Yukon"),
                     longitude = c(161.30, 123.37, -133.70, 66.6, 86.15, -162.87),
                     latitude = c(68.75, 66.77, 68.33, 66.52, 69.38, 61.93),
                     stringsAsFactors = FALSE)

agro1 <- inner_join(agro1, coords)

# ********************************************************************
# Bind both Agro datasets.
# ********************************************************************

agro <- bind_rows(agro1, agro2) %>%
  mutate(unique_id = paste("agro", as.numeric(
    interaction(river, date, drop = TRUE)), sep = "_")) %>%
  mutate(study_id = "agro") %>%
  mutate(unique_id = unique_id)

saveRDS(agro, file = "dataset/clean/complete_profiles/agro.rds")

# ********************************************************************
# Also process discrete data found in the last sheet.
# ********************************************************************

rm(list = ls())

agro_partners <- read_excel("dataset/raw/complete_profiles/arctic-GRO/Arctic-GRO Dataset.xls",
                         sheet = "PARTNERS Data", skip = 6)

agro_partners <- agro_partners[, c(1:2, 4, 7, 28)]
names(agro_partners) <- c("description", "date", "temperature", "absorption", "doc")

agro_partners$wavelength <- 375
agro_partners$date <- as.Date(agro_partners$date)
agro_partners$study_id <- "agro_partners"

agro_partners <- separate(agro_partners, description, into = c("river", "year"),
                          sep = " ", remove = FALSE) %>%
  select(-year) %>%
  filter(!is.na(doc) & !is.na(absorption)) %>%
  mutate(unique_id = paste("agro_partners", 1:nrow(.), sep = "_"))

# Data in the excel file
coords <- data.frame(river = c("Kolyma", "Lena", "Mackenzie", "Ob'", "Yenisey", "Yukon"),
                     longitude = c(161.30, 123.37, -133.70, 66.6, 86.15, -162.87),
                     latitude = c(68.75, 66.77, 68.33, 66.52, 69.38, 61.93),
                     stringsAsFactors = FALSE)

agro_partners <- left_join(agro_partners, coords)

saveRDS(agro_partners, file = "dataset/clean/literature/agro_partners.rds")
