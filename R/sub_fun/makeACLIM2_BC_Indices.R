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

# 1  -- Create indices from Hindcast
# 2  -- loop across GCMs and create historical run indicies
# 3  -- create projection indices
# 4  -- bias correct the projections
# 5  -- save results

makeACLIM2_BC_Indices <- function(
  bystrata  = TRUE, #if false do survey rep, if true do strata estimates
  sv = NULL,
  smoothIT = TRUE,
  BC_target = "mn_val",
  CMIP_fdlr ="K20P19_CMIP6",
  scenIN    = c("ssp126","ssp585"),
  hind_sim  =  "B10K-K20_CORECFS",
  histLIST,
  usehist   = TRUE,
  regnm     = "ACLIMregion",
  srvynm    = "ACLIMsurveyrep",
  Rdata_pathIN = Rdata_path,
  normlist_IN = normlist,
  gcmcmipLIST = c("B10K-K20P19_CMIP6_miroc","B10K-K20P19_CMIP6_gfdl","B10K-K20P19_CMIP6_cesm"),
  sim_listIN,
  gcinfoIN = FALSE){
  
  
  reg_txtIN  = paste0("Level3/",regnm,"_")
  srvy_txtIN = paste0("Level3/",srvynm,"_")
  gcinfo(gcinfoIN)
  # ------------------------------------
  # 1  -- Create indices from Hindcast
  cat("-- Starting analysis...\n")
  
  # load the Hindcast:
  # -------------------------
  cat("-- making hindcast indices....\n")
  sim  <- hind_sim
  
  
  
  
  if(is.null(sv)){
    sv <- unique(hnd_srvy$var)
    svout <- "allvar"
  }else{
    svout <- sv
  }
  
  if(bystrata) {
    load(file.path(Rdata_pathIN,file.path(sim,paste0(reg_txtIN,sim,".Rdata"))))
    eval(parse(text=paste0("hnd       <- ",regnm,"; rm(",regnm,")")))
    if(is.null(sv))
      sv <- unique(hnd$var)
  }else{
    load(file.path(Rdata_pathIN,file.path(sim,paste0(srvy_txtIN,sim,".Rdata"))))
    eval(parse(text=paste0("hnd_srvy  <- ",srvynm,"; rm(",srvynm,")")))
  }
  # Get Indices: 
  # -------------------------
 
   
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
    hindA <-make_indices_strata(
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
        log_adj    = 1e-4)
    
    mn_hind <- hindA$datout%>%rename(
      mnVal_hind = mnVal_x,
      sdVal_hind    = sdVal_x,
      nVal_hind = nVal_x,
      seVal_hind  = seVal_x,
      sdVal_hind_mo = sdVal_x_mo,
      sdVal_hind_yr = sdVal_x_yr)
      # mnLNVal_hind = mnLNVal_x,
      # sdLNVal_hind = sdLNVal_x,
      # nLNVal_hind = nLNVal_x,
      # sdLNVal_hind_mo = sdLNVal_x_mo,
      # sdLNVal_hind_yr = sdLNVal_x_yr)
    
    hindIN    <- hindA$datIN%>%rename(
      mnVal_hind = mnVal_x,
      sdVal_hind = sdVal_x,
      nVal_hind = nVal_x,
      seVal_hind    = seVal_x,
      sdVal_hind_mo = sdVal_x_mo,
      sdVal_hind_yr = sdVal_x_yr)
      # nLNVal_hind    = nLNVal_x,
      # mnLNVal_hind = mnLNVal_x,
      # sdLNVal_hind = sdLNVal_x, 
      # sdLNVal_hind_mo = sdLNVal_x_mo,
      # sdLNVal_hind_yr = sdLNVal_x_yr)
    
    #save in temporary file:
    if(dir.exists("data/out/tmp"))
      dir.remove("data/out/tmp")
    dir.create("data/out/tmp")
    save(hindIN,file="data/out/tmp/hindIN.Rdata")
    rm(list=c("hnd","hindA","hindIN"))
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
      sim     <- histLIST[ii]
      
      if(bystrata) {
        load(file.path(Rdata_pathIN,file.path(sim,paste0(reg_txtIN,sim,".Rdata"))))
        eval(parse(text=paste0("hist       <- ",regnm,"; rm(",regnm,")")))
        
      }else{
       
        load(file.path(Rdata_pathIN,file.path(sim,paste0(srvy_txtIN,sim,".Rdata"))))
        eval(parse(text=paste0("hist_srvy  <- ",srvynm,"; rm(",srvynm,")")))
      }
      
      
      # Get Historical Indices: 
      # -------------------------
      cat("-- making historical indices ...\n" )
      # cat("-- ",sim,"...\n-----------------------------------\n")
      # cat("[",paste0(c(rep("=",bar*0),">",rep(" ",60-(bar*0))),collapse=""),"]\n")
      # 
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
        # strata_indices_weekly_hist <- make_indices_strata(simIN = hist,
        #                                                   timeblockIN = c("strata","strata_area_km2",
        #                                                                   "yr","season","mo","wk"),
        #                                                   seasonsIN   = seasons,
        #                                                   type        = "strata weekly means")
        histA <-make_indices_strata(
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
          log_adj    = 1e-4)
        
        mn_hist <- histA$datout%>%rename(
          mnVal_hist = mnVal_x,
          sdVal_hist    = sdVal_x,
          nVal_hist = nVal_x,
          # mnLNVal_hist = mnLNVal_x,
          # sdLNVal_hist = sdLNVal_x,
          # nLNVal_hist = nLNVal_x,
          seVal_hist  = seVal_x,
          sdVal_hist_mo = sdVal_x_mo,
          # sdLNVal_hist_mo = sdLNVal_x_mo,
          sdVal_hist_yr = sdVal_x_yr)
          # sdLNVal_hist_yr = sdLNVal_x_yr)
        histIN    <- histA$datIN%>%rename(
          mnVal_hist = mnVal_x,
          sdVal_hist = sdVal_x,
          nVal_hist = nVal_x,
          # mnLNVal_hist = mnLNVal_x,
          # sdLNVal_hist = sdLNVal_x,
          # nLNVal_hist = nLNVal_x,
          seVal_hist    = seVal_x,
          sdVal_hist_mo = sdVal_x_mo,
          # sdLNVal_hist_mo = sdLNVal_x_mo,
          sdVal_hist_yr = sdVal_x_yr)
          # sdLNVal_hist_yr = sdLNVal_x_yr)
        #save in temporary file:
        if(file.exists("data/out/tmp/histIN.Rdata"))
          file.remove("data/out/tmp/histIN.Rdata")
        save(histIN,file="data/out/tmp/histIN.Rdata")
        rm(list=c("hist","histA","histIN"))
      }
    }
    
    # ------------------------------------
    # 3  -- create projection indices
    
    # Now for each projection get the index and bias correct it 
    cat("-- making projection indices....\n")
    sim <- simL[1]
  #  cat("[",paste0(c(rep("=",bar*i),">",rep(" ",60-(bar*i))),collapse=""),"]\n")
    for (sim in simL){
      i <- i + 1
      cat("    -- ",sim,"...\n-----------------------------------\n")
      #gcmcmipLIST = c("B10K-K20P19_CMIP6_miroc","B10K-K20P19_CMIP6_gfdl","B10K-K20P19_CMIP6_cesm")
      sim_listIN
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
        cat("-- making historical indices....\n")
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
          # strata_indices_weekly_hist <- make_indices_strata(simIN = hist,
          #                                                   timeblockIN = c("strata","strata_area_km2",
          #                                                                   "yr","season","mo","wk"),
          #                                                   seasonsIN   = seasons,
          #                                                   type        = "strata weekly means")
          # 
          histA <-make_indices_strata(
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
            log_adj    = 1e-4)
          
          mn_hist <- histA$datout%>%rename(
            mnVal_hist = mnVal_x,
            sdVal_hist    = sdVal_x,
            nVal_hist = nVal_x,
            # mnLNVal_hist = mnLNVal_x,
            # sdLNVal_hist = sdLNVal_x,
            # nLNVal_hist = nLNVal_x,
            seVal_hist  = seVal_x,
            sdVal_hist_mo = sdVal_x_mo,
            # sdLNVal_hist_mo = sdLNVal_x_mo,
            sdVal_hist_yr = sdVal_x_yr)
            # sdLNVal_hist_yr = sdLNVal_x_yr)
          histIN    <- histA$datIN%>%rename(
            mnVal_hist = mnVal_x,
            sdVal_hist = sdVal_x,
            nVal_hist = nVal_x,
            # mnLNVal_hist = mnLNVal_x,
            # sdLNVal_hist = sdLNVal_x,
            # nLNVal_hist = nLNVal_x,
            seVal_hist    = seVal_x,
            sdVal_hist_mo = sdVal_x_mo,
            # sdLNVal_hist_mo = sdLNVal_x_mo,
            sdVal_hist_yr = sdVal_x_yr)
            # sdLNVal_hist_yr = sdLNVal_x_yr)
          #save in temporary file:
          if(file.exists("data/out/tmp/histIN.Rdata"))
            file.remove("data/out/tmp/histIN.Rdata")
          save(histIN,file="data/out/tmp/histIN.Rdata")
          rm(list=c("hist","histA","histIN"))
        }
      }
      
      # Get Projection Indices: 
      # -------------------------
      
      if(bystrata) {
        load(file.path(Rdata_pathIN,file.path(sim,paste0(reg_txtIN,sim,".Rdata"))))
        eval(parse(text=paste0("proj_wk       <- ",regnm,"; rm(",regnm,")")))
      }else{
        load(file.path(Rdata_pathIN,file.path(sim,paste0(srvy_txtIN,sim,".Rdata"))))
        eval(parse(text=paste0("proj_srvy  <- ",srvynm,"; rm(",srvynm,")")))
      }
       
      if(!bystrata){  # station specific survey indices (annual)
          # station specific survey indices (annual)
          cat("    -- get srvy_indices_fut ... \n")
          srvy_station_indices_fut  <-  make_indices_srvyrep_station(simIN = proj_srvy,
                                                                     seasonsIN   = seasons, 
                                                                     type        = "station replicated")
          rm(list=c("proj_srvy"))
      }else{
          # area weekly means for each strata
        cat("    -- get strata_indices_weekly_fut ... \n")
          # strata_indices_weekly_fut <- make_indices_strata(simIN = proj_wk,
          #                                                  timeblockIN = c("strata","strata_area_km2",
          #                                                                  "yr","season","mo","wk"),
          #                                                  seasonsIN   = seasons,
          #                                                  type        = "strata weekly means")
        projA <-make_indices_strata(
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
          log_adj    = 1e-4)
        
        mn_fut <- projA$datout%>%rename(
          mnVal_fut = mnVal_x,
          sdVal_fut    = sdVal_x,
          nVal_fut = nVal_x,
          # mnLNVal_fut = mnLNVal_x,
          # sdLNVal_fut = sdLNVal_x,
          # nLNVal_fut = nLNVal_x,
          seVal_fut  = seVal_x,
          sdVal_fut_mo = sdVal_x_mo,
          # sdLNVal_fut_mo = sdLNVal_x_mo,
          sdVal_fut_yr = sdVal_x_yr)
        
          # sdLNVal_fut_yr = sdLNVal_x_yr)
        futIN<- projA$datIN%>%rename(
          mnVal_fut = mnVal_x,
          sdVal_fut = sdVal_x,
          nVal_fut = nVal_x,
          # mnLNVal_fut = mnLNVal_x,
          # nLNVal_fut    = nLNVal_x,
          # sdLNVal_fut = sdLNVal_x,
          seVal_fut    = seVal_x,
          sdVal_fut_mo = sdVal_x_mo,
          # sdLNVal_fut_mo = sdLNVal_x_mo,
          sdVal_fut_yr = sdVal_x_yr)%>%
          # sdLNVal_fut_yr = sdLNVal_x_yr)%>%
          ungroup()%>%
          select("basin","strata","strata_area_km2", 
                 "year","season","mo","wk",
                 "var","lognorm","units","sim","mn_val","mnjday",
                 #"LNval",
                 "mnDate","qry_date","type","val_raw","sim_type")
        #save in temporary file:
        if(file.exists("data/out/tmp/futIN.Rdata"))
          file.remove("data/out/tmp/futIN.Rdata")
        save(futIN,file="data/out/tmp/futIN.Rdata")
        
        rm(list=c("proj_wk","projA","futIN"))
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
                      "scaling_factorwk",
                      "scaling_factormo",
                      "scaling_factoryr", 
                      "mnjday","mnDate","type","lognorm",
                      "mnVal_hind","sdVal_hind",
                      "sdVal_hind_mo",
                      "sdVal_hind_yr",
                      # "mnLNVal_hind","sdLNVal_hind",
                      # "sdLNVal_hind_mo","sdLNVal_hind_yr",
                      "mnVal_hist","sdVal_hist","sdVal_hist_mo","sdVal_hist_yr")
                      # "mnLNVal_hist","sdLNVal_hist","sdLNVal_hist_mo","sdLNVal_hist_yr")
      
      if(!bystrata){
        cat("    -- bias correct station surveyrep_adj ... \n")
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
        
        cat("saving surveyrep_station_adj...\n")
        save_indices(
          flIN      = surveyrep_station_adj, 
          subfl     = "BC_srvy_station",
          post_txt  = paste0("ACLIMsurveyrep_",sim,"bc"),
          CMIP_fdlr = CMIP_fdlr,
          outlist   = c("fut","hind","hist"))
        # remove sim/gcm
        rm(list=c("surveyrep_station_adj",
                  "srvy_station_indices_fut"))
        if(!usehist)
          rm(list=c("srvy_station_indices_hist"))
      }else{
        load(file="data/out/tmp/futIN.Rdata")
        futIN <- futIN%>%
          select("basin","strata","strata_area_km2", 
                 "year","season","mo","wk",
                 "var","lognorm","units","sim","mn_val","mnjday",
                 #"LNval",
                 "mnDate","qry_date","type","val_raw","sim_type")
        load(file="data/out/tmp/hindIN.Rdata")
        load(file="data/out/tmp/histIN.Rdata")
        
        ll <- 0
        #for(v in normlist_IN$var){
        for(v in sv){
          sfIN <- "bcmo"
          # if(v%in%c("aice"))
          #   sfIN <- "bcyr"
          # 
          ll <- ll + 1
          cat("    -- bias correct ",round(100*ll/length(normlist_IN$var)),"% ",v," ...\n")
          strata_weekly_adj <- suppressMessages(bias_correct_new_strata( 
            smoothIT = smoothIT,
            sf = sfIN,
            hind_clim  = mn_hind%>%filter(var==v),
            hist_clim  = mn_hist%>%filter(var==v),
            fut_clim   = futIN%>%filter(var==v), 
            normlistIN = normlist_IN,
             group_byIN = c("var","lognorm","basin","strata","strata_area_km2","season","mo","wk"),
            outlist    = outlistUSE, 
            ref_yrs    = ref_years,   # currently set to 1980-2013 change to 1985?
            log_adj    = 1e-4))
          if(1==10){
            
          
            ggplot(data=strata_weekly_adj[[1]]%>%filter(strata==70))+
              #geom_line(aes(x=mnjday,y=val_biascorrectedwk,color="bcwk"))+
              geom_line(aes(x=mnjday,y=val_biascorrectedmo,color="bcmo"))+
              geom_line(aes(x=mnjday,y=val_biascorrectedyr,color="bcyr"))+
              geom_line(aes(x=mnjday,y=val_raw,color="raw"))+
              geom_line(aes(x=mnjday,y=mnVal_hind,color="mnVal_hind"),size=1.2)+
              geom_line(aes(x=mnjday,y=mnVal_hist,color="mnVal_hist"),size=1.2)
          }
          if(ll==1){ 
            strata_weekly_adjALL    <- strata_weekly_adj
          }else{
            strata_weekly_adjALL$fut  <- rbind(strata_weekly_adjALL$fut,strata_weekly_adj$fut)
            strata_weekly_adjALL$hind <- rbind(strata_weekly_adjALL$hind,strata_weekly_adj$hind)
            strata_weekly_adjALL$hist <- rbind(strata_weekly_adjALL$hist,strata_weekly_adj$hist)
          }
          rm(list=c("strata_weekly_adj"))
        } #end var
        
        cat("saving strata_weekly_adj...\n")
        save_indices(
          flIN      = strata_weekly_adjALL, 
          subfl     = "BC_strata_weekly",
          post_txt  = paste0("ACLIMregion_strata_",sim,"bc"),
          CMIP_fdlr = CMIP_fdlr,
          outlist   = c("fut","hind","hist"))
        # remove sim/gcm
        rm(list=c("mn_fut","strata_weekly_adjALL"))
        if(!usehist) rm(list=c("mn_hist"))
      }
    } #end sim
    
    if(bystrata)
      rm(list=c("mn_hist"))
    if(!bystrata)
      rm(list=c("srvy_station_indices_hist"))
    
  } # end gcmscen
  
  dir.remove("data/out/tmp")
  return("complete")
}


