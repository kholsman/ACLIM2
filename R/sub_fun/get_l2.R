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
  overwrite   = FALSE,
  xi_rangeIN  = 1:182,   
  eta_rangeIN = 1:258,
  ID          = "",
  ds_list     = dl,
  yearsIN     = NULL,
  originIN    = "1900-01-01 00:00:00",
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
    cat(paste("get "),m,"\n")
    # create the simulation Level2 folder (and overwrite it if overwrite is set to T)
    if(!dir.exists(file.path(rd_path,m)))
      dir.create(file.path(rd_path,m))
    if(!dir.exists(file.path(rd_path,m,"/Level2")) )
      dir.create(file.path(rd_path,m,"/Level2"))
    
    for(d in 1:length(ds_list)){
      cat("------------------\n")
      cat(paste("get "),ds_list[d],"\n")
      cat("------------------\n")
      # create filename:
      tmp_fl     <- paste0(d,"_",m)
      tmppath    <- file.path(rd_path,paste0(m,"/Level2/",ds_list[d],"_",m,".nc"))
      tmppath    <- stringr::str_replace(tmppath," 5m","_5m")
      tmp_rdpath <- file.path( main,Rdata_path,m,"Level2",
                             paste0(m_flnm,"_",var_get,ID,".Rdata"))
      
     
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
        if(length( grep("B10K_K20",m_flnm))>0 )
          m_flnm       <- stringr::str_replace(m_flnm,"B10K_K20","B10K-K20")
        m_flnm         <- stringr::str_replace(m_flnm,"Level2_","")
        
        
        
        tmppath        <- file.path(rd_path,paste0(m,"/Level2/",ds_list[d],"_",m,".nc"))
        tmppath    <- stringr::str_replace(tmppath," 5m","_5m")
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
          ncpath      <- tmpURL
          #nc         <- nc_open(tmpURL)
        }
        
      }else{
          ncpath     <- tmp_path
          #nc         <- nc_open(tmp_path)
      }
      
      
     
      
      for(var_get in sub_varlist[[d]]){
        
        # name the rdata out file:
        tmp_rdpath     <- file.path( main,Rdata_path,m,"Level2",
                                     paste0(m_flnm,"_",var_get,ID,".Rdata"))
        
        if(overwrite | !file.exists(tmp_rdpath)){
          cat(paste0("get ",sub_varlist[[d]],"...\n"))
          nc             <- nc_open(ncpath)
          
          # available variables:
          # names(nc$var)
          
          time_steps  <- as.POSIXct(
            nc$var[[ sub_varlist[[d]][1] ]]$dim[[3]]$vals, 
            origin = originIN,
            tz = "GMT") 
          
          # get years in simulation
          yrs      <- yearsIN
          if (is.null(yearsIN))
            yrs    <- sort(unique(substr(time_steps,1,4)))
          
          tmp_tr <-  paste0(yrs,trIN)
          
          # subset the lat and lon values
             cat("get lat...\n")
          lat    <- ncvar_get(nc, varid = "lat_rho")
             cat("get lon...\n")
          lon    <- ncvar_get(nc, varid = "lon_rho")
          #M2 <- (56.87°N, -164.06°W)
        
          cat("get data... (slow)...")
          tmp_var      <- get_level2(
            ncIN        = nc, 
            originIN    = originIN,
            varIN       = var_get,
            xi_range    = xi_rangeIN,   
            eta_range   = eta_rangeIN, 
            time_range  = tmp_tr)
          
          # rename the object
          eval(parse(text =paste0(var_get,"<-tmp_var") ))
          
          # save the nc file in the Data/in/Newest/Rdata/ [ simulation]/Level3 folder
          eval(parse(text =paste0("save(",var_get,", file=tmp_rdpath)")))
          eval(parse(text =paste0("rm(",var_get,")") ))
          cat(paste("success:",tmp_rdpath, "saved in local folder\n"))
          
          # close the nc file
          nc_close(nc)
        }else{
          #skip it
          cat(paste0("skipping ", sub_varlist[[d]],"; already exists, overwrite = F\n"))
        }
        
      } # each sub var
    }# each ds_list
  } # each sim_list
}