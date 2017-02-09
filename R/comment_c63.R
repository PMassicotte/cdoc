read_feather("dataset/clean/complete_data_350nm.feather") %>% 
  filter(ecosystem == "wetland") %>% 
  select(study_id) %>% 
  distinct()
