#'
#'
#'
#' makeACLIM_operational_hind.R
#' 
#'
#'Author: Kirstin Holsman
#'kirstin.holsman@noaa.gov
#'
#'This script will created the ACLIM indices
#'
#'


makeACLIM2_operational_Indices_new <- function(
  
  # switches
  bystrata  = TRUE, #if false do survey rep, if true do strata estimates
  sv        = NULL,
  smoothIT  = TRUE,
  usehist   = TRUE,
  gcinfoIN  = FALSE,
  # setup 
  BC_target = "mn_val",
  CMIP_fdlr = "K20P19_CMIP6",
  scenIN    =  c("ssp126","ssp585"),
  hind_sim  = "B10K-K20_CORECFS",
  regnm     = "ACLIMregion",
  srvynm    = "ACLIMsurveyrep",
  # data
  histLIST,
  Rdata_pathIN = Rdata_path,
  normlist_IN = normlist,
  gcmcmipLIST = c("B10K-K20P19_CMIP6_miroc","B10K-K20P19_CMIP6_gfdl","B10K-K20P19_CMIP6_cesm"),
  sim_listIN){
  
  
  reg_txtIN  = paste0("Level3/",regnm,"_")
  srvy_txtIN = paste0("Level3/",srvynm,"_")
  gcinfo(gcinfoIN)
  # ------------------------------------
  # 1  -- Create indices from Hindcast
  cat("-- Starting analysis...\n")
  
  # load the Hindcast:
  # -------------------------
  cat("    -- making hindcast indices....\n")
  sim  <- hind_sim
  # Load data
  cat("-------------------------\n Get hindcast indices \n------------------------\n")
  cat("Load data \n")
  
  if(bystrata) {
    cat("loading hnd\n")
    load(file.path(Rdata_pathIN,file.path(sim,paste0(reg_txtIN,sim,".Rdata"))))
    eval(parse(text=paste0("hnd       <- ",regnm,"; rm(",regnm,")")))
    if(is.null(sv))
      sv <- unique(normlist_IN$var)
    subtxt <- regnm
  }else{
    cat("loading hnd_srvy: ",file.path(Rdata_pathIN,file.path(sim,paste0(srvy_txtIN,sim,".Rdata"))),"\n")
    load(file.path(Rdata_pathIN,file.path(sim,paste0(srvy_txtIN,sim,".Rdata"))))
    eval(parse(text=paste0("hnd_srvy  <- ",srvynm,"; rm(",srvynm,")")))
    
    if(is.null(sv))
      sv <-  unique(normlist_IN$var)
    subtxt <- srvynm
  }
  
  
  # Get Indices: 
  # -------------------------
  cat("Get indices \n")
  
  if(!bystrata){  # get survey replicated
    cat("    -- get srvy_indices_hind ... \n")
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
    
    rmlistIN <- c("sdVal_hind", "seVal_hind", 
                  "sdVal_hind_strata", "sdVal_hind_yr",
                  "nVal_hind")
    
    hind    <- hindA$fullDat%>%rename(
      mnVal_hind  = mnVal_x,
      sdVal_hind  = sdVal_x,
      nVal_hind   = nVal_x,
      seVal_hind  = seVal_x,
      sdVal_hind_strata = sdVal_x_strata,
      sdVal_hind_yr = sdVal_x_yr)%>%select(-all_of(rmlistIN))%>%
      ungroup()
    
    # # convert logit or log trans data back
    # hind  <-  unlink_val(indat=hind,
    #                      log_adj  = 1e-4,
    #                      roundn   = 5,
    #                      listIN   = c("mn_val","mnVal_hind"),
    #                      rmlistIN = c("sdVal_hind", "seVal_hind", "sdVal_hind_strata", "sdVal_hind_yr",
    #                                   "nVal_hind"))
    # # convert logit or log trans data back
    # hind  <-  unlink_val(indat=hind,
    #                      log_adj =1e-4,
    #                      roundn     = 5,
    #                      listIN = c("mn_val","mnVal_hind"),
    #                      rmlistIN = c("sdVal_hind", "seVal_hind", "sdVal_hind_strata", "sdVal_hind_yr",
    #                                   "nVal_hind"))
    # 
    if(!dir.exists(file.path("Data/out",CMIP_fdlr)))
      dir.create(file.path("Data/out",CMIP_fdlr))
    if(!dir.exists(file.path("Data/out",CMIP_fdlr,paste0("BC_",subtxt))))
      dir.create(file.path("Data/out",CMIP_fdlr,paste0("BC_",subtxt)))
    fl <- file.path("Data/out",CMIP_fdlr,paste0("BC_",subtxt))
    nm <- paste(subtxt,hind_sim,"BC_hind.Rdata",sep="_")
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
      seasonsIN  = seasons,
      type       = "strata weekly means", 
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
    rmlistIN <- c("sdVal_hind", "seVal_hind", "sdVal_hind_mo", "sdVal_hind_yr",
                  "nVal_hind")
    hind    <- hindA$fullDat%>%rename(
      mnVal_hind  = mnVal_x,
      sdVal_hind  = sdVal_x,
      nVal_hind   = nVal_x,
      seVal_hind  = seVal_x,
      sdVal_hind_mo = sdVal_x_mo,
      sdVal_hind_yr = sdVal_x_yr)%>%
      select(-all_of(rmlistIN))%>%
      ungroup()
    # 
    # # convert logit or log trans data back
    # hind  <-  unlink_val(indat=hind,
    #                      log_adj =1e-4,
    #                      roundn     = 5,
    #                      listIN = c("mn_val","mnVal_hind"),
    #                      rmlistIN = c("sdVal_hind", "seVal_hind", "sdVal_hind_mo", "sdVal_hind_yr",
    #                                   "nVal_hind"))
    
    if(!dir.exists(file.path("Data/out",CMIP_fdlr)))
      dir.create(file.path("Data/out",CMIP_fdlr))
    if(!dir.exists(file.path("Data/out",CMIP_fdlr,paste0("BC_",subtxt))))
      dir.create(file.path("Data/out",CMIP_fdlr,paste0("BC_",subtxt)))
    fl <- file.path("Data/out",CMIP_fdlr,paste0("BC_",subtxt))
    nm <- paste(subtxt,hind_sim,"BC_hind.Rdata",sep="_")
    save(hind,file=file.path(fl,nm))
    
    rm(list=c("hnd","hindA","hind"))
    
  }
  
  return("complete")
}


