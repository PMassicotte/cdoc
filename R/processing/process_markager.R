#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         process_stiig.R
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

stiig <- select(stiig, -DOC_w) %>%
  filter(!is.na(DOC_mol)) %>%
  filter(DOC_mol >= 20 & DOC_mol <= 4000)

names(stiig) <- tolower(names(stiig))

saveRDS(stiig, file = "dataset/clean/literature/markager.rds")
