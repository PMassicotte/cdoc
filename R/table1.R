
rm(list = ls())


df <- read_feather("dataset/clean/complete_data_350nm.feather") %>% 
  group_by(study_id, source) %>% 
  summarise(n = n(), 
            date_min = as.character(min(date)),
            date_max = as.character(max(date)))


caption = "Summary of data used in this study."

print(xtable::xtable(df, 
                     align = c("llllll"),
                     caption = caption), 
      file = "article/tables/table1.tex", 
      include.rownames = FALSE)
