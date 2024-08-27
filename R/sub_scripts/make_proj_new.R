#'
#'
#'
#'make_proj.R
#'
#'
#' THIS CODE PORTED TO QUICK START 
    
    
    # Bias corrected proj: don't need to update CMIP6 again
    # -----------------------------
    
    # set up hindcast
    sim       <-  "B10K-K20_CORECFS"
    load(file.path(localfolder,file.path(sim,paste0(reg_txt,sim,".Rdata"))))
    hnd       <- ACLIMregion; rm(ACLIMregion)
    
    load(file.path(localfolder,file.path(sim,paste0(srvy_txt,sim,".Rdata"))))
    hnd_srvy  <- ACLIMsurveyrep; rm(ACLIMsurveyrep)
    
    # area weighted weekly means for the NEBS and SEBS seperately
    reg_indices_weekly_hind <- make_indices_region(simIN = hnd,
                                              timeblockIN = c("yr","season","mo","wk"),
                                              seasonsIN   = seasons,
                                              refyrs      = deltayrs,
                                              type        = "weekly means")
    
    # get monthly means:
    reg_indices_monthly_hind  <- reg_indices_weekly_hind%>%
      group_by(var,year,season,mo,units, long_name,basin,sim)%>%
      summarize(val = mean(val, na.rm = T))
    reg_indices_monthly_hind $type <- "monthly means"
    
    # get seasonal means:
    reg_indices_season_hind  <- reg_indices_weekly_hind%>%
      group_by(var,year,season,units, long_name,basin,sim)%>%
      summarize(val = mean(val, na.rm = T))
    reg_indices_season_hind $type <- "seaonal means"
    
    # get annual means:
    reg_indices_season_hind  <- reg_indices_weekly_hind%>%
      group_by(var,year,units, long_name,basin,sim)%>%
      summarize(val = mean(val, na.rm = T))
    reg_indices_season_hind $type <- "annual means"
    
    
    i <- 0
    for( gcmcmip  in c("CMIP6_miroc","CMIP6_gfdl","CMIP6_cesm")){
      
      # set up historical:
      sim   <- paste0("B10K-K20P19_",gcmcmip,"_historical")
      load(file.path(localfolder,file.path(sim,paste0(reg_txt,sim,".Rdata"))))
      hist  <- ACLIMregion; rm(ACLIMregion)
      load(file.path(localfolder,file.path(sim,paste0(srvy_txt,sim,".Rdata"))))
      hist_srvy  <- ACLIMsurveyrep; rm(ACLIMsurveyrep)
      reg_indices_weekly_hist <- make_indices_region(simIN = hist,
                                                     timeblockIN = c("yr","season","mo","wk"),
                                                     seasonsIN   = seasons,
                                                     refyrs      = deltayrs)
      reg_indices_weekly_hist $type <- "weekly means"
      
      reg_indices_monthly_hist  <- reg_indices_weekly_hist%>%group_by(var,year,season,mo,units, long_name,basin,sim)%>%
        summarize(val = mean(val, na.rm = T))
      reg_indices_monthly_hind $type <- "monthly means"
      
      reg_indices_season_hist  <- reg_indices_weekly_hist%>%group_by(var,year,season,units, long_name,basin,sim)%>%
        summarize(val = mean(val, na.rm = T))
      reg_indices_season_hist$type <- "seaonal means"
      
      sim_listIN <- sim_list[grep(gcmcmip,sim_list)]
      sim_listIN <- sim_listIN[-grep("historical",sim_listIN)]
      
      # sim = sim_listIN[1]
      for (sim in sim_listIN){
        i <- i + 1
        cat("\n",sim,"....\n-----------------------------------\n\n")
        
        # open a "survey" specific  file
        load(file.path(localfolder,file.path(sim,paste0(srvy_txt,sim,".Rdata")))) 
        srvy_indices <-  make_indices_srvyrep(simIN       = ACLIMsurveyrep,
                                              seasonsIN   = seasons, 
                                              refyrs      = deltayrs)
        
        ## Pick up here biac correct survey indices
        # open a "region" or strata specific  file
        load(file.path(localfolder,file.path(sim,paste0(reg_txt,sim,".Rdata"))))
        reg_indices_weekly <- make_indices_region(
          simIN       = ACLIMregion,
          timeblockIN = c("yr","season","mo","wk"),
          seasonsIN   = seasons,
          refyrs      = deltayrs)
        reg_indices_weekly$type <- "weekly means"
        reg_indices_monthly <- reg_indices_weekly%>%group_by(var,year,season,mo,units, long_name,basin,sim)%>%
          summarize(val = mean(val, na.rm = T));reg_indices_monthly$type <- "monthly means"
        reg_indices_season <- reg_indices_weekly%>%group_by(var,year,season,units, long_name,basin,sim)%>%
          summarize(val = mean(val, na.rm = T));reg_indices_season$type <- "seaonal means"
        
        
        SIM_adj <- bias_correct( 
          hindIN = reg_indices_season_hind,
          histIN = reg_indices_season_hist,
          futIN  = reg_indices_season,
          ref_yrs    = 1980:2013,
          normlistIN =  normlist,
          plotIT     = TRUE,
          plotwk     = 2,
          plotvarIN  = "temp_bottom5m",
          log_adj    = 1e-4)
        
        # now the same for survey replicated 
        # -------------------------------------
       
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
        
        
        reg_indices$type  <- "strata means"
        srvy_indices$type <- "survey replicated"
        tmpproj <- rbind(reg_indices,
                         srvy_indices[,match(names(reg_indices),names(srvy_indices))])
        if(i ==1)
          proj <- tmpproj
        if(i!=1)
          proj <- rbind(proj,tmpproj)
        
        rm(reg_indices)
        rm(srvy_indices)
      }
    }
    
    proj      <- add_gcmssp(proj)
    if(!dir.exists("Data/out")) dir.create("Data/out")
    tmpfl <- file.path("Data/out/",paste0("proj_CMIP6_BiasCorr_",tmstamp1,".Rdata"))
    if(file.exists(tmpfl)) file.remove(tmpfl)    
    save(proj, file=tmpfl)
    rm(tmpfl)
    
    
    for( gcmcmip  in c("CMIP5_CESM","CMIP5_GFDL","CMIP5_MIROC")){
      sim_listIN <- sim_list[grep(gcmcmip,sim_list)]
      for (sim in sim_listIN){
        i<-i+1
        cat(sim,"....\n")
        
        # open a "region" or strata specific  file
        load(file.path(localfolder,file.path(sim,paste0(reg_txt,sim,".Rdata"))))
        fut     <- ACLIMregion; rm(ACLIMregion)
        SIM_adj <- bias_correct( 
          hindIN = hnd,
          histIN = hnd,
          futIN  = fut,
          ref_yrs    = 2006:2020,
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
        load(file.path(localfolder,file.path(sim,paste0(srvy_txt,sim,".Rdata")))) 
        fut_srvy     <- ACLIMsurveyrep; rm(ACLIMsurveyrep)
        SIM_adjsrvy <- bias_correct_srvy( 
          hindIN = hnd_srvy,
          histIN = hnd_srvy,
          futIN  = fut_srvy,
          ref_yrs    = 2006:2020,
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
        
        proj <- rbind(proj,tmpproj)
        
        rm(reg_indices)
        rm(srvy_indices)
      }
    }
    proj      <- add_gcmssp(proj)
    if(!dir.exists("Data/out")) dir.create("Data/out")
    tmpfl <- file.path("Data/out/",paste0("proj_CMIP5n6_BiasCorr_",tmstamp1,".Rdata"))
    if(file.exists(tmpfl)) file.remove(tmpfl)    
    save(proj, file=tmpfl)
    rm(tmpfl)
    
    # Non-Bias corrected proj (CMIP5 and CMIP66) don't need to update again
    # -----------------------------
    # set up hindcast
    sim  <-"B10K-K20_CORECFS"
    load(file.path(localfolder,file.path(sim,paste0(reg_txt,sim,".Rdata"))))
    hnd  <- ACLIMregion; rm(ACLIMregion)
    load(file.path(localfolder,file.path(sim,paste0(srvy_txt,sim,".Rdata"))))
    hnd_srvy  <- ACLIMsurveyrep; rm(ACLIMsurveyrep)
    
    i <- 0
    sim_listIN <- sim_list[-grep("CORECFS",sim_list)]
    
    for (sim in sim_listIN){
      i<-i+1
      cat(sim,"....\n")
      
      # open a "region" or strata specific  file
      load(file.path(localfolder,file.path(sim,paste0(reg_txt,sim,".Rdata"))))
      reg_indices <-  make_indices_region( simIN = ACLIMregion,
                                           BiasCorrect = FALSE,
                                           seasonsIN = seasons,
                                           refyrs    = deltayrs)
      
      # open a "region" or strata specific  file
      load(file.path(localfolder,file.path(sim,paste0(srvy_txt,sim,".Rdata")))) 
      srvy_indices <-  make_indices_srvyrep(sim = ACLIMsurveyrep,
                                            BiasCorrect = FALSE,
                                            seasonsIN = seasons, 
                                            refyrs = deltayrs)
      reg_indices$type  <- "strata means"
      srvy_indices$type <- "survey replicated"
      tmpproj <- rbind(reg_indices,
                       srvy_indices[,match(names(reg_indices),names(srvy_indices))])
      if(i ==1)
        proj <- tmpproj
      if(i!=1)
        proj <- rbind(proj,tmpproj)
      
      rm(reg_indices)
      rm(srvy_indices)
    }
    
    proj      <- add_gcmssp(proj)
    if(!dir.exists("Data/out")) dir.create("Data/out")
    tmpfl <- file.path("Data/out/",paste0("proj_CMIP6_raw_",tmstamp1,".Rdata"))
    if(file.exists(tmpfl)) file.remove(tmpfl)    
    save(proj, file=tmpfl)
    rm(tmpfl)
    
 
    
    