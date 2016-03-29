#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         process_finish_rivers.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Process raw data (Finish rivers). Data provided by E. Asmala.
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

finish_rivers <- read_csv("dataset/raw/literature/finish_rivers/finnish_river_data.csv") %>%
  select(site,
         latitude = YK_Pohjoinen,
         longitude = YK_ita,
         date,
         absorption,
         wavelength = wl,
         toc,
         doc) %>%
  mutate(date = as.Date(date, format("%d/%m/%Y")),
         study_id = "finish_rivers",
         unique_id = paste("finish_rivers", 1:nrow(.), sep = "_"),
         ecotype = "lake") %>%
  as.data.frame()


# ********************************************************************
# Transform geographical coordinates from kkj to lat/lon.
# http://spatialreference.org/ref/epsg/kkj-finland-uniform-coordinate-system
# ********************************************************************
coordinates(finish_rivers) <- c("longitude", "latitude")
proj4string(finish_rivers) <- "+proj=tmerc +lat_0=0 +lon_0=27 +k=1 +x_0=3500000 +y_0=0 +ellps=intl +units=m +no_defs"

finish_rivers <- spTransform(finish_rivers, CRS("+proj=longlat +datum=WGS84"))

finish_rivers <- as_data_frame(as.data.frame(finish_rivers))

# ********************************************************************
# Save the dataset.
# ********************************************************************
saveRDS(finish_rivers, file = "dataset/clean/literature/finish_rivers.rds")
