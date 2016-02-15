#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         doc_vs_acdom.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Look at the relation between DOC and aCDOM.
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

cdom_metrics <- readRDS("dataset/clean/cdom_metrics.rds")

cdom_doc <- readRDS("dataset/clean/complete_dataset.rds") %>% 
  filter(wavelength == 254) %>% 
  select(doc, absorption, study_id, unique_id) %>% 
  right_join(., cdom_metrics) %>% 
  
  mutate(class_suva254 = cut(suva254, 
                     quantile(suva254, na.rm = TRUE), 
                     include.lowest = T)) %>% 
  
  mutate(class_suva440 = cut(suva440, 
                        quantile(suva440, na.rm = TRUE), 
                        include.lowest = T)) %>% 
  
  mutate(class_s_275_295 = cut(s_275_295, 
                             quantile(s_275_295, na.rm = TRUE), 
                             include.lowest = T)) %>% 
  
  mutate(class_s_350_400 = cut(s_350_400, 
                               quantile(s_350_400, na.rm = TRUE), 
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
  facet_wrap(~class_suva254) +
  scale_y_log10() +
  scale_x_log10() +
  annotation_logticks() +
  xlab(expression(aCDOM[254])) +
  ggtitle("DOC vs aCDOM254 for various classes of suva254")

p3 <- ggplot(cdom_doc, aes(x = absorption, y = doc)) +
  geom_point(size = 1) +
  geom_smooth(method = "lm") +
  facet_wrap(~class_suva440) +
  scale_y_log10() +
  scale_x_log10() +
  annotation_logticks() +
  xlab(expression(aCDOM[254])) +
  ggtitle("DOC vs aCDOM254 for various classes of suva440")

p4 <- ggplot(cdom_doc, aes(x = absorption, y = doc)) +
  geom_point(size = 1) +
  geom_smooth(method = "lm") +
  facet_wrap(~class_s_275_295) +
  scale_y_log10() +
  scale_x_log10() +
  annotation_logticks() +
  xlab(expression(aCDOM[254])) +
  ggtitle("DOC vs aCDOM254 for various classes of S275_295")

p5 <- ggplot(cdom_doc, aes(x = absorption, y = doc)) +
  geom_point(size = 1) +
  geom_smooth(method = "lm") +
  facet_wrap(~class_s_350_400) +
  scale_y_log10() +
  scale_x_log10() +
  annotation_logticks() +
  xlab(expression(aCDOM[254])) +
  ggtitle("DOC vs aCDOM254 for various classes of S350_400")

pdf("graphs/doc_vs_acdom.pdf", width = 8, height = 6)

print(p1)
print(p2)
print(p3)
print(p4)
print(p5)

dev.off()

#---------------------------------------------------------------------
# Look at the relations for each individual study.
#---------------------------------------------------------------------
ggplot(cdom_doc, aes(x = doc, y = absorption)) +
  geom_point() +
  geom_smooth(method = "lm") +
  facet_wrap(~study_id, scales = "free") +
  ylab(expression(a[CDOM(254)]))

ggsave("graphs/acdom254_vs_doc.pdf", width = 10, height = 8)