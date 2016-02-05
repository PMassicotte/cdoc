#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         doc_vs_acdom.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Look at the relation between DOC and aCDOM for various 
#               classes of SUVA254.
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
rm(list = ls())

cdom_metrics <- readRDS("dataset/clean/cdom_metrics.rds")

cdom_doc <- readRDS("dataset/clean/complete_dataset.rds") %>% 
  filter(wavelength == 254) %>% 
  select(doc, absorption, study_id, unique_id) %>% 
  right_join(., cdom_metrics) %>% 
  
  mutate(class254 = cut(suva254, 
                     quantile(suva254, na.rm = TRUE), 
                     include.lowest = T)) %>% 
  
  mutate(class440 = cut(suva440, 
                        quantile(suva440, na.rm = TRUE), 
                        include.lowest = T))


p1 <- ggplot(cdom_doc, aes(x = absorption, y = doc)) +
  geom_point(size = 1) +
  geom_smooth(method = "lm") +
  scale_y_log10() +
  scale_x_log10() +
  annotation_logticks() +
  xlab(expression(aCDOM[254])) +
  ggtitle("DOC vs aCDOM254 using all data")

p2 <- ggplot(cdom_doc, aes(x = absorption, y = doc)) +
  geom_point(size = 1) +
  geom_smooth(method = "lm") +
  facet_wrap(~class254) +
  scale_y_log10() +
  scale_x_log10() +
  annotation_logticks() +
  xlab(expression(aCDOM[254])) +
  ggtitle("DOC vs aCDOM254 for various classes of suva254")

p3 <- ggplot(cdom_doc, aes(x = absorption, y = doc)) +
  geom_point(size = 1) +
  geom_smooth(method = "lm") +
  facet_wrap(~class440) +
  scale_y_log10() +
  scale_x_log10() +
  annotation_logticks() +
  xlab(expression(aCDOM[440])) +
  ggtitle("DOC vs aCDOM440 for various classes of suva440")

pdf("graphs/doc_vs_acdom.pdf", width = 8, height = 6)

print(p1)
print(p2)
print(p3)
dev.off()
