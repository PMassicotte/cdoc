path <- "../../../dataset/clean/cdom_dataset.feather"
# print(path)
cdom_doc <- read_feather(path)

context("Test that unique_id is really unique")

test_that("No duplicate in unique_id", {
  
  res <- group_by(cdom_doc, wavelength, unique_id) %>% 
    summarise(n = n()) %>% 
    filter(n > 1)
  
  expect_true(nrow(res) == 0)
  
})
