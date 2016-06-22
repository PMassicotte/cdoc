# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>  
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Script producing a latex table with the coefficients of the 
#               linear regressions
# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
rm(list = ls())

f <- function(x, y) {
  
  fit <- lm(y$absorption ~ x$absorption)
  
  return(fit)
}

literature_wl <- read_feather("dataset/clean/literature_datasets.feather") %>% 
  select(wavelength) %>% 
  distinct() %>% 
  c(.$wavelength)

cdom_doc <- read_feather("dataset/clean/cdom_dataset.feather") %>%
  filter(study_id != "nelson") %>% # Nelson is missing wl < 275
  filter(study_id != "greenland_lakes") %>%  # These had lamp problem at 360 nm
  filter(study_id != "horsen") %>% 
  filter(wavelength %in% literature_wl) %>% 
  group_by(wavelength) %>% 
  nest()


source_wl <- filter(cdom_doc, wavelength != 350)
target_wl <- filter(cdom_doc, wavelength == 350)

models <- map2(source_wl$data, target_wl$data, f)

coefs <- models %>% purrr::map(broom::tidy) %>%
  bind_rows() %>%
  select(term, estimate) %>% 
  mutate(wavelenght = rep(source_wl$wavelength, each = 2)) %>% 
  spread(term, estimate) %>% 
  mutate(r2 = models %>% purrr::map(summary) %>% map_dbl("r.squared"))

colnames(coefs) <- c("Wavelength (nm)", "Intercept", "Slope", "$R^2$")

caption = "Coefficients of the linear regressions between absorption 
coefficents at 350 nm and other wavelengths. Each regression includes a total 
of 2190 observations."

print(xtable::xtable(coefs, 
                     align = c("ccccc"),
                     caption = caption), 
      file = "article/tables/table2.tex", 
      include.rownames = FALSE,
      sanitize.text.function = function(x) {x})


