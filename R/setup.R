# ----------------------------------------
# setup.R
# subset of Holsman et al. 2020 Nature Comm.
# kirstin.holsman@noaa.gov
# updated 2020
# ----------------------------------------
  
    # switches and options:
    #-------------------------------------------
    # set the reference years for bias correcting:CMIP5 doesn't start until 2005
    ref_years <- 1980:2013
    
    # identify the year to z-score scale / delta (note that )
    deltayrs  <- 1970:2012
    
    # Designate strata:
    NEBS_strata <- c(70, 71,81,82,90) #c(70,71, 81) 
    SEBS_strata <- c(10,20,31,32,50,
                     20,41,42,43,61,62)
    NEBS_strata <- c(70,71, 81) 
    SEBS_strata <- c(10,20,31,32,41,42,43,50, 61,62,82,90)
    
    # set this to TRUE to "update" the indices from the original files on mox
    redownload_level3_mox  <- FALSE
    update_base_data       <- FALSE
    # subfldr                <- "2022_03_07"
    # subfldrR               <- "2022_03_07_Rdata"
    subfldr                <- "2022_10_17"
    subfldrR               <- "2022_10_17_Rdata"
    
    

    load_gis        <-  FALSE  # load mapfiles, note first time through downloading these may take a long time
    update.figs     <-  FALSE  # set to true to re-save figs
    update.outputs  <-  TRUE   # overwrite the existing Rdatafiles in out_fn
    status          <-  TRUE   # print progress
    scaleIN         <-  1      # controls the ratio (relative scaling of window)
    dpiIN           <-  150    # dpi for figures (set to lower res for smaller file size- these will be about 3.5 MB)
    
    # set up directory paths:
    #-------------------------------------------
    remote_fl     <- "roms_for_public"
    #main          <- getwd()  #"~/GitHub_new/ACLIM2"
    local_fl      <- file.path("Data/in")
    
    
    if(redownload_level3_mox)
      subfldr     <- tmstp
    local_fl      <- file.path("Data/in",  subfldr)
    localfolder   <- file.path(local_fl,remote_fl)
    # data_path     <- file.path(local_fl,remote_fl)
    # Rdata_path    <- file.path(file.path("Data/in",  subfldrR),remote_fl)
    # 
    if(.Platform$OS.type == "unix") {
      # data_path     <- file.path("/Volumes/LaCie/romsnpz",remote_fl)
      # Rdata_path    <- file.path(file.path("/Volumes/LaCie/romsnpz",  subfldrR),remote_fl)
      data_path     <- file.path("data/in",remote_fl)
      Rdata_path    <- file.path(file.path("data/in",  subfldrR),remote_fl)
      if(!dir.exists(file.path(file.path("data/in",  subfldrR))))  dir.create(file.path(file.path("data/in",  subfldrR)))
      
    }
    if(.Platform$OS.type == "windows") {
      data_path     <- file.path("D:/romsnpz",remote_fl)
      Rdata_path    <- file.path(file.path("D:/romsnpz",  subfldrR),remote_fl)
    }
    
    
    #Rdata_path_C    <- file.path(file.path("/Volumes/LaCie/romsnpz",  "2022_05_16_C_Rdata"),remote_fl)
    if(!dir.exists(local_fl))       
      dir.create(local_fl)
    if(!dir.exists(file.path(local_fl,remote_fl)))   
      dir.create(file.path(local_fl,remote_fl))
    
    mapdata_path     <- file.path("Data/in/Map_layers")
    geotif_dir       <- "Data/in/Map_layers/geo_tif"
    shp_dir          <- "Data/in/Map_layers/shp_files"
    
    shareddata_path  <- "Data/shared"
   
    
    # create a directory for our new indices 
    if(!dir.exists(Rdata_path))     dir.create(Rdata_path)
    if(!dir.exists(mapdata_path))     dir.create(mapdata_path)
   
    # dataset names:
    #-------------------------------------------
    weekly_flnm     <- "ACLIMregion"
    survey_rep_flnm <- "ACLIMsurveyrep"
    
    # URL paths:
    #-------------------------------------------
    # specify the root URL:
    ACLIM_data_url <- "https://data.pmel.noaa.gov/aclim/thredds/"
    
    
    # simulation names:
    #-------------------------------------------
    sim_list <- scenarios <- c("B10K-K20_CORECFS",
                               "B10K-H16_CMIP5_CESM_BIO_rcp85",
                               "B10K-H16_CMIP5_CESM_rcp45",
                               "B10K-H16_CMIP5_CESM_rcp85",
                               "B10K-H16_CMIP5_GFDL_BIO_rcp85",
                               "B10K-H16_CMIP5_GFDL_rcp45",
                               "B10K-H16_CMIP5_GFDL_rcp85",
                               "B10K-H16_CMIP5_MIROC_rcp45",
                               "B10K-H16_CMIP5_MIROC_rcp85",
                               "B10K-H16_CORECFS",
                               "B10K-K20P19_CMIP5_CESM_rcp45",
                               "B10K-K20P19_CMIP5_CESM_rcp85",
                               "B10K-K20P19_CMIP5_GFDL_rcp45",
                               "B10K-K20P19_CMIP5_GFDL_rcp85",
                               "B10K-K20P19_CMIP5_MIROC_rcp45",
                               "B10K-K20P19_CMIP5_MIROC_rcp85",
                               "B10K-K20P19_CMIP6_cesm_historical",
                               "B10K-K20P19_CMIP6_cesm_ssp126",
                               "B10K-K20P19_CMIP6_cesm_ssp585",
                               "B10K-K20P19_CMIP6_gfdl_historical",
                               "B10K-K20P19_CMIP6_gfdl_ssp126",
                               "B10K-K20P19_CMIP6_gfdl_ssp585",
                               "B10K-K20P19_CMIP6_miroc_historical",
                               "B10K-K20P19_CMIP6_miroc_ssp126",
                               "B10K-K20P19_CMIP6_miroc_ssp585")
    
    # Identify ACLIM shared models:
    #-------------------------------------------
    reg_txt   <- "Level3/ACLIMregion_"
    srvy_txt  <- "Level3/ACLIMsurveyrep_"
    dirlist    <- dir(data_path)
    dirlist    <- aclim <- c(
    "B10K-H16_CMIP5_CESM_BIO_rcp85"  ,  
     "B10K-H16_CMIP5_CESM_rcp45"       ,  
     "B10K-H16_CMIP5_CESM_rcp85"        , 
     "B10K-H16_CMIP5_GFDL_BIO_rcp85"     ,
     "B10K-H16_CMIP5_GFDL_rcp45"         ,
     "B10K-H16_CMIP5_GFDL_rcp85"         ,
     "B10K-H16_CMIP5_MIROC_rcp45"        ,
     "B10K-H16_CMIP5_MIROC_rcp85"        ,
     "B10K-K20P19_CMIP6_cesm_historical" ,
     "B10K-K20P19_CMIP6_cesm_ssp126"     ,
     "B10K-K20P19_CMIP6_cesm_ssp585"     ,
     "B10K-K20P19_CMIP6_gfdl_historical" ,
     "B10K-K20P19_CMIP6_gfdl_ssp126"     ,
     "B10K-K20P19_CMIP6_gfdl_ssp585"     ,
    "B10K-K20P19_CMIP6_miroc_historical",
    "B10K-K20P19_CMIP6_miroc_ssp126"    ,
   "B10K-K20P19_CMIP6_miroc_ssp585" )
    embargo_n  <- grep("CMIP6",dirlist)
    public_n   <- grep ("B10K-H16_",dirlist)
    pilcher    <- grep("B10K-K20P19_CMIP5",dirlist)
    nobio      <- grep("nobio",dirlist)
    public     <- dirlist[-c(pilcher,nobio,embargo_n)]
    embargoed  <- dirlist[embargo_n]
    
    
    # Return some flags:
    #-------------------------------------------
    cat("------------------------------\n")
    cat("ALIM2/R/setup.R settings \n")
    cat("------------------------------\n")
    #cat(paste("main:                :",main,"\n"))
    cat(paste("data_path            :",data_path,"\n"))
    cat(paste("Rdata_path           :",Rdata_path,"\n"))
    cat(paste("redownload_level3_mox:",redownload_level3_mox,"\n"))
    cat(paste("update.figs          :", update.figs,"\n"))
    
    cat(paste("load_gis             :", load_gis,"\n"))
    cat(paste("update.outputs       :", update.outputs,"\n"))
    cat(paste("update.figs          :", update.figs,"\n"))
    cat(paste("dpiIN                :", dpiIN,"\n"))
    cat(paste("update.figs          :", update.figs,"\n"))
    
    cat("------------------------------\n")
    cat("------------------------------\n")
    cat("\n")
    cat(paste("The following datasets use the B10K-H16_CORECFS hindcast and are public, please cite as Hermann et al. 2019 (v.H16) :\n"))
    for(k in public)
      cat(paste(k,"\n"))
    cat("\n")
    cat(paste("The following datasets use the B10K-K20_CORECFS hindcast and are public, please reach out to A. Hermann, K. Kearney, W. Cheng, and D. Pilcher for more info, please cite as Kearney et al. 2020 and Pilcher et al. (2021) for v.K20 hindcast), Hermann et al. (2021), and Cheng et al. 2021 (for CMIP6 projections). \n"))
    for(k in embargoed)
      cat(paste(k,"\n"))
    
    
  # Some settings for which scenarios to evaluate:
  #-------------------------------------------
    start_yr        <-  1979        # first year of the hindcast simulation
    fut_start       <-  2018        # first year of the projections
  
   # Risk thresholds/limits (used for threhold/tipping point analysis)
   #-------------------------------------------
    limlist         <-  c(-10,-50,-80)  # % thresholds for decline, severe decline, collapse relative to persistence scenario
    modeLIST        <-  c("SSM","MSM")
    Yrbin           <-  c(2017,2025,2050,2075,2100)  # bins for the risk calculation
    
    # Plotting stuff:
    #-------------------------------------------
    # The width of figures, when printed, 
    # will usually be 5.5 cm (2.25 inches or 1 column) 
    # or 12.0 cm (4.75 inches or 2 columns). 

    # set up color palettes
    plt     <- c("Zissou1","Darjeeling1","Darjeeling2","FantasticFox1")
    blues   <- RColorBrewer::brewer.pal(5, "Blues")
    BG      <- RColorBrewer::brewer.pal(9, "GnBu")  #5
    Ornjazz <- RColorBrewer::brewer.pal(5, "Oranges")
    YGB     <- (RColorBrewer::brewer.pal(5, "YlGnBu"))
    bg      <- colorRampPalette(BG)
    YlGnBu  <- colorRampPalette(YGB[-1])
    blu     <- colorRampPalette(blues[-1])
    night   <- colorRampPalette(colors()[c(653,47,474,72,491,477)])
    dawn    <- colorRampPalette(c(colors()[c(477,491,72,474,47,653)],"orange","red"))
    orng    <- colorRampPalette(Ornjazz[1:5])
    colIN1  <- colorRampPalette(c(wes_palette(n=5, name=plt[1])[1:5]))
    col4    <- colorRampPalette(c(colIN1(6),"maroon"))
    
    col_in  <- colorRampPalette(colors()[c(459,122,73)])
    col_in  <- colorRampPalette(colors()[c(408,44,73)])
    col_in2 <- colorRampPalette(c("orange","red"))
    wes     <- colorRampPalette(c(wes_palette(n=5, name=plt[1])[1:5]))
    col1    <- colorRampPalette(colors()[c(280,320)])
    #col2     <- colorRampPalette(colors()[c(70,491)])
    cola    <- colorRampPalette(colors()[c(114,491)])
    col2    <- colorRampPalette(c(wes(7)[c(3,1)],cola(3)[3]))
    col3    <- colorRampPalette(c(wes(7)[4:7]))
    
    # set the color scheme
    coll_use         <-  c(colors()[320],col2(8)[c(2,5,7)],col3(8)[c(2,5,7)])
    
    # Set up plotting stuff:
    #------------------------------------     
   
    probbs        <-  c(.1,.25,.5,.75,.9)
    alphaAll      <-  ceiling(rep(100/(length(probbs)/2),length(probbs)/2))
    c1            <-  col2(5)
    c2            <-  col2(6)[seq(2,6,2)]
    c3            <-  col3(6)[seq(2,6,2)]
    collIn        <-  rep(NA,13)
    collIn[1:2]   <-  col2(2)[2]
    ltyall                  <-  rep(1,13)  
    ltyall[1:2]             <-  1
    lwdall                  <-  rep(1,13)  
    lwdall[1:2]             <-  2
 

