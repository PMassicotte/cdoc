# setup -------------------------------------------------------------------

library(cshapes)
library(gpclib)
library(maptools)
library(rgeos)
library(rgdal)
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
library(testthat)

## Clean the workspace
rm(list = ls())

graphics.off()

## Set default ggplot2 font size and font family
loadfonts(quiet = TRUE)
theme_set(theme_bw(base_size = 12, base_family = "Open Sans"))


# processing --------------------------------------------------------------

# ---------------------------------------------------------------------
# Read and process 'raw' CDOM and DOC datasets.  The
# following scripts clean CDOM data and merge it with DOC.
# These can be executed only if the data changes.
# ---------------------------------------------------------------------
unlink("tmp/", recursive = TRUE)
dir.create("tmp/")

unlink("graphs/datasets/", recursive = TRUE)
dir.create("graphs/datasets")

unlink("dataset/clean/", recursive = TRUE)
dir.create("dataset/clean/literature/", recursive = TRUE)
dir.create("dataset/clean/complete_profiles/", recursive = TRUE)

files <- list.files("R/processing/", "process*", full.names = TRUE)
lapply(files, source)

source("R/processing/merge_cdom_datasets.R")
source("R/processing/merge_literature_datasets.R")
source("R/calculate_cdom_metrics.R")
source("R/processing/clean_data.R")

# ---------------------------------------------------------------------
# Some tests to validate the data.
# ---------------------------------------------------------------------
test_dir("R/tests/testthat/")

# ---------------------------------------------------------------------
# Statistical analysis and visualisation of the data.
# ---------------------------------------------------------------------
source("R/plot_map.R")

# source('R/visualize_cdom_metrics.R')
