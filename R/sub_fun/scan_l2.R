#' 
#' scan_l2.R
#' scan l3 .nc files for available variables and timesteps
#' @param web_nc  TRUE = pull files from the web;  FALSE =  use 'local_path'
#' @param download_nc  TURE = download the nc files from the web, FALSE = access nc files without downloading
#' @param rd_path Path where the Rdata file (outputs) should be saved
#' @param local_path Path where .nc files are stored locally
#' @param varlist list of variables to extract from the .nc files
#' @param proj_list list of simulations to draw from
#' @example 
#' 
# scan_l2(ds_list = "Bottom 5m",sim_list = "B10K-H16_CORECFS" )

scan_l2 <-function(
  web_nc      = TRUE,
  local_path  = NULL,
  ds_list     = dl,
  sim_list    = c(hind, proj)
) {
  out <- list()
  # preview the datasets on the server:
  url_list <- tds_list_datasets(thredds_url = ACLIM_data_url)
  
  # now grab dattat for the hindcast and projection sets:
  for(m in sim_list){
    
    for(d in 1:length(ds_list)){
      out[[ds_list[d]]]<-list()
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
          
        tmpURL         <- paste0(paste0(ACLIM_data_url,"dodsC/Level2/"),m_flnm,".nc")
          
        # open the netcdf file remotely
        nc      <- nc_open(tmpURL)
      }else{
        nc      <- nc_open(tmp_path)
      }
      
      # available variables:
      out[[ds_list[d]]]$vars        <- names(nc$var)
      
      #timesteps
      out[[ds_list[d]]]$time_steps  <- as.POSIXct(
        nc$var[[ sub_varlist[[d]][1] ]]$dim[[3]]$vals, 
        origin = substr(nc$var[["temp"]]$dim[[3]]$units,15,36),
        tz = "GMT") 
      
      # get years in simulation
      out[[ds_list[d]]]$years    <- sort(unique(substr(time_steps,1,4)))
     
      # subset the lat and lon values
      out[[ds_list[d]]]$lat    <- ncvar_get(nc, varid = "lat_rho")
      out[[ds_list[d]]]$lon    <- ncvar_get(nc, varid = "lon_rho")
      
      # close the nc file
      nc_close(nc)
    }
  }
  return(out)
}