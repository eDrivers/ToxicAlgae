# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#                                     LIBRARIES
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
library(sf)
library(sp)
library(rgdal)
library(magrittr)
library(tidyverse)

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#                                   DOWNLOAD DATA
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The data used to characterize comes from DFO in the form of an expert map that
# was digitized and georeferenced.
# For more information read the repo's README.md document.

# Output location for downloaded data
output <- './Data/RawData'

# Data will need to be archived to Zenodo with restricted access and downloaded
# using an access token.
# Eventually it would ideally be part of the SLGO web portal


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#                                   IMPORT DATA
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# File name
fileName <- dir(output, pattern = '.zip')

# Unzip kmz file
unzip(zipfile = paste0(output, '/', fileName),
      exdir = output)

# Get georeferenced data and transform projection
asp <- readOGR(dsn = paste0(output, '/'), layer = "asp") %>%
       st_as_sf() %>%
       st_transform(crs = 32198)

pec <- readOGR(dsn = paste0(output, '/'), layer = "pectenotoxin") %>%
       st_as_sf() %>%
       st_transform(crs = 32198)

psp <- readOGR(dsn = paste0(output, '/'), layer = "psp") %>%
       st_as_sf() %>%
       st_transform(crs = 32198)

spi <- readOGR(dsn = paste0(output, '/'), layer = "spirolides") %>%
       st_as_sf() %>%
       st_transform(crs = 32198)

dsp <- readOGR(dsn = paste0(output, '/'), layer = "dsp") %>%
       st_as_sf() %>%
       st_transform(crs = 32198)


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#                                   FORMAT DATA
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Buffered points
buf <- 15000
asp <- st_buffer(asp, buf)
pec <- st_buffer(pec, buf)
spi <- st_buffer(spi, buf)
dsp <- st_buffer(dsp, buf)

# Clip areas with St. Lawrence
load('./Data/Grids/Data/egslSimple.RData')
asp <- st_intersection(asp, egslSimple)
pec <- st_intersection(pec, egslSimple)
spi <- st_intersection(spi, egslSimple)
dsp <- st_intersection(dsp, egslSimple)
psp <- st_intersection(psp, egslSimple)



# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#                                   EXPORT DATA
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
save(asp, file = './data/RawData/asp.RData')
save(pec, file = './data/RawData/pec.RData')
save(spi, file = './data/RawData/spi.RData')
save(dsp, file = './data/RawData/dsp.RData')
save(psp, file = './data/RawData/psp.RData')
