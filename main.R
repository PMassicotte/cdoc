library(readr)
library(readxl)
library(dplyr)
library(ggplot2)
library(gridExtra)
library(tidyr)
library(stringr)
library(extrafont)

## Clean the workspace
rm(list = ls())

graphics.off()

## Set default ggplot2 font size and font family
loadfonts(quiet = TRUE)
theme_set(theme_bw(base_size = 12, base_family = "Ubuntu"))

rm(list = ls())