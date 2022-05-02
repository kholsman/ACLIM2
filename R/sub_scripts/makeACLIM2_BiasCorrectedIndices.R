#'
#'
#'
#'Bias_correct_CMIP6_K20
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

# these must be defined ahead of time:
# BC_target = "mn_val",
# CMIP_fdlr = "CMIP6",
# hind_sim  =  "B10K-K20_CORECFS",
# histLIST,
# gcmcmipLIST = c("CMIP6_miroc","CMIP6_gfdl","CMIP6_cesm"),
# sim_listIN

  # ------------------------------------
  # 1  -- Create indices from Hindcast
  cat("-- Starting analysis,files will be saved in",paste0("Data/out/",CMIP_fdlr)," ....\n")
  
  # load the Hindcast:
  # -------------------------
  cat("-- making hindcast indices....\n")
  
  #sim <- "B10K-K20_CORECFS"
  sim  <- hind_sim
  load(file.path(Rdata_path,file.path(sim,paste0(reg_txt,sim,".Rdata"))))
  hnd       <- ACLIMregion; rm(ACLIMregion)
  load(file.path(Rdata_path,file.path(sim,paste0(srvy_txt,sim,".Rdata"))))
  hnd_srvy  <- ACLIMsurveyrep; rm(ACLIMsurveyrep)
  
  # Get Indices: 
  # -------------------------
  # area weighted  means for survey indices (annual)
  srvy_indices_hind  <-  make_indices_srvyrep(simIN = hnd_srvy,
                                              seasonsIN   = seasons, 
                                              refyrs      = deltayrs,
                                              type        = "survey replicated")
  
  # area weighted weekly means for the NEBS and SEBS separately
  reg_indices_weekly_hind <- make_indices_region(simIN = hnd,
                                                 timeblockIN = c("yr","season","mo","wk"),
                                                 seasonsIN   = seasons,
                                                 refyrs      = deltayrs,
                                                 type        = "weekly means")
  tmp <- reg_indices_weekly_hind
  
  # get monthly means:
  reg_indices_monthly_hind  <- tmp%>%
    group_by(var,year,season,mo,units, long_name,basin,sim)%>%
    summarize(mn_val  = mean(mn_val, na.rm = T),
              mnDate  = mean(mnDate, na.rm = T))%>%
    mutate(type = "monthly means")
  
  # get seasonal means:
  reg_indices_seasonal_hind  <- tmp%>%
    group_by(var,year,season,units, long_name,basin,sim)%>%
    summarize(mn_val  = mean(mn_val, na.rm = T),
              mnDate  = mean(mnDate, na.rm = T))%>%
    mutate(type =  "seaonal means")
  
  # get annual means:
  reg_indices_annual_hind <- tmp%>%
    group_by(var,year,units, long_name,basin,sim)%>%
    summarize(mn_val  = mean(mn_val, na.rm = T),
              mnDate  = mean(mnDate, na.rm = T))%>%
    mutate(type = "annual means")
  
  # ------------------------------------
  # 2  -- loop across GCMs and create historical run indicies
  
  i <- 0
  # gcmcmip <- "CMIP6_miroc"
  #for( gcmcmip  in c("CMIP6_miroc","CMIP6_gfdl","CMIP6_cesm")){
  for( ii in 1:length(gcmcmipLIST)){
    
    #sim   <- paste0("B10K-K20P19_",gcmcmip,"_historical")
    gcmcmip <- gcmcmipLIST[ii]
    sim     <- histLIST[ii]
    
    load(file.path(Rdata_path,file.path(sim,paste0(reg_txt,sim,".Rdata"))))
    hist  <- ACLIMregion; rm(ACLIMregion)
    load(file.path(Rdata_path,file.path(sim,paste0(srvy_txt,sim,".Rdata"))))
    hist_srvy  <- ACLIMsurveyrep; rm(ACLIMsurveyrep)
    
    # Get Historical Indices: 
    # -------------------------
    cat("-- making historical indices....\n")
    # area weighted  means for survey indices (annual)
    srvy_indices_hist <-  make_indices_srvyrep(simIN  = hist_srvy,
                                               seasonsIN   = seasons, 
                                               refyrs      = deltayrs,
                                               type        = "survey replicated")
    
    # area weighted weekly means for the NEBS and SEBS separately
    reg_indices_weekly_hist <- make_indices_region(simIN       = hist,
                                                   timeblockIN = c("yr","season","mo","wk"),
                                                   seasonsIN   = seasons,
                                                   refyrs      = deltayrs,
                                                   type        = "weekly means")
    
    tmp <- reg_indices_weekly_hist
    # get monthly means:
    reg_indices_monthly_hist  <- tmp%>%
      group_by(var,year,season,mo,units, long_name,basin,sim)%>%
      summarize(mn_val  = mean(mn_val, na.rm = T),
                mnDate  = mean(mnDate, na.rm = T))%>%
      mutate(type = "monthly means")
    
    # get seasonal means:
    reg_indices_seasonal_hist  <- tmp%>%
      group_by(var,year,season,units, long_name,basin,sim)%>%
      summarize(mn_val  = mean(mn_val, na.rm = T),
                mnDate  = mean(mnDate, na.rm = T))%>%
      mutate(type =  "seaonal means")
    
    # get annual means:
    reg_indices_annual_hist  <- tmp%>%
      group_by(var,year,units, long_name,basin,sim)%>%
      summarize(mn_val  = mean(mn_val, na.rm = T),
                mnDate  = mean(mnDate, na.rm = T))%>%
      mutate(type = "annual means")
    
    
    # select the simulations that correspond to the cmip x gcm:
    simL <- sim_listIN[grep(gcmcmip,sim_listIN)]
    
    # ------------------------------------
    # 3  -- create projection indices
    
    # Now for each projection get the index and bias correct it 
    cat("-- making projection indices....\n")
    for (sim in simL){
      i <- i + 1
      cat("-- ",sim,"....\n-----------------------------------\n\n")
      
      load(file.path(Rdata_path,file.path(sim,paste0(reg_txt,sim,".Rdata"))))
      proj_wk  <- ACLIMregion; rm(ACLIMregion)
      load(file.path(Rdata_path,file.path(sim,paste0(srvy_txt,sim,".Rdata"))))
      proj_srvy  <- ACLIMsurveyrep; rm(ACLIMsurveyrep)
      
      
      # Get Projection Indices: 
      # -------------------------
      # area weighted  means for survey indices (annual)
      srvy_indices_proj <-  make_indices_srvyrep(simIN  = proj_srvy,
                                                 seasonsIN   = seasons, 
                                                 refyrs      = deltayrs,
                                                 type        = "survey replicated")
      
      # area weighted weekly means for the NEBS and SEBS separately
      reg_indices_weekly_proj <- make_indices_region(simIN  = proj_wk,
                                                     timeblockIN = c("yr","season","mo","wk"),
                                                     seasonsIN   = seasons,
                                                     refyrs      = deltayrs,
                                                     type        = "weekly means")
      tmp <- reg_indices_weekly_proj
      # get monthly means:
      reg_indices_monthly_proj  <- tmp%>%
        group_by(var,year,season,mo,units, long_name,basin,sim)%>%
        summarize(mn_val  = mean(mn_val, na.rm = T),
                  mnDate  = mean(mnDate, na.rm = T))%>%
        mutate(type = "monthly means")
      
      # get seasonal means:
      reg_indices_seasonal_proj   <- tmp%>%
        group_by(var,year,season,units, long_name,basin,sim)%>%
        summarize(mn_val  = mean(mn_val, na.rm = T),
                  mnDate  = mean(mnDate, na.rm = T))%>%
        mutate(type =  "seaonal means")
      
      # get annual means:
      reg_indices_annual_proj   <- tmp%>%
        group_by(var,year,units, long_name,basin,sim)%>%
        summarize(mn_val  = mean(mn_val, na.rm = T),
                  mnDate  = mean(mnDate, na.rm = T))%>%
        mutate(type = "annual means", time = year)
      
      # ------------------------------------
      # 4  -- bias correct the projections
      
      # Now bias correct the data:
      seasonal_adj <- suppressWarnings(bias_correct( 
        target     = BC_target,
        hindIN = reg_indices_seasonal_hind,
        histIN = reg_indices_seasonal_hist,
        futIN  = reg_indices_seasonal_proj,
        ref_yrs    = ref_years,
        group_byIN = c("var","basin","season"),
        normlistIN =  normlist,
        plotwk     = 2,
        plotvarIN  = "temp_bottom5m", # this is just one of the variables
        log_adj    = 1e-4))
      
      weekly_adj <- suppressWarnings(bias_correct( 
        target     = BC_target,
        hindIN = reg_indices_weekly_hind,
        histIN = reg_indices_weekly_hist,
        futIN  = reg_indices_weekly_proj,
        ref_yrs    = ref_years,
        group_byIN = c("var","basin","season","mo","wk"),
        normlistIN =  normlist,
        plotwk     = 2,
        plotvarIN  = "temp_bottom5m", # this is just one of the variables
        log_adj    = 1e-4))
      
      monthly_adj <- suppressWarnings(bias_correct( 
        target     = BC_target,
        hindIN = reg_indices_monthly_hind,
        histIN = reg_indices_monthly_hist,
        futIN  = reg_indices_monthly_proj,
        ref_yrs    = ref_years,
        group_byIN = c("var","basin","season","mo"),
        normlistIN =  normlist,
        plotwk     = 2,
        plotvarIN  = "temp_bottom5m", # this is just one of the variables
        log_adj    = 1e-4))
      
      annual_adj <- suppressWarnings(bias_correct( 
        target     = BC_target,
        hindIN = reg_indices_annual_hind,
        histIN = reg_indices_annual_hist,
        futIN  = reg_indices_annual_proj,
        ref_yrs    = ref_years,
        group_byIN = c("var","basin"),
        normlistIN =  normlist,
        plotwk     = 2,
        plotvarIN  = "temp_bottom5m", # this is just one of the variables
        log_adj    = 1e-4))
      
      
      surveyrep_adj <- bias_correct( 
        target     = BC_target,
        hindIN = srvy_indices_hind,
        histIN = srvy_indices_hist,
        futIN  = srvy_indices_proj,
        ref_yrs    = ref_years,
        group_byIN = c("var","basin","season"),
        normlistIN =  normlist,
        plotIT = TRUE,
        plotwk = 45,
        plotvarIN  = "temp_bottom5m",
        log_adj    = 1e-4)
      if(1==10){
        
        dd<- annual_adj
        ff <- dd$fut%>%filter(var =="temp_bottom5m")
        hd <- dd$hind%>%filter(var =="temp_bottom5m")
        ht <- dd$hist%>%filter(var =="temp_bottom5m")
        
        ggplot(ff)+
          geom_line(aes(x=year,y=val_biascorrected),color="orange")+
          geom_line(aes(x=year,y=val),color="grey")+
          facet_wrap(~basin)+
          geom_line(data=hd, aes(x=year,y=val),color="blue3",alpha = .6)+
          geom_line(data=hd,aes(x=year,y=mnVal_hind),color="blue3")+
          geom_line(data=ht,aes(x=year,y=val),color="gray",linetype = "dashed",alpha = .8)+
          geom_line(data=ht,aes(x=year,y=mnVal_hist),color="gray",linetype = "dashed")+
          theme_minimal()+ylab(" Bottom Temperature")
        
        dd  <-  seasonal_adj
        ff  <-  dd$fut%>%filter(var =="temp_bottom5m",basin =="SEBS")
        hd <- dd$hind%>%filter(var =="temp_bottom5m",basin =="SEBS")
        ht <- dd$hist%>%filter(var =="temp_bottom5m",basin =="SEBS")
        
        ggplot(ff)+
          geom_line(aes(x=year,y=val_biascorrected),color="orange")+
          geom_line(aes(x=year,y=val),color="grey")+
          facet_wrap(~season)+
          geom_line(data=hd, aes(x=year,y=val),color="blue3",alpha = .6)+
          geom_line(data=hd,aes(x=year,y=mnVal_hind),color="blue3")+
          geom_line(data=ht,aes(x=year,y=val),color="gray",linetype = "dashed",alpha = .8)+
          geom_line(data=ht,aes(x=year,y=mnVal_hist),color="gray",linetype = "dashed")+
          theme_minimal()+ylab(" Bottom Temperature")
        
      }
      
      CMIP  <- strsplit(gcmcmip,"_")[[1]][1]
      GCM   <- strsplit(gcmcmip,"_")[[1]][2]
      RCP  <- rev(strsplit(sim,"_")[[1]])[1]
      mod   <- (strsplit(sim,"_")[[1]])[1]
      
      
      if(i ==1){
        # first time through
        ACLIM_annual_hind   <- annual_adj$hind%>%mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)
        ACLIM_seasonal_hind <- seasonal_adj$hind%>%mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)
        ACLIM_monthly_hind  <- monthly_adj$hind%>%mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)
        ACLIM_weekly_hind   <- weekly_adj$hind%>%mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)
        ACLIM_surveyrep_hind<- surveyrep_adj$hind%>%mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)
        
        ACLIM_annual_hist   <- annual_adj$hist%>%mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)
        ACLIM_seasonal_hist <- seasonal_adj$hist%>%mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)
        ACLIM_monthly_hist  <- monthly_adj$hist%>%mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)
        ACLIM_weekly_hist   <- weekly_adj$hist%>%mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)
        ACLIM_surveyrep_hist<- surveyrep_adj$hist%>%mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)
        
        ACLIM_annual_fut    <- annual_adj$fut%>%mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)
        ACLIM_seasonal_fut  <- seasonal_adj$fut%>%mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)
        ACLIM_monthly_fut   <- monthly_adj$fut%>%mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)
        ACLIM_weekly_fut    <- weekly_adj$fut%>%mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)
        ACLIM_surveyrep_fut <- surveyrep_adj$fut%>%mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)
        
      }
      
      if(i!=1){
        # next time through
        ACLIM_annual_hind   <- rbind(ACLIM_annual_hind,annual_adj$hind%>%mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod))
        ACLIM_seasonal_hind <- rbind(ACLIM_seasonal_hind,seasonal_adj$hind%>%mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod))
        ACLIM_monthly_hind  <- rbind(ACLIM_monthly_hind,monthly_adj$hind%>%mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod))
        ACLIM_weekly_hind   <- rbind(ACLIM_weekly_hind,weekly_adj$hind%>%mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod))
        ACLIM_surveyrep_hind<- rbind(ACLIM_surveyrep_hind,surveyrep_adj$hind%>%mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod))
        
        ACLIM_annual_hist   <- rbind(ACLIM_annual_hist,annual_adj$hist%>%mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod))
        ACLIM_seasonal_hist <- rbind(ACLIM_seasonal_hist,seasonal_adj$hist%>%mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod))
        ACLIM_monthly_hist  <- rbind(ACLIM_monthly_hist,monthly_adj$hist%>%mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod))
        ACLIM_weekly_hist   <- rbind(ACLIM_weekly_hist,weekly_adj$hist%>%mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod))
        ACLIM_surveyrep_hist<- rbind(ACLIM_surveyrep_hist,surveyrep_adj$hist%>%mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod))
        
        ACLIM_annual_fut    <- rbind(ACLIM_annual_fut,annual_adj$fut%>%mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod))
        ACLIM_seasonal_fut  <- rbind(ACLIM_seasonal_fut,seasonal_adj$fut%>%mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod))
        ACLIM_monthly_fut   <- rbind(ACLIM_monthly_fut,monthly_adj$fut%>%mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod))
        ACLIM_weekly_fut    <- rbind(ACLIM_weekly_fut,weekly_adj$fut%>%mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod))
        ACLIM_surveyrep_fut <- rbind(ACLIM_surveyrep_fut,surveyrep_adj$fut%>%mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod))
        
      }
      rm(list= c( 
        "proj_wk","proj_srvy",
        "reg_indices_annual_proj",
        "reg_indices_seasonal_proj",
        "reg_indices_monthly_proj",
        "reg_indices_weekly_proj",
        "srvy_indices_proj","tmp",
        "surveyrep_adj",
        "annual_adj",
        "monthly_adj",
        "weekly_adj",
        "seasonal_adj",
        "CMIP",
        "GCM",
        "RCP",
        "mod"))
    }
  }
  
  
  # remove duplicates:
  ACLIM_annual_hind    <- ACLIM_annual_hind %>% distinct(var, basin, year, units,
                                                         long_name,sim, type, sim_type, .keep_all= TRUE)
  ACLIM_seasonal_hind  <- ACLIM_seasonal_hind %>% distinct(var, basin,season, year, units,
                                                           long_name,sim, type, sim_type, .keep_all= TRUE)
  ACLIM_monthly_hind   <- ACLIM_monthly_hind %>% distinct(var, basin,season, mo, year, units,
                                                          long_name,sim, type, sim_type, .keep_all= TRUE)
  ACLIM_weekly_hind    <- ACLIM_weekly_hind %>% distinct(var, basin,season, mo, wk,year, units,
                                                         long_name,sim, type, sim_type, .keep_all= TRUE)
  ACLIM_surveyrep_hind <- ACLIM_surveyrep_hind %>% distinct(var, basin,season, year, units,
                                                            long_name,sim, type, sim_type, .keep_all= TRUE)
  
  ACLIM_annual_hist    <- ACLIM_annual_hist %>% distinct(var, basin, year, units,
                                                         long_name,sim, type, sim_type, .keep_all= TRUE)
  ACLIM_seasonal_hist  <- ACLIM_seasonal_hist %>% distinct(var, basin,season, year, units,
                                                           long_name,sim, type, sim_type, .keep_all= TRUE)
  ACLIM_monthly_hist   <- ACLIM_monthly_hist %>% distinct(var, basin,season, mo, year, units,
                                                          long_name,sim, type, sim_type, .keep_all= TRUE)
  ACLIM_weekly_hist    <- ACLIM_weekly_hist %>% distinct(var, basin,season, mo, wk,year, units,
                                                         long_name,sim, type, sim_type, .keep_all= TRUE)
  ACLIM_surveyrep_hist <- ACLIM_surveyrep_hist %>% distinct(var, basin,season, year, units,
                                                            long_name,sim, type, sim_type, .keep_all= TRUE)
  
  
  mi <- 6
  ACLIM_annual_hind$i    <- factor(ACLIM_annual_hind$i, levels = 1:mi )
  ACLIM_seasonal_hind$i  <- factor(ACLIM_seasonal_hind$i, levels = 1:mi )
  ACLIM_monthly_hind$i   <- factor(ACLIM_monthly_hind$i, levels = 1:mi )
  ACLIM_weekly_hind$i    <- factor(ACLIM_weekly_hind$i, levels = 1:mi )
  ACLIM_surveyrep_hind$i <- factor(ACLIM_surveyrep_hind$i, levels = 1:mi )
  
  ACLIM_annual_hist$i    <- factor(ACLIM_annual_hist$i, levels = 1:mi )
  ACLIM_seasonal_hist$i  <- factor(ACLIM_seasonal_hist$i, levels = 1:mi )
  ACLIM_monthly_hist$i   <- factor(ACLIM_monthly_hist$i, levels = 1:mi )
  ACLIM_weekly_hist$i    <- factor(ACLIM_weekly_hist$i, levels = 1:mi )
  ACLIM_surveyrep_hist$i <- factor(ACLIM_surveyrep_hist$i, levels = 1:mi )
  
  if(1==10){  
    dd <- ACLIM_annual_hind%>%
      filter(var =="temp_bottom5m")
    ht <- ACLIM_annual_hist%>%
      filter(var =="temp_bottom5m",basin=="SEBS")%>%
      mutate(sim2 =(strsplit(sim,"_")[[1]][4]))
    
    hd <- ACLIM_annual_hind%>%
      filter(var =="temp_bottom5m",basin=="SEBS")%>%
      mutate (sim2 = "hindcast")
    fut <- ACLIM_annual_fut%>%
      filter(var =="temp_bottom5m",basin=="SEBS")%>%
      mutate(sim2 =(strsplit(sim,"_")[[1]][4]))
    
    ggplot(fut)+
      geom_line(aes(x=mnDate,y=mn_val,color=sim))+
      geom_line(data=hd, aes(x=mnDate,y=mn_val),color="blue3",alpha = .6)+
      geom_line(data=hd,aes(x=mnDate,y=mnVal_hind),color="blue3")+
      #geom_line(data=ht,aes(x=mnDate,y=mn_val),color="gray",linetype = "dashed",alpha = .8)+
      #geom_line(data=ht,aes(x=mnDate,y=mnVal_hist),color="gray",linetype = "dashed")+
      theme_minimal()+ylab(" Bottom Temperature")
    
    # ------------------------------------
    # 5  -- save results    
    
    outlist <- c("ACLIM_annual_hind",
                 "ACLIM_seasonal_hind",
                 "ACLIM_monthly_hind",
                 "ACLIM_weekly_hind",
                 "ACLIM_surveyrep_hind",
                 
                 "ACLIM_annual_hist",
                 "ACLIM_seasonal_hist",
                 "ACLIM_monthly_hist",
                 "ACLIM_weekly_hist",
                 "ACLIM_surveyrep_hist",
                 
                 "ACLIM_annual_fut",
                 "ACLIM_seasonal_fut",
                 "ACLIM_monthly_fut",
                 "ACLIM_weekly_fut",
                 "ACLIM_surveyrep_fut")
    
    if(!dir.exists("Data/out")) dir.create("Data/out")
    if(!dir.exists( paste0("Data/out") )) dir.create(paste0("Data/out"))
    fl_out <- paste0("Data/out")
    if(!dir.exists(file.path(fl_out,CMIP_fdlr))) 
      dir.create(file.path(fl_out,CMIP_fdlr))
    
    if(BC_target=="mn_val"){
      if(!dir.exists(file.path(fl_out,CMIP_fdlr,"watercolumn_mean"))) 
        dir.create(file.path(fl_out,CMIP_fdlr,"watercolumn_mean"))
      for(outfl in outlist){
        tmpfl <- file.path(fl_out,CMIP_fdlr,"watercolumn_mean",paste0(outfl,"_mn",".Rdata"))
        if(file.exists(tmpfl)) 
          file.remove(tmpfl)    
        eval(parse(text = paste0("save(",outfl,", file=",tmpfl,")")))
        rm(tmpfl)
      } }else{
        if(BC_target=="tot_val"){
          if(!dir.exists(file.path(fl_out,CMIP_fdlr,"watercolumn_total"))) 
            dir.create(file.path(fl_out,CMIP_fdlr,"watercolumn_total"))
          for(outfl in outlist){
            tmpfl <- file.path(fl_out,CMIP_fdlr,"watercolumn_mean",paste0(outfl,"_mn",".Rdata"))
            if(file.exists(tmpfl)) 
              file.remove(tmpfl)    
            eval(parse(text = paste0("save(",outfl,", file=",tmpfl,")")))
            rm(list=c("tmpfl","outfl"))
          } }else{
            stop("BC_target must be either 'mn_val' or 'tot_val'")
          }}
    
  }
  cat("-- Complete\n")
