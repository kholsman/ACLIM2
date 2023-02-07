#'
#'
#'
#'makeACLIM2_BC_Indices_new()
#'
#'Author: Kirstin Holsman
#'kirstin.holsman@noaa.gov
#'
#'This script will created the ACLIM indices and 
#'    correct the CMIP6 projections using the 
#'    hindcast and historical simulations
#'
#'

# 1  -- Create indices from Hindcast and save
# 2  -- loop across GCMs and create historical run indices & save
# 3  -- create projection indices
# 4  -- bias correct the projections
# 5  -- save results

makeACLIM2_BC_Indices_new <- function(

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
                         log_adj  = 1e-4,
                         roundn   = 5,
                         listIN   = c("mn_val","mnVal_hind"),
                         rmlistIN = c("sdVal_hind", "seVal_hind", "sdVal_hind_strata", "sdVal_hind_yr",
                                      "nVal_hind"))
    
    if(!dir.exists(file.path("Data/out",CMIP_fdlr)))
      dir.create(file.path("Data/out",CMIP_fdlr))
    if(dir.exists(file.path("Data/out",CMIP_fdlr,paste0("BC_",subtxt)))){
      dir.remove(file.path("Data/out",CMIP_fdlr,paste0("BC_",subtxt)))
    }
    dir.create(file.path("Data/out",CMIP_fdlr,paste0("BC_",subtxt)))
    fl <- file.path("Data/out",CMIP_fdlr,paste0("BC_",subtxt))
    nm <- paste(subtxt,hind_sim,"BC_hind.Rdata",sep="_")
    save(hind,file=file.path(fl,nm))
    nm <- paste(subtxt,hind_sim,"BC_mn_hind.Rdata",sep="_")
    save(mn_hind,file=file.path(fl,nm))
    
    # if(!dir.exists(file.path("Data/out",CMIP_fdlr,"bc_mnVals")))
    #   dir.create(file.path("Data/out",CMIP_fdlr,"bc_mnVals"))
    # fl <- file.path("Data/out",CMIP_fdlr,"bc_mnVals")
    # nm <- paste(subtxt,hind_sim,"BC_mnVal_hind.Rdata",sep="_")
    # save(mn_hind,file=file.path(fl,nm))
    
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
    nm <- paste(subtxt,hind_sim,"BC_hind.Rdata",sep="_")
    save(hind,file=file.path(fl,nm))
    nm <- paste(subtxt,hind_sim,"BC_mn_hind.Rdata",sep="_")
    save(mn_hind,file=file.path(fl,nm))
    
    rm(list=c("hnd","hindA","hind"))
    
  }
 
 
  # ------------------------------------
  # 2  -- loop across GCMs and create historical run indices
  
  i  <- 0
  ii <- 1
  for( ii in 1:length(gcmcmipLIST)){
    
    gcmcmip <- gcmcmipLIST[ii]
    simL    <- sim_listIN[sim_listIN%in%paste0(gcmcmip,"_",rep(scenIN,1,each=length(gcmcmip)))]
    
    if(usehist){
      cat("-------------------------\n Get historical indices \n------------------------\n")
      sim     <- histLIST[ii]
      
      cat("Load data \n")
      
      if(bystrata) {
        load(file.path(Rdata_pathIN,file.path(sim,paste0(reg_txtIN,sim,".Rdata"))))
        eval(parse(text=paste0("hist       <- ",regnm,"; rm(",regnm,")")))
        
      }else{
       
        load(file.path(Rdata_pathIN,file.path(sim,paste0(srvy_txtIN,sim,".Rdata"))))
        eval(parse(text=paste0("hist_srvy  <- ",srvynm,"; rm(",srvynm,")")))
      }
      
      cat("Get indices \n")
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
        nm <- paste(subtxt,gcmcmip,"BC_hist.Rdata",sep="_")
        save(hist,file=file.path(fl,nm))
        nm <- paste(subtxt,gcmcmip,"BC_mn_hist.Rdata",sep="_")
        save(mn_hist,file=file.path(fl,nm))
        
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
        nm <- paste(subtxt,gcmcmip,"BC_hist.Rdata",sep="_")
        save(hist,file=file.path(fl,nm))
        nm <- paste(subtxt,gcmcmip,"BC_mn_hist.Rdata",sep="_")
        save(mn_hist,file=file.path(fl,nm))
        
        rm(list=c("hist","histA"))
        
        # #save in temporary file:
        # if(file.exists("data/out/tmp/histIN.Rdata"))
        #   file.remove("data/out/tmp/histIN.Rdata")
        # save(histIN,file="data/out/tmp/histIN.Rdata")
        # rm(list=c("hist","histA","histIN"))
      } 
      
    }
    
    # ------------------------------------
    # 3  -- create projection indices
    
    # Now for each projection get the index and bias correct it 
    cat("    -- making projection indices....\n")
    sim <- simL[2]
    
    # Get Projection Indices: 
    # -------------------------
    cat("-------------------------\n Get historical & projection indices \n------------------------\n")
    for (sim in simL){
      i <- i + 1
      cat("    -- ",sim,"...\n-----------------------------------\n")
      
      # sim_listIN
      RCP   <- rev(strsplit(sim,"_")[[1]])[1]
      mod   <- (strsplit(sim,"_")[[1]])[1]
      CMIP  <- strsplit(sim,"_")[[1]][2]
      GCM   <- strsplit(sim,"_")[[1]][3]
      
      
      if(!usehist){
        
        if(bystrata) {
          load(file.path(Rdata_pathIN,file.path(sim,paste0(reg_txtIN,sim,".Rdata"))))
          eval(parse(text=paste0("hist       <- ",regnm,"; rm(",regnm,")")))
          
          
        }else{
          load(file.path(Rdata_pathIN,file.path(sim,paste0(srvy_txtIN,sim,".Rdata"))))
          eval(parse(text=paste0("hist_srvy  <- ",srvynm,"; rm(",srvynm,")")))
          
        }
        # Get Historical Indices: 
        # -------------------------
        cat("    -- making historical indices....\n")
        # station specific survey indices (annual)
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
          nm <- paste(subtxt,gcmcmip,"BC_hist.Rdata",sep="_")
          save(hist,file=file.path(fl,nm))
          nm <- paste(subtxt,gcmcmip,"BC_mn_hist.Rdata",sep="_")
          save(mn_hist,file=file.path(fl,nm))
          
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
          nm <- paste(subtxt,gcmcmip,"BC_hist.Rdata",sep="_")
          save(hist,file=file.path(fl,nm))
          nm <- paste(subtxt,gcmcmip,"BC_mn_hist.Rdata",sep="_")
          save(mn_hist,file=file.path(fl,nm))
          
          rm(list=c("hist","histA"))
          
          # #save in temporary file:
          # if(file.exists("data/out/tmp/histIN.Rdata"))
          #   file.remove("data/out/tmp/histIN.Rdata")
          # save(histIN,file="data/out/tmp/histIN.Rdata")
          # rm(list=c("hist","histA","histIN"))
        } 
      }
      
      if(bystrata) {
        load(file.path(Rdata_pathIN,file.path(sim,paste0(reg_txtIN,sim,".Rdata"))))
        eval(parse(text=paste0("proj_wk       <- ",regnm,"; rm(",regnm,")")))
      }else{
        load(file.path(Rdata_pathIN,file.path(sim,paste0(srvy_txtIN,sim,".Rdata"))))
        eval(parse(text=paste0("proj_srvy  <- ",srvynm,"; rm(",srvynm,")")))
      }
      
      # get projection indices
      if(!bystrata){  # station specific survey indices (annual)
        # station specific survey indices (annual)
        cat("    -- get srvy_indices_proj... \n")
        projA  <-  suppressMessages(make_indices_srvyrep_station(
          simIN       = proj_srvy,
          svIN        = sv,
          typeIN      =  "proj",
          STRATA_AREAIN = STRATA_AREA,
          normlistIN  = normlist_IN,
          ref_yrs     = NULL,
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
         # svIN ="largeZoop_integrated",
          timeblockIN = c("strata","strata_area_km2",
                          "yr","season","mo","wk"),
          seasonsIN   = seasons,
          type        = "strata weekly means", 
          typeIN     =  "proj", #"hist" "proj"
          ref_yrs    = NULL,
          normlistIN = normlist_IN,
          group_byIN = c("var","lognorm","basin","strata","strata_area_km2","season","mo","wk"),
          smoothIT     = smoothIT,
          log_adj    = 1e-4))
        
        mn_fut <- projA$mnDat%>%rename(
          mnVal_fut = mnVal_x,
          sdVal_fut = sdVal_x,
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
        
      #New Nov 2022 Bias correct weekly then bin up:
      # ------------------------------------
      # 4  -- bias correct the projections
      
    
      
      if(!bystrata){
        outlistUSE <- c("year","units",
                        #"rm(list=c("proj_wk","projA"))long_name","sim","bcIT","val_delta",
                        "sim","sim_type",
                        "val_biascorrected",
                        "val_raw",
                        "sf",
                        "val_biascorrectedstation", "val_delta","val_biascorrectedstrata", 
                        "val_biascorrectedyr",
                        "sf_station",
                        "sf_strata",
                        "sf_yr", 
                        "jday","mnDate","type","lognorm",
                        "mnVal_hind","sdVal_hind",
                        "sdVal_hind_strata",
                        "sdVal_hind_yr",
                        "mnVal_hist","sdVal_hist","sdVal_hist_strata","sdVal_hist_yr")
        
        cat("         -- bias correct station surveyrep_adj ... \n")
        selct <- c("station_id","latitude", "longitude",
          "basin","strata","strata_area_km2", 
                   "year",
                   "var","lognorm","units","sim","mn_val","jday",
                   "mnDate","qry_date","type","val_raw","sim_type")
        
        
        ll <- 0
        
        for(v in sv){
          sfIN <- "bcstation"
          ll <- ll + 1
          cat("    -- bias correct ",round(100*ll/length(normlist_IN$var)),"% ",v," ...\n")
          futtmp <- suppressMessages(suppressWarnings(
            bias_correct_new_station( 
              smoothIT = smoothIT,
              sf = sfIN,
              hind_clim  = mn_hind%>%filter(var==v),
              hist_clim  = mn_hist%>%filter(var==v),
              futIN2    = futraw%>%select(all_of(selct))%>%filter(var==v),
              normlistIN = normlist_IN,
              group_byIN = c("var","lognorm","basin","strata","strata_area_km2","station_id","latitude", "longitude"),
              group_byout = NULL,
              outlist    = outlistUSE, 
              log_adj    = 1e-4)))
          
          if(ll==1){ 
            fut   <- futtmp
          }else{
            fut  <- rbind(fut,futtmp)
          }
          rm(list=c("futtmp"))
        } #end var
        rm(list=c("mn_fut","futraw"))
      }else{
        
        outlistUSE <- c("year","season","mo","wk","units",
                        #"rm(list=c("proj_wk","projA"))long_name","sim","bcIT","val_delta",
                        "sim","sim_type",
                        "val_biascorrected",
                        "val_raw",
                        "sf",
                        "val_biascorrectedwk", "val_delta","val_biascorrectedmo", 
                        "val_biascorrectedyr",
                        "sf_wk",
                        "sf_mo",
                        "sf_yr", 
                        "jday","mnDate","type","lognorm",
                        "mnVal_hind","sdVal_hind",
                        "sdVal_hind_mo",
                        "sdVal_hind_yr",
                        "mnVal_hist","sdVal_hist","sdVal_hist_mo","sdVal_hist_yr")
        
        selct <- c("basin","strata","strata_area_km2", 
        "year","season","mo","wk",
        "var","lognorm","units","sim","mn_val","jday",
        "mnDate","qry_date","type","val_raw","sim_type")
       
        
        ll <- 0
        
        for(v in sv){
          sfIN <- "bcwk"
          ll <- ll + 1
          cat("    -- bias correct ",round(100*ll/length(normlist_IN$var)),"% ",v," ...\n")
          futtmp <- suppressMessages(
            bias_correct_new_strata( 
            smoothIT = smoothIT,
            sf = sfIN,
            hind_clim  = mn_hind%>%filter(var==v),
            hist_clim  = mn_hist%>%filter(var==v),
            futIN2    = futraw%>%select(all_of(selct))%>%filter(var==v),
            normlistIN = normlist_IN,
            group_byout = NULL,
            roundn = 5,
            group_byIN = c("var","lognorm","basin","strata","strata_area_km2","season","mo","wk"),
            outlist    = outlistUSE, 
            ref_yrs    = ref_years,   # currently set to 1980-2013 change to 1985?
            log_adj    = 1e-4))
          
          if(ll==1){ 
            fut   <- futtmp
          }else{
            fut  <- rbind(fut,futtmp)
          }
          rm(list=c("futtmp"))
        } #end var
        rm(list=c("mn_fut","futraw"))
      } #by strata
      
      
      fl <- file.path("Data/out",CMIP_fdlr,paste0("BC_",subtxt))
      nm <- paste(subtxt,sim,"BC_fut.Rdata",sep="_")
      save(fut,file=file.path(fl,nm))
      rm("fut")
      if(!usehist) rm(list=c("mn_hist"))
    } #end sim
    if(usehist) rm(list=c("mn_hist"))
  } # end gcmscen 
  #dir.remove("data/out/tmp")
  return("complete")
}


