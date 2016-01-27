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
# Read and process "raw" CDOM datasets. All scripts with "cdom" in 
# their name mean that we have complete spectra + the DOC.
#---------------------------------------------------------------------
source("R/processing/process_cdom_colin.R")
source("R/processing/process_cdom_asmala2014.R")

