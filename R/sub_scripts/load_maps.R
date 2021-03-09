#
# load_maps.R
# loads maps and packages needed to plot them

  #_______________________________________
  # Load mapping & gis packages
  #_______________________________________

  lib_list <- c(
  # these for ggplot mapping:
  "raster",
  "ggspatial",             # used for N arrow and scale bar 
  "sf",                    # used for shapefiles
  "rnaturalearth",         # has more shapefiles; used to make the "world" object 
  "maps",                  # has some state shapefiles, need to be converted with st_as_sf
  "akima",                 # Interpolation of Irregularly and Regularly Spaced Data
  "rnaturalearthdata",
  "rgeos"
  )
  
  # Install missing libraries:
  missing <- setdiff(lib_list, installed.packages()[, 1])
  if (length(missing) > 0) {
    cat(" Loading missing packages, may take 5 mins or less ...\n ")
    cat(" ... \n ")
  
    install.packages(missing)
  }
  
  # Load libraries:
  for(lib in lib_list)
    eval(parse(text=paste("library(",lib,")")))
  
  
  ## same for git libraries
  lib_list_git <- c("rnaturalearthhires") 
  
  missing <- setdiff(lib_list_git, installed.packages()[, 1])
  
  #since each github library has custom address, need to look for each one
  if ("rnaturalearthhires"%in%missing) devtools::install_github("ropensci/rnaturalearthhires")
  
  # Load libraries:
  for(lib in lib_list_git)
    eval(parse(text=paste("library(",lib,")")))
  
  
  #_______________________________________
  # Now get map layers from the web, first time through onlu
  #_______________________________________
  source("R/sub_scripts/Get_map_layers.R")
  
  
  #_______________________________________
  # Read base map layers
  #_______________________________________
  
  # NASA data files: neo.sci.gsfc.nasa.gov
  marble       <-  raster::brick(file.path(geotif_dir,"blue_marble.tif"))
  
  # limit shapefile:
  limit        <-  sf::st_read(file.path(shp_dir,"global/CNTR_RG_03M_2014/CNTR_RG_03M_2014.shp"))
  ocean110     <-  sf::st_read(file.path(shp_dir,"global/natural_earth_vector/110m_physical/ne_110m_ocean.shp"))
  ocean50      <-  sf::st_read(file.path(shp_dir,"global/natural_earth_vector/50m_physical/ne_50m_ocean.shp"))
  
  bathy1000    <-  sf::st_read(file.path(shp_dir,"global/ne_10m_bathymetry_J_1000/ne_10m_bathymetry_J_1000.shp"))
  bathy200     <-  sf::st_read(file.path(shp_dir,"global/ne_10m_bathymetry_K_200/ne_10m_bathymetry_K_200.shp"))
  ocean_bot    <-  raster::brick(file.path(geotif_dir,"OB_LR/OB_LR.tif"))
  
  # rnaturalearth files
  world 		   <-  rnaturalearth::ne_countries(scale = "medium", returnclass = "sf") 
  # class(world)
  world        <-  sf::st_as_sf(map('world', plot = FALSE, fill = TRUE))
  #world     
  world_df     <-  map_data("world")
  states 		   <-  rnaturalearth::ne_states(country = c('United States of America',"Canada","Mexico"), returnclass = "sf" ) ; class(states)
  
  #_______________________________________
  # Now set up some things
  #_______________________________________
  
  # set up epsg 
  #-------------------------------------------
  epsg_bering       <- 3571  #(WGS84)
  epsg_NAM          <- 4269
  epsg_arctic       <- 3995
  epsg_antarctic    <- 3031
  arctic_lat_lim    <- 45
  antarctic_lat_lim <- -40
  
  crs_bering        <-  paste0("+init=epsg:",epsg_bering)
  crs_arctic        <-  paste0("+init=epsg:",epsg_arctic)
  crs_antarctic     <-  paste0("+init=epsg:",epsg_antarctic)
  
  arctic_extent     <- c(-180,180,45,90)
  antarctic_extent  <- c(-180,180,-88,-45)
  
  
  # set up preferred projections
  #-------------------------------------------
  polar_proj        <- ""
  nam_proj          <- ""
  
  # coordinate systems
  #-------------------------------------------
  bering_coord   <-  CRS("+init=epsg:3571")
  polar_coord    <-  CRS("+init=epsg:3995")
  longlat_coord  <-  CRS("+init=epsg:4326")
  NAM_coord      <-  CRS("+init=epsg:4269")
  #EPSG           <-  rgdal::make_EPSG()
  
  # base maps
  #-------------------------------------------
  bering_land       <-  limit[limit$CNTR_ID%in%c("RU", "US", "CA" ),]%>% st_transform(epsg_bering)
  bering_countries  <-  world[world$ID%in%c("Norway","Sweden", "Finland", "Russia", "USA", "Canada" , "Greenland", "Iceland" ),]
  bering_land       <- sf::st_buffer(bering_land, dist = 0)
  
  bering_ocean110   <- ocean110 %>% st_transform(epsg_bering)
  bering_ocean110   <- sf::st_buffer(bering_ocean110, dist = 0)
  #  bering_ocean110   <- st_intersection( st_transform(bering_ocean110,crs=crs_bering),st_transform(ring_N,crs=crs_bering))
  
  # Arctic shapfile of land masses:
  bering_sf         <- sf::st_as_sf(
    sp::spTransform(
      raster::crop(ne_countries(scale = "large", type = 'map_units'),
                   clip_spdt(lon_lim=c(-143,-180),lat_lim=c(52,70)) ), sp::CRS(crs_bering)))
  #bering_sf         <- st_intersection( st_transform(bering_sf,crs=crs_bering),st_transform(ring_N,crs=crs_bering))
  
  
  # same but as outlines:
  bering_l          <- bering_sf%>%st_cast("MULTILINESTRING")
  



