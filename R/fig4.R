# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>  
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Figure showing the "global" relation between a350 and DOC.
# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

# Panel A -----------------------------------------------------------------

df <- read_feather("dataset/clean/complete_data_350nm.feather") %>% 
  filter(doc > 30) %>% 
  filter(absorption >= 3.754657e-05)

df2 <- df %>% 
  select(doc, ecosystem, study_id, absorption) %>% 
  mutate(doc = log(doc)) %>% 
  mutate(absorption = log(absorption))

model1 <- lm(absorption ~ log(doc), data = df2)
summary(model1)
exp(range(predict(model1)))

r2 <- paste("R^2== ", round(summary(model1)$r.squared, digits = 2))

pA <- df %>% 
  ggplot(aes(x = doc, y = absorption)) +
  geom_point(color = "gray25", size = 1) +
  scale_x_log10() +
  scale_y_log10() +
  annotation_logticks() +
  geom_smooth(method = "lm", formula = y ~ log(x)) +
  xlab(bquote("Dissolved organic carbon"~(mu*mC%*%L^{-1}))) +
  ylab(bquote("Absorption at 350 nm"~(m^{-1}))) +
  annotate("text", 12000, 0.025, label = r2, vjust = 0, hjust = 0, parse = TRUE) +
  annotate(
    "text",
    Inf,
    Inf,
    label = "A",
    vjust = 1.5,
    hjust = 1.2,
    size = 5,
    fontface = "bold"
  )

# Panel B -----------------------------------------------------------------

df <- read_feather("dataset/clean/complete_data_350nm.feather") %>% 
  filter(doc > 30) %>% 
  filter(absorption >= 3.754657e-05) %>% 
  group_by(ecosystem) %>% 
  nest() %>% 
  filter(purrr::map(data, ~nrow(.)) > 10) %>% 
  mutate(model = purrr::map(data, ~lm(log(.$absorption) ~ log(.$doc), data = .))) %>% 
  unnest(model %>% purrr::map(broom::glance)) %>% 
  mutate(ecosystem = factor(
    ecosystem,
    levels = c(
      "wetland",
      "lake",
      "river",
      "coastal",
      "estuary",
      "ocean"
    ),
    labels = c(
      "Wetland",
      "Lake",
      "River",
      "Coastal",
      "Estuary",
      "Ocean"
    )
  ))

r2 <- df %>% 
  unnest(model %>% purrr::map(broom::tidy))

mean(r2$r.squared)

pB <- df %>% 
  ggplot(aes(x = ecosystem, y = r.squared)) +
  geom_bar(stat = "identity", fill = "gray25") +
  xlab("Ecosystems") +
  ylab(bquote("Determination coefficient"~(R^2))) +
  geom_hline(yintercept = mean(r2$r.squared), lty = 2, color = "gray") +
  annotate(
    "text",
    Inf,
    Inf,
    label = "B",
    vjust = 1.5,
    hjust = 1.2,
    size = 5,
    fontface = "bold"
  ) +
  geom_text(
    aes(label = format(round(r.squared, digits = 2), nsmall = 2)),
    vjust = 4, 
    color = "gray",
    size = 3
  )

# Merge plots -------------------------------------------------------------

p <- cowplot::plot_grid(pA, pB, ncol = 1, align = "hv")
cowplot::save_plot("graphs/fig4.pdf", p, base_height = 7, base_width = 6)
embed_fonts("graphs/fig4.pdf")

# Detailed plots ----------------------------------------------------------

# *************************************************************************
# Plot data (1 file per ecosystem)
# *************************************************************************

myplot <- function(df, ecosystem) {
  
  p <- df %>%
    ggplot(aes(x = doc, y = absorption)) +
    geom_point(aes(color = study_id)) +
    ggtitle(ecosystem) +
    scale_y_log10() +
    scale_x_log10() +
    geom_smooth(method = "lm") +
    annotation_logticks()
  
  fn <- paste0("graphs/", ecosystem, ".pdf")
  ggsave(fn, p)
  
}

map2(df$data, df$ecosystem, myplot)


# *************************************************************************
# Combine graphs into a single file.
# *************************************************************************

files <- list.files("graphs/")
files <- files[files %in% paste0(df$ecosystem, ".pdf")]
files <- paste0("graphs/", files)

cmd <- sprintf("pdftk %s cat output %s", str_c(files, collapse = " "),
               "graphs/ecosystems.pdf")

system(cmd)
unlink(files)

# Supplementary figure ----------------------------------------------------

# rm(list = ls())

r2$ecosystem <- str_to_title(r2$ecosystem)

df <- read_feather("dataset/clean/complete_data_350nm.feather") %>% 
  filter(doc > 30) %>% 
  filter(absorption >= 3.754657e-05) %>% 
  select(ecosystem, doc, absorption) %>% 
  mutate(ecosystem = str_to_title(ecosystem))

df_bg <- df %>% select(-ecosystem)

p <- df %>% 
  ggplot(aes(x = doc, y = absorption)) +
  geom_point(data = df_bg, aes(x = doc, y = absorption), color = "grey85", size = 0.2, alpha = 0.75) +
  geom_point(color = "gray25", size = 0.2) +
  geom_smooth(method = "lm", formula = y ~ log(x), size = 0.5) +
  facet_wrap(~ecosystem, ncol = 2) +
  scale_x_log10(limits = c(10, 100000)) +
  scale_y_log10(limits = c(0.001, 10000)) +
  annotation_logticks(size = 0.2) +
  xlab(bquote("Dissolved organic carbon"~(mu*mC%*%L^{-1}))) +
  ylab(bquote("Absorption at 350 nm"~(m^{-1}))) +
  geom_text(
    data = distinct(r2[, 1:2]),
    aes(
      x = 20,
      y = 1e04,
      label = sprintf("R^2 == %2.2f", r.squared)
    ),
    vjust = 1,
    hjust = 0,
    size = 2.5,
    parse = TRUE
  )

ggsave("graphs/appendix3.pdf", p, width = 5, height = 5)
# embed_fonts("graphs/appendix3.pdf")


# Appendix ----------------------------------------------------------------


df3 <- df2 %>% 
  mutate(predicted = predict(model1)) %>% 
  mutate(residuals = resid(model1))


p1 <- df3 %>% 
  ggplot(aes(x = absorption, y = predicted)) +
  geom_point(size = 0.2) +
  xlab(bquote("Observed absorption at 350 nm"~(m^{-1}))) +
  ylab(bquote("Predicted absorption at 350 nm"~(m^{-1}))) +
  annotation_logticks(side = "bl", size = 0.25) +
  geom_smooth(method = "lm") +
  geom_abline(slope = 1, intercept = 0, col = "red", lty = 2) +
  # annotate("text", -Inf, Inf, label = "A",
  #          vjust = 2, hjust = -2, size = 5, fontface = "bold") +
  facet_wrap(~ecosystem, scale = "free")

p2 <- df3 %>% 
  ggplot(aes(x = absorption, y = residuals)) +
  geom_point(size = 0.2) +
  geom_hline(yintercept = 0, col = "red", lty = 2) +
  annotation_logticks(side = "bl", size = 0.25) +
  xlab(bquote("Observed absorption at 350 nm"~(m^{-1}))) +
  ylab(bquote("Residuals"~(m^{-1}))) +
  # annotate("text", -Inf, Inf, label = "B",
  #          vjust = 2, hjust = -2, size = 5, fontface = "bold") +
  facet_wrap(~ecosystem, scale = "free")

p <- plot_grid(p1, p2, ncol = 1, align = "hv", labels = "AUTO")

save_plot("graphs/appendix4.pdf", p, base_height = 9, base_width = 7)
embed_fonts("graphs/appendix4.pdf")
