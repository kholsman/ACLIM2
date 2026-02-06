# ----------------------------------------
# packages.R
# load or install packages
# subset of Holsman et al. 2020 ACLIM Simulations
# kirstin.holsman@noaa.gov
# updated 2020
# ----------------------------------------

lib_list <- c(
  # these for reshaping and manipulating data:
    "ncdf4",
    "devtools",
   # "ncfd",
    "magrittr",
    "httr",
    "reshape",
    "dplyr", 
    "purrr",
    "readxl", 
    "tidyverse",
   "shiny",
   "fuzzyjoin",
   # Matt C's packages
   "magrittr",
   "httr",
   "jsonlite",
    
  # # these for ggplot mapping:
  #   "raster",
  #   "ggspatial",             # used for N arrow and scale bar 
  #   "sf",                    # used for shapefiles
  #   "rnaturalearth",         # has more shapefiles; used to make the "world" object 
  #   "maps",                  # has some state shapefiles, need to be converted with st_as_sf
  #   "akima",                 # Interpolation of Irregularly and Regularly Spaced Data
  # 
    
  # markdown stuff:
    "knitr",
    "kableExtra",
    
  # These for making plots:
    "ggnewscale",
    "RColorBrewer",
    "ggplot2", 
    "mgcv",
    "cowplot",               # 
    "wesanderson",
    "scales",
    "ggforce",
    "grid",
    "processx",
    "plotly",
    "extrafont"
  )

# Install missing libraries:
missing <- setdiff(lib_list, installed.packages()[, 1])
if (length(missing) > 0) install.packages(missing)

# Load libraries:
for(lib in lib_list)
       eval(parse(text=paste("library(",lib,")")))

## same for git libraries
lib_list_git <- c(
#  "rnaturalearthhires",
  "thredds"
  )


missing <- setdiff(lib_list_git, installed.packages()[, 1])

if (length(missing) > 0) devtools::install_github("bocinsky/thredds")
# if ("rnaturalearthhires"%in%missing) devtools::install_github("ropensci/rnaturalearthhires")

# Load libraries:
for(lib in lib_list_git)
  eval(parse(text=paste("library(",lib,")")))

