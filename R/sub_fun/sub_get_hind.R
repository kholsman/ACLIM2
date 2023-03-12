#'
#'
#'
#' sub_get_hind.R
#' 
#' 
#' 


sub_get_hind<-function(sim = hind_sim,
                       reg_txtIN = reg_txtIN,
                       srvy_txtIN = srvy_txtIN,
                       subtxt = subtxt,
                       fl = fl,
                       bystrata  = bystrata, #if false do survey rep, if true do strata estimates
                       sv        = sv,
                       sfIN      = sfIN,
                       smoothIT  = smoothIT,
                       usehist   = usehist,
                       gcinfoIN  = gcinfoIN,
                       ref_yrsIN = ref_yrsIN,
                       BC_target = BC_target,
                       CMIP_fdlr = CMIP_fdlr,
                       scenIN    =  scenIN,
                       regnm     = regnm,
                       srvynm    = srvynm,
                       histLIST =histLIST,
                       Rdata_pathIN = Rdata_pathIN,
                       normlist_IN = normlist_IN,
                       gcmcmipLIST = gcmcmipLIST,
                       sim_listIN = sim_listIN){
  

cat("-------------------------\n Get hindcast indices (takes 5-10 mins) \n------------------------\n")
  cat("hind_sim: ", sim)
# Load data
# -------------------------
  if(bystrata) {
    cat(" -- loading hnd\n")
    load(file.path(Rdata_pathIN,file.path(sim,paste0(reg_txtIN,sim,".Rdata"))))
    eval(parse(text=paste0("hnd       <- ",regnm,"; rm(",regnm,")")))
    gc()
  }else{
    cat(" -- loading hnd_srvy: ",file.path(Rdata_pathIN,file.path(sim,paste0(srvy_txtIN,sim,".Rdata"))),"\n")
    load(file.path(Rdata_pathIN,file.path(sim,paste0(srvy_txtIN,sim,".Rdata"))))
    eval(parse(text=paste0("hnd_srvy  <- ",srvynm,"; rm(",srvynm,")")))
    gc()
  }


# Get Indices: 
# -------------------------
cat(" -- Get indices \n")

  if(!bystrata){  # get survey replicated
    cat("    -- get srvy_indices_hind ... \n")
    hindA  <-  suppressMessages(make_indices_srvyrep_station(
      simIN      = hnd_srvy,
      svIN       = sv,
      typeIN     =  "hind",
      STRATA_AREAIN = STRATA_AREA,
      normlistIN    = normlist_IN,
      ref_yrs       = ref_yrsIN,
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
    
    # if(!dir.exists(file.path("Data/out",CMIP_fdlr)))
    #   dir.create(file.path("Data/out",CMIP_fdlr))
    # dir.create(file.path("Data/out",CMIP_fdlr,paste0("BC_",subtxt)))
    # 
    
    rm(list=c("hnd_srvy","hindA"))
    gc()
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
      ref_yrs    = ref_yrsIN,
      normlistIN = normlist_IN,
      group_byIN = c("var","lognorm","basin","strata","strata_area_km2","season","mo","wk"),
      smoothIT     = smoothIT,
      log_adj    = 1e-4))
    startB2 <- Sys.time()
    
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
    
    rm(list=c("hnd","hindA"))
    gc()
    
  }

  nm <- paste(subtxt,sim,"BC_hind.Rdata",sep="_")
  #nm <- "BC_hind.Rdata"
  save(hind,file=file.path(fl,nm))
  
  #nm <- paste(subtxt,hind_sim,"BC_mn_hind.Rdata",sep="_")
  nm <-  paste(subtxt,sim,"BC_mn_hind.Rdata",sep="_")
  save(mn_hind,file=file.path(fl,nm))
}
