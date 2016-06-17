# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>  
# AUTHOR:       Philippe Massicotte
#
# DESCRIPTION:  This function uses salinity to determine the ecosystem.
# <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

classify <- function(x) {
  
  if (is.na(x)) {return(NA)}
  
  if (x <= 0.5) {
    return("river")
  } else if (x > 0.5 & x <= 5) {
    return("estuary")
  } else if (x > 5 & x <= 30) {
    return("coastal")
  } else if (x > 30) {
    return("ocean")
  } else {
    return(NA)
  }
  
}

salinity2ecosystem <- function(salinity) {
  
  stopifnot(all(is.numeric(salinity)))
  
  res <- unlist(lapply(salinity, classify))
  
  return(res)
  
}

# salinity <- c(0.2, 4, 6, 32, NA)
# 
# tt <- salinity2ecosystem(salinity)
