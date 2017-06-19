rm(list = ls())

df <- read_feather("dataset/clean/complete_data_350nm.feather") %>% 
  filter(absorption >= 3.754657e-05) %>% # Clear outliers
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
  )) %>% 
  mutate(absorbance = (absorption * 0.01) / 2.303) %>%
  mutate(suva350 = absorbance / (doc / 1000) * 12)

# Quantile values (asked for the paper review)
quantile(df$doc, probs = c(0.05, 0.95))

## Coefficient of variation (comment C19)
res <- df %>% 
  select(ecosystem, absorption, doc, suva350) %>% 
  gather(variable, value, -ecosystem) %>% 
  group_by(ecosystem, variable) %>% 
  summarise(cv = round(raster::cv(value), digits = 2)) %>% 
  arrange(variable, cv)


# Plot --------------------------------------------------------------------

p1 <- df %>% 
  ggplot(aes(x = ecosystem, y = absorption)) +
  geom_boxplot(size = 0.1, outlier.size = 0.5, fill = "grey75") +
  xlab("Ecosystem") +
  scale_y_log10() +
  annotation_logticks(side = "l") +
  ylab(bquote(a[CDOM](350)~(m^{-1}))) +
  theme(axis.ticks.x = element_blank()) +
  theme(axis.title.x = element_blank()) +
  theme(axis.text.x = element_blank()) +
  annotate(
    "text",
    Inf,
    Inf,
    label = "A",
    vjust = 2,
    hjust = 2,
    size = 5,
    fontface = "bold"
  ) +
  scale_x_discrete(expand = c(0.05, 0.05)) +
  geom_text(
    data = filter(res, variable == "absorption"),
    aes(x = ecosystem, y = 1e-3, label = cv),
    inherit.aes = FALSE,
    size = 3
  )

p2 <- df %>% 
  ggplot(aes(x = ecosystem, y = doc)) +
  geom_boxplot(size = 0.1, outlier.size = 0.5, fill = "grey75") +
  xlab("Ecosystem") +
  scale_y_log10() +
  annotation_logticks(side = "l") +
  ylab(bquote(DOC~(mu*mol~C%*%L^{-1}))) +
  theme(axis.ticks.x = element_blank()) +
  theme(axis.title.x = element_blank()) +
  theme(axis.text.x = element_blank()) +
  annotate(
    "text",
    Inf,
    Inf,
    label = "B",
    vjust = 2,
    hjust = 2,
    size = 5,
    fontface = "bold"
  ) +
  scale_x_discrete(expand = c(0.05, 0.05)) +
  geom_text(
    data = filter(res, variable == "doc"),
    aes(x = ecosystem, y = 10, label = cv),
    inherit.aes = FALSE,
    size = 3
  )

p3 <- df %>% 
  ggplot(aes(x = ecosystem, y = suva350)) +
  geom_boxplot(size = 0.1, outlier.size = 0.5, fill = "grey75") +
  xlab("Ecosystems") +
  scale_y_log10(bquote(SUVA[350]~(m^2%*%g~C^{-1})), 
                sec.axis = sec_axis(~. * 27.64, breaks = c(0, 1, 10, 100), 
                name = bquote(a^"*"*~(m^2%*%mol~C^{-1})))) +
  annotation_logticks(side = "l") +
  # ylab(bquote(SUVA[350]~(L%*%mgC^{-1}%*%m^{-1}))) +
  annotate(
    "text",
    Inf,
    Inf,
    label = "C",
    vjust = 2,
    hjust = 2,
    size = 5,
    fontface = "bold"
  ) +
  scale_x_discrete(expand = c(0.05, 0.05)) +
  theme(axis.text.x = element_text(size = 8)) +
  geom_text(
    data = filter(res, variable == "suva350"),
    aes(x = ecosystem, y = 0.003, label = cv),
    inherit.aes = FALSE,
    size = 3
  )

p4 <- data.frame(x = 0:1, y = c(0.5, 0.5)) %>%
  ggplot(aes(x = x, y = y)) +
  geom_path(size = 2,
            arrow = arrow(type = "closed", length = unit(0.25, "inches"))) +
  annotate(
    "text",
    x = 0,
    y = 0.51,
    label = "Freshwater",
    hjust = -0.05,
    fontface = "bold",
    size = 5
  ) +
  annotate(
    "text",
    x = 1,
    y = 0.51,
    label = "Marine water",
    hjust = 1.25,
    fontface = "bold",
    size = 5
  ) +
  theme(
    axis.line = element_blank(),
    axis.text.x = element_blank(),
    axis.text.y = element_blank(),
    axis.ticks = element_blank(),
    axis.title.x = element_blank(),
    axis.title.y = element_blank(),
    legend.position = "none",
    panel.background = element_blank(),
    panel.border = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    plot.background = element_blank()
  ) +
  coord_cartesian(ylim = c(0.49, 0.52))

p <- cowplot::plot_grid(
  p1,
  p2,
  p3,
  p4,
  ncol = 1,
  align = "hv",
  rel_heights = c(1, 1, 1, 0.35)
)

cowplot::save_plot(
  "graphs/fig3.pdf",
  p,
  base_height = 10,
  base_width = 5
)

embed_fonts("graphs/fig3.pdf")

# Some stats --------------------------------------------------------------

df %>% group_by(ecosystem) %>% summarise(x = median(absorption))
df %>% group_by(ecosystem) %>% summarise(x = median(doc))
df %>% group_by(ecosystem) %>% summarise(x = median(suva350))

df %>% 
  filter(ecosystem %in% c("River", "Wetland", "Lake", "Pond")) %>% 
  mutate(m = median(suva350)) %>% 
  distinct(m)
  
df %>% 
  filter(ecosystem %in% c("Coastal", "Estuary", "Ocean")) %>% 
  mutate(m = median(suva350)) %>% 
  distinct(m)


# ANOVA tables ------------------------------------------------------------

mod <- df %>%
  select(ecosystem, absorption, doc, suva350) %>%
  gather(variable, value, -ecosystem) %>%
  group_by(variable) %>%
  nest() %>%
  mutate(aov = map(data, ~aov(value ~ ecosystem, data = .))) %>% 
  mutate(tukey = map(aov, TukeyHSD))

## aCDOM350

caption = "Tukey Honest Significant Differences between the means of $a_{\\text{CDOM}}(350)$ among ecosystems (See Fig. 3A)."

print(
  xtable::xtable(broom::tidy(mod$tukey[[1]])[, 2:6], caption = caption),
  file = "article/tables/tukey_acdom.tex",
  include.rownames = FALSE,
  sanitize.text.function = function(x) {
    x
  }
)

caption = "Anova results of $a_{\\text{CDOM}}(350)$ among ecosystems (See Fig. 3A)."

print(
  xtable::xtable(summary(mod$aov[[1]]), caption = caption),
  file = "article/tables/anova_acdom.tex",
  include.rownames = FALSE,
  sanitize.text.function = function(x) {
    x
  }
)


## DOC

caption = "Tukey Honest Significant Differences between the means of DOC among ecosystems (See Fig. 3B)."

print(
  xtable::xtable(broom::tidy(mod$tukey[[2]])[, 2:6], caption = caption),
  file = "article/tables/tukey_doc.tex",
  include.rownames = FALSE,
  sanitize.text.function = function(x) {
    x
  }
)

caption = "Anova results of DOC among ecosystems (See Fig. 3A)."

print(
  xtable::xtable(summary(mod$aov[[2]]), caption = caption),
  file = "article/tables/anova_doc.tex",
  include.rownames = FALSE,
  sanitize.text.function = function(x) {
    x
  }
)

## suva350

caption = "Tukey Honest Significant Differences between the means of $\\text{SUVA}_{350}$ among ecosystems (See Fig. 3C)."

print(
  xtable::xtable(broom::tidy(mod$tukey[[3]])[, 2:6], caption = caption),
  file = "article/tables/tukey_suva350.tex",
  include.rownames = FALSE,
  sanitize.text.function = function(x) {
    x
  }
)

caption = "Anova results of $\\text{SUVA}_{350}$ among ecosystems (See Fig. 3A)."

print(
  xtable::xtable(summary(mod$aov[[3]]), caption = caption),
  file = "article/tables/anova_suva350.tex",
  include.rownames = FALSE,
  sanitize.text.function = function(x) {
    x
  }
)
