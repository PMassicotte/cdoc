#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# FILE:         plot_doc_vs_cdom.R
#
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Plot the relationship between CDOM and DOC for all datasets
#               were we have complete CDOM profiles.
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rm(list = ls())

dana12 <- readRDS("dataset/clean/stedmon/dana12.rds")
