#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         graphs_acdom350_vs_cdom_all_wl.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Explore the relation between aCDOM350 and aCDOM at various
#               wavelengths.
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
rm(list = ls())

cdom_doc <- readRDS("dataset/clean/cdom_dataset.rds") %>%
  filter(study_id != "nelson") %>% # Nelson is missing wl < 275
  select(unique_id, wavelength, absorption) %>%
  spread(wavelength, absorption) %>% 
  select(-unique_id)

get_data <- function(wl, cdom_doc) {
  
  y <- select(cdom_doc, contains(as.character(wl)))
  
  
  res <- map2(y, cdom_doc, ~ lm(.y ~ .x)) 
  
  
  stats <- res %>% map(broom::glance) %>% 
    bind_rows() %>% 
    mutate(wavelength = extract_numeric(names(cdom_doc))) %>% 
    mutate(type = wl)
  
  coefs <- res %>% map_df(~ as.data.frame(t(as.matrix(coef(.)))))
  names(coefs) <- c("intercept", "slope")
  
  df <- bind_cols(stats, coefs)
  
  return(df)
}

res254 <- get_data(wl = 254, cdom_doc)
res350 <- get_data(wl = 350, cdom_doc) 
res440 <- get_data(wl = 440, cdom_doc)

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
