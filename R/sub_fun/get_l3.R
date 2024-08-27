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
# vl <-
#   c("temp_bottom5m",    # bottom temperature,
#   "NCaS_integrated",  # Large Cop
#   "Cop_integrated",   # Small Cop
#   "EupS_integrated")  # Shelf  euphausiids
# sl <- c(hind, proj)
# 
# # three options are:
# 
# # opt 1: access nc files remotely (fast, less local storage needed)
# get_l3(web_nc = TRUE, download_nc = F,
#       varlist = vl,sim_list = sl)
# 
# # opt 2:  download nc files then access locallly:
# get_l3(web_nc = TRUE, download_nc = T,
#       local_path = file.path(local_fl,"aclim_thredds"),
#       varlist = vl,sim_list = sl)

# opt 3:  access existinig nc files locally:
# get_l3(web_nc = F, download_nc = F,
#       local_path = file.path(local_fl,"roms_for_aclim"),
#       varlist = vl,sim_list = sl)


get_l3 <-function(
    web_nc      = TRUE,
    download_nc = FALSE,
    rd_path    = file.path(main,Rdata_path),
    local_path = file.path(local_fl,"roms_for_aclim"),
    varlist    = c(
      "temp_bottom5m",    # bottom temperature,
      "NCaS_integrated",  # Large Cop
      "Cop_integrated",   # Small Cop
      "EupS_integrated"),  # Shelf  euphausiids
    sim_list   = c(hind, proj)  
  ){

    
  
    # create a directory for our new indices 
    if(!dir.exists(rd_path))
      dir.create(rd_path)
  
    
    # now grab dattat for the hindcast and projection sets:
    for(m in sim_list){
      
      TYPE <- 1
      
      # create the simulation Level3 folder (and overwrite it if overwrite is set to T)
      if(!dir.exists(file.path(rd_path,m)))
        dir.create((file.path(rd_path,m)))
      if(!dir.exists(file.path(rd_path,m,"/Level3")))
        dir.create((file.path(rd_path,m,"/Level3")))
      
    for(d in c(weekly_flnm,survey_rep_flnm)){
      
      # create filename:
      tmp_fl  <- paste0(d,"_",m)
      tmppath <- file.path(local_path,paste0(m,"/Level3/",d,"_",m,".nc"))
      
      if(web_nc){
        # create the temporary URL
        
        if(download_nc){
          # create local folders for nc files
          if(!dir.exists(local_path))
            dir.create(local_path)
          if(!dir.exists( file.path( local_path,m ) ))
            dir.create( file.path(local_path,m) )
          if(!dir.exists( file.path( local_path,paste0(m,"/Level3/") ) ))
            dir.create( file.path(local_path,paste0(m,"/Level3/")) )
          
          # download the nc file and save locally
          tmpURL <- paste0(paste0(ACLIM_data_url,"fileServer/",m,"/Level3/"),d,"_",m,".nc")
          download.file(tmpURL,destfile = tmppath, overwrite = T)
          
          # open the local netcdf file 
          nc     <- nc_open(tmppath)
          
        }else{
          
          # access nc remotely
          tmpURL <- paste0(paste0(ACLIM_data_url,"dodsC/",m,"/Level3/"),d,"_",m,".nc")
          
          # open the local netcdf file 
          nc     <- nc_open(tmpURL)
        }
        
      }else{
        # open the local netcdf file 
        nc     <- nc_open(tmppath)
      }
      
      # convert the nc files into a long data.frame for each variable
      i <- 0
      for(v in varlist){
        i <- i + 1
        tmp_var0      <- convert2df(ncIN = nc, 
                                    type = TYPE, 
                                    varIN = v)
        tmp_var0$sim  <- tmp_fl
        if(i == 1)
          tmp_var     <- tmp_var0
        if(i != 1)
          tmp_var     <- rbind(tmp_var,
                               tmp_var0)
        rm(tmp_var0)
      }
      
      # close the nc file
      nc_close(nc)
      
      # rename the object
      eval(parse(text =paste0(d,"<- tmp_var") ))
      
      # save the nc file in the Data/in/Newest/Rdata/ [ simulation]/Level3 folder
      tmp_path <- file.path(main, Rdata_path,m,"Level3",
                             paste0(tmp_fl,".Rdata"))
      eval(parse(text =paste0("save(",d,", file=tmp_path)")))
      TYPE     <-  TYPE + 1
      cat(paste("success:",tmp_path,"created from nc files\n"))
    }
  }
}
