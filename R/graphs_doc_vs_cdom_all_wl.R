#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         doc_vs_cdom_all_wl.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Look at the relationship between DOC vs aCDOM at various
#               wavelengths.
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

cdom_doc <- readRDS("dataset/clean/complete_dataset.rds") %>% 
  #filter(doc < 100) %>% 
  mutate(class_doc = cut(doc,
                         quantile(doc, probs = seq(0, 1, 0.25), na.rm = TRUE),
                         include.lowest = T)) %>% 
  group_by(wavelength, class_doc) %>% 
  nest() %>% 
  mutate(model = map(data, ~ lm(doc ~ absorption, data = .))) %>% 
  unnest(map(model, broom::glance)) %>% 
  unnest(map(model, broom::tidy))

cdom_doc2 <- readRDS("dataset/clean/complete_dataset.rds") %>%
  group_by(wavelength) %>% 
  nest() %>% 
  mutate(model = map(data, ~ lm(doc ~ absorption, data = .))) %>%
  mutate(class_doc = "all") %>% 
  unnest(map(model, broom::glance)) %>% 
  unnest(map(model, broom::tidy))

#---------------------------------------------------------------------
# Create the plots.
#---------------------------------------------------------------------

p1 <- ggplot(cdom_doc, aes(x = wavelength, y = r.squared, group = class_doc)) +
  geom_point(aes(color = class_doc), size = 0.5) +
  ylab(expression(R^2)) +
  ggtitle(expression(paste("DOC ~ ", aCDOM[lambda]))) +
  geom_point(data = cdom_doc2, aes(x = wavelength, y = r.squared), size = 0.5) +
  geom_vline(xintercept = c(254, 350, 440), lty = 2, size = 0.1, color = "gray50")

p2 <- ggplot(cdom_doc[cdom_doc$term == "absorption", ], aes(x = wavelength, y = estimate, group = class_doc)) +
  geom_point(aes(color = class_doc), size = 0.5) +
  ylab("Slope (umol C)") +
  geom_point(data = cdom_doc2[cdom_doc2$term == "absorption", ], aes(x = wavelength, y = estimate), size = 0.5)

p3 <- ggplot(cdom_doc[cdom_doc$term == "(Intercept)", ], aes(x = wavelength, y = estimate, group = class_doc)) +
  geom_point(aes(color = class_doc), size = 0.5) +
  ylab("Intercept (umol C)") +
  geom_point(data = cdom_doc2[cdom_doc2$term == "(Intercept)", ], aes(x = wavelength, y = estimate), size = 0.5)


p4 <- readRDS("dataset/clean/complete_dataset.rds") %>% 
  filter(wavelength == 254) %>% 
  mutate(class_doc = cut(doc,
                         quantile(doc, probs = seq(0, 1, 0.25), na.rm = TRUE),
                         include.lowest = T)) %>% 
  ggplot(aes(x = absorption, y = doc)) +
  geom_point(aes(color = study_id), alpha = 0.5) +
  geom_smooth(method = "lm", aes(group = class_doc)) +
  facet_wrap(~class_doc, scales = "free", ncol = 2) +
  ggtitle("lm models at wl = 254 for the 4 quantiles of DOC") +
  geom_text(data = cdom_doc[cdom_doc$wavelength == 254, ][seq(1, 8, 2), ],
            x = -Inf,
            y = Inf,
            aes(label = round(r.squared, digits = 2)),
            vjust = 1.5,
            hjust = -0.5) +
  scale_color_brewer(palette = "Set1")

p5 <- readRDS("dataset/clean/complete_dataset.rds") %>% 
  filter(wavelength == 350) %>% 
  mutate(class_doc = cut(doc,
                         quantile(doc, probs = seq(0, 1, 0.25), na.rm = TRUE),
                         include.lowest = T)) %>% 
  ggplot(aes(x = absorption, y = doc)) +
  geom_point(aes(color = study_id), alpha = 0.5) +
  geom_smooth(method = "lm", aes(group = class_doc)) +
  facet_wrap(~class_doc, scales = "free", ncol = 2) +
  ggtitle("lm models at wl = 350 for the 4 quantiles of DOC") +
  geom_text(data = cdom_doc[cdom_doc$wavelength == 350, ][seq(1, 8, 2), ],
            x = -Inf,
            y = Inf,
            aes(label = round(r.squared, digits = 2)),
            vjust = 1.5,
            hjust = -0.5) +
  scale_color_brewer(palette = "Set1")

p6 <- readRDS("dataset/clean/complete_dataset.rds") %>% 
  filter(wavelength == 440) %>% 
  mutate(class_doc = cut(doc,
                         quantile(doc, probs = seq(0, 1, 0.25), na.rm = TRUE),
                         include.lowest = T)) %>% 
  ggplot(aes(x = absorption, y = doc)) +
  geom_point(aes(color = study_id), alpha = 0.5) +
  geom_smooth(method = "lm", aes(group = class_doc)) +
  facet_wrap(~class_doc, scales = "free", ncol = 2) +
  ggtitle("lm models at wl = 440 for the 4 quantiles of DOC") +
  geom_text(data = cdom_doc[cdom_doc$wavelength == 440, ][seq(1, 8, 2), ],
            x = -Inf,
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

print(p4)

print(p5)

print(p6)

dev.off()

#plotly::ggplotly()

# cdom_doc <- readRDS("dataset/clean/complete_dataset.rds") %>% 
#   filter(wavelength == 536)
# 
# ggplot(cdom_doc, aes(x = absorption, y = doc)) +
#   geom_point(aes(color = study_id)) 
# 
# summary(lm(doc ~ absorption, cdom_doc))

