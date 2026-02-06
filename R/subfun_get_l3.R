#' 
#' get_l3.R
#' Convert Level 3 .nc files to Rdata files
#' @param from_thredds  TRUE = pull files from the thredds server;  FALSE =  use 'local_path'
#' @param download_nc  TURE = download the nc files from the web, FALSE = access nc files without downloading
#' @param rd_path Path where the Rdata file (outputs) should be saved
#' @param local_path default is NULL, optional path where the nc file (outputs) should be (or are) saved
#' @param varlist list of variables to extract from the .nc files
#' @param convert2Rdata convert the nc files to Rdata files
#' @param proj_list list of simulations to draw from
#' @param cleanIT  strip the longer columsn and collaspse them to a meta data file
#' @param verbose return info on which variables are being converted
#' @include  fun_aclim_thredds_util.R
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
# get_l3(from_thredds = TRUE, download_nc = F,
#       varlist = vl,sim_list = sl)
# 
# # opt 2:  download nc files then access locally:
# get_l3(from_thredds = TRUE, download_nc = T,
#       local_path = file.path(local_fl,"aclim_thredds"),
#       varlist = vl,sim_list = sl)

# opt 3:  access existing nc files locally:
# get_l3(from_thredds = F, download_nc = F,
#       local_path = file.path(local_fl,"roms_for_aclim"),
#       varlist = vl,sim_list = sl)
# source(here("R/subfun_aclim_thredds_util.R"))

get_l3 <-function(
    from_thredds     = TRUE,
    download_nc      = FALSE,
    ACLIM_data_urlIN = ACLIM_data_url,
    rd_path          = Rdata_path,
    local_path       = NULL,
    varlist    = NULL,
    overwriteIN = T,
    cleanIT = T,
    convert2Rdata  = T,
    fileset = NULL,
    verbose = F,
    # weekly_varsIN = weekly_vars[-which(weekly_vars%in%c("region_area"))],
    # srvy_varsIN  =  srvy_vars[-which(srvy_vars%in%c("station_id",
    #                                                            "latitude",
    #                                                            "longitude", "stratum","doy"))],
    sim_list   = NULL){
  
  
    # now get the model_runs from the thredds server
     if (is.null(sim_list)){
       sims <- aclim_thredds(section = "files")
       model_runs <- sims
       save(model_runs,file = file.path(rd_path,"model_runs.Rdata"))
       tmp_set <- model_runs[sim_list%in%model_runs]
     }else{
       tmp_set <- sim_list
     }
      
      for(s in seq_along(tmp_set) )
      {
        
        files_L3use <- aclim_thredds(run =tmp_set[s], level = 3)
        
        
        for(f in seq_along(files_L3use$filename))
        {
         
         
          # for each file in the model_run folder....
          
          # determine the type
          TYPE <- d<- NULL
          if( length(grep("ACLIMsurveyrep_",files_L3use[f,]$filename)) > 0){ 
            TYPE <- 2
            d <-"ACLIMsurveyrep"
          }
          if( length(grep("ACLIMregion_",files_L3use[f,]$filename)) > 0) {
            TYPE <- 1
            d <- "ACLIMregion"
          }
         
          
         
          # create the nc folder 
          tmpdest <-  make_fldr(list_obj = files_L3use[f,],base_path = nc_data_path, onefolder = F)
          
          # create the rdata folder
          tmpfl<- files_L3use[f,]
          tmpfl$filename <- paste0(strsplit(files_L3use[f,]$filename,".nc")[[1]],".Rdata")
          tmpdestRda     <-  make_fldr(list_obj = tmpfl,base_path = Rdata_path, onefolder = F)
          
          if(from_thredds){
            # download the nc file from the thredds server
            tmpURl  <- files_L3use$download_url[f]
            
            if(download_nc){
                # download the file:
                thredds_download_nc(url = tmpURl,
                                    dest = tmpdest,
                                    cache_dir = "~/.aclim_cache",
                                    overwrite = TRUE)
                
              # open the local netcdf file 
              if(convert2Rdata)nc     <- nc_open(tmpdest)
              
            }else{
              
              # open the remote netcdf file 
              if(convert2Rdata)nc     <- nc_open(tmpURl)
                
            }
            
          }else{
            # open the local netcdf file 
            if(!is.null(local_path))
                  tmpdest <-  local_path
            if(convert2Rdata) nc <- nc_open(tmpdest)
          }
       
          if(convert2Rdata){
            
            if (!is.null(fileset)) 
              if (!any(vapply(fileset, grepl, logical(1), 
                              x = files_L3use$filename[f], fixed = TRUE))) {
                message("Skipping (fileset filter): ", files_L3use$filename[f])
                next
            }
            
            if(verbose) message(paste(
              paste(tmpfl$filename,": converting nc to rdata data for... ",collapse = "")))
            
            # convert the nc files into a long data.frame for each variable
           
            meta <- data.frame(var = NA, 
                               units = NA_character_, 
                               long_name = NA_character_ )
            
            pb <- txtProgressBar(min = 0, max = length(varlist), style = 3)
            tmpvars <- names(nc$var)
            
            # first make varlist if it is null:
            if(is.null(varlist)) varlist <- tmpvars
             ii<- 0
             
            for (i in seq_along(tmpvars)) {
              if(!tmpvars[i]%in%varlist) next
              
              if(verbose) message(paste(tmpvars[i]))
              ii <- ii + 1
              tmp_var0      <- convert2df(ncIN = nc, 
                                          type = TYPE, 
                                          varIN =  tmpvars[i])
              
              dt_tmp <- tmp_var0%>%select(var,units,long_name)|>unique() |>data.frame()
              meta          <- rbind(meta,dt_tmp)
             
              if(cleanIT)
                tmp_var0 <- tmp_var0%>%select(-units,-long_name)|>data.frame()
              tmp_var0$sim  <- strsplit(tmpfl$filename,".nc")[[1]]
              
              if(ii == 1)
                tmp_var     <- tmp_var0
              if(ii != 1)
                tmp_var     <- rbind(tmp_var,
                                     tmp_var0)
              rm(tmp_var0)
              
              setTxtProgressBar(pb, i)
            } # end for each variable
           
            meta <- meta[-1,]
            close(pb)
        
            # save the nc file in the Data/in/Newest/Rdata/ [ simulation]/Level3 folder
            fl <- file.path( rd_path)
            if(!dir.exists(fl)) dir.create(fl)
            
            fl <- file.path(rd_path,tmp_set[s])
            if(!dir.exists(fl)) dir.create(fl)
            
            fl <- file.path(rd_path,tmp_set[s],"Level3")
            if(!dir.exists(fl)) dir.create(fl)
            
            tmp_path <- tmpdestRda
            save_as(tmp_var, d, tmp_path)
            cat(paste("success:",tmp_path,"created from nc files\n"))
            
            if(cleanIT){
              fl <- file.path(rd_path,tmp_set[s],"META")
              if(!dir.exists(fl)) dir.create(fl)
              tmp_path <- paste0( substr(tmpdestRda,1,nn-6),"_META.Rdata")
              save_as(meta, paste0(d,"_META"), tmp_path)
            }
            rm(tmp_var0)
            rm(tmp_var)
            rm(meta)
          } # if convert2Rdata
          nc_close(nc)
        } # for each file in the model_run_folder
      }# for each model in the set
      
}
