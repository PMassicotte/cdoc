#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         graphs_acdom350_vs_cdom_all_wl.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Explore the relation between aCDOM350 and aCDOM at various
#               wavelengths.
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
rm(list = ls())

get_data <- function(wl) {
  
  tmp <- readRDS("dataset/clean/cdom_dataset.rds") %>% 
    filter(wavelength == wl) %>% 
    select(absorption)
  
  cdom_doc <- readRDS("dataset/clean/cdom_dataset.rds") %>% 
    filter(wavelength >= 275) %>% # Because Nelson's data only start at 275
    group_by(wavelength) %>% 
    nest() %>% 
    mutate(model = map(data, ~ lm(tmp$absorption ~ .$absorption))) %>% 
    unnest(map(model, broom::glance)) %>% 
    unnest(map(model, broom::tidy))

  names(cdom_doc) <- make.unique(names(cdom_doc))
    
  cdom_doc$term <- ifelse(cdom_doc$term == "(Intercept)", "intercept", "slope")
  
  cdom_doc$type = wl
  
  cdom_doc <- select(cdom_doc, wavelength, r.squared, term, estimate, type) %>% 
    spread(term, estimate)
  
  return(cdom_doc)
}

res254 <- get_data(wl = 254) 
res350 <- get_data(wl = 350) 
res440 <- get_data(wl = 440)

res <- bind_rows(res254, res350, res440)


p1 <- ggplot(res, aes(x = wavelength, y = r.squared, color = factor(type))) +
  geom_point(size = 0.5) +
  ylab(expression(R^2)) +
  labs(color = "Target wl") +
  geom_vline(xintercept = c(254, 350, 440), lty = 2, size = 0.1, color = c("red", "green", "blue")) +
  scale_x_continuous(breaks = seq(240, 600, length.out = 10))

p2 <- ggplot(res, aes(x = wavelength, y = slope, color = factor(type))) +
  geom_point(size = 0.5) +
  ylab("slope") +
  labs(color = "Target wl") +
  geom_vline(xintercept = c(254, 350, 440), lty = 2, size = 0.1, color = c("red", "green", "blue")) +
  scale_x_continuous(breaks = seq(240, 600, length.out = 10))

p3 <- ggplot(res, aes(x = wavelength, y = intercept, color = factor(type))) +
  geom_point(size = 0.5) +
  ylab("intercept") +
  labs(color = "Target wl") +
  geom_vline(xintercept = c(254, 350, 440), lty = 2, size = 0.1, color = c("red", "green", "blue")) +
  scale_x_continuous(breaks = seq(240, 600, length.out = 10))

ggsave("graphs/acdom350_vs_cdom_all_wl.pdf", 
       gridExtra::grid.arrange(p1, p2, p3, ncol = 1), 
       height = 10)
