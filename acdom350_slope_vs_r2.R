# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>  
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  This script looks at the relation between the slope of the 
#               relation between acdom350 and DOC for all studies (n ~ 43).
#               
#               Then, the relation between the slope and R2 is explored.
# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

target_wl <- 350

cdom_complete <- readRDS("dataset/clean/cdom_dataset.rds") %>%
  select(study_id, absorption, doc, wavelength, unique_id, longitude, latitude) %>%
  filter(wavelength == target_wl) %>%
  mutate(source = "complete")

cdom_literature <- readRDS("dataset/clean/literature_datasets_estimated_absorption.rds") %>%
  filter(r2 > 0.98) %>%
  select(study_id, absorption = predicted_absorption, doc, wavelength, unique_id, longitude, latitude) %>%
  mutate(source = "literature")

df <- bind_rows(cdom_complete, cdom_literature)

lms <- df %>% group_by(study_id) %>%
  nest() %>%
  mutate(m = data %>% purrr::map(~lm(absorption ~ doc, data = .))) %>% 
  mutate(coefs = m %>% purrr::map(broom::tidy)) %>% 
  mutate(r2 = m %>% purrr::map(broom::glance))

res <- unnest(lms, coefs) %>% 
  select(study_id, term, estimate) %>% 
  filter(term == "doc") %>% 
  mutate(r2 = lms$r2 %>% map_dbl("r.squared")) 

# http://www.fao.org/docrep/w5449e/w5449e05.htm
mod1 <- minpack.lm::nlsLM(r2 ~ rmax * (1 - exp(-k * estimate - b)),
            data = res,
            start = list(rmax = 1, k = 1, b = 1))

df <- data_frame(x = res$estimate, y = predict(mod1))


# Plot --------------------------------------------------------------------

p1 <- res %>% 
  ggplot(aes(x = estimate, y = r2)) +
  geom_point() +
  geom_line(data = df, aes(x = x, y = y), col = "red") +
  xlab("Slope of the aCDOM350-DOC regression") +
  ylab("R2 of the aCDOM350-DOC regression")

p2 <- p1 +
  geom_text_repel(aes(label = study_id), size = 2)


# pseudo-R2
cor(df$y, res$r2)^2


p <- cowplot::plot_grid(p1, p2, ncol = 1)

cowplot::save_plot("graphs/acdom350_slope_vs_r2.pdf", 
                   p, 
                   base_height = 10,
                   base_width = 8)
