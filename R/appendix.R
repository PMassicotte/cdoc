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


# Appendix 2 --------------------------------------------------------------

#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Explore the relation between aCDOM350 and aCDOM at various
#               wavelengths.
#               
#               This script produces figure 2 for the manuscript.
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

data350 <- read_feather("dataset/clean/cdom_dataset.feather") %>% 
  filter(wavelength == 350) %>% 
  filter(study_id != "nelson") %>% # Nelson is missing wl < 275
  filter(study_id != "greenland_lakes") %>%  # These had lamp problem at 360 nm
  filter(study_id != "horsen")

cdom_doc <- read_feather("dataset/clean/cdom_dataset.feather") %>%
  filter(study_id != "nelson") %>% # Nelson is missing wl < 275
  filter(study_id != "greenland_lakes") %>%  # These had lamp problem at 360 nm
  filter(study_id != "horsen") %>% 
  filter(wavelength <= 500) %>% 
  group_by(wavelength) %>% 
  nest() %>% 
  mutate(model = purrr::map(data, ~lm(data350$absorption ~ .$absorption)))

f <- function(x) {
  
  df <- as.data.frame(confint(x)) 
  df$term = rownames(df)
  return(df)
  
}

res <- cdom_doc %>% 
  mutate(tt = purrr::map(model, f)) %>%
  unnest(tt) %>% 
  filter(term == "(Intercept)")


cdom_doc %>% 
  unnest(model %>% purrr::map(broom::glance)) %>% 
  filter(wavelength %in% c(250, 500))

cdom_doc %>% 
  unnest(model %>% purrr::map(broom::tidy)) %>% 
  filter(wavelength %in% c(250, 500))

## R2 panel 

p1 <- cdom_doc %>% 
  filter(wavelength != 416) %>% #instrument error
  unnest(model %>% purrr::map(broom::glance)) %>% 
  ggplot(aes(x = wavelength, y = r.squared)) +
  geom_line(size = 0.5) +
  ylab(expression(R^2)) +
  theme(axis.ticks.x = element_blank()) +
  theme(axis.title.x = element_blank()) +
  theme(axis.text.x = element_blank()) +
  annotate("text", Inf, Inf, label = "A",
           vjust = 1.5, hjust = 1.5, size = 5, fontface = "bold") +
  scale_x_continuous(breaks = seq(250, 500, length.out = 6), limits = c(250, 515)) +
  scale_y_continuous(limits = c(0.85, 1)) +
  geom_vline(xintercept = 350, lty = 2, size = 0.25)

p1

## Slope panel

ci <- cdom_doc %>% 
  mutate(tt = purrr::map(model, f)) %>%
  unnest(tt) %>% 
  filter(term == ".$absorption")

slope <- cdom_doc %>% 
  unnest(model %>% purrr::map(broom::tidy)) %>% 
  filter(term == ".$absorption")

p2 <- ggplot() + 
  geom_ribbon(data = ci, aes(x = wavelength, ymin = `2.5 %`, ymax = `97.5 %`),
              fill = "gray75") +
  geom_line(data = slope, aes(x = wavelength, y = estimate), size = 0.5) +
  ylab("Slope") +
  theme(axis.ticks.x = element_blank()) +
  theme(axis.title.x = element_blank()) +
  theme(axis.text.x = element_blank()) +
  annotate("text", Inf, Inf, label = "B",
           vjust = 1.5, hjust = 1.5, size = 5, fontface = "bold") +
  scale_x_continuous(breaks = seq(250, 500, length.out = 6), limits = c(250, 515)) +
  geom_vline(xintercept = 350, lty = 2, size = 0.25)

p2

## Intercept panel

ci <- cdom_doc %>% 
  mutate(tt = purrr::map(model, f)) %>%
  unnest(tt) %>% 
  filter(term == "(Intercept)")

intercept <- cdom_doc %>% 
  unnest(model %>% purrr::map(broom::tidy)) %>% 
  filter(term == "(Intercept)")

p3 <-  ggplot() +
  geom_ribbon(data = ci, aes(x = wavelength, ymin = `2.5 %`, ymax = `97.5 %`),
              fill = "gray") +
  geom_line(data = intercept, aes(x = wavelength, y = estimate), size = 0.5) +
  ylab(bquote(Intercept~(m^{-1}))) +
  xlab("Wavelengths (nm)") +
  annotate("text", Inf, Inf, label = "C",
           vjust = 1.5, hjust = 1.5, size = 5, fontface = "bold") +
  scale_x_continuous(breaks = seq(250, 500, length.out = 6),
                     limits = c(250, 515)) +
  geom_vline(xintercept = 350, lty = 2, size = 0.25)

p3

## Combine plots

p <- cowplot::plot_grid(
  p1,
  p2,
  p3,
  ncol = 1,
  align = "v",
  rel_heights = c(1, 1, 1.2)
)

cowplot::save_plot("graphs/appendix2a.pdf", 
                   p, 
                   base_height = 5,
                   base_width = 3.5)

embed_fonts("graphs/appendix2a.pdf")

## Raster plot

f <- function(x, y) {
  
  df <- data.frame(x = x$absorption, y = y$absorption)
  
  fit <- biglm::biglm(y ~ x, data = df)
  
  return(list(fit))
}

cdom_doc <- read_feather("dataset/clean/cdom_dataset.feather") %>%
  filter(study_id != "nelson") %>% # Nelson is missing wl < 275
  filter(study_id != "greenland_lakes") %>%  # These had lamp problem at 360 nm
  filter(study_id != "horsen") %>% 
  filter(wavelength <= 500) %>% 
  group_by(wavelength) %>% 
  nest()

# Take ~ 1-2 minute(s)
models <- outer(cdom_doc$data, cdom_doc$data, Vectorize(f))

r2 <- lapply(models, function(x) summary(x)$rsq) %>% 
  unlist() %>% 
  pracma::Reshape(., 251, 251) %>% 
  data.frame() %>% 
  mutate(wavelength = 250:500)

names(r2) <- c(paste("W", 250:500, sep = ""), "wavelength")

r2 <- gather(r2, wavelength2, r2, -wavelength) %>% 
  mutate(wavelength2 = parse_number(wavelength2))


p <- ggplot(r2, aes(x = wavelength, wavelength2, fill = r2)) +
  geom_raster() +
  scale_fill_viridis() +
  scale_x_continuous(expand = c(0, 0)) +
  scale_y_continuous(expand = c(0, 0)) +
  coord_equal() +
  ylab("Wavelength (nm)") +
  xlab("Wavelength (nm)") +
  labs(fill = bquote(R^2)) +
  guides(fill = guide_colorbar(barwidth = 1.5)) 

ggsave("graphs/appendix2b.pdf")

## CSV file for the appendix

wl <- 250:500

coefs <- lapply(models, function(x) round(coef(x), digits = 6)) %>% 
  do.call(rbind, .) %>% 
  data.frame() %>% 
  setNames(c("intercept", "slope")) %>% 
  mutate(from = rep(wl, length(wl))) %>% 
  mutate(to = rep(wl, each = length(wl))) %>% 
  mutate(r2 = round(as.numeric(r2$r2), digits = 6)) %>% 
  arrange(from) %>% 
  select(from, to, intercept, slope, r2)

write_csv(coefs, "dataset/clean/supplementary_coef.csv")

# Appendix 5 --------------------------------------------------------------

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

save_plot("graphs/appendix5.pdf", p, base_width = 6, base_height = 5)
embed_fonts("graphs/appendix5.pdf")

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



# Appendix 7 --------------------------------------------------------------

# Explore the effect of changing salinity thershold to classify ocean sample
# from 30 to 32. Also explore the effect  of sampling depth on the reported
# relationship.

rm(list = ls())

df <- read_feather("dataset/clean/complete_data_350nm.feather") %>% 
  filter(ecosystem == "ocean") %>% 
  filter(doc > 30) %>% 
  filter(absorption >= 3.754657e-05) %>% 
  select(ecosystem, doc, absorption, salinity, study_id, depth) %>% 
  mutate(ecosystem = str_to_title(ecosystem)) %>% 
  mutate(sal = ifelse(salinity <= 32 | is.na(salinity), "t", "f")) %>% 
  mutate(is_nelson = ifelse(study_id == "nelson", TRUE, FALSE)) %>% 
  mutate(is_deep = ifelse(depth >= 500 | is.na(depth), TRUE, FALSE))

mylabels <- c(
  "t" = "Salinity <= 32",
  "f" = "Salinity > 32"
)

df %>% 
  ggplot(aes(x = doc, y = absorption)) +
  geom_point(aes(color = is_nelson, shape = is_deep), size = 1) +
  geom_smooth(aes(group = interaction(is_nelson, is_deep)), method = "lm", formula = y ~ log(x), size = 0.5) +
  scale_x_log10() +
  scale_y_log10() +
  facet_wrap(~sal, scales = "free", labeller = labeller(sal = mylabels)) +
  annotation_logticks(size = 0.2) +
  xlab(bquote("Dissolved organic carbon"~(mu*mol~C%*%L^{-1}))) +
  ylab(bquote("Absorption at 350 nm"~(m^{-1}))) +
  labs(color = "Nelson data",
       shape = "Depth >= 500 m") +
  theme(legend.justification = c(0.95, 0),
        legend.position = c(0.99, 0.05)) +
  theme(legend.title = element_text(size = 10) ,
        legend.text = element_text(size = 9))

ggsave("graphs/appendix7.pdf", width = 10, height = 5)
