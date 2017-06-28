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
  
ggsave("graphs/stedmon2015.pdf")
embed_fonts("graphs/stedmon2015.pdf")

# Predict MW --------------------------------------------------------------

nls_fit <- function(df) {
  
  mod <- minpack.lm::nlsLM(absorption ~ a0 * exp(-s * (wavelength - 350)) + k,
                           data = df,
                           start = c(s = 0.02, a0 = 5, k = 0))
  return(mod)
}

cdom_metrics <- read_feather("dataset/clean/cdom_dataset.feather") %>%
  filter(wavelength >= 300 & wavelength <= 600) %>% 
  select(doc, wavelength, absorption, unique_id, ecosystem) %>% 
  group_by(unique_id, ecosystem) %>% 
  nest() 

cdom_metrics <- cdom_metrics %>%
  mutate(mod_300_600 = purrr::map(data, nls_fit)) %>% 
  mutate(coef = map(mod_300_600, broom::tidy)) %>% 
  unnest(coef) %>% 
  filter(term == "s")

cdom_metrics <- cdom_metrics %>%
  mutate(mw = coef(nls1)[1] * estimate^coef(nls1)[2])

# Plot --------------------------------------------------------------------

cdom_metrics %>% 
  mutate(ecosystem = factor(ecosystem, c("ocean", "coastal", "estuary", "river", "lake"))) %>% 
  ggplot(aes(x = ecosystem, mw, y = mw)) +
  geom_boxplot(outlier.size = 0.5) +
  ylab("Molecular weight (Dalton)") +
  xlab("Ecosystems")

ggsave("graphs/molecular_weight.pdf")

# ggsave("graphs/fig7.pdf")
# embed_fonts("graphs/fig7.pdf")

cdom_metrics %>% 
  ggplot(aes(x = mw, fill = ecosystem)) +
  geom_histogram() +
  facet_wrap(~ecosystem)
