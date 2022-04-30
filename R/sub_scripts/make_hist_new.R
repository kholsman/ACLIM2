#'
#'
#'make_hist_new.R
#'

    # Bias corrected proj: don't need to update CMIP6 again
    # -----------------------------
    
    # set up hindcast
    sim       <-  "B10K-K20_CORECFS"
    load(file.path(Rdata_path,file.path(sim,paste0(reg_txt,sim,".Rdata"))))
    hnd       <- ACLIMregion; rm(ACLIMregion)
    load(file.path(Rdata_path,file.path(sim,paste0(srvy_txt,sim,".Rdata"))))
    hnd_srvy  <- ACLIMsurveyrep; rm(ACLIMsurveyrep)
    
    i <- 0
    for( gcmcmip  in c("CMIP6_miroc","CMIP6_gfdl","CMIP6_cesm")){
      
      # set up historical:
      sim   <- paste0("B10K-K20P19_",gcmcmip,"_historical")
      load(file.path(Rdata_path,file.path(sim,paste0(reg_txt,sim,".Rdata"))))
      hist  <- ACLIMregion; rm(ACLIMregion)
      load(file.path(Rdata_path,file.path(sim,paste0(srvy_txt,sim,".Rdata"))))
      hist_srvy  <- ACLIMsurveyrep; rm(ACLIMsurveyrep)
      
      sim_listIN <- sim_list[grep(gcmcmip,sim_list)]
      sim_listIN <- sim_listIN[grep("historical",sim_listIN)]

      for (sim in sim_listIN){
        i<-i+1
        cat(sim,"....\n")
        
        # open a "region" or strata specific  file
        load(file.path(Rdata_path,file.path(sim,paste0(reg_txt,sim,".Rdata"))))
        reg_indices <-  make_indices_region( simIN = ACLIMregion,
                                             BiasCorrect = FALSE,
                                             seasonsIN = seasons,
                                             refyrs    = deltayrs)
        # open a "region" or strata specific  file
        load(file.path(Rdata_path,file.path(sim,paste0(srvy_txt,sim,".Rdata")))) 
        srvy_indices <-  make_indices_srvyrep(simIN = ACLIMsurveyrep,
                                              BiasCorrect = FALSE,
                                              seasonsIN = seasons, 
                                              refyrs = deltayrs)
        reg_indices$type  <- "strata means"
        srvy_indices$type <- "survey replicated"
        tmpproj <- rbind(reg_indices,
                         srvy_indices[,match(names(reg_indices),names(srvy_indices))])
        if(i ==1)
          hist2 <- tmpproj
        if(i!=1)
          hist2 <- rbind(hist2,tmpproj)
        
        rm(reg_indices)
        rm(srvy_indices)
      }
    }
  
  hist2      <- add_gcmssp(hist2)
  if(!dir.exists("Data/out")) dir.create("Data/out")
  tmpfl <- file.path("Data/out/",paste0("hist_CMIP6_raw_",tmstamp1,".Rdata"))
  if(file.exists(tmpfl)) file.remove(tmpfl)    
  save(hist2, file=tmpfl)
  rm(tmpfl)
  rm(hist)
  
  i <- 0
  for( gcmcmip  in c("CMIP6_miroc","CMIP6_gfdl","CMIP6_cesm")){
    
    # set up historical:
    sim   <- paste0("B10K-K20P19_",gcmcmip,"_historical")
    load(file.path(Rdata_path,file.path(sim,paste0(reg_txt,sim,".Rdata"))))
    hist  <- ACLIMregion; rm(ACLIMregion)
    load(file.path(Rdata_path,file.path(sim,paste0(srvy_txt,sim,".Rdata"))))
    hist_srvy  <- ACLIMsurveyrep; rm(ACLIMsurveyrep)
    
    
    sim_listIN <- sim_list[grep(gcmcmip,sim_list)]
    sim_listIN <- sim_listIN[grep("historical",sim_listIN)]
    
    for (sim in sim_listIN){
      i<-i+1
      cat(sim,"....\n")
      
      # open a "region" or strata specific  file
      load(file.path(Rdata_path,file.path(sim,paste0(reg_txt,sim,".Rdata"))))
      fut     <- ACLIMregion; rm(ACLIMregion)
      SIM_adj <- bias_correct( 
        hindIN = hnd,
        histIN = hist,
        futIN  = fut,
        ref_yrs    = 1980:2013,
        normlistIN =  normlist,
        plotIT = TRUE,
        plotwk = 2,
        plotvarIN  = "temp_bottom5m",
        log_adj    = 1e-4)
      
      reg_indices <-  make_indices_region( simIN = SIM_adj$fut,
                                           BiasCorrect = TRUE,
                                           seasonsIN = seasons,
                                           refyrs    = deltayrs)
      # open a "region" or strata specific  file
      load(file.path(Rdata_path,file.path(sim,paste0(srvy_txt,sim,".Rdata")))) 
      fut_srvy    <- ACLIMsurveyrep; rm(ACLIMsurveyrep)
      SIM_adjsrvy <- bias_correct_srvy( 
        hindIN = hnd_srvy,
        histIN = hist_srvy,
        futIN  = fut_srvy,
        ref_yrs    = 1980:2013,
        normlistIN =  normlist,
        plotIT = TRUE,
        plotwk = 45,
        plotvarIN  = "temp_bottom5m",
        log_adj    = 1e-4)
      
      srvy_indices <-  make_indices_srvyrep(simIN = SIM_adjsrvy$fut,
                                            BiasCorrect = TRUE,
                                            seasonsIN = seasons, 
                                            refyrs = deltayrs)
      reg_indices$type  <- "strata means"
      srvy_indices$type <- "survey replicated"
      tmpproj <- rbind(reg_indices,
                       srvy_indices[,match(names(reg_indices),names(srvy_indices))])
      if(i ==1)
        hist2 <- tmpproj
      if(i!=1)
        hist2 <- rbind(hist2,tmpproj)
      
      rm(reg_indices)
      rm(srvy_indices)
    }
  }
  
  hist2      <- add_gcmssp(hist2)
  if(!dir.exists("Data/out")) dir.create("Data/out")
  tmpfl <- file.path("Data/out/",paste0("hist_CMIP6_BiasCorr_",tmstamp1,".Rdata"))
  if(file.exists(tmpfl)) file.remove(tmpfl)    
  save(hist2, file=tmpfl)
  rm(tmpfl)
  
