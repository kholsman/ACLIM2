# ----------------------------------------
# load_data.R
# subset of Holsman et al. 2020 Nature Comm.
# kirstin.holsman@noaa.gov
# updated 2020
# ----------------------------------------
  #cat("loading data, this may take a few mins...")
  NEBS_strata <- c(71,70,81,82,90)
  SEBS_strata <- c(10,20,31,32,50,
                   20,41,42,43,61,62)
  
  if(update_base_data) 
    source("R/sub_scripts/update_base_data.R")
  
  load(file.path(shareddata_path,"base_data.Rdata"))
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
  
    
  #mod_lkup <- readxl::read_xlsx(file.path(in_dir,"aclim_qry_ControlFile.xlsx"),sheet="models")
  #var_lkup <- readxl::read_xlsx(file.path(in_dir,"aclim_qry_ControlFile.xlsx"),sheet="variables")
  
  #_______________________________________
  # Load ROMSNPZ covariates:
  #_______________________________________
  # 
  # load(file.path(in_dir,"covariates.Rdata"))
  # 
  # Scenarios     <-  unique(covariates$Scenario)
  # A1B_n         <-  grep("A1B",Scenarios)
  # bio_n         <-  grep("bio",Scenarios)
  # rcp45_n       <-  grep("rcp45",Scenarios)
  # rcp85_n       <-  grep("rcp85",Scenarios)
  # rcp85NoBio_n  <-  setdiff(rcp85_n,bio_n)
  # plotList      <-  Scenario_set  <- c(1,rcp45_n,rcp85NoBio_n)
  # esnm          <-  list(c(rcp45_n,rcp85NoBio_n))
  # esmlist       <-  list(rcp45_n,rcp85NoBio_n)
  # 
  #_______________________________________
  # Load simulations:
  #_______________________________________
  # 
  # if( update.outputs ){
  #   cat(paste0("\nLoading Intermediate data ('",in_dir,"')...\n"))
  #   for(fn in infn){
  #     if(!any(dir(in_dir)%in%fn))
  #       stop(paste0(fn," file not found in: \t \t",in_dir,
  #                   "\n\nplease go to: https://figshare.com/s/6dea7722df39e07d79f0","",
  #                   "\n\nand download file into: \t \t",in_dir,"/",fn))
  #     load(file.path(in_dir,fn))
  #     cat(paste("\nloaded",fn))
  #   }
  #   cat(paste0("\nIntermediate data loaded  ('",in_dir,"')...\n"))
  #   
  #   if(!file.exists(out_dir))
  #     dir.create(out_dir)
  #   compile.natcommruns(out=out_dir,savelist= outfn)
  #   update.outputs  <-  FALSE
  # }
  #   cat(paste0("\nLoading final data ('",out_dir,"')...\n"))
  #   for(fn in outfn){
  #     if(!any(dir(out_dir)%in%paste0(fn,".Rdata")))
  #       stop(paste0(fn," file not found in: \t \t",out_dir,
  #                   "\n\nplease go to: https://figshare.com/s/6dea7722df39e07d79f0","",
  #                   "\n\nand download file into: \t \t",in_dir," and re-run the R/make.R script"))
  #     load(file.path(out_dir,paste0(fn,".Rdata")))
  #     cat(paste("\nloaded:",fn))
  #   }
  #   cat(paste0("\n\nfinal data loaded('",out_dir,"')...\n"))
  #   
  # 
  #   
  #   simnames  <- Scenarios
  #   Years     <- sort(unique(msm_noCap$future_year)+start_yr-1)
  #   nYrsTot   <- length(Years )

# subset of downscaled projections used for the paper = Scenario_set
# bio runs are a sensitivity set of runs to evaluate nutrient forcing
# of boundary conditions, not used here bc they are highly similar to 
# non-bio runs (See Kearney et al. 2020 and Hermann et al. 2019 for more info
# A1B not used bc they were AR4 runs and only went to 2040
# print(as.character(Scenarios[Scenario_set]))
# ACLIM Projection simulations
# "###########################################################"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
# [1]  "#  | mn_Hind"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   
# [2]  "#  | MIROC_A1B"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
# [3]  "#  | ECHOG_A1B"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
# [4]  "#  | CCCMA_A1B"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
# [5]  "#  | GFDL_rcp45"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
# [6]  "#  | GFDL_rcp85"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
# [7]  "#  | GFDL_rcp85_bio"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
# [8]  "#  | MIROC_rcp45"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               
# [9]  "#  | MIROC_rcp85"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               
# [10] "#  | CESM_rcp45"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
# [11] "#  | CESM_rcp85"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
# [12] "#  | CESM_rcp85_bio"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
#  "###########################################################"  

#cat("Load Data Complete")





