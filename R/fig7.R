rm(list = ls())


# Make a model to predict MW ----------------------------------------------

stedmon2015 <- read_csv("dataset/data_figure_10_4_stedmon2015.csv") %>% 
  mutate(s = s / 1000) %>% 
  filter(mw > 525) # Remove 1 outlier

nls1 <- stedmon2015 %>% 
  nls(mw ~ a * s^b, data = ., start = list(a = 1000, b = -1))

stedmon2015 %>% 
  mutate(predicted_mw = predict(nls1)) %>% 
  ggplot(aes(x = s, y = mw)) +
  geom_point() +
  geom_line(aes(y = predicted_mw), color = "red ") +
  xlab(bquote(S[300-600]~(nm^{-1}))) +
  ylab("Molecular weight (Dalton)") +
  xlim(0.008, 0.022)
  
ggsave("graphs/appendix4.pdf")
embed_fonts("graphs/appendix4.pdf")

# Predict MW --------------------------------------------------------------

get_s <- function(x) {
  
  s <- coef(x)[1]
  
  s <- data.frame(s = s)
  
  return(s)
  
}

cdom_metrics <- read_feather("dataset/clean/cdom_dataset.feather") %>%
  select(doc, wavelength, absorption, unique_id, ecosystem) %>% 
  group_by(unique_id) %>% 
  nest() %>% 
  mutate(s_300_600 = purrr::map(data, 
                                ~ cdom_exponential(absorbance = .$absorption,
                                                   wl = .$wavelength,
                                                   startwl = 300,
                                                   endwl = 600))) %>% 
  unnest(s_300_600 %>% purrr::map(get_s)) %>% 
  mutate(mw = predict(nls1, newdata = list(s = s))) %>% 
  unnest(data) %>% 
  select(-wavelength, -absorption) %>% 
  distinct()
  


# Plot --------------------------------------------------------------------

cdom_metrics %>% 
  ggplot(aes(x = reorder(str_to_title(ecosystem), mw, FUN = median), y = mw)) +
  geom_boxplot(size = 0.1, outlier.size = 0.5, fill = "grey75") +
  ylab("Molecular weight (Dalton)") +
  xlab("Ecosystems")

ggsave("graphs/fig7.pdf")
embed_fonts("graphs/fig7.pdf")
