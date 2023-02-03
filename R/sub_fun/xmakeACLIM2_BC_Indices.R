#'
#'
#'
#'makeACLIM2_BC_Indices()
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

makeACLIM2_BC_Indices <- function(

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
    load(file.path(Rdata_pathIN,file.path(sim,paste0(reg_txtIN,sim,".Rdata"))))
    eval(parse(text=paste0("hnd       <- ",regnm,"; rm(",regnm,")")))
    if(is.null(sv))
      sv <- unique(hnd$var)
  }else{
    load(file.path(Rdata_pathIN,file.path(sim,paste0(srvy_txtIN,sim,".Rdata"))))
    eval(parse(text=paste0("hnd_srvy  <- ",srvynm,"; rm(",srvynm,")")))
    if(is.null(sv))
      sv <- unique(hnd_srvy$var)
  }
  
  
  # Get Indices: 
  # -------------------------
  cat("Get indices \n")
  
  if(!bystrata){  # get survey replicated
    cat("    -- get srvy_indices_hind ... \n")
    srvy_station_indices_hind  <-  make_indices_srvyrep_station(simIN = hnd_srvy,
                                                                seasonsIN   = seasons, 
                                                                type        = "station replicated")
    rm(list=c("hnd_srvy"))
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
    
    hindIN    <- hindA$fullDat%>%rename(
        mnVal_hind  = mnVal_x,
        sdVal_hind  = sdVal_x,
        nVal_hind   = nVal_x,
        seVal_hind  = seVal_x,
        sdVal_hind_mo = sdVal_x_mo,
        sdVal_hind_yr = sdVal_x_yr)%>%
      ungroup()
    
    # convert logit or log trans data back
    hind  <-  unlink_val(indat=hindIN,
                           listIN = c("mn_val","mnVal_hind","mnVal_hist"),
                           rmlistIN = c("sdVal_hind", "seVal_hind", "sdVal_hind_mo", "sdVal_hind_yr",
                                        "sdVal_hist", "seVal_hist", "sdVal_hist_mo", "sdVal_hist_yr",
                                        "nVal_hist","nVal_hind"))
    
    load(file.path(Rdata_pathIN,file.path(sim,paste0(reg_txtIN,sim,".Rdata"))))
    
    # save hindcast indices:
    # keep hind_clim in the loop
    
    # if(dir.exists("data/out/tmp"))
    #   dir.remove("data/out/tmp")
    #  dir.create("data/out/tmp")
    #save(hindIN,file="data/out/tmp/hindIN.Rdata")
    #rm(list=c("hnd","hindA","hindIN"))
    rm(list=c("hnd","hindA"))
  }
 
 
  # ------------------------------------
  # 2  -- loop across GCMs and create historical run indices
  # pg <- paste("[",rep(" ",60),"]")
  # bar<- 60/length(gcmcmipLIST)
  # 
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
        srvy_station_indices_hist  <-  make_indices_srvyrep_station(simIN = hist_srvy,
                                                                    seasonsIN   = seasons, 
                                                                    type        = "station replicated")
        rm(list=c("hist_srvy"))
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
        
        histIN    <- histA$fullDat%>%rename(
          mnVal_hist = mnVal_x,
          sdVal_hist = sdVal_x,
          nVal_hist = nVal_x,
          seVal_hist    = seVal_x,
          sdVal_hist_mo = sdVal_x_mo,
          sdVal_hist_yr = sdVal_x_yr)%>%
          ungroup()
        # #save in temporary file:
        # if(file.exists("data/out/tmp/histIN.Rdata"))
        #   file.remove("data/out/tmp/histIN.Rdata")
        # save(histIN,file="data/out/tmp/histIN.Rdata")
        # rm(list=c("hist","histA","histIN"))
        rm(list=c("hist","histA"))
      }
    }
    
    # ------------------------------------
    # 3  -- create projection indices
    
    # Now for each projection get the index and bias correct it 
    cat("    -- making projection indices....\n")
    sim <- simL[1]
  #  cat("[",paste0(c(rep("=",bar*i),">",rep(" ",60-(bar*i))),collapse=""),"]\n")
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
        
       
        if(!bystrata){  # station specific survey indices (annual)
          # station specific survey indices (annual)
          cat("    -- get srvy_indices_hist ... \n")
          srvy_station_indices_hist  <-  make_indices_srvyrep_station(simIN = hist_srvy,
                                                                      seasonsIN   = seasons, 
                                                                      type        = "station replicated")
          
          
          rm(list=c("hist_srvy"))
        }else{
          # area weekly means for each strata
          cat("    -- get strata_indices_weekly_hist ... \n")
          histA <- suppressMessages(make_indices_strata(
            simIN = hist,
            svIN = sv,
            timeblockIN = c("strata","strata_area_km2",
                            "yr","season","mo","wk"),
            seasonsIN   = seasons,
            type        = "strata weekly means", 
            typeIN     =  "hist", #"hist" "proj"
            ref_yrs    = 1980:2013,
            normlistIN = normlist_IN,
             group_byIN = c("var","lognorm","basin","strata","strata_area_km2","season","mo","wk"),
            smoothIT     = smoothIT,
            log_adj    = 1e-4))
          
          mn_hist <- histA$mnDat%>%rename(
            mnVal_hist = mnVal_x,
            sdVal_hist    = sdVal_x,
            nVal_hist = nVal_x,
            seVal_hist  = seVal_x,
            sdVal_hist_mo = sdVal_x_mo,
            sdVal_hist_yr = sdVal_x_yr)
          
          histIN    <- histA$fullDat%>%rename(
            mnVal_hist = mnVal_x,
            sdVal_hist = sdVal_x,
            nVal_hist = nVal_x,
            seVal_hist    = seVal_x,
            sdVal_hist_mo = sdVal_x_mo,
            sdVal_hist_yr = sdVal_x_yr)
          
          # #save in temporary file:
          # if(file.exists("data/out/tmp/histIN.Rdata"))
          #   file.remove("data/out/tmp/histIN.Rdata")
          # save(histIN,file="data/out/tmp/histIN.Rdata")
          # rm(list=c("hist","histA","histIN"))
          rm(list=c("hist","histA"))
        }
      }
      
      if(bystrata) {
        load(file.path(Rdata_pathIN,file.path(sim,paste0(reg_txtIN,sim,".Rdata"))))
        eval(parse(text=paste0("proj_wk       <- ",regnm,"; rm(",regnm,")")))
      }else{
        load(file.path(Rdata_pathIN,file.path(sim,paste0(srvy_txtIN,sim,".Rdata"))))
        eval(parse(text=paste0("proj_srvy  <- ",srvynm,"; rm(",srvynm,")")))
      }
       
      if(!bystrata){  # station specific survey indices (annual)
          # station specific survey indices (annual)
          cat("        -- get srvy_indices_fut ... \n")
          srvy_station_indices_fut  <-  make_indices_srvyrep_station(simIN = proj_srvy,
                                                                     seasonsIN   = seasons, 
                                                                     type        = "station replicated")
          rm(list=c("proj_srvy"))
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
        
        futIN<- projA$fullDat%>%rename(
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
      
      outlistUSE <- c("year","season","mo","wk","units",
                      #"long_name","sim","bcIT","val_delta",
                      "sim","sim_type",
                      "val_biascorrected",
                      "val_raw",
                      "sf",
                      "val_biascorrectedwk", "val_delta","val_biascorrectedmo", 
                      "val_biascorrectedyr",
                      "sf_wk",
                      "sf_mo",
                      "sf_yr", 
                      "mnjday","mnDate","type","lognorm",
                      "mnVal_hind","sdVal_hind",
                      "sdVal_hind_mo",
                      "sdVal_hind_yr",
                      "mnVal_hist","sdVal_hist","sdVal_hist_mo","sdVal_hist_yr")
      
      if(!bystrata){
        cat("         -- bias correct station surveyrep_adj ... \n")
        surveyrep_station_adj <- suppressMessages(
          bias_correct_new( 
          target     = BC_target,
          hindIN = srvy_station_indices_hind,
          histIN = srvy_station_indices_hist,
          futIN  = srvy_station_indices_fut,
          ref_yrs     = ref_years,
          smoothIT    = smoothIT,
          group_byIN = c("var","lognorm","basin","station_id","latitude","longitude","strata"),
          normlistIN  = normlist_IN,
          outlist     = outlistUSE[-grep("mo",outlistUSE)],
          log_adj     = 1e-4))
        
        cat("        -- saving surveyrep_station_adj...\n")
        save_indices(
          flIN      = surveyrep_station_adj, 
          subfl     = "BC_srvy_station",
          post_txt  = paste0("ACLIMsurveyrep_",sim,"bc"),
          CMIP_fdlr = CMIP_fdlr,
          outlist   = c("fut","hind","hist"))
        
        rm(list=c("surveyrep_station_adj",
                  "srvy_station_indices_fut"))
        if(!usehist)
          rm(list=c("srvy_station_indices_hist"))
      }else{
        selct <- c("basin","strata","strata_area_km2", 
        "year","season","mo","wk",
        "var","lognorm","units","sim","mn_val","mnjday",
        "mnDate","qry_date","type","val_raw","sim_type")
       
        
        ll <- 0
        #for(v in normlist_IN$var){
        # load(file="data/out/tmp/futIN.Rdata")
        # load(file="data/out/tmp/hindIN.Rdata")
        # load(file="data/out/tmp/histIN.Rdata")
        hindIN<-hindIN%>%
          select(all_of(selct))
        histIN<-histIN%>%
          select(all_of(selct))
        futIN <- futIN%>%
          select(all_of(selct))
        
        for(v in sv){
          sfIN <- "bcwk"
          ll <- ll + 1
          cat("    -- bias correct ",round(100*ll/length(normlist_IN$var)),"% ",v," ...\n")
          strata_weekly_adj <- suppressMessages(
            bias_correct_new_strata( 
            smoothIT = smoothIT,
            sf = sfIN,
            hind_clim  = mn_hind%>%filter(var==v),
            hist_clim  = mn_hist%>%filter(var==v),
            futIN      = futIN%>%filter(var==v),
            hindIN     = hindIN,
            histIN     = histIN,
            normlistIN = normlist_IN,
            group_byIN = c("var","lognorm","basin","strata","strata_area_km2","season","mo","wk"),
            outlist    = outlistUSE, 
            ref_yrs    = ref_years,   # currently set to 1980-2013 change to 1985?
            log_adj    = 1e-4))
          
          if(ll==1){ 
            strata_weekly_adjALL   <- strata_weekly_adj
          }else{
            strata_weekly_adjALL$fut  <- rbind(strata_weekly_adjALL$hind,strata_weekly_adj$hind)
            strata_weekly_adjALL$fut  <- rbind(strata_weekly_adjALL$hist,strata_weekly_adj$hist)
            strata_weekly_adjALL$fut  <- rbind(strata_weekly_adjALL$fut,strata_weekly_adj$fut)
          }
          rm(list=c("strata_weekly_adj"))
        } #end var
        
        cat("        -- saving strata_weekly_adj...\n")
        save_indices(
          flIN      = strata_weekly_adjALL, 
          subfl     = "BC_strata_weekly",
          post_txt  = paste0("ACLIMregion_strata_",sim,"bc"),
          CMIP_fdlr = CMIP_fdlr,
          outlist   = c("fut","hind","hist"))
        # remove sim/gcm
        rm(list=c("mn_fut","futIN", "strata_weekly_adjALL"))
      } # end var
        if(!usehist) rm(list=c("mn_hist","histIN"))
    } #end sim
    
    if(bystrata)
      rm(list=c("mn_hist","histIN"))
    if(!bystrata)
      rm(list=c("srvy_station_indices_hist"))
    
  } # end gcmscen
  
  #dir.remove("data/out/tmp")
  return("complete")
}


