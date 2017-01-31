# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>  
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Various figures for the supplementary materials.
# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>


# Appendix 1 --------------------------------------------------------------

rm(list = ls())

source("R/utils.R")

ll <- read_feather("dataset/clean/complete_data_350nm.feather") %>% 
  select(study_id, longitude, latitude, ecosystem, unique_id) %>% 
  mutate(region = coords2location(longitude, latitude))

any(is.na(ll$region))

hm <-
  list(
    "Asia" = "Asia",
    "North America" = "North America",
    "SouthAtlantic" = "South Atlantic Ocean",
    "SouthernOcean" = "Southern Ocean",
    "Europe" = "Europe",
    "NorthAtlantic" = "North Atlantic Ocean",
    "ArcticOcean" = "Arctic Ocean",
    "IndianOcean" = "Indian Ocean",
    "NorthPacific" = "North Pacific Ocean",
    "SouthPacific" = "South Pacific Ocean",
    "Australia" = "Australia",
    "Africa" = "Africa"
  )

ll <- ll %>% 
  mutate(region = unlist(hm[region], use.names = FALSE))

p1 <- ll %>%
  group_by(region) %>%
  summarise(n = n()) %>%
  ggplot(aes(x = reorder(region, n), y = n)) +
  geom_text(aes(label = n), vjust = 0.75, hjust = -0.25, size = 3) +
  geom_bar(stat = "identity") +
  ylab("Number of observation") +
  xlab("Regions") +
  scale_y_continuous(breaks = seq(0, 5500, by = 500), limits = c(0, 5500)) +
  theme(axis.title.x = element_blank()) +
  annotate(
    "text",
    Inf,
    Inf,
    label = "A",
    vjust = 1.5,
    hjust = 1.5,
    size = 5,
    fontface = "bold"
  ) + 
  coord_flip()

p2 <- ll %>%
  group_by(ecosystem) %>%
  summarise(n = n()) %>%
  ggplot(aes(x = reorder(stringr::str_to_title(ecosystem), n), y = n)) +
  geom_text(aes(label = n), vjust = 0.75, hjust = -0.25, size = 3) +
  geom_bar(stat = "identity") +
  xlab("Ecosystems") +
  ylab("Number of observation") +
  annotate(
    "text",
    Inf,
    Inf,
    label = "B",
    vjust = 1.5,
    hjust = 1.5,
    size = 5,
    fontface = "bold")  + 
  coord_flip() +
  scale_y_continuous(breaks = seq(0, 5500, by = 500), limits = c(0, 5500))

p <- cowplot::plot_grid(p1, p2, ncol = 1, align = "hv")
cowplot::save_plot("graphs/appendix1.pdf", p, base_height = 9, base_width = 7)
embed_fonts("graphs/appendix1.pdf")

# Appendix 4 --------------------------------------------------------------

df <- read_feather("dataset/clean/complete_data_350nm.feather") %>% 
  mutate(year = as.numeric(format(date, "%Y"))) %>% 
  mutate(month = format(date, "%B")) %>% 
  mutate(month = factor(month, levels = month.name)) %>% 
  mutate(hemisphere = ifelse(latitude < 0, "South", "North"))

res <- df %>%
  group_by(month, hemisphere) %>%
  summarise(n = n()) %>%
  drop_na(month)

pA <- res %>% 
  ggplot(aes(x = month, y = n)) +
  geom_bar(stat = "identity") +
  facet_wrap(~ hemisphere, scales = "free") +
  theme(axis.text.x = element_text(
    angle = 45,
    hjust = 1,
    vjust = 1,
    size = 8
  )) +
  xlab("Months") +
  ylab("Number of observation")

res <- df %>%
  group_by(year, hemisphere) %>%
  summarise(n = n()) %>%
  drop_na(year)

pB <- res %>% 
  ggplot(aes(x = year, y = n)) +
  geom_bar(stat = "identity") +
  facet_wrap(~ hemisphere, scales = "free_y") +
  theme(axis.text.x = element_text(
    # angle = 0,
    # hjust = 1,
    # vjust = 1,
    size = 8
  )) +
  scale_x_continuous(
    breaks = seq(1990, 2015, by = 5),
    labels = seq(1990, 2015, by = 5)
  ) +
  xlab("Years") +
  ylab("Number of observation")

p <- cowplot::plot_grid(pB, pA, ncol = 1, align = "v", rel_heights = c(1, 1.15))
p

save_plot("graphs/appendix4.pdf", p, base_width = 6, base_height = 5)
embed_fonts("graphs/appendix4.pdf")

df %>%
  group_by(hemisphere) %>% 
  summarise(n = n()) %>% 
  mutate(percent = n / sum(n))


# Supplementary table 1 ---------------------------------------------------


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
  group_by(wavelength) %>% 
  summarise(n = n())

wl <- literature_wl$wavelength

cdom_doc <- read_feather("dataset/clean/cdom_dataset.feather") %>%
  filter(study_id != "nelson") %>% # Nelson is missing wl < 275
  filter(study_id != "greenland_lakes") %>%  # These had lamp problem at 360 nm
  filter(study_id != "horsen") %>% 
  filter(wavelength %in% wl) %>% 
  group_by(wavelength) %>% 
  nest()

source_wl <- filter(cdom_doc, wavelength != 350)
target_wl <- filter(cdom_doc, wavelength == 350)

models <- map2(source_wl$data, target_wl$data, f)

coefs <- models %>% purrr::map(broom::tidy) %>%
  bind_rows() %>%
  select(term, estimate) %>% 
  mutate(wavelength = rep(source_wl$wavelength, each = 2)) %>% 
  spread(term, estimate) %>% 
  mutate(r2 = models %>% purrr::map(summary) %>% map_dbl("r.squared")) %>% 
  left_join(literature_wl)

colnames(coefs) <- c("Wavelength (nm)", "Intercept", "Slope", "$R^2$", "$n$")

caption = "Coefficients of the linear regressions between absorption 
coefficents at 350 nm and other wavelengths. Each regression includes a total 
of 2321 observations. All regression have p-value < 0.00001.  $n$ represents 
the number of observations used in this study that were reported at this 
wavelength."

print(
  xtable::xtable(
    coefs,
    align = c("cccccr"),
    caption = caption,
    digits = c(0, 0, 2, 2, 4, 0)
  ),
  file = "article/tables/sup_table1.tex",
  include.rownames = FALSE,
  sanitize.text.function = function(x) {
    x
  }
)



