get_l3_forecasts <-function(
  rd_path      = file.path(main,Rdata_path),
  local_path   = file.path(local_fl,"roms_for_aclim"),
  strata_grid  = strata_grid,
  basin_grid   = basin_grid,
  cell_area_grid = area_feast,
  fnm          = "EBS_forecast",
  varlist      = c("temp_bottom5m"),
  forcast_vars = "forecast_temp_bottom5m",
  sim_list     = "B10K-K20_CORECFS")
  {
  
  
  
  # create a directory for our new indices 
  if(!dir.exists(rd_path))
    dir.create(rd_path)
  
  
  # now grab dattat for the hindcast and projection sets:
  for(m in sim_list){
    
    # create the simulation Level3 folder (and overwrite it if overwrite is set to T)
    if(!dir.exists(file.path(rd_path,m)))
      dir.create((file.path(rd_path,m)))
    if(!dir.exists(file.path(rd_path,m,"/Level3")))
      dir.create((file.path(rd_path,m,"/Level3")))
    
    for(d in fnm){
      for(v in varlist){
        # create filename:
        tmp_fl  <- paste0(m,"_2021forecast_",v)
        tmppath <- file.path(local_path,paste0(m,"/Level3/",tmp_fl,".nc"))
        
        # open the local netcdf file 
        nc     <- nc_open(tmppath)
        
        # convert the nc files into a long data.frame for each variable
        i <- 0
        #for(vv in names(nc[[14]])){
        for(vv in forcast_vars){
          i <- i + 1
          tmp_var0      <- convert2df_forecast(ncIN = nc, 
                                               strata_gridIN    = strata_grid,
                                               basin_gridIN     = basin_grid,
                                               cell_area_gridIN = cell_area_grid,
                                               varIN = vv)
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
        cat(paste("success:",tmp_path,"created from nc files\n"))
      }
    }
  }
}