#path <- "../../../dataset/clean/literature_datasets.feather"
path <- "dataset/clean/literature_datasets.feather"
literature_datasets <- read_feather(path)

#path <- "../../../dataset/clean/cdom_dataset.feather"
path <- "dataset/clean/cdom_dataset.feather"
complete_dataset <- read_feather(path)

# f <- function(x, file) {
#   x <- spread(x, wavelength, acdom)
# 
#   fname <- paste("/media/persican/Philippe Massicotte/Phil/Dropbox/project doc cdom/doc/to validate/", tools::file_path_sans_ext(basename(file)), ".csv", sep = "")
# 
#   write_csv(x, fname)
# }
# 
# mapply(f, data, files)

minimal_variables <- c("absorption", "doc", "wavelength", "study_id", "unique_id", 
                       "longitude", "latitude", "ecotype")

numeric_variables <- c("absorption", "doc", "wavelength", "longitude", 
                       "latitude")

context("Test common variables")

test_that("Has all minimal set of variables", {
  
  expect_true(all(minimal_variables %in% names(literature_datasets)))
  expect_true(all(minimal_variables %in% names(complete_dataset)))
  
})

test_that("Has appropriate numerical values", {
  
  expect_true(all(unlist(lapply(literature_datasets[, numeric_variables], class)) %in% "numeric"))
  expect_true(all(unlist(lapply(complete_dataset[, numeric_variables], class)) %in% "numeric"))
  
  # All DOC and cdom values should be greater than 0
  expect_true(all(literature_datasets[, c("doc", "absorption")] > 0))
  
})

test_that("Has no NA", {
  
  # No NA in all minimal variables
  expect_false(any(is.na(literature_datasets[, minimal_variables])))
  expect_false(any(is.na(complete_dataset[, minimal_variables])))

})
