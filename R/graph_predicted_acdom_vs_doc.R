# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>  
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Show the relation between DOC and aCDOM350. aCDOM350 is 
#               predicted using the developped interpolation method.
# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

target_wl <- 350

cdom_complete <- read_feather("dataset/clean/cdom_dataset.feather") %>% 
  select(study_id, absorption, doc, wavelength, unique_id) %>% 
  filter(wavelength == 350) %>% 
  mutate(source = "complete")

cdom_literature <- read_feather("dataset/clean/literature_datasets_estimated_absorption.feather") %>%
  filter(r2 > 0.98) %>% 
  select(study_id, absorption = predicted_absorption, doc, wavelength, unique_id) %>% 
  mutate(source = "literature")

df <- bind_rows(cdom_complete, cdom_literature)


# Graph by study ----------------------------------------------------------

st <- "This shows the relation between DOC and 'predicted' aCDOM350."
st <- paste0(strwrap(st, 70), sep = "", collapse = "\n")

ggplot(df, aes(y = absorption, x = doc)) +
  geom_point(size = 0.5) +
  facet_wrap(~study_id, scales = "free", ncol = 4) +
  theme(legend.position = "none") +
  ylab(sprintf("Absorption at %d nm", target_wl)) +
  geom_smooth(method = "lm", size = 0.1) +
  ggtitle(label = "", subtitle = st)

ggsave("graphs/predicted_acdom_vs_doc.pdf", width = 10, height = 16)

# Graph with all data -----------------------------------------------------

p <- df %>% 
  ggplot(aes(x = doc, y = absorption)) +
  geom_point(aes(color = study_id), size = 1) +
  scale_x_log10() + 
  scale_y_log10() +
  geom_smooth(method = "lm")

plotly::ggplotly(p)

# Some stats --------------------------------------------------------------

df %>% group_by(study_id) %>% 
  summarise(n = n())
