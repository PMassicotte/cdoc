lm_eqn = function(m) {
  
  l <- list(a = format(coef(m)[1], digits = 2),
            b = format(abs(coef(m)[2]), digits = 2),
            r2 = format(summary(m)$r.squared, digits = 2));
  
  if (coef(m)[2] >= 0)  {
    eq <- substitute(italic(y) == a + b %.% italic(x)*","~~italic(R)^2~"="~r2,l)
  } else {
    eq <- substitute(italic(y) == a - b %.% italic(x)*","~~italic(R)^2~"="~r2,l)    
  }
  
  as.character(as.expression(eq));                 
}


# http://stackoverflow.com/questions/21708488/get-country-and-continent-from-longitude-and-latitude-point-in-r
library(rworldmap)

# The single argument to this function, points, is a data.frame in which:
#   - column 1 contains the longitude in degrees
#   - column 2 contains the latitude in degrees
coords2continent = function(long, lat)
{  
  
  points <- data_frame(long = long, lat = lat)
  
  countriesSP <- getMap(resolution='high')
  #countriesSP <- getMap(resolution='high') #you could use high res map from rworldxtra if you were concerned about detail
  
  # converting points to a SpatialPoints object
  # setting CRS directly to that from rworldmap
  pointsSP = SpatialPoints(points, proj4string=CRS(proj4string(countriesSP)))  
  
  
  # use 'over' to get indices of the Polygons object containing each point 
  indices = over(pointsSP, countriesSP)
  
  #indices$continent   # returns the continent (6 continent model)
  as.character(indices$REGION)   # returns the continent (7 continent model)
  # as.character(indices$ADMIN)  #returns country name
  #indices$ISO3 # returns the ISO3 code 
}