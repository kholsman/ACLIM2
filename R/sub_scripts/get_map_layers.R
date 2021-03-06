#'
#'
#'Get_map_layers.R
#'
    # set up folders:
    # ---------------------------------
    fldrs<-c(file.path(mapdata_path,"shp_files"),
             file.path(mapdata_path,"shp_files/global"),
             file.path(mapdata_path,"shp_files/global/natural_earth_vector"),
             file.path(mapdata_path,"geo_tif"),
             file.path(mapdata_path,"geo_tif/OB_LR"))
    for(ddir in fldrs){
      if(!dir.exists(ddir)) dir.create(ddir)
    }
    
    
    # download blue marble files:
    # ---------------------------------
    if(!file.exists(file.path(mapdata_path,"geo_tif/blue_marble.tif") ))
      download.file(
        url ="https://eoimages.gsfc.nasa.gov/images/imagerecords/57000/57752/land_shallow_topo_8192.tif",
        file.path(file.path(mapdata_path,"geo_tif/blue_marble.tif") ))
    
    
    # download OB_LR
    # ---------------------------------
  
    #http://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/raster/OB_LR.zip
    # /Users/kholsman/GitHub_new/ACLIM2/Data/in/Map_layers/geo_tif/OB_LR
    
    if(!file.exists(file.path(mapdata_path,"geo_tif/OB_LR") )){
      
       getZip( 
         urlIN = "http://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/raster/OB_LR.zip", 
         destfileIN = file.path(mapdata_path,"geo_tif/OB_LR.zip") )
      
      
    }
    
    
    ## CNTR_RG_03M_2014
    # ---------------------------------
    #C NTR_RG_03M_2014
    
    tmp_fldr <-  file.path(mapdata_path,"shp_files/global")
    if(!dir.exists(file.path(mapdata_path,tmp_fldr,"CNTR_RG_03M_2014"))){
      getZip( 
        url     = "https://dominicroye.github.io/files/CNTR_RG_03M_2014.zip",
        destfile = file.path( tmp_fldr,"CNTR_RG_03M_2014.zip") )
    }
   
    
    # natural_earth_vector
    # ---------------------------------
    #10m
      
    base_url <-"https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/"
    tmp_fldr <-  file.path(mapdata_path,"shp_files/global")
    
    # https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/physical/10m_physical.zip
    # https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/50m/physical/50m_physical.zip
    # https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/110m/physical/110m_physical.zip
    
    for(nn in c(10,50,110) ){
      
      nm       <-  paste0(nn,"m/physical/",nn,"m_physical.zip")
      outfl    <-  paste0("natural_earth_vector/",nn,"m_physical.zip")
      
      if(!dir.exists(file.path(tmp_fldr,paste0("natural_earth_vector/",nn,"m_physical")  )))
        getZip( url = paste0(base_url,nm), destfile = file.path(tmp_fldr,outfl) )
    }
 
    # natural earth shp downloads:
    # ---------------------------------
    base_url <-"https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/physical/"
    tmp_fldr <-  file.path(mapdata_path,"shp_files/global")
    
    tmpnms <- c("ne_10m_bathymetry_K_200","ne_10m_bathymetry_J_1000")
   
    for(nm in tmpnms){
      if(!dir.exists( file.path( tmp_fldr,nm)   ) )
           getZip( url = paste0(base_url,paste0(nm,".zip" )),
                   destfile = file.path( tmp_fldr,paste0(nm,".zip" )) )
    }
      
      
  
