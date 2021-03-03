#' 
#' get_l3.R
#' Convert Level 3 .nc files to Rdata files
#' @param web_nc  TRUE = pull files from the web;  FALSE =  use 'local_path'
#' @param download_nc  TURE = download the nc files from the web, FALSE = access nc files without downloading
#' @param rd_path Path where the Rdata file (outputs) should be saved
#' @param local_path Path where .nc files are stored locally
#' @param varlist list of variables to extract from the .nc files
#' @param proj_list list of simulations to draw from
#' @example 
#' 
# grab nc files from the aclim server and convert to rdatafiles:
# get_l2(
#   ID          = "",
#   ds_list     = dl,
#   trIN        = tr,
#   sub_varlist = svl,
#   sim_list    = sl  )

get_l2 <-function(
  web_nc      = TRUE,
  download_nc = FALSE,
  rd_path     = file.path(main,Rdata_path),
  local_path  = NULL,
  xi_rangeIN  = 1:182,   
  eta_rangeIN = 1:258,
  ID          = "",
  ds_list     = dl,
  originIN      = "1900-01-01 00:00:00",
  trIN        = c("-08-1 12:00:00 GMT"),
  sub_varlist = list(
    "temp",
    "temp",
    c("EupS","Cop","NCaS") ),  
  sim_list  ) {
    
  # preview the datasets on the server:
  url_list <- tds_list_datasets(thredds_url = ACLIM_data_url)
  
  # now grab dattat for the hindcast and projection sets:
  for(m in sim_list){
    
    # create the simulation Level3 folder (and overwrite it if overwrite is set to T)
    if(!dir.exists(file.path(rd_path,m)))
      dir.create(file.path(rd_path,m))
    if(!dir.exists(file.path(rd_path,m,"/Level2")) )
      dir.create(file.path(rd_path,m,"/Level2"))
    
    for(d in 1:length(ds_list)){
      
      # create filename:
      tmp_fl  <- paste0(d,"_",m)
      tmppath <- file.path(local_path,paste0(m,"/Level2/",ds_list[d],"_",m,".nc"))
      tmppath <- stringr::str_replace(tmppath," 5m","_5m")
      
      if(web_nc){
        # create the temporary URL
        
        # get the url for the simulation
        m_url       <- url_list[url_list$dataset == paste0(m,"/"),]$path
        
        # preview the projection and hindcast data and data catalogs (Level 1, 2, and 3):
        m_datasets  <- tds_list_datasets(thredds_url = m_url)
        
        # get Level 2 .nc file URL
        m_l2_cat       <- m_datasets[m_datasets$dataset == "Level 2/",]$path
        m_l2_datasets  <- tds_list_datasets(m_l2_cat)
        m_l2_vT_url    <- m_l2_datasets[m_l2_datasets$dataset == ds_list[d],]$path
        m_flnm         <- strsplit(m_l2_vT_url,split="dataset=")[[1]][2]
        m_flnm         <- stringr::str_replace(m_flnm,"Level2_","")
        tmppath        <- file.path(local_path,paste0(m,"/Level2/",ds_list[d],"_",m,".nc"))
        
        if(ds_list[d] =="Surface 5m") 
          m_flnm       <- stringr::str_replace(m_flnm,"surface_5m","surface5m")
        
        if(download_nc){
          error("downloading level 2 files not yet avail.")
          if(1==10){
            # create local folders for nc files
            if(!dir.exists(local_path))
              dir.create(local_path)
            if(!dir.exists( file.path( local_path,m ) ))
              dir.create( file.path(local_path,m) )
            if(!dir.exists( file.path( local_path,paste0(m,"/Level2/") ) ))
              dir.create( file.path(local_path,paste0(m,"/Level2/")) )
            
            # download the nc file and save locally
            #https://data.pmel.noaa.gov/aclim/thredds/fileServer/B10K-K20_CORECFS/Level2/2015-2019/B10K-K20_CORECFS_2015-2019_average_temp_bottom5m.nc
  
            tmpURL         <- paste0(paste0(ACLIM_data_url,"fileServer/Level2/"),m_flnm,".nc")
            download.file(tmpURL,destfile = tmppath, overwrite = T)
            
            # open the local netcdf file 
            nc     <- nc_open(tmppath)
          }
          
        }else{
        
          tmpURL         <- paste0(paste0(ACLIM_data_url,"dodsC/Level2/"),m_flnm,".nc")
          
          # open the netcdf file remotely
          nc             <- nc_open(tmpURL)
        }
        
      }else{
          nc      <- nc_open(tmp_path)
      }
      
      
      # available variables:
      names(nc$var)
      
      time_steps  <- as.POSIXct(
        nc$var[[ sub_varlist[[d]][1] ]]$dim[[3]]$vals, 
        origin = originIN,
        tz = "GMT") 
      
      # get years in simulation
      yrs    <- sort(unique(substr(time_steps,1,4)))
      tmp_tr <-  paste0(yrs,trIN)
      
      # subset the lat and lon values
      lat    <- ncvar_get(nc, varid = "lat_rho")
      lon    <- ncvar_get(nc, varid = "lon_rho")
      #M2 <- (56.87°N, -164.06°W)
      
      for(var_get in sub_varlist[[d]]){
        # convert the nc files into a long data.frame for each variable
        # Tinker: try extracting other vars like "NO3", or "uEast"
        
          tmp_var      <- get_level2(
            ncIN      = nc, 
            originIN = originIN,
            varIN     = var_get,
            xi_range  = xi_rangeIN,   
            eta_range = eta_rangeIN, 
            time_range  = tmp_tr)
          
        
        # rename the object
        eval(parse(text =paste0(var_get,"<-tmp_var") ))
        
        # save the nc file in the Data/in/Newest/Rdata/ [ simulation]/Level3 folder
        tmp_path <- file.path( main,Rdata_path,m,"Level2",
                               paste0(m_flnm,"_",var_get,ID,".Rdata"))
        eval(parse(text =paste0("save(",var_get,", file=tmp_path)")))
        eval(parse(text =paste0("rm(",var_get,")") ))
        cat(paste("success:",tmp_path, "saved in local folder\n"))
      }
      # close the nc file
      nc_close(nc)
    }
  }
}