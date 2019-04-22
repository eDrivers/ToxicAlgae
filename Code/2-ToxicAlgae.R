# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#                                  LIBRARIES
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
library(sf)
library(magrittr)
library(tidyverse)


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#                                    DATA
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
load('./Data/Grids/Data/egslGrid.RData')
load('./data/RawData/asp.RData')
load('./data/RawData/pec.RData')
load('./data/RawData/spi.RData')
load('./data/RawData/dsp.RData')
load('./data/RawData/psp.RData')


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#                                 TOXIC ALGAE
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# NOT A NICE SCRIPT, BUT IT WORKS
# For each toxin, intersect with grid cells
# All dsp symbols are open, thus all values for this toxin will be set to 0.5
# ASP with id == 1 are open symbols --> value = 0.5
# ASP with id == 2 are closed symbols --> value = 1
toxins <- vector('list', 6)
toxNames <- c('psp','spi','pec','dsp','asp')

# Intersect with 1km2 egsl hexagonal grid
toxins[[1]] <- st_intersects(psp, egslGrid) %>% unlist() %>% unique()
toxins[[2]] <- st_intersects(spi, egslGrid) %>% unlist() %>% unique()
toxins[[3]] <- st_intersects(pec, egslGrid) %>% unlist() %>% unique()
toxins[[4]] <- st_intersects(dsp, egslGrid) %>% unlist() %>% unique()
toxins[[5]] <- st_intersects(asp[asp$id == 1, ], egslGrid) %>% unlist() %>% unique()
toxins[[6]] <- st_intersects(asp[asp$id == 2, ], egslGrid) %>% unlist() %>% unique()

# Add to grid
toxic <- egslGrid
toxic$asp <- toxic$dsp <- toxic$pec <- toxic$spi <- toxic$psp <- 0
toxic$psp[toxins[[1]]] <- 1
toxic$spi[toxins[[2]]] <- 1
toxic$pec[toxins[[3]]] <- 1
toxic$dsp[toxins[[4]]] <- 1
toxic$asp[toxins[[5]]] <- 0.5
toxic$asp[toxins[[6]]] <- 1

# Calculate toxin risk
toxic$ToxicAlgae <- rowSums(toxic[, toxNames, drop = T])

# Keep only toxin risk
toxic <- toxic[, 'ToxicAlgae']

# Remove empty cells
toxic <- toxic[toxic$ToxicAlgae > 0, ]


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#                                  EXPORT DATA
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Export object as .RData
save(toxic, file = './Data/Driver/ToxicAlgae.RData')


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#                                 VISUALIZE DATA
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
png('./Figures/ToxicAlgae.png', width = 1280, height = 1000, res = 200, pointsize = 6)
plot(toxic[, 'ToxicAlgae'], border = 'transparent')
dev.off()
