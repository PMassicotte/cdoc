#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         process_markager.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Process data that Stiig et al. extracted from the literature.
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

stiig <- read_sas("dataset/raw/literature/stiig/lit2.sas7bdat") %>%
  select(ID:abs, S, wave_S_min, wave_S_max, DOC_w, DOC_mol) %>%
  mutate(DOC_w = DOC_w / 12 * 1000)

stiig$DOC_mol <- rowSums(stiig[, c("DOC_w", "DOC_mol")], na.rm = T)

stiig <- select(stiig,
                id = ID,
                unique_id = unique_id,
                country = Country,
                water = Water,
                water2 = Water2,
                water3 = Water3,
                mar,
                region = Region,
                salinity = Salinity,
                station = Station,
                depth,
                study_id = Ref,
                wavelength = Wave,
                absorption = abs,
                doc = DOC_mol) %>%
  filter(!is.na(doc) & !is.na(absorption) & doc > 20 & study_id != "")

ggplot(stiig, aes(x = doc, y = absorption)) +
  geom_point() +
  facet_wrap(study_id ~ wavelength, scales = "free")


#---------------------------------------------------------------------
# Based on the plot I remove outliers or studies with like 2 observations.
#---------------------------------------------------------------------

to_remvoe <- c("C110", "C327", "C357", "C50", "S1623", "S1625",
               "Stedmon unpublished", "C36")

`%ni%` <- Negate(`%in%`)

stiig <- filter(stiig, study_id %ni% to_remvoe)


# Final dataset
ggplot(stiig, aes(x = doc, y = absorption)) +
  geom_point() +
  facet_wrap(study_id ~ wavelength, scales = "free")

ggsave("graphs/datasets/stiig.pdf", width = 18, height = 12)


#saveRDS(stiig, file = "dataset/clean/literature/markager.rds")
