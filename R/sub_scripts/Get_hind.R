#'
#'
#'
#'Get_hind.R
#'
#'

if(!bystrata){  # get survey replicated
  cat("    -- get srvy_indices_hind ... \n")
  hindA  <-  suppressMessages(make_indices_srvyrep_station(
    simIN      = hnd_srvy,
    svIN       = sv,
    typeIN     =  "hind",
    STRATA_AREAIN = STRATA_AREA,
    normlistIN    = normlist_IN,
    ref_yrs       = 1980:2013,
    seasonsIN     = seasons, 
    type          = "station replicated",
    log_adj       = 1e-4,
    group_byIN    = c("station_id","lognorm","latitude", "longitude",
                      "strata","strata_area_km2","basin","units","sim","long_name","var")))
  
  mn_hind <- hindA$mnDat%>%rename(
    mnVal_hind  = mnVal_x,
    sdVal_hind  = sdVal_x,
    nVal_hind   = nVal_x,
    seVal_hind  = seVal_x,
    sdVal_hind_strata = sdVal_x_strata,
    sdVal_hind_yr = sdVal_x_yr)%>%
    ungroup()
  
  hind    <- hindA$fullDat%>%rename(
    mnVal_hind  = mnVal_x,
    sdVal_hind  = sdVal_x,
    nVal_hind   = nVal_x,
    seVal_hind  = seVal_x,
    sdVal_hind_strata = sdVal_x_strata,
    sdVal_hind_yr = sdVal_x_yr)%>%
    ungroup()
  
  # convert logit or log trans data back
  hind  <-  unlink_val(indat=hind,
                       log_adj =1e-4,
                       roundn     = 5,
                       listIN = c("mn_val","mnVal_hind"),
                       rmlistIN = c("sdVal_hind", "seVal_hind", "sdVal_hind_strata", "sdVal_hind_yr",
                                    "nVal_hind"))
  
  if(!dir.exists(file.path("Data/out",CMIP_fdlr)))
    dir.create(file.path("Data/out",CMIP_fdlr))
  if(dir.exists(file.path("Data/out",CMIP_fdlr,paste0("BC_",subtxt)))){
    dir.remove(file.path("Data/out",CMIP_fdlr,paste0("BC_",subtxt)))
  }
  dir.create(file.path("Data/out",CMIP_fdlr,paste0("BC_",subtxt)))
  fl <- file.path("Data/out",CMIP_fdlr,paste0("BC_",subtxt))
  nm <- paste(subtxt,hind_sim,"BC_hind.R",sep="_")
  save(hind,file=file.path(fl,nm))
  
  rm(list=c("hnd_srvy","hindA","hind"))
}else{
  # area weekly means for each strata
  cat("    -- get strata_indices_weekly_hind ...\n")
  # strata_indices_weekly_hind 
  hindA <- suppressMessages(make_indices_strata(
    simIN = hnd,
    svIN = sv,
    timeblockIN = c("strata","strata_area_km2",
                    "yr","season","mo","wk"),
    seasonsIN   = seasons,
    type        = "strata weekly means", 
    typeIN     =  "hind", #"hist" "proj"
    ref_yrs    = 1980:2013,
    normlistIN = normlist_IN,
    group_byIN = c("var","lognorm","basin","strata","strata_area_km2","season","mo","wk"),
    smoothIT     = smoothIT,
    log_adj    = 1e-4))
  
  mn_hind <- hindA$mnDat%>%rename(
    mnVal_hind  = mnVal_x,
    sdVal_hind  = sdVal_x,
    nVal_hind   = nVal_x,
    seVal_hind  = seVal_x,
    sdVal_hind_mo = sdVal_x_mo,
    sdVal_hind_yr = sdVal_x_yr)%>%
    ungroup()
  
  hind    <- hindA$fullDat%>%rename(
    mnVal_hind  = mnVal_x,
    sdVal_hind  = sdVal_x,
    nVal_hind   = nVal_x,
    seVal_hind  = seVal_x,
    sdVal_hind_mo = sdVal_x_mo,
    sdVal_hind_yr = sdVal_x_yr)%>%
    ungroup()
  
  # convert logit or log trans data back
  hind  <-  unlink_val(indat=hind,
                       log_adj =1e-4,
                       roundn     = 5,
                       listIN = c("mn_val","mnVal_hind"),
                       rmlistIN = c("sdVal_hind", "seVal_hind", "sdVal_hind_mo", "sdVal_hind_yr",
                                    "nVal_hind"))
  
  if(!dir.exists(file.path("Data/out",CMIP_fdlr)))
    dir.create(file.path("Data/out",CMIP_fdlr))
  if(dir.exists(file.path("Data/out",CMIP_fdlr,paste0("BC_",subtxt)))){
    dir.remove(file.path("Data/out",CMIP_fdlr,paste0("BC_",subtxt)))
  }
  dir.create(file.path("Data/out",CMIP_fdlr,paste0("BC_",subtxt)))
  fl <- file.path("Data/out",CMIP_fdlr,paste0("BC_",subtxt))
  nm <- paste(subtxt,hind_sim,"BC_hind.R",sep="_")
  save(hind,file=file.path(fl,nm))
  
  rm(list=c("hnd","hindA","hind"))
  
  # save hindcast indices:
  # keep hind_clim in the loop
  
  # if(dir.exists("data/out/tmp"))
  #   dir.remove("data/out/tmp")
  #  dir.create("data/out/tmp")
  #save(hindIN,file="data/out/tmp/hindIN.Rdata")
  #rm(list=c("hnd","hindA","hindIN"))
  
}