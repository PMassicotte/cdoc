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
  annotate("text", 50, 1000, label = "A",
           vjust = 0, hjust = 2.25, size = 5, fontface = "bold")

# Panel B -----------------------------------------------------------------

df <- read_feather("dataset/clean/complete_data_350nm.feather") %>% 
  filter(doc > 30) %>% 
  filter(absorption >= 3.754657e-05) %>% 
  group_by(ecosystem) %>% 
  nest() %>% 
  filter(purrr::map(data, ~nrow(.)) > 10) %>% 
  mutate(model = purrr::map(data, ~lm(log(.$absorption) ~ log(.$doc), data = .))) %>% 
  unnest(model %>% purrr::map(broom::glance))

r2 <- df %>% 
  unnest(model %>% purrr::map(broom::tidy))

mean(r2$r.squared)

pB <- df %>% 
  ggplot(aes(x = reorder(str_to_title(ecosystem), r.squared), y = r.squared)) +
  geom_bar(stat = "identity", fill = "gray25") +
  xlab("Ecosystems") +
  ylab(bquote("Determination coefficient"~(R^2))) +
  geom_hline(yintercept = mean(r2$r.squared), lty = 2, color = "gray") +
  annotate("text", -Inf, Inf, label = "B",
           vjust = 1.5, hjust = -1, size = 5, fontface = "bold")

# Merge plots -------------------------------------------------------------

p <- cowplot::plot_grid(pA, pB, ncol = 1, align = "hv")
cowplot::save_plot("graphs/fig4.pdf", p, base_height = 6, base_width = 6)

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
  geom_point(color = "gray25", size = 1) +
  geom_smooth(method = "lm", formula = y ~ log(x), size = 0.5) +
  facet_wrap(~ecosystem, ncol = 3) +
  scale_x_log10(limits = c(10, 100000)) +
  scale_y_log10() +
  annotation_logticks(size = 0.2) +
  xlab(bquote("Dissolved organic carbon"~(mu*mC%*%L^{-1}))) +
  ylab(bquote("Absorption at 350 nm"~(m^{-1}))) +
  geom_text(
    data = distinct(r2[, 1:2]),
    aes(
      x = 75,
      y = 1e03,
      label = sprintf("R^2 == %2.2f", r.squared)
    ),
    vjust = 1,
    hjust = 0,
    size = 2.5,
    parse = T
  )

ggsave("graphs/appendix3.pdf", p)
# embed_fonts("graphs/appendix3.pdf")

