#'
#'
#'Get_hist.R
#'
#'



if(!bystrata){  # survey replicated
  # station specific survey indices (annual)
  cat("    -- get srvy_indices_hist ... \n")
  histA  <-  suppressMessages(make_indices_srvyrep_station(
    simIN = hist_srvy,
    svIN      = sv,
    typeIN     =  "hist",
    STRATA_AREAIN = STRATA_AREA,
    normlistIN = normlist_IN,
    ref_yrs    = 1980:2013,
    seasonsIN   = seasons, 
    type        = "station replicated",
    log_adj    = 1e-4,
    group_byIN    = c("station_id","lognorm","latitude", "longitude",
                      "strata","strata_area_km2","basin","units","sim","long_name","var")))
  
  mn_hist <- histA$mnDat%>%rename(
    mnVal_hist  = mnVal_x,
    sdVal_hist  = sdVal_x,
    nVal_hist   = nVal_x,
    seVal_hist  = seVal_x,
    sdVal_hist_strata = sdVal_x_strata,
    sdVal_hist_yr = sdVal_x_yr)%>%
    ungroup()
  
  hist    <- histA$fullDat%>%rename(
    mnVal_hist  = mnVal_x,
    sdVal_hist  = sdVal_x,
    nVal_hist   = nVal_x,
    seVal_hist  = seVal_x,
    sdVal_hist_strata = sdVal_x_strata,
    sdVal_hist_yr = sdVal_x_yr)%>%
    ungroup()
  
  # convert logit or log trans data back
  hist  <-  unlink_val(indat=hist,
                       log_adj =1e-4,
                       roundn     = 5,
                       listIN = c("mn_val","mnVal_hist"),
                       rmlistIN = c("sdVal_hist", "seVal_hist", "sdVal_hist_strata", "sdVal_hist_yr",
                                    "nVal_hist"))
  
  fl <- file.path("Data/out",CMIP_fdlr,paste0("BC_",subtxt))
  nm <- paste(subtxt,gcmcmip,"BC_hist.R",sep="_")
  save(hist,file=file.path(fl,nm))
  
  rm(list=c("hist","histA","hist_srvy"))
  
}else{
  # area weekly means for each strata
  cat("    -- get strata_indices_weekly_hist ... \n")
  
  histA <- suppressMessages(make_indices_strata(
    simIN       = hist,
    svIN        = sv,
    timeblockIN = c("strata","strata_area_km2",
                    "yr","season","mo","wk"),
    seasonsIN   = seasons,
    type        = "strata weekly means", 
    typeIN      =  "hist", #"hist" "proj"
    ref_yrs     = 1980:2013,
    normlistIN  = normlist_IN,
    group_byIN = c("var","lognorm","basin","strata","strata_area_km2","season","mo","wk"),
    smoothIT    = smoothIT,
    log_adj     = 1e-4))
  
  mn_hist <- histA$mnDat%>%rename(
    mnVal_hist = mnVal_x,
    sdVal_hist    = sdVal_x,
    nVal_hist = nVal_x,
    seVal_hist  = seVal_x,
    sdVal_hist_mo = sdVal_x_mo,
    sdVal_hist_yr = sdVal_x_yr)%>%
    ungroup()
  
  hist    <- histA$fullDat%>%rename(
    mnVal_hist = mnVal_x,
    sdVal_hist = sdVal_x,
    nVal_hist = nVal_x,
    seVal_hist    = seVal_x,
    sdVal_hist_mo = sdVal_x_mo,
    sdVal_hist_yr = sdVal_x_yr)%>%
    ungroup()
  
  # convert logit or log trans data back
  hist  <-  unlink_val(indat    = hist,
                       log_adj  = 1e-4,
                       roundn   = 5,
                       listIN   = c("mn_val","mnVal_hist"),
                       rmlistIN = c("sdVal_hist", "seVal_hist", "sdVal_hist_mo", "sdVal_hist_yr",
                                    "nVal_hist"))
  
  fl <- file.path("Data/out",CMIP_fdlr,paste0("BC_",subtxt))
  nm <- paste(subtxt,gcmcmip,"BC_hist.R",sep="_")
  save(hist,file=file.path(fl,nm))
  
  rm(list=c("hist","histA"))
  
  # #save in temporary file:
  # if(file.exists("data/out/tmp/histIN.Rdata"))
  #   file.remove("data/out/tmp/histIN.Rdata")
  # save(histIN,file="data/out/tmp/histIN.Rdata")
  # rm(list=c("hist","histA","histIN"))
}