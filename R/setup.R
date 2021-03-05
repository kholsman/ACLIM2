# ----------------------------------------
# setup.R
# subset of Holsman et al. 2020 Nature Comm.
# kirstin.holsman@noaa.gov
# updated 2020
# ----------------------------------------
  
    # switches and options:
    #-------------------------------------------
    # set this to TRUE to "update" the indices from the original files on mox
    redownload_level3_mox  <- FALSE
    update_base_data       <- FALSE
    update.figs     <-  FALSE   # set to true to re-save figs
    update.outputs  <-  TRUE   # overwrite the existing Rdatafiles in out_fn
    status          <-  TRUE   # print progress
    scaleIN         <-  1      # controls the ratio (relative scaling of window)
    dpiIN           <-  150    # dpi for figures (set to lower res for smaller file size- these will be about 3.5 MB)
    
    # dataset names:
    #-------------------------------------------
    weekly_flnm     <- "ACLIMregion"
    survey_rep_flnm <- "ACLIMsurveyrep"
    
    # URL paths:
    #-------------------------------------------
    # specify the root URL:
    ACLIM_data_url <- "https://data.pmel.noaa.gov/aclim/thredds/"
    
    # set up directory paths:
    #-------------------------------------------
    remote_fl    <- "roms_for_aclim"
    local_fl     <- file.path(main,"Data/in",  "Newest")
    if(redownload_level3_mox)
      local_fl    <- file.path(main,"Data/in",  tmstp)
    localfolder   <- file.path(local_fl,remote_fl)
    data_path     <- file.path(local_fl,remote_fl)
    
    
    if(!dir.exists(local_fl))   
      dir.create(local_fl)
    if(!dir.exists(file.path(local_fl,remote_fl)))   
      dir.create(file.path(local_fl,remote_fl))
    
    geotif_dir    <- "Data/in/Map_layers/geo_tif"
    shp_dir       <- "Data/in/Map_layers/shp_files"
    Rdata_path    <- "Data/in/Newest/Rdata"
    shareddata_path   <-  "Data/shared"
    
    # create a directory for our new indices 
    if(!dir.exists("Data/in/Newest/Rdata")) 
      dir.create("Data/in/Newest/Rdata")
    
    
    # Identify ACLIM shared models:
    #-------------------------------------------
    reg_txt   <- "Level3/ACLIMregion_"
    srvy_txt  <- "Level3/ACLIMsurveyrep_"
    dirlist    <- dir(data_path)
    embargo_n  <- grep("CMIP6",dirlist)
    public_n   <- grep ("B10K-H16_",dirlist)
    pilcher    <- grep("B10K-K20P19_CMIP5",dirlist)
    nobio      <- grep("nobio",dirlist)
    aclim      <- dirlist
    public     <- dirlist[-c(pilcher,nobio,embargo_n)]
    embargoed  <- dirlist[embargo_n]
    
    # Return some flags:
    #-------------------------------------------
    cat(paste("main is set to:",main,"\n"))
    cat(paste("redownload_level3_mox is set to:",redownload_level3_mox,"\n"))
    cat(paste("data_path is set to:",data_path,"\n"))
    cat(paste("update.figs is set to:", update.figs,"\n"))
    cat("\n")
    cat(paste("The following datasets are public, please cite as Hermann et al. 2019 (v.H16) and Kearney et al. 2020 (v.K20) :\n"))
    for(k in public)
      cat(paste(k,"\n"))
    cat("\n")
    cat(paste("The following datasets are still under embargo, please do not share outside of ACLIM:\n"))
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
 

