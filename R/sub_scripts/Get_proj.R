#'
#'
#'
#'Get_proj.R
#'



if(!bystrata){  # station specific survey indices (annual)
  # station specific survey indices (annual)
  cat("    -- get srvy_indices_proj... \n")
  projA  <-  suppressMessages(make_indices_srvyrep_station(
    simIN       = proj_srvy,
    svIN        = sv,
    typeIN      =  "proj",
    STRATA_AREAIN = STRATA_AREA,
    normlistIN  = normlist_IN,
    ref_yrs     = 1980:2013,
    seasonsIN   = seasons, 
    type        = "station replicated",
    log_adj     = 1e-4,
    group_byIN    = c("station_id","lognorm","latitude", "longitude",
                      "strata","strata_area_km2","basin","units","sim","long_name","var")))
  
  mn_fut <- projA$mnDat%>%rename(
    mnVal_fut  = mnVal_x,
    sdVal_fut  = sdVal_x,
    nVal_fut   = nVal_x,
    seVal_fut  = seVal_x,
    sdVal_fut_strata = sdVal_x_strata,
    sdVal_fut_yr = sdVal_x_yr)%>%
    ungroup()
  
  futraw    <- projA$fullDat%>%rename(
    mnVal_fut  = mnVal_x,
    sdVal_fut  = sdVal_x,
    nVal_fut   = nVal_x,
    seVal_fut  = seVal_x,
    sdVal_fut_strata = sdVal_x_strata,
    sdVal_fut_yr = sdVal_x_yr)%>%
    ungroup()
  
  rm(list=c("proj_srvy","projA"))
}else{
  # area weekly means for each strata
  cat("        -- get strata_indices_weekly_fut ... \n")
  projA <- suppressMessages(make_indices_strata(
    simIN = proj_wk,
    svIN = sv,
    timeblockIN = c("strata","strata_area_km2",
                    "yr","season","mo","wk"),
    seasonsIN   = seasons,
    type        = "strata weekly means", 
    typeIN     =  "proj", #"hist" "proj"
    ref_yrs    = 1980:2013,
    normlistIN = normlist_IN,
    group_byIN = c("var","lognorm","basin","strata","strata_area_km2","season","mo","wk"),
    smoothIT     = smoothIT,
    log_adj    = 1e-4))
  
  mn_fut <- projA$mnDat%>%rename(
    mnVal_fut = mnVal_x,
    sdVal_fut    = sdVal_x,
    nVal_fut = nVal_x,
    seVal_fut  = seVal_x,
    sdVal_fut_mo = sdVal_x_mo,
    sdVal_fut_yr = sdVal_x_yr)%>%
    ungroup()
  
  futraw<- projA$fullDat%>%rename(
    mnVal_fut = mnVal_x,
    sdVal_fut = sdVal_x,
    nVal_fut = nVal_x,
    seVal_fut    = seVal_x,
    sdVal_fut_mo = sdVal_x_mo,
    sdVal_fut_yr = sdVal_x_yr)%>%
    ungroup()
  
  
  # #save in temporary file:
  # if(file.exists("data/out/tmp/futIN.Rdata"))
  #   file.remove("data/out/tmp/futIN.Rdata")
  # save(futIN,file="data/out/tmp/futIN.Rdata")
  # rm(list=c("proj_wk","projA","mn_fut"))
  rm(list=c("proj_wk","projA"))
}