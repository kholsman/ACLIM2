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
          group_byIN    = c("station_id","lognorm","latitude", "longitude",
                            "strata","strata_area_km2","basin","units","sim","long_name","var")))
        
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
        # rmlistIN <- c("sdVal_hist", "seVal_hist", "sdVal_hist_strata", "sdVal_hist_yr",
        #               "nVal_hist")
       # rmlistIN <- c( "sdVal_hist_strata", "sdVal_hist_yr")
        
        tmphist    <- histA$fullDat%>%rename(
          mnVal_hist  = mnVal_x,
          sdVal_hist  = sdVal_x,
          nVal_hist   = nVal_x,
          seVal_hist  = seVal_x,
          sdVal_hist_strata = sdVal_x_strata,
          sdVal_hist_yr = sdVal_x_yr)%>%
         # select(-all_of(rmlistIN))%>%
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
        # rmlistIN = c("sdVal_hist", "seVal_hist", "sdVal_hist_mo", "sdVal_hist_yr",
        #              "nVal_hist")
       # rmlistIN = c("sdVal_hist_mo", "sdVal_hist_yr")
        tmphist    <- histA$fullDat%>%rename(
          mnVal_hist = mnVal_x,
          sdVal_hist = sdVal_x,
          nVal_hist = nVal_x,
          seVal_hist    = seVal_x,
          sdVal_hist_mo = sdVal_x_mo,
          sdVal_hist_yr = sdVal_x_yr)%>%
          #select(-all_of(rmlistIN))%>%
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
          eval(parse(text=paste0("hist_reg  <- ",regnm,"; rm(",regnm,")")))
          gc()
          hist_reg <- hist_reg%>%mutate(year = as.numeric(substr(time,1,4)))%>%filter(year%in%ref_yrsIN)
          
        }else{
          load(file.path(Rdata_pathIN,file.path(sim,paste0(srvy_txtIN,sim,".Rdata"))))
          eval(parse(text=paste0("hist_srvy  <- ",srvynm,"; rm(",srvynm,")")))
          gc()
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
            group_byIN    = c("station_id","lognorm","latitude", "longitude",
                              "strata","strata_area_km2","basin","units","sim","long_name","var")))
          
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
          #rmlistIN = c("sdVal_hist_strata", "sdVal_hist_yr")
          tmphist    <- histA$fullDat%>%rename(
            mnVal_hist  = mnVal_x,
            sdVal_hist  = sdVal_x,
            nVal_hist   = nVal_x,
            seVal_hist  = seVal_x,
            sdVal_hist_strata = sdVal_x_strata,
            sdVal_hist_yr = sdVal_x_yr)%>%
           # select(-all_of(rmlistIN))%>%
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
         # rmlistIN = c( "sdVal_hist_mo", "sdVal_hist_yr")
          tmphist    <- histA$fullDat%>%rename(
            mnVal_hist = mnVal_x,
            sdVal_hist = sdVal_x,
            nVal_hist = nVal_x,
            seVal_hist    = seVal_x,
            sdVal_hist_mo = sdVal_x_mo,
            sdVal_hist_yr = sdVal_x_yr)%>%
            #select(-all_of(rmlistIN))%>%
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
  #nm <- "BC_hist.Rdata"
  save(hist,file=file.path(fl,nm))
  
  #nm <- paste(subtxt,gcmcmip,"BC_mn_hist.Rdata",sep="_")
  nm <- "BC_mn_hist.Rdata"
  nm <-  paste(subtxt,"BC_mn_hist.Rdata",sep="_")
  save(mn_hist,file=file.path(fl,nm))
}

