#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Process raw data given by P. Kowalczuk. 
#               There is no reference, but a grant number should be assigned.
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

kowalczuk2012 <- read_excel("dataset/raw/literature/kowalczuk2012/Polarstern_ANT_XXVIII_5_aCDOM_DOC_eng.xlsx") %>% 
  select(
    station = Station,
    date = Date,
    latitude = `Latitude [°S negative]  [°N positive]`,
    longitude = `Longitude [°W, negative]  [°E, positive]`,
    depth = `Sample depth [m]`,
    temperature = `Temperature [°C]`,
    salinity = Salinity,
    `a_cdom(275)`:`a_cdom(670)  `,
    doc = `DOC [mg/l]`
  ) %>% 
  mutate(date = as.Date(date, origin = "1899-12-30")) %>% 
  mutate(doc = doc / 12 * 1000) %>% 
  gather(wavelength, absorption, `a_cdom(275)`:`a_cdom(670)  `) %>% 
  mutate(wavelength = parse_number(wavelength)) %>% 
  drop_na(doc, absorption) %>% 
  filter(doc >= 40) %>% # As recommanded by Piotr 
  filter(wavelength == 350) %>% 
  mutate(ecosystem = "ocean") %>% 
  mutate(study_id = "kowalczuk2012") %>% 
  mutate(unique_id = paste(study_id, 1:nrow(.), sep = "_"))

write_feather(kowalczuk2012, "dataset/clean/literature/kowalczuk2012.feather")

# kowalczuk2012 %>% 
#   filter(wavelength == 350) %>% 
#   ggplot(aes(x = doc, y = absorption)) +
#   geom_point()

# map <- rworldmap::getMap()
# 
# pdf("/home/persican/Desktop/map.pdf")
# plot(map, lwd = 0.1)
# points(kowalczuk2012$longitude, kowalczuk2012$latitude, col = "red", pch = "*")
# dev.off()
# 
# 
# kowalczuk2012 %>% 
#   ggplot(aes(x = wavelength, y = absorption, group = station)) +
#   geom_line(size = 0.5) +
#   facet_wrap(~depth, scales = "free", ncol = 4) +
#   labs(title = "Numbers in gray boxes are depth (m)",
#        subtitle = "I have assumed that cdom data is in absorption coeff per meter.")
# 
# ggsave("/home/persican/Desktop/piotr.pdf", width = 10, height = 10)
