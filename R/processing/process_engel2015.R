# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>  
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Process raw data from:
# 
# Engel, Anja; Borchard, Corinna; Loginova, Alexandra; Meyer, Judith; Hauss, 
# Helena; Kiko, Rainer (2015): Mesocosm experiment Cape Verde 2012: 
# chromophoric and fluorescent dissolved organic matter, polysaccharidic and 
# proteinaceous gel particles production. doi:10.1594/PANGAEA.847693
# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

engel2015 <- read_delim("dataset/raw/literature/engel2015/Engel-etal_2015.tab", 
                        delim = "\t", skip = 40)

engel2015 <- engel2015[ , !duplicated(colnames(engel2015))] %>%  
  select(run_id = `Run ID`,
         label = Label,
         date = `Date/Time`,
         treatment = Treatm,
         doc = `DOC [µmol/l]`,
         a325 = `ac325 [1/m]`,
         a355 = `ac355 [1/m]`,
         a375 = `ac375 [1/m]`) %>% 
  gather(wavelength, absorption, a325:a375) %>% 
  mutate(wavelength = extract_numeric(wavelength)) %>%
  mutate(unique_id = paste("engel2015", 1:nrow(.), sep = "_")) %>%
  mutate(study_id = "engel2015") %>% 
  mutate(longitude = -25.156600) %>% 
  mutate(latitude = 16.740000) %>% 
  mutate(ecosystem = "ocean")

write_feather(engel2015, "dataset/clean/literature/engel2015.feather")

# engel2015 %>% 
#   ggplot(aes(x = doc, y = absorption)) +
#   geom_point(aes(color = treatment)) +
#   facet_wrap(~wavelength, scales = "free")
