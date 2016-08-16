# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>  
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  PCA based on the metrics.
# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

library(vegan)

rm(list = ls())

# PCA on metrics ----------------------------------------------------------

# http://rpubs.com/sinhrks/plot_pca

metrics <- read_feather("dataset/clean/cdom_metrics.feather") %>% 
  mutate(salinity = ifelse(ecosystem == "lake", 0, salinity)) %>% 
  mutate(salinity = ifelse(ecosystem == "river" & is.na(salinity), 0, salinity))

metrics %>%
  summarise_each(funs(complete = 1 - (length(which(is.na(.))) / nrow(metrics)))) %>%
  gather(variable, complete) %>%
  arrange(desc(complete)) %>%
  filter(complete > 0.2) %>%
  ggplot(aes(x = reorder(variable, complete), y = complete)) +
  geom_bar(stat = "identity")

df2 <- metrics %>%
  filter(study_id != "massicotte2011") %>%
  select(
    # study_id,
    # depth, 
    doc, 
    sr, 
    s, 
    suva254, 
    # suva350, 
    s_275_295,
    s_350_400,
    salinity, 
    ecosystem
  ) %>%
  na.omit() %>% 
  mutate(ecosystem = str_to_title(ecosystem)) 

pca1 <- df2 %>%
  select(-ecosystem) %>% 
  prcomp(., center = TRUE, scale. = TRUE)

summary(pca1)

# Extract PC variance
percent <- summary(pca1)$importance[2, 1:2] * 100

# Extract loadings positions
ll <- as.data.frame(pca1$rotation) %>% 
  tibble::rownames_to_column(.)

ll$rowname <- c(
  "DOC",
  "S[R]",
  "S",
  "SUVA[254]",
  "S[275-295]",
  "S[350-400]",
  "Salinity"
  )

cbPalette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", 
               "#0072B2", "#D55E00", "#CC79A7")

autoplot(pca1, data = df2, 
         colour = "ecosystem", 
         loadings = TRUE, 
         # label = TRUE,
         # label.size = 10,
         # loadings.label = TRUE, 
         # loadings.label.size = 1,
         size = 0.5,
         scale = 0.7) +
  theme(legend.justification = c(0, 1), legend.position = c(0, 1)) +
  xlab(sprintf("PC1 (%2.2f%%)", percent[1])) +
  ylab(sprintf("PC2 (%2.2f%%)", percent[2])) +
  labs(color = "Ecosystems") +
  geom_text_repel(data = ll, 
                  aes(x = PC1, y = PC2, label = rowname), 
                  parse = TRUE, 
                  segment.size = NA,
                  size = 3,
                  fontface = "bold") +
  scale_color_brewer(palette = "Set2") +
  guides(colour = guide_legend(override.aes = list(size = 2)))
  

ggsave("graphs/pca.pdf")
embed_fonts("graphs/pca.pdf")
