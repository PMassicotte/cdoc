rm(list = ls())

spc <- read_feather("dataset/clean/cdom_dataset.feather") %>% 
  filter(study_id == "nelson")



p1 <- filter(spc, wavelength == 325) %>% 
ggplot(aes(x = doc, y = absorption)) +
  geom_point(aes(color = depth), size = 1) +
  geom_smooth(method = "lm") +
  ylab("a325") +
  ylim(0, 0.25) + 
  scale_colour_gradientn(colours = rainbow(7))


p2 <- filter(spc, wavelength == 275) %>% 
  ggplot(aes(x = doc, y = absorption)) +
  geom_point(aes(color = depth), size = 1) +
  geom_smooth(method = "lm") +
  ylab("a275") + 
  scale_colour_gradientn(colours = rainbow(7))

p <- grid.arrange(p1, p2)

ggsave("graphs/nelson_doc_cdom.pdf", p, height = 8)

metrics <- read_feather("dataset/clean/cdom_metrics.feather") %>% 
  left_join(., spc) %>% 
  filter(study_id == "nelson") %>% 
  select(unique_id:doc, -river, -date, -suva254, depth, -suva440) %>% 
  distinct()


tmp <- gather(metrics, variable, value, suva350:sr)

p3 <- ggplot(tmp, aes(x = doc, y = value)) +
  geom_point(aes(color = depth), size = 0.1) +
  geom_smooth(method = "lm") +
  facet_wrap(~variable, scales = "free") +
  scale_colour_gradientn(colours = rainbow(7))

p3

ggsave("graphs/nelson_doc_metrics.pdf", p3, width = 10, height = 5)
