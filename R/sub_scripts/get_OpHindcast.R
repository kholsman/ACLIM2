#'
#'
#'
#'
#'
#'get_OpHindcast
#'
#'Get the operational hindcast and covert to ACLIM indices
#'
  #source("R/make.R") 
  #thisYr <- format(Sys.time(), "%Y")
  load(paste0("../../romsnpz/",tmstp,"_Rdata/l3srvy_varlist.Rdata"))
  load(paste0("../../romsnpz/",tmstp,"_Rdata/l3wk_varlist.Rdata"))
  
  main <- getwd()

  varlist <- c("largeZoop_integrated","fracbelow2",
               "temp_bottom5m","temp_surface5m","pH_depthavg")
  varlist  <- c(srvy_vars,weekly_vars)
  server_files <- c(
    "ACLIMregion_B10K-K20_CORECFS.nc",
    "ACLIMsurveyrep_B10K-K20_CORECFS.nc",
   # "B10K-K20_CORECFS_2021forecast_temp_bottom5m.nc",
    "B10K-K20_CORECFS_2022forecast_temp_bottom5m.nc",
    "B10K-K20_CORECFS_coldpool.nc")

  # getfiles and save locally
  #-----------------------------------
    local_file <- "Data/in/2022_10_17/operationalHindForcast"
    if(!dir.exists(local_file)) dir.create(local_file)
    URL_base1<-"https://data.pmel.noaa.gov/aclim/thredds/dodsC/files/B10K-K20_CORECFS/Level3/"
    URL_base<-"https://data.pmel.noaa.gov/aclim/thredds/fileServer/files/B10K-K20_CORECFS/Level3/"
    
    if(1==10){
      for(i in 1:length(server_files)){
        download.file(url = paste0(URL_base,server_files[i]),
                      destfile =paste0(file.path(main,local_file),
                                       "/",basename(server_files[i])), 
                      overwrite = T)
      }
    }
  # convert nc files to Rdata_path
  # ---------------------------------

    

  # create filename:
    nc_tmppath  <- paste0(file.path(main,local_file),
                          "/",basename(server_files[i]))
    rd_tmppath <- file.path(rd_path)
    if(!dir.exists(rd_tmppath))   dir.create(file.path(rd_tmppath))
    if(!dir.exists(file.path(rd_path,"OperationalHindcast"))) 
      dir.create(file.path(file.path(rd_path,"OperationalHindcast")))
    if(!dir.exists(file.path(rd_path,"OperationalHindcast","Level3"))) 
      dir.create(file.path(file.path(rd_path,"OperationalHindcast","Level3")))
    
  
  # open the netcdf file 
  #---------------------------------------------
  nc         <- nc_open(paste0(URL_base1,"ACLIMregion_B10K-K20_CORECFS.nc")) #Forecasts
  
  
  verbose    <- T
  cc<-which(l3wk_varlist%in%c("alkalinity_bottom5m","oxygen_depthavg","pH_depthavg","calcite_depthavg","arag_depthavg"))
  cc<-c(grep("alkalinity",l3wk_varlist),
        grep("oxygen",l3wk_varlist),
        grep("pH",l3wk_varlist),
        grep("calcite",l3wk_varlist),
        grep("TIC",l3wk_varlist),
        grep("arag",l3wk_varlist))
  
  
  l3wk_varlistOP <-l3wk_varlist[-cc]
  save(l3wk_varlistOP,file=file.path(rd_path,"l3wk_varlistOP.Rdata"))
        
  # convert the nc files into a long data.frame for each variable
  i <- 0
  if(verbose) cat("Convert variable: ")
  for(v in l3wk_varlist[-cc]){
    i <- i + 1
    if(verbose) cat(v,"...")
    tmp_var0      <- convert2df(ncIN = nc, 
                                type = 1, #1 weekly ; 2 = srvy
                                varIN = v,
                                weekly_varsIN = l3wk_varlist,
                                srvy_varsIN   = l3srvy_varlist)
    tmp_var0$sim  <- "OperationalHindcast" #paste0("Hindcast",thisYr)
    if(i == 1)
      tmp_var     <- tmp_var0
    if(i != 1)
      tmp_var     <- rbind(tmp_var,
                           tmp_var0)
    rm(tmp_var0)
  }
  ACLIMregion <- tmp_var
  save(ACLIMregion,file=file.path(rd_path,"OperationalHindcast/Level3/ACLIMregion_OperationalHindcast.Rdata"))
  # close the nc file
  nc_close(nc)
  rm(tmp_var)
  
  
  # open the netcdf file 
  #---------------------------------------------
  nc         <- nc_open(paste0(URL_base1,"ACLIMsurveyrep_B10K-K20_CORECFS.nc")) #Forecasts
  
  verbose    <- T
  cc<-c(grep("alkalinity",l3wk_varlist),
        grep("oxygen",l3wk_varlist),
        grep("pH",l3wk_varlist),
        grep("calcite",l3wk_varlist),
        grep("TIC",l3wk_varlist),
        grep("arag",l3wk_varlist))
  
  l3srvy_varlistOP <-l3srvy_varlist[-cc]
  save(l3srvy_varlistOP,file=file.path(rd_path,"l3srvy_varlistOP.Rdata"))
  
  # convert the nc files into a long data.frame for each variable
  i <- 0
  if(verbose) cat("Convert variable: ")
  for(v in l3srvy_varlist[-cc]){
    i <- i + 1
    if(verbose) cat(v,"...")
    tmp_var0      <- convert2df(ncIN = nc, 
                                type = 2, #1 weekly ; 2 = srvy
                                varIN = v,
                                weekly_varsIN = l3wk_varlist,
                                srvy_varsIN   = l3srvy_varlist)
    tmp_var0$sim  <- "OperationalHindcast" # paste0("Hindcast",thisYr)
    if(i == 1)
      tmp_var     <- tmp_var0
    if(i != 1)
      tmp_var     <- rbind(tmp_var,
                           tmp_var0)
    rm(tmp_var0)
  }
  ACLIMsurveyrep <- tmp_var
  save(ACLIMsurveyrep,file=file.path(rd_path,"OperationalHindcast/Level3/ACLIMsurveyrep_OperationalHindcast.Rdata"))
  # close the nc file
  nc_close(nc)
  rm(tmp_var)
  
  
  # open the netcdf file 
  #---------------------------------------------
  nc         <- nc_open(paste0(URL_base1,"B10K-K20_CORECFS_2022forecast_temp_bottom5m.nc")) #Forecasts
  # convert the nc files into a long data.frame for each variable
  i <- 0
  forcast_vars <- c("forecast_temp_bottom5m","anom_temp_bottom5m","clima_temp_bottom5m","climatology_bnds")
  #for(vv in names(nc[[14]])){
  for(vv in "forecast_temp_bottom5m"){
    i <- i + 1
    tmp_var0      <- convert2df_forecast(ncIN = nc, 
                                         strata_gridIN    = strata_grid,
                                         basin_gridIN     = basin_grid,
                                         cell_area_gridIN = area_feast,
                                         varIN = vv)
    tmp_var0$sim  <- "OperationalForecast" #paste0("Forecast",thisYr)
    if(i == 1)
      tmp_var     <- tmp_var0
    if(i != 1)
      tmp_var     <- rbind(tmp_var,
                           tmp_var0)
    rm(tmp_var0)
  }
  forecast_temp_bottom5m <- tmp_var
  save(forecast_temp_bottom5m,file=file.path(rd_path,"OperationalHindcast/Level3/forecast_temp_bottom5m.Rdata"))
  
  nc_close(nc)
  rm(tmp_var)
  
  
  
  nc  <- nc_open(paste0(URL_base1,"B10K-K20_CORECFS_coldpool.nc")) #Forecasts
  i   <- 0
  #for(vv in names(nc[[14]])){
  #"average_bottom_temp"
  for(vv in c("cold_pool_index")){
    i <- i + 1
    tmp_var0      <- convert2df_coldpool(ncIN = nc,
                                         varIN = vv)
    tmp_var0$sim  <- paste0("ColdPool",thisYr)
    if(i == 1)
      tmp_var     <- tmp_var0
    if(i != 1)
      tmp_var     <- rbind(tmp_var,
                           tmp_var0)
    rm(tmp_var0)
  }
  coldpool <- tmp_var
  save(coldpool,file=file.path(rd_path,"OperationalHindcast/Level3/coldpool.Rdata"))
  
  nc_close(nc)
  rm(tmp_var)
  
  
  
  
