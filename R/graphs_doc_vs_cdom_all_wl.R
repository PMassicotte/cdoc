#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         doc_vs_cdom_all_wl.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Look at the relationship between DOC vs aCDOM at various
#               wavelengths.
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

cdom_doc <- readRDS("dataset/clean/cdom_dataset.rds") %>% 
  left_join(., readRDS("dataset/clean/cdom_metrics.rds")) %>% 
  #filter(doc < 100) %>% 
  mutate(class_s_240_600 = cut(s_240_600,
                               quantile(s_240_600, na.rm = TRUE),
                               include.lowest = T)) %>% 
  group_by(wavelength, class_s_240_600) %>% 
  nest() %>% 
  mutate(model = map(data, ~ lm(doc ~ absorption, data = .)))

models <- unnest(cdom_doc, map(model, broom::glance))
#unnest(map(model, broom::tidy))

mydata <- unnest(models, data)

#---------------------------------------------------------------------
# Create the plots.
#---------------------------------------------------------------------

p1 <- ggplot(models, aes(x = wavelength, y = r.squared, group = class_s_240_600)) +
  geom_point(aes(color = class_s_240_600), size = 0.5) +
  ylab(expression(R^2)) +
  ggtitle(expression(paste("DOC ~ ", aCDOM[lambda]))) +
  #geom_point(data = cdom_doc2, aes(x = wavelength, y = r.squared), size = 0.5) +
  geom_vline(xintercept = c(254, 350, 440), lty = 2, size = 0.1, color = "gray50")

p2 <- filter(mydata, wavelength == 254) %>% 
  ggplot(aes(x = absorption, y = doc)) +
  
  geom_point(aes(color = study_id), alpha = 0.5) +
  
  geom_smooth(method = "lm", aes(group = class_s_240_600)) +
  facet_wrap(~class_s_240_600, scales = "free", ncol = 2) +
  ggtitle("lm models at wl = 254 for the 4 quantiles of class_s_240_600") +
  geom_text(x = -Inf,
            y = Inf,
            aes(label = round(r.squared, digits = 2)),
            vjust = 1.5,
            hjust = -0.5) +
  scale_color_brewer(palette = "Set1")

p3 <- filter(mydata, wavelength == 350) %>% 
  ggplot(aes(x = absorption, y = doc)) +
  
  geom_point(aes(color = study_id), alpha = 0.5) +
  
  geom_smooth(method = "lm", aes(group = class_s_240_600)) +
  facet_wrap(~class_s_240_600, scales = "free", ncol = 2) +
  ggtitle("lm models at wl = 350 for the 4 quantiles of class_s_240_600") +
  geom_text(x = -Inf,
            y = Inf,
            aes(label = round(r.squared, digits = 2)),
            vjust = 1.5,
            hjust = -0.5) +
  scale_color_brewer(palette = "Set1")

p4 <- filter(mydata, wavelength == 440) %>% 
  ggplot(aes(x = absorption, y = doc)) +
  
  geom_point(aes(color = study_id), alpha = 0.5) +
  
  geom_smooth(method = "lm", aes(group = class_s_240_600)) +
  facet_wrap(~class_s_240_600, scales = "free", ncol = 2) +
  ggtitle("lm models at wl = 440 for the 4 quantiles of class_s_240_600") +
  geom_text(x = -Inf,
            y = Inf,
            aes(label = round(r.squared, digits = 2)),
            vjust = 1.5,
            hjust = -0.5) +
  scale_color_brewer(palette = "Set1")

#---------------------------------------------------------------------
# Plot the graphs.
#---------------------------------------------------------------------
pdf("graphs/doc_vs_cdom_all_wl.pdf", width = 10)

print(p1)

print(p2)

print(p3)

print(p4)

dev.off()

#plotly::ggplotly()

# cdom_doc <- readRDS("dataset/clean/complete_dataset.rds") %>% 
#   filter(wavelength == 536)
# 
# ggplot(cdom_doc, aes(x = absorption, y = doc)) +
#   geom_point(aes(color = study_id)) 
# 
# summary(lm(doc ~ absorption, cdom_doc))

