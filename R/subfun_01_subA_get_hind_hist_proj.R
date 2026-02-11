#'
#'subfun_subA_get_hind_hist_proj.R
#'
#'K Holsman
#'ACLIM supportive scripts to generate bias corrected level4 indices


#'
#'
#'
#'
#'sub_get_proj.R
#'


sub_get_proj<-function(
    fut_startY = 2015,
    reg_txtIN = reg_txtIN,
    srvy_txtIN = srvy_txtIN,
    mn_hist = mn_hist,
    mn_hind = mn_hind,
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
  
  # Now for each projection get the index and bias correct it 
  cat("    -- making projection indices....\n")
  #sim <- simL[2]
  
  cat("-------------------------\n Get projection indices \n------------------------\n")
  i  <- 0
  ii <- 1
  for( ii in 1:length(gcmcmipLIST)){
    
    gcmcmip <- gcmcmipLIST[ii]
    simL    <- sim_listIN[sim_listIN%in%paste0(gcmcmip,"_",rep(scenIN,1,each=length(gcmcmip)))]
    sim <- simL[1]
    for (sim in simL){
      i <- i + 1
      cat("    -- ",sim,"...\n-----------------------------------\n")
      
      RCP   <- rev(strsplit(sim,"_")[[1]])[1]
      mod   <- (strsplit(sim,"_")[[1]])[1]
      CMIP  <- strsplit(sim,"_")[[1]][2]
      GCM   <- strsplit(sim,"_")[[1]][3]
      gcmsim<-paste(subtxt,gcmcmip,sep="_")
      
      if(bystrata) {
        load(file.path(Rdata_pathIN,file.path(sim,paste0(reg_txtIN,sim,".Rdata"))))
        eval(parse(text=paste0("proj_wk       <- ",regnm,"; rm(",regnm,")")))
        
        gc()
      }else{
        load(file.path(Rdata_pathIN,file.path(sim,paste0(srvy_txtIN,sim,".Rdata"))))
        eval(parse(text=paste0("proj_srvy  <- ",srvynm,"; rm(",srvynm,")")))
        proj_srvy <- proj_srvy%>%filter(year>  fut_startY)
        gc()
      }
      
      # get projection indices
      if(!bystrata){  # station specific survey indices (annual)
        # station specific survey indices (annual)
        cat("        -- get srvy_indices_proj... \n")
        grpbylist <- c("station_id","lognorm","latitude", "longitude",
                       "strata","strata_area_km2","basin",
                       #"units","long_name",
                       "sim","var")
        #grpbylist <- grpbylist[grpbylist%in%colnames(proj_srvy)]
        
        projA  <-  
          make_indices_srvyrep_station(
          simIN       = proj_srvy,
          svIN        = sv,
          typeIN      = "proj",
          STRATA_AREAIN = STRATA_AREA,
          normlistIN  = normlist_IN,
          ref_yrs     = NULL,
          seasonsIN   = seasons, 
          type        = "station replicated",
          log_adj     = 1e-4,
          group_byIN    = grpbylist)|>suppressMessages()
        
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
          mutate(
            GCM = GCM,
            RCP = RCP,
            mod = mod,
            CMIP = CMIP)%>%
          ungroup()
        
        futraw$val_raw[futraw$val_raw >= 9.96e36]<-NaN
        
        rm(list=c("proj_srvy","projA"))
        gc()
      }else{
        # area weekly means for each strata
        cat("        -- get strata_indices_weekly_fut ... \n")
        
        projA <- suppressMessages(
          make_indices_strata(
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
            smoothIT     = FALSE,
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
          mutate(
            GCM = GCM,
            RCP = RCP,
            mod = mod,
            CMIP = CMIP,
            gcmsim = gcmsim)%>%
          ungroup()
        
        rm(list=c("proj_wk","projA"))
        gc()
      }
      
      #New Nov 2022 Bias correct weekly then bin up:
      # ------------------------------------
      # 4  -- bias correct the projections
      
      if(!bystrata){
        outlistUSE <- c("year",
                        #"units",
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
                        "mnVal_hist","sdVal_hist","sdVal_hist_strata","sdVal_hist_yr",
                        "GCM","RCP",
                        "mod","CMIP")
        
        cat("         -- bias correct station surveyrep_adj ... \n")
        selct <- c("station_id","latitude", "longitude",
                   "basin","strata","strata_area_km2", 
                   "year",
                   "var","lognorm",
                   #"units",
                   "sim","mn_val","jday",
                   "mnDate","qry_date","type","val_raw","sim_type","GCM","RCP",
                   "mod","CMIP")
        
        selct <- selct[selct%in%colnames(futraw)]
        
        
        ll <- 0
        
        for(v in sv){
          #sfIN <- "bcstation"
          ll <- ll + 1
          cat("    -- bias correct ",round(100*ll/length(normlist_IN$var)),"% ",v," ...\n")
          if(!v%in% futraw$var) {
            message(paste(v,"not included in raw data, skipping..."))
            next
          }
          futtmp <- suppressMessages(suppressWarnings(
            bias_correct_new_station( 
              smoothIT    = FALSE,
              sf          = sfIN,
              usehist     = usehist,
              hind_clim   = mn_hind%>%filter(var==v),
              hist_clim   = mn_hist%>%filter(var==v),
              futIN2      = futraw%>%select(all_of(selct))%>%filter(var==v),
              normlistIN  = normlist_IN,
              group_byIN  = c("var","lognorm","basin","strata","strata_area_km2","station_id","latitude", "longitude"),
              group_byout = NULL,
              outlist     = outlistUSE, 
              log_adj     = 1e-4)))
          
          # # convert logit or log trans data back
          futtmp  <-  unlink_val(indat    = futtmp,
                                 log_adj  = 1e-4,
                                 roundn   = 5,
                                 listIN   = c("val_delta","val_biascorrected",
                                              "val_biascorrectedstation","val_biascorrectedstrata", 
                                              "val_biascorrectedyr"))
          
          
          if(ll==1){
            fut   <- futtmp
            fl <- here::here("Data/out",CMIP_fdlr,paste0("BC_",subtxt))
            nm <- paste(subtxt,sim,"BC_fut.Rdata",sep="_")
            save(fut,file=file.path(fl,nm))
            rm("fut")
          }else{
            fl <- here::here("Data/out",CMIP_fdlr,paste0("BC_",subtxt))
            nm <- paste(subtxt,sim,"BC_fut.Rdata",sep="_")
            load(file=file.path(fl,nm))
            fut  <- rbind(fut,futtmp)
            save(fut,file=file.path(fl,nm))
            rm("fut")
          }
          rm(list=c("futtmp"))
          gc()
        } #end var
        rm(list=c("mn_fut","futraw"))
        gc()
      }else{
        
        outlistUSE <- c("year","season","mo","wk",
                        #"units",
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
                        "mnVal_hist","sdVal_hist","sdVal_hist_mo","sdVal_hist_yr",
                        "GCM","RCP",
                        "mod","CMIP","gcmsim")
        
        selct <- c("basin","strata","strata_area_km2", 
                   "year","season","mo","wk",
                   "var","lognorm",
                   #"units",
                   "sim",
                   "mn_val", "sd_val","n_val",
                   "jday",
                   "mnDate","qry_date","type","val_raw","sim_type","GCM","RCP",
                   "mod","CMIP","gcmsim")
        
        selct <- selct[selct%in%colnames(futraw)]
        
        ll <- 0
        v <-sv[1]
        
        for(v in sv){
          
          
          #sfIN <- "val_delta"
          ll <- ll + 1
          cat("    -- bias correct ",round(100*ll/length(normlist_IN$var)),"% ",v," ...\n")
          if(!v%in%futraw$var) {
            message(paste(v,"not included in strata weekly raw data, skipping..."))
            next
          }
          futtmp <- suppressMessages(
            bias_correct_new_strata( 
              smoothIT = smoothIT,
              sf = sfIN,
              usehist = usehist,
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
          
          
          # # convert logit or log trans data back
          futtmp  <-  unlink_val(indat    = futtmp,
                                 log_adj  = 1e-4,
                                 roundn   = 5,
                                 listIN   = c("val_delta","val_biascorrected",
                                              "val_biascorrectedwk","val_biascorrectedmo", 
                                              "val_biascorrectedyr"))
          if(ll==1){
            fut   <- futtmp
            fl <- here::here("Data/out",CMIP_fdlr,paste0("BC_",subtxt))
            nm <- paste(subtxt,sim,"BC_fut.Rdata",sep="_")
            save(fut,file=file.path(fl,nm))
            rm("fut")
          }else{
            fl <- here::here("Data/out",CMIP_fdlr,paste0("BC_",subtxt))
            nm <- paste(subtxt,sim,"BC_fut.Rdata",sep="_")
            load(file=file.path(fl,nm))
            fut  <- rbind(fut,futtmp)
            save(fut,file=file.path(fl,nm))
            rm("fut")
          }
          rm(list=c("futtmp"))
          gc()
        } #end var
        rm(list=c("mn_fut","futraw"))
        gc()
      } #by strata
      gc()
    } #end sim
    gc()
  } # end gcmscen 
  
}

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
    
    grpbylist <- c("station_id","lognorm","latitude", "longitude",
                   "strata","strata_area_km2","basin",
                   #"units","long_name",
                   "sim","var")
    #grpbylist <- grpbylist[grpbylist%in%colnames(hnd_srvy)]
    
    hindA  <-  suppressMessages(
      make_indices_srvyrep_station(
      simIN      = hnd_srvy,
      svIN       = sv,
      typeIN     =  "hind",
      STRATA_AREAIN = STRATA_AREA,
      normlistIN    = normlist_IN,
      ref_yrs       = ref_yrsIN,
      seasonsIN     = seasons, 
      type          = "station replicated",
      log_adj       = 1e-4,
      group_byIN    = grpbylist))
    
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
    
   
    rm(list=c("hnd_srvy","hindA"))
    gc()
  }else{
    # area weekly means for each strata
    cat("    -- get strata_indices_weekly_hind ...\n")
    # strata_indices_weekly_hind 
    
    hindA <- suppressMessages(
      make_indices_strata(
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
   
    
    hind    <- hindA$fullDat%>%rename(
      mnVal_hind  = mnVal_x,
      sdVal_hind  = sdVal_x,
      nVal_hind   = nVal_x,
      seVal_hind  = seVal_x,
      sdVal_hind_mo = sdVal_x_mo,
      sdVal_hind_yr = sdVal_x_yr)%>%
      ungroup()
    
    rm(list=c("hnd","hindA"))
    gc()
    
  }

  nm <- paste(subtxt,sim,"BC_hind.Rdata",sep="_")
  save(hind,file=file.path(fl,nm))
  
  nm <-  paste(subtxt,sim,"BC_mn_hind.Rdata",sep="_")
  save(mn_hind,file=file.path(fl,nm))
}

#'
#'
#'
#'sub_get_hist.R
#'
#'

sub_get_hist<-function(
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
  
  cat("-------------------------\n Get historical indices (takes 5-10 mins) \n------------------------\n")
  i  <- 0
  ii <- 1
  for( ii in 1:length(gcmcmipLIST)){
    
    gcmcmip <- gcmcmipLIST[ii]
    simL    <- sim_listIN[sim_listIN%in%paste0(gcmcmip,"_",rep(scenIN,1,each=length(gcmcmip)))]
    
    if(usehist){
      
      sim     <- histLIST[ii]
      i <- i + 1
      cat(" -- ",sim,"...\n-----------------------------------\n")
      cat(" ---- Load data \n")
      RCP   <- rev(strsplit(sim,"_")[[1]])[1]
      mod   <- (strsplit(sim,"_")[[1]])[1]
      CMIP  <- strsplit(sim,"_")[[1]][2]
      GCM   <- strsplit(sim,"_")[[1]][3]
      gcmsim<-paste(subtxt,gcmcmip,sep="_")
      
      if(bystrata) {
        load(file.path(Rdata_pathIN,file.path(sim,paste0(reg_txtIN,sim,".Rdata"))))
        eval(parse(text=paste0("hist_reg       <- ",regnm,"; rm(",regnm,")")))
        gc()
        
      }else{
        
        load(file.path(Rdata_pathIN,file.path(sim,paste0(srvy_txtIN,sim,".Rdata"))))
        eval(parse(text=paste0("hist_srvy  <- ",srvynm,"; rm(",srvynm,")")))
        gc()
      }
      
      cat(" ---- Get indices \n")
      if(!bystrata){  # survey replicated
        # station specific survey indices (annual)
        cat("    -- get srvy_indices_hist ... \n")
        grpbylist <-c("station_id","lognorm","latitude", "longitude",
                      "strata","strata_area_km2","basin",
                      #"units","long_name",
                      "sim","var")
        #grpbylist <- grpbylist[grpbylist%in%colnames(hist_srvy)]
        
        histA  <-  suppressMessages(make_indices_srvyrep_station(
          simIN      = hist_srvy,
          svIN       = sv,
          typeIN     =  "hist",
          STRATA_AREAIN = STRATA_AREA,
          normlistIN    = normlist_IN,
          ref_yrs       = ref_yrsIN,
          seasonsIN     = seasons, 
          type          = "station replicated",
          log_adj    = 1e-4,
          group_byIN    = grpbylist))
        
        tmpmn_hist <- histA$mnDat%>%rename(
          mnVal_hist  = mnVal_x,
          sdVal_hist  = sdVal_x,
          nVal_hist   = nVal_x,
          seVal_hist  = seVal_x,
          sdVal_hist_strata = sdVal_x_strata,
          sdVal_hist_yr = sdVal_x_yr)%>%
          mutate(
            GCM = GCM,
            RCP2 = RCP,
            mod = mod,
            CMIP = CMIP,
            gcmsim = gcmsim)%>%
          ungroup()
        
        tmphist    <- histA$fullDat%>%rename(
          mnVal_hist  = mnVal_x,
          sdVal_hist  = sdVal_x,
          nVal_hist   = nVal_x,
          seVal_hist  = seVal_x,
          sdVal_hist_strata = sdVal_x_strata,
          sdVal_hist_yr = sdVal_x_yr)%>%
          mutate(
            GCM = GCM,
            RCP2 = RCP,
            mod = mod,
            CMIP = CMIP,
            gcmsim = gcmsim)%>%
          ungroup()
        
        
        if(i==1){
          hist    <- tmphist
          mn_hist <- tmpmn_hist
        }else{
          hist    <- rbind(hist,tmphist)
          mn_hist <- rbind(mn_hist, tmpmn_hist)
          
        }
        rm(list=c("histA","hist_srvy"))
        gc()
      }else{
        # area weekly means for each strata
        cat(" ------ get strata_indices_weekly_hist ... \n")
        
        histA <- suppressMessages(make_indices_strata(
          simIN       = hist_reg,
          svIN        = sv,
          timeblockIN = c("strata","strata_area_km2",
                          "yr","season","mo","wk"),
          seasonsIN   = seasons,
          type        = "strata weekly means", 
          typeIN      =  "hist", #"hist" "proj"
          ref_yrs     = ref_yrsIN,
          normlistIN  = normlist_IN,
          group_byIN = c("var","lognorm","basin","strata","strata_area_km2","season","mo","wk"),
          smoothIT    = smoothIT,
          log_adj     = 1e-4))
        
        tmpmn_hist <- histA$mnDat%>%rename(
          mnVal_hist = mnVal_x,
          sdVal_hist    = sdVal_x,
          nVal_hist = nVal_x,
          seVal_hist  = seVal_x,
          sdVal_hist_mo = sdVal_x_mo,
          sdVal_hist_yr = sdVal_x_yr)%>%
          mutate(
            GCM = GCM,
            RCP2 = RCP,
            mod = mod,
            CMIP = CMIP,
            gcmsim = gcmsim)%>%
          ungroup()
        
        tmphist    <- histA$fullDat%>%rename(
          mnVal_hist = mnVal_x,
          sdVal_hist = sdVal_x,
          nVal_hist = nVal_x,
          seVal_hist    = seVal_x,
          sdVal_hist_mo = sdVal_x_mo,
          sdVal_hist_yr = sdVal_x_yr)%>%
          mutate(
            GCM = GCM,
            RCP = RCP,
            mod = mod,
            CMIP = CMIP,
            gcmsim = gcmsim)%>%
          ungroup()
        
        if(i==1){
          hist    <- tmphist
          mn_hist <- tmpmn_hist
        }else{
          hist    <- rbind(hist,tmphist)
          mn_hist <- rbind(mn_hist, tmpmn_hist)
          
        }
        rm(list=c("histA","hist_reg"))
        gc()
        
      } 
      
    }
    
    if(!usehist){
      # use hind instead of hist
      for (sim in simL){
        i <- i + 1
        cat(" -- ",sim,"...\n-----------------------------------\n")
        cat(" ---- Load data \n")
        
        RCP   <- rev(strsplit(sim,"_")[[1]])[1]
        mod   <- (strsplit(sim,"_")[[1]])[1]
        CMIP  <- strsplit(sim,"_")[[1]][2]
        GCM   <- strsplit(sim,"_")[[1]][3]
        gcmsim<-paste(subtxt,gcmcmip,sep="_")
        
        
        if(bystrata) {
          load(file.path(Rdata_pathIN,file.path(sim,paste0(reg_txtIN,sim,".Rdata"))))
          #eval(parse(text=paste0("hist_reg  <- ",regnm,"; rm(",regnm,")")))
          hist_reg <- get(regnm, inherits = FALSE)
          rm(list = regnm)
          gc()
          
          hist_reg <- hist_reg%>%
            mutate(year = as.numeric(substr(time,1,4)))%>%
            filter(year%in%ref_yrsIN)
          
        }else{
          load(file.path(Rdata_pathIN,file.path(sim,paste0(srvy_txtIN,sim,".Rdata"))))
          #eval(parse(text=paste0("hist_srvy  <- ",srvynm,"; rm(",srvynm,")")))
          hist_srvy <- get(srvynm, inherits = FALSE)
          rm(list = srvynm)
          hist_srvy <- hist_srvy%>%filter(year%in%ref_yrsIN)
          
        }
        # Get Historical Indices: 
        # -------------------------
        cat(" ---- Get indices \n")
        cat(" ------ making historical indices....\n")
        # station specific survey indices (annual)
        if(!bystrata){  # survey replicated
          # station specific survey indices (annual)
          cat("    -- get srvy_indices_hist ... \n")
          grpbylist <- c("station_id","lognorm","latitude", "longitude",
                         "strata","strata_area_km2","basin",
                         #"units","long_name",
                         "sim","var")
          
          #grpbylist <- grpbylist[grpbylist%in%colnames(hist_srvy)]
          
          histA  <-  suppressMessages(make_indices_srvyrep_station(
            simIN = hist_srvy,
            svIN      = sv,
            typeIN     =  "hist",
            STRATA_AREAIN = STRATA_AREA,
            normlistIN = normlist_IN,
            ref_yrs    = ref_yrsIN,
            seasonsIN   = seasons, 
            type        = "station replicated",
            log_adj    = 1e-4,
            group_byIN    = grpbylist ))
          
          tmpmn_hist <- histA$mnDat%>%rename(
            mnVal_hist  = mnVal_x,
            sdVal_hist  = sdVal_x,
            nVal_hist   = nVal_x,
            seVal_hist  = seVal_x,
            sdVal_hist_strata = sdVal_x_strata,
            sdVal_hist_yr = sdVal_x_yr)%>%
            mutate(
              GCM = GCM,
              RCP = RCP,
              RCP2 = RCP,
              mod = mod,
              CMIP = CMIP,
              gcmsim = gcmsim)%>%
            ungroup()
          
          tmphist    <- histA$fullDat%>%rename(
            mnVal_hist  = mnVal_x,
            sdVal_hist  = sdVal_x,
            nVal_hist   = nVal_x,
            seVal_hist  = seVal_x,
            sdVal_hist_strata = sdVal_x_strata,
            sdVal_hist_yr = sdVal_x_yr)%>%
            mutate(
              GCM = GCM,
              RCP = RCP,
              mod = mod,
              CMIP = CMIP,
              gcmsim = gcmsim)%>%
            ungroup()
          
          if(i==1){
            hist    <- tmphist
            mn_hist <- tmpmn_hist
          }else{
            hist    <- rbind(hist,tmphist)
            mn_hist <- rbind(mn_hist, tmpmn_hist)
            
          }
          rm(list=c("histA","hist_srvy"))
          gc()
          
        }else{
          # area weekly means for each strata
          cat("    -- get strata_indices_weekly_hist ... \n")
          
          histA <- suppressMessages(make_indices_strata(
            simIN       = hist_reg,
            svIN        = sv,
            timeblockIN = c("strata","strata_area_km2",
                            "yr","season","mo","wk"),
            seasonsIN   = seasons,
            type        = "strata weekly means", 
            typeIN      =  "hist", #"hist" "proj"
            ref_yrs     = ref_yrsIN,
            normlistIN  = normlist_IN,
            group_byIN = c("var","lognorm","basin","strata","strata_area_km2","season","mo","wk"),
            smoothIT    = smoothIT,
            log_adj     = 1e-4))
          
          tmpmn_hist <- histA$mnDat%>%rename(
            mnVal_hist = mnVal_x,
            sdVal_hist    = sdVal_x,
            nVal_hist = nVal_x,
            seVal_hist  = seVal_x,
            sdVal_hist_mo = sdVal_x_mo,
            sdVal_hist_yr = sdVal_x_yr)%>%
            mutate(
              GCM = GCM,
              RCP = RCP,
              RCP2 = RCP,
              mod = mod,
              CMIP = CMIP,
              gcmsim = gcmsim)%>%
            ungroup()
          
          tmphist    <- histA$fullDat%>%rename(
            mnVal_hist = mnVal_x,
            sdVal_hist = sdVal_x,
            nVal_hist = nVal_x,
            seVal_hist    = seVal_x,
            sdVal_hist_mo = sdVal_x_mo,
            sdVal_hist_yr = sdVal_x_yr)%>%
            mutate(
              GCM = GCM,
              RCP = RCP,
              mod = mod,
              CMIP = CMIP,
              gcmsim = gcmsim)%>%
            ungroup()
          
          
          
          if(i==1){
            hist    <- tmphist
            mn_hist <- tmpmn_hist
          }else{
            hist    <- rbind(hist,tmphist)
            mn_hist <- rbind(mn_hist, tmpmn_hist)
            
          }
          hist <- hist%>%filter(year%in%ref_yrsIN)
          rm(list=c("histA","hist_reg"))
          gc()
        }
      } # end simL
      
      
    } #!usehist
  } # gcmcmipLIST
  
  
  nm <- paste(subtxt,gcmcmip,"BC_hist.Rdata",sep="_")
  nm <- paste(subtxt,"BC_hist.Rdata",sep="_")
  
  save(hist,file=file.path(fl,nm))
  
  
  nm <- "BC_mn_hist.Rdata"
  nm <-  paste(subtxt,"BC_mn_hist.Rdata",sep="_")
  save(mn_hist,file=file.path(fl,nm))
}


