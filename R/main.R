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

# source("R/processing/process_cdom_doc_colin.R")
# source("R/processing/process_cdom_doc_asmala2014.R")
# source("R/processing/process_cdom_doc_massicotte2011.R")

# source("R/merge_datasets.R")

# source("R/count_spectra_per_study.R")

