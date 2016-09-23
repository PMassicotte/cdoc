#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  Small script to calculate how many observations we have for 
#               variables.
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

res <- read_feather("dataset/clean/complete_data_350nm.feather") %>% 
  summarise_each(funs(sum(!is.na(.)))) %>% 
  gather(variable, n) %>% 
  arrange(desc(n)) %>% 
  mutate(percent = n / max(n) * 100)

# write_csv(res, "/home/persican/Desktop/variables.csv")
