#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         merge_cdom_datasets.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Merge all datasets containing CDOM and DOC data from
#               Colin, Eero and Philippe.
#
#               Additionally, interpolate CDOM data so we have 1 nm increment
#               in wavelengths for each spectra. This will ensure that all
#               metrics are calculated using the same spectral ranges.
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

cdom_doc <- list.files("dataset/clean/complete_profiles/",
                       "^[^((?!neslon).)*$]",
                       full.names = TRUE) %>%

  lapply(., readRDS) %>%
  bind_rows()

#---------------------------------------------------------------------
# Based on the following two lines of code I decided to keep only
# wavelengths between 250 and 600 nm.
#---------------------------------------------------------------------
range(tapply(cdom_doc$wavelength, cdom_doc$unique_id, min))
range(tapply(cdom_doc$wavelength, cdom_doc$unique_id, max))

cdom_doc <- filter(cdom_doc, wavelength >= 250 & wavelength <= 600) %>%
  arrange(study_id, wavelength)

#---------------------------------------------------------------------
# Lets interpolate CDOM between 250 mm and 600 mm by 1 nm.
#---------------------------------------------------------------------
# res <- filter(cdom_doc, study_id == "chen2000") %>% group_by(unique_id) %>%
res <- group_by(cdom_doc, unique_id) %>%
  do(interpolated = pracma::interp1(x = .$wavelength,
                                    y = .$absorption,
                                    xi = seq(250, 600, by = 1),
                                    method = "spline"))

res2 <- data.frame(do.call("cbind", res$interpolated))
names(res2) <- res$unique_id
res2$wavelength <- seq(250, 600, by = 1)

res2 <- gather(res2, unique_id, absorption, -wavelength)

#---------------------------------------------------------------------
# Plot the results of the interpolation.
# Randomly select 50 profiles
#---------------------------------------------------------------------
pdf("graphs/interpolation_cdom_at_1nm.pdf", width = 6, height = 4)

set.seed(1234)
ind <- sample(1:length(unique(cdom_doc$unique_id)), 50, replace = FALSE)

for(i in unique(cdom_doc$unique_id)[ind]){

  p <- ggplot(cdom_doc[cdom_doc$unique_id == i, ],
              aes(x = wavelength, y = absorption)) +
    geom_line(size = 2, aes(color = "Raw profile")) +
    geom_line(data = res2[res2$unique_id == i, ],
              aes(color = "Interpolated at 1 nm increment")) +
    ggtitle(i) +
    labs(color = "") +
    scale_color_manual(values = c("red", "black")) +
    theme(legend.justification = c(1, 1), legend.position = c(1, 1))

  print(p)

}

dev.off()

#---------------------------------------------------------------------
# Remove "old" wavelengths and absorption and replace with
# interpolated ones.
#---------------------------------------------------------------------
cdom_doc <- select(cdom_doc, -wavelength, -absorption) %>%
  distinct() %>%
  left_join(., res2)

#---------------------------------------------------------------------
# Nelson data. This has been done separatly because wavelengths were
# shorter (275-700).
#---------------------------------------------------------------------
nelson <- readRDS("dataset/clean/complete_profiles/nelson.rds") %>%
  filter(wavelength <= 600)

cdom_doc <- bind_rows(cdom_doc, nelson)

#---------------------------------------------------------------------
# Final data cleaning
#---------------------------------------------------------------------
`%ni%` <- Negate(`%in%`)

# Remove profils where absorption at 400 nm < 0
tmp <- filter(cdom_doc, wavelength == 400)

cdom_doc <- filter(cdom_doc, unique_id %ni% tmp$unique_id[which(tmp$absorption < 0)])

# Remove data without DOC values.
cdom_doc <- filter(cdom_doc, !is.na(doc) & !is.na(absorption))


#---------------------------------------------------------------------
# Save the final result.
#---------------------------------------------------------------------
saveRDS(cdom_doc, file = "dataset/clean/cdom_dataset.rds")
