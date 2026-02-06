#'
#'
#'
#'get_ACLIM_nc_thredds_data.R
#'
#'
 

# you can also use the ACLIM function
# get_l3(from_thredds = F, download_nc = F,
#       local_path = file.path(local_fl,"roms_for_aclim"),
#       varlist = vl,sim_list = sl)
  # ========================================
  # switches & settings
  # ========================================
 
   # ~/Documents/GitHub_mac/ACLIM2/Vignettes/get_ACLIM_nc_thredds_data.R
    library(here)
    main <- "~/Documents/GitHub_mac/ACLIM2"
    source(here(main,"R/make.R")) |> suppressMessages()

    tmstp    <- "2026_02_05"
    #tmstp  <- format(Sys.time(), "%Y%m%d")
   
    local_fl <- file.path(main,"Data/in",tmstp)
    Rdata_path   <- file.path(local_fl,"Rdata_files")
    nc_data_path <- file.path(local_fl,"nc_files")
    
    if(!file.exists(local_fl)) dir.create(local_fl)
    if(!file.exists(Rdata_path)) dir.create(Rdata_path)
    if(!file.exists(nc_data_path)) dir.create(nc_data_path)
    
    
    update_biascorrection <- TRUE # set to true to update the bias correction
    update_CMIP6 <- TRUE    # will re-download the nc files from the thredds server
    update_CMIP5 <- TRUE   # will re-download the nc files from the thredds server
    update_l2    <- TRUE      # will re-download the level 2 files form the thredds server - slow!
    
    source(here("R/fun_aclim_thredds_util.R"))
    
    
    if(update_l3){  
      
      # now get the L2 and L3 data:
      sims <- aclim_thredds(section = "files")
      head(sims)
      model_runs<-sims
      #save(model_runs,file = file.path(Rdata_path,"model_runs.Rdata"))
      save_as(sims, model_runs, file = file.path(Rdata_path,"model_runs.Rdata"))
      # what are the sub folders?
      aclim_thredds(run = sims[2])

      files_L3 <- aclim_thredds(run =sims[2], level = 3)
      files_L3
      
      # ---- Get the CMIP5 set ----
      if(update_CMIP5){
        message("Updating CMIP5 set, may take a while...")
        
        tmp_set <- sims[grep("H16",sims)]
        for(s in seq_along(tmp_set) ) 
        {
          files_L3 <- aclim_thredds(run =tmp_set[s], level = 3)
          # ignore the _C files bc they are holdovers from bridging activities
          #files_L3use <-files_L3[-grep("_C_",files_L3$filename),]
          files_L3use <- files_L3
          for(f in seq(files_L3use$filename)){
            
            # make the folder:
            tmpURl  <- files_L3use$download_url[f]
            tmpdest <-  make_fldr(list_obj = files_L3use[f,])
            # download the file:
            thredds_download_nc(url = tmpURl,
                                dest = tmpdest,
                                cache_dir = "~/.aclim_cache",
                                overwrite = TRUE)
            
          }
          
        }
      }
      
      # ---- Get the CMIP6 set ----
      if(update_CMIP6){
        message("Updating CMIP6 set, may take a while...")
        tmp_set <- sims[grep("K20P19_",sims)]
        for(s in seq_along(tmp_set) ) 
        {
          
          files_L3 <- aclim_thredds(run =tmp_set[s], level = 3)
          # ignore the _C files bc they are holdovers from bridging activities
          #files_L3use <-files_L3[-grep("_C_",files_L3$filename),]
          files_L3use<-files_L3
          for(f in seq_along(files_L3use$filename)){
            
            # make the folder:
            tmpURl  <- files_L3use$download_url[f]
            tmpdest <-  make_fldr(list_obj = files_L3use[f,])
            
            # download the file:
            thredds_download_nc(url = tmpURl,
                                dest = tmpdest,
                                cache_dir = "~/.aclim_cache",
                                overwrite = TRUE)
            
          }
          
        }
      }
    }
    message("completed L3 Downloads")
    
    if(update_l2){
        message("now updating the L2 data, may take a while...")
        # first get the updated grid for L2 files:
        anc <- aclim_thredds(section = "ancillary")
        anc
        
        for(i in seq(anc$filename)){
          thredds_download_nc(url = anc$download_url[i],
                              dest = file.path(nc_data_path,anc$filename[i]),
                              cache_dir = "~/.aclim_cache",
                              overwrite = TRUE)
        }
        
        # now get L2 files
        sims <- aclim_thredds(section = "files")
        head(sims)
        
        # what are the sub folders
        aclim_thredds(run = sims[2])
        
        L2_time_periods <- aclim_thredds(run =sims[2], level = 2)
        L2_time_periods
        
        L2_files <- aclim_thredds(run =sims[2], level = 2, time_period = L2_time_periods[1] )
        L2_files$variable
        
        # example - get avg bottom temp
        ll <- which(L2_files$variable =="average_temp_bottom5m")
        
        tmpURL <- L2_files$download_url[ll]
        
        tmpdest <- make_fldr(list_obj = L2_files[ll,])
        
        thredds_download_nc(url = L2_files$download_url[ll],
                            dest = tmpdest,
                            cache_dir = "~/.aclim_cache",
                            overwrite = TRUE)
        
        # get all bottom temps:
        L2_files$variable
        l2varset <- "average_temp_bottom5m"
        if(update_l2){
          for(v in seq_along(l2varset)){
            for(s in seq_along(sims)){
              message(paste("getting L2 data for ",sims[s],"..."))
              L2_time_periods <- aclim_thredds(run =sims[s], 
                                               level = 2)
              L2_time_periods
              
              
              for(t in seq_along(L2_time_periods)){
                
                L2_files <- aclim_thredds(run =sims[s], 
                                          level = 2, 
                                          time_period = L2_time_periods[t] )
                
                ll <- which(L2_files$variable ==varset[v])
                
                tmpURL <- L2_files$download_url[ll]
                
                tmpdest <- make_fldr(list_obj = L2_files[ll,])
                
                thredds_download_nc(url = L2_files$download_url[ll],
                                    dest = tmpdest,
                                    cache_dir = "~/.aclim_cache",
                                    overwrite = TRUE)
              }
            }
          }
          
          
          
        }
        
      }
      
    message("completed L2 Downloads")
    