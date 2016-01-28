#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         plot_doc_vs_cdom.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Plot the relationship between CDOM and DOC for all datasets
#               were we have complete CDOM profiles.
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

cdom_doc <- readRDS("dataset/clean/complete_dataset.rds")

cdom_doc <- filter(cdom_doc, wavelength == 350) %>% 
  select(study_id, wavelength, absorption, doc)

ggplot(cdom_doc, aes(x = doc, y = absorption)) +
  geom_point() +
  geom_smooth(method = "lm") +
  facet_wrap(~study_id, scales = "free") +
  ylab(expression(a[CDOM(350)]))

ggsave("graphs/acdom350_vs_doc.pdf", width = 10, height = 8)


ggplot(cdom_doc, aes(x = doc, y = absorption, group = study_id)) +
  geom_point(aes(color = study_id), alpha = 0.5) + 
  geom_smooth(method = "lm", aes(color = study_id)) +
  scale_x_log10() +
  scale_y_log10() +
  annotation_logticks() +
  ylab(expression(a[CDOM(350)]))

ggsave("graphs/acdom350_vs_doc2.pdf", width = 10, height = 8)
