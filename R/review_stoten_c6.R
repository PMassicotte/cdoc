# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>  
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  This script explore how CDOM metrics (ex.: S275-295) can be
#               used to approximate the MW of the DOM sample.
# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

cdom_metrics <- read_feather("dataset/clean/cdom_dataset.feather") %>%
  filter(wavelength >= 275) %>% 
  select(doc, wavelength, absorption, unique_id, ecosystem) %>% 
  group_by(unique_id, ecosystem) %>% 
  nest() 

res <- cdom_metrics %>%
  mutate(mod_275_295 = purrr::map(data,  ~cdom_exponential(.$wavelength, .$absorption, startwl = 275, endwl = 295))) %>% 
  mutate(mod_350_400 = purrr::map(data,  ~cdom_exponential(.$wavelength, .$absorption, startwl = 350, endwl = 400))) 

res <- res %>% 
  mutate(s_275_295 = map(mod_275_295, function(x){coef(x$model)[1]})) %>% 
  mutate(s_350_400 = map(mod_350_400, function(x){coef(x$model)[1]})) %>% 
  mutate(r2_275_295 = map(mod_275_295, function(x){x$r2})) %>% 
  mutate(r2_350_400 = map(mod_350_400, function(x){x$r2})) %>% 
  unnest(s_275_295, s_350_400, r2_275_295, r2_350_400) %>% 
  mutate(sr = s_275_295 / s_350_400)

## Calculate MW from equations provided in fig. 5 caption (Helms 2008)

res <- res %>% 
  filter(r2_275_295 >= 0.95 & r2_350_400 >= 0.95) %>% 
  mutate(mw_275_295 = 9800 - (2000000 * s_275_295) / 3)

hist(res$mw_275_295)

dana12_166 <- res %>% 
  filter(unique_id == "dana12_166")

df <- data_frame(
  wavelength = c(275:295, 350:400),
  absorption = c(predict(dana12_166$mod_275_295[[1]]), predict(dana12_166$mod_350_400[[1]])),
  type = c(rep("275-295", 21), rep("350-400", 51))
)

dana12_166 %>% 
  unnest(data) %>% 
  ggplot(aes(x = wavelength, y = absorption)) +
  geom_point() + 
  geom_line(data = df, aes(x = wavelength, y = absorption, color = type), size = 1.5) +
  annotate("text", 500, 0.2, label = "s275-295 = 0.08308374") +
  annotate("text", 500, 0.15, label = "s350-400 = 0.01910781") +
  annotate("text", 500, 0.1, label = "sr = 0.08308374") +
  annotate("text", 500, 0.05, label = "mw = -45589.16") +

ggsave("~/Desktop/sr.pdf")
  
x <- seq(-45000, 4000, 200)
y <- -1.57e-6 * x + 0.0147

plot(x, y, xlab = "mw", ylab = "s275-295", type = "l")


# Helms 2008 --------------------------------------------------------------

df <- data_frame(
  s_275_295 = unique(res$s_275_295),
  mw = 9800 - (2000000 * s_275_295) / 3,
  range = between(s_275_295, 0.008, 0.014)
)

df %>% 
  ggplot(aes(x = mw, y = s_275_295)) +
  geom_point(aes(color = range)) +
  xlab("Molecular weight (Da)") +
  ylab(bquote(S[275-295]~(m^{-1}))) +
  scale_x_continuous(breaks = scales::pretty_breaks(n = 10), limits = c(NA, 7000)) +
  labs(color = "Helms 2008") +
  labs(title = "Relationship between S275-295 and molecular weight") +
  labs(subtitle = stringr::str_wrap("The points in red show the unique values of S275-295 in our study whereas blue points show the limited range covered by the empirical relationship proposed by Helms et al. 2008.", 80)) +
  geom_hline(aes(yintercept = 0.0147), lty = 2, size = 0.25)

ggsave("graphs/molecular_weight_helms2008.png")


## Find at which value of 275-295 MW becomes negative

res %>% 
  select(mw_275_295, s_275_295) %>% 
  filter(mw_275_295 <= 0) %>% 
  arrange(desc(mw_275_295))
