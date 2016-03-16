files <- list.files("dataset/clean/literature/", full.names = TRUE)
data <- lapply(files, readRDS)


# f <- function(x, file) {
#   x <- spread(x, wavelength, acdom)
# 
#   fname <- paste("/media/persican/Philippe Massicotte/Phil/Dropbox/project doc cdom/doc/to validate/", tools::file_path_sans_ext(basename(file)), ".csv", sep = "")
# 
#   write_csv(x, fname)
# }
# 
# mapply(f, data, files)

minimal_variables <- c("acdom", "doc", "wavelength", "study_id", "sample_id", 
                       "longitude", "latitude", "ecotype")

context("Test common variables")

test_that("Has all minimal set of variables", {
  
  expect_true(all(Reduce(intersect, lapply(data, names)) %in% minimal_variables))
  
})

test_that("Has appropriate numerical values", {
  
  expect_true(all(unlist(lapply(data, function(x){class(x$doc)})) %in% c("numeric", "integer")))
  
  # All DOC and cdom values should be greater than 0
  expect_true(all(unlist(lapply(data, function(x){x[, c("doc", "acdom")]})) > 0))
  
})

test_that("Has no NA", {
  
  # No NA in all minimal variables
  expect_false(any(unlist(lapply(data, function(x){is.na(x[, minimal_variables])}))))

})
