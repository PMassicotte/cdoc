library(readr)
library(readxl)
library(dplyr)
library(ggplot2)
library(gridExtra)
library(tidyr)
library(stringr)
library(extrafont)
library(haven)
library(R.matlab)
library(cdom)
library(purrr)

## Clean the workspace
rm(list = ls())

graphics.off()

## Set default ggplot2 font size and font family
loadfonts(quiet = TRUE)
theme_set(theme_bw(base_size = 12, base_family = "Open Sans"))

#---------------------------------------------------------------------
# Read and process "raw" CDOM and DOC datasets.
#  
# The following scripts clean CDOM data and merge it with DOC.
# 
# These can be executed only if the data changes.
#---------------------------------------------------------------------

unlink("graphs/datasets/", recursive = TRUE)
dir.create("graphs/datasets")

files <- list.files("R/processing/", "process*", full.names = TRUE)
lapply(files, source)

source("R/processing/merge_cdom_datasets.R")
source("R/processing/merge_literature_datasets.R")

source("R/count_spectra_per_study.R")

#---------------------------------------------------------------------
# Statistical analysis and visualisation of the data.
#---------------------------------------------------------------------

# source("R/calculate_cdom_metrics.R")
# source("R/visualize_cdom_metrics.R")