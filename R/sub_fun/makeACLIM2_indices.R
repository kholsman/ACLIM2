#'
#'
#'
#'makeACLIM2_Indices()
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

makeACLIM2_Indices <- function(
  BC_target = "mn_val",
  CMIP_fdlr = "CMIP6",
  hind_sim  =  "B10K-K20_CORECFS",
  histLIST,
  regnm    = "ACLIMregion",
  srvynm    = "ACLIMsurveyrep",
  
  Rdata_pathIN = Rdata_path,
  normlist_IN = normlist,
  gcmcmipLIST = c("B10K-K20P19_CMIP6_miroc","B10K-K20P19_CMIP6_gfdl","B10K-K20P19_CMIP6_cesm"),
  sim_listIN){

  reg_txtIN  = paste0("Level3/",regnm,"_")
  srvy_txtIN =paste0("Level3/",srvynm,"_")
    # ------------------------------------
    # 1  -- Create indices from Hindcast
    cat("-- Starting analysis...\n")
    
    # load the Hindcast:
    # -------------------------
    cat("-- making hindcast indices....\n")
  
    #sim <- "B10K-K20_CORECFS"
    sim  <- hind_sim
    load(file.path(Rdata_pathIN,file.path(sim,paste0(reg_txtIN,sim,".Rdata"))))
    
    load(file.path(Rdata_pathIN,file.path(sim,paste0(srvy_txtIN,sim,".Rdata"))))
    eval(parse(text=paste0("hnd       <- ",regnm,"; rm(",regnm,")")))
    eval(parse(text=paste0("hnd_srvy  <- ",srvynm,"; rm(",srvynm,")")))
    gc()
    # Get Indices: 
    # -------------------------
    # area weighted  means for survey indices (annual)
    cat("    -- get srvy_indices_hind ... \n")
    srvy_indices_hind  <-  make_indices_srvyrep(simIN = hnd_srvy,
                                                seasonsIN   = seasons, 
                                                refyrs      = deltayrs,
                                                type        = "survey replicated")
    
    # area weighted weekly means for the NEBS and SEBS separately
    cat("    -- get reg_indices_weekly_hind ... \n")
    reg_indices_weekly_hind <- make_indices_region(simIN = hnd,
                                                   timeblockIN = c("yr","season","mo","wk"),
                                                   seasonsIN   = seasons,
                                                   refyrs      = deltayrs,
                                                   type        = "weekly means")
    tmp <- reg_indices_weekly_hind
    
    # get monthly means:
    cat("    -- make reg_indices_monthly_hind ... \n")
    reg_indices_monthly_hind  <- tmp%>%
      dplyr::group_by(var,year,season,mo,units, long_name,basin,sim)%>%
      dplyr::summarize(mn_val  = mean(mn_val, na.rm = T),
                mnDate  = mean(mnDate, na.rm = T))%>%
      dplyr::mutate(type = "monthly means",
                    jday = mnDate,
                    mnDate = as.Date(paste0(year,"-01-01"))+mnDate)
    
    # get seasonal means:
    cat("    -- make reg_indices_seasonal_hind ... \n")
    reg_indices_seasonal_hind  <- tmp%>%
      dplyr::group_by(var,year,season,units, long_name,basin,sim)%>%
      dplyr::summarize(mn_val  = mean(mn_val, na.rm = T),
                mnDate  = mean(mnDate, na.rm = T))%>%
      dplyr::mutate(type =  "seaonal means",
                    jday = mnDate,
                    mnDate = as.Date(paste0(year,"-01-01"))+mnDate)
    
    # get annual means:
    cat("    -- make reg_indices_annual_hind ... \n")
    reg_indices_annual_hind <- tmp%>%
      dplyr::group_by(var,year,units, long_name,basin,sim)%>%
      dplyr::summarize(mn_val  = mean(mn_val, na.rm = T),
                mnDate  = mean(mnDate, na.rm = T))%>%
      dplyr::mutate(type = "annual means",
                    jday = mnDate,
                    mnDate = as.Date(paste0(year,"-01-01"))+mnDate)
    
    reg_indices_weekly_hind <- reg_indices_weekly_hind%>%
      dplyr::mutate(type = "weekly means",
                    jday = mnDate,
                    mnDate = as.Date(paste0(year,"-01-01"))+mnDate)
    
    srvy_indices_hind <- srvy_indices_hind%>%
      dplyr::mutate(jday = mnDate,
                    mnDate = as.Date(paste0(year,"-01-01"))+mnDate)
   rm(list=c("tmp","hnd","hnd_srvy"))
   gc()
  # ------------------------------------
  # 2  -- loop across GCMs and create historical run indicies
     
      i <- 0
      # gcmcmip <- "CMIP6_miroc"
      #for( gcmcmip  in c("CMIP6_miroc","CMIP6_gfdl","CMIP6_cesm")){
      for( ii in 1:length(gcmcmipLIST)){
       
        #sim   <- paste0("B10K-K20P19_",gcmcmip,"_historical")
        gcmcmip <- gcmcmipLIST[ii]
        sim     <- histLIST[ii]
        
        
        load(file.path(Rdata_pathIN,file.path(sim,paste0(reg_txtIN,sim,".Rdata"))))
        load(file.path(Rdata_pathIN,file.path(sim,paste0(srvy_txtIN,sim,".Rdata"))))
        eval(parse(text=paste0("hist       <- ",regnm,"; rm(",regnm,")")))
        eval(parse(text=paste0("hist_srvy  <- ",srvynm,"; rm(",srvynm,")")))
        gc()
        
        
        # Get Historical Indices: 
        # -------------------------
        cat("-- making historical indices....\n")
        # area weighted  means for survey indices (annual)
        cat("    -- make srvy_indices_hist ... \n")
        srvy_indices_hist <-  make_indices_srvyrep(simIN  = hist_srvy,
                                                   seasonsIN   = seasons, 
                                                   refyrs      = deltayrs,
                                                   type        = "survey replicated")
        
        # area weighted weekly means for the NEBS and SEBS separately
        cat("    -- make reg_indices_weekly_hist ... \n")
        reg_indices_weekly_hist <- make_indices_region(simIN       = hist,
                                                       timeblockIN = c("yr","season","mo","wk"),
                                                       seasonsIN   = seasons,
                                                       refyrs      = deltayrs,
                                                       type        = "weekly means")
        
        tmp <- reg_indices_weekly_hist
        # get monthly means:
        cat("    -- make reg_indices_monthly_hist ... \n")
        reg_indices_monthly_hist  <- tmp%>%
          dplyr::group_by(var,year,season,mo,units, long_name,basin,sim)%>%
          dplyr::summarize(mn_val  = mean(mn_val, na.rm = T),
                    mnDate  = mean(mnDate, na.rm = T))%>%
          dplyr::mutate(type = "monthly means",
                        jday = mnDate,
                        mnDate = as.Date(paste0(year,"-01-01"))+mnDate)
        
        # get seasonal means:
        cat("    -- make reg_indices_seasonal_hist ... \n")
        reg_indices_seasonal_hist  <- tmp%>%
          dplyr::group_by(var,year,season,units, long_name,basin,sim)%>%
          dplyr::summarize(mn_val  = mean(mn_val, na.rm = T),
                    mnDate  = mean(mnDate, na.rm = T))%>%
          dplyr::mutate(type =  "seaonal means",
                        jday = mnDate,
                        mnDate = as.Date(paste0(year,"-01-01"))+mnDate)
        
        # get annual means:
        cat("    -- make reg_indices_annual_hist ... \n")
        reg_indices_annual_hist  <- tmp%>%
          dplyr::group_by(var,year,units, long_name,basin,sim)%>%
          dplyr::summarize(mn_val  = mean(mn_val, na.rm = T),
                    mnDate  = mean(mnDate, na.rm = T))%>%
          dplyr::mutate(type = "annual means",
                        jday = mnDate,
                        mnDate = as.Date(paste0(year,"-01-01"))+mnDate)
        
        reg_indices_weekly_hist <- reg_indices_weekly_hist%>%
          dplyr::mutate(type = "weekly means",
                        jday = mnDate,
                        mnDate = as.Date(paste0(year,"-01-01"))+mnDate)
        
        srvy_indices_hist <- srvy_indices_hist%>%
          dplyr::mutate(jday = mnDate,
                        mnDate = as.Date(paste0(year,"-01-01"))+mnDate)
        
        rm(list=c("tmp","hist","hist_srvy"))
        gc()
        # select the simulations that correspond to the cmip x gcm:
        simL <- sim_listIN[grep(gcmcmip,sim_listIN)]
  
  # ------------------------------------
  # 3  -- create projection indices

        # Now for each projection get the index and bias correct it 
        cat("-- making projection indices....\n")
        for (sim in simL){
          i <- i + 1
          cat("-- ",sim,"...\n-----------------------------------\n")
          #gcmcmipLIST = c("B10K-K20P19_CMIP6_miroc","B10K-K20P19_CMIP6_gfdl","B10K-K20P19_CMIP6_cesm")
          sim_listIN
          # CMIP  <- strsplit(gcmcmip,"_")[[1]][2]
          # GCM   <- strsplit(gcmcmip,"_")[[1]][3]
          RCP  <- rev(strsplit(sim,"_")[[1]])[1]
          mod   <- (strsplit(sim,"_")[[1]])[1]
          CMIP  <- strsplit(sim,"_")[[1]][2]
          GCM   <- strsplit(sim,"_")[[1]][3]
          
          load(file.path(Rdata_pathIN,file.path(sim,paste0(reg_txtIN,sim,".Rdata"))))
          load(file.path(Rdata_pathIN,file.path(sim,paste0(srvy_txtIN,sim,".Rdata"))))
          eval(parse(text=paste0("proj_wk       <- ",regnm,"; rm(",regnm,")")))
          eval(parse(text=paste0("proj_srvy  <- ",srvynm,"; rm(",srvynm,")")))
          gc()
          
          # Get Projection Indices: 
          # -------------------------
          # area weighted  means for survey indices (annual)
          cat("    -- make srvy_indices_proj ... \n")
          srvy_indices_proj <-  make_indices_srvyrep(simIN  = proj_srvy,
                                                     seasonsIN   = seasons, 
                                                     refyrs      = deltayrs,
                                                     type        = "survey replicated")
          cat("    -- make reg_indices_weekly_proj ... \n")
          # area weighted weekly means for the NEBS and SEBS separately
          reg_indices_weekly_proj <- make_indices_region(simIN  = proj_wk,
                                                         timeblockIN = c("yr","season","mo","wk"),
                                                         seasonsIN   = seasons,
                                                         refyrs      = deltayrs,
                                                         type        = "weekly means")

          tmp <- reg_indices_weekly_proj
          # get monthly means:
          cat("    -- make reg_indices_monthly_proj ... \n")
          reg_indices_monthly_proj  <- tmp%>%
            dplyr::group_by(var,year,season,mo,units, long_name,basin,sim)%>%
            dplyr::summarize(mn_val  = mean(mn_val, na.rm = T),
                      mnDate  = mean(mnDate, na.rm = T))%>%
            dplyr::mutate(type = "monthly means",
                          jday = mnDate,
                          mnDate = as.Date(paste0(year,"-01-01"))+mnDate)
          
          # get seasonal means:
          cat("    -- make reg_indices_seasonal_proj ... \n")
          reg_indices_seasonal_proj   <- tmp%>%
            dplyr::group_by(var,year,season,units, long_name,basin,sim)%>%
            dplyr::summarize(mn_val  = mean(mn_val, na.rm = T),
                      mnDate  = mean(mnDate, na.rm = T))%>%
            dplyr::mutate(type =  "seaonal means",
                          jday = mnDate,
                          mnDate = as.Date(paste0(year,"-01-01"))+mnDate)
          
          # get annual means:
          cat("    -- make reg_indices_annual_proj ... \n")
          reg_indices_annual_proj   <- tmp%>%
            dplyr::group_by(var,year,units, long_name,basin,sim)%>%
            dplyr::summarize(
              mn_val  = mean(mn_val, na.rm = T),
              mnDate  = mean(mnDate, na.rm = T))%>%
            dplyr::mutate(type = "annual means",
                          jday = mnDate,
                          mnDate = as.Date(paste0(year,"-01-01"))+mnDate)
          
          reg_indices_weekly_proj <- reg_indices_weekly_proj%>%
            dplyr::mutate(type = "weekly means",
                          jday = mnDate,
                          mnDate = as.Date(paste0(year,"-01-01"))+mnDate)
          
          srvy_indices_proj <- srvy_indices_proj%>%
            dplyr::mutate(jday = mnDate,
                          mnDate = as.Date(paste0(year,"-01-01"))+mnDate)
          
          rm(list=c("tmp","proj_wk","proj_srvy"))
          gc()
  # ------------------------------------
  # 4  -- bias correct the projections
                 
          # Now bias correct the data:
          cat("    -- bias correct seasonal_adj ... \n")
          seasonal_adj <- suppressWarnings(bias_correct( 
            target     = BC_target,
            hindIN = reg_indices_seasonal_hind,
            histIN = reg_indices_seasonal_hist,
            futIN  = reg_indices_seasonal_proj,
            ref_yrs    = ref_years,
            group_byIN = c("var","basin","season"),
            normlistIN =  normlist_IN,
            plotwk     = 2,
            plotvarIN  = "temp_bottom5m", # this is just one of the variables
            log_adj    = 1e-4))
          # rm(list=c("reg_indices_seasonal_hind","reg_indices_seasonal_hist","reg_indices_seasonal_proj"))
          # gc()
          
          cat("    -- bias correct weekly_adj ... \n")
          weekly_adj <- suppressWarnings(bias_correct( 
            target     = BC_target,
            hindIN = reg_indices_weekly_hind,
            histIN = reg_indices_weekly_hist,
            futIN  = reg_indices_weekly_proj,
            ref_yrs    = ref_years,
            group_byIN = c("var","basin","season","mo","wk"),
            normlistIN =  normlist_IN,
            plotwk     = 2,
            plotvarIN  = "temp_bottom5m", # this is just one of the variables
            log_adj    = 1e-4))
          
          # rm(list=c("reg_indices_weekly_hind","reg_indices_weekly_hist","reg_indices_weekly_proj"))
          # gc()
          
          cat("    -- bias correct monthly_adj ... \n")
          monthly_adj <- suppressWarnings(bias_correct( 
            target     = BC_target,
            hindIN = reg_indices_monthly_hind,
            histIN = reg_indices_monthly_hist,
            futIN  = reg_indices_monthly_proj,
            ref_yrs    = ref_years,
            group_byIN = c("var","basin","season","mo"),
            normlistIN =  normlist_IN,
            plotwk     = 2,
            plotvarIN  = "temp_bottom5m", # this is just one of the variables
            log_adj    = 1e-4))
          
          # rm(list=c("reg_indices_monthly_hind","reg_indices_monthly_hist","reg_indices_monthly_proj"))
          # gc()
          cat("    -- bias correct annual_adj ... \n")
          annual_adj <- suppressWarnings(bias_correct( 
            target     = BC_target,
            hindIN = reg_indices_annual_hind,
            histIN = reg_indices_annual_hist,
            futIN  = reg_indices_annual_proj,
            ref_yrs    = ref_years,
            group_byIN = c("var","basin"),
            normlistIN =  normlist_IN,
            plotwk     = 2,
            plotvarIN  = "temp_bottom5m", # this is just one of the variables
            log_adj    = 1e-4))
          
          # rm(list=c("reg_indices_annual_hind","reg_indices_annual_hist","reg_indices_annual_proj"))
          # gc()
          # 
          cat("    -- bias correct surveyrep_adj ... \n")
          surveyrep_adj <- bias_correct( 
            target     = BC_target,
            hindIN = srvy_indices_hind,
            histIN = srvy_indices_hist,
            futIN  = srvy_indices_proj,
            ref_yrs    = ref_years,
            group_byIN = c("var","basin","season"),
            normlistIN =  normlist_IN,
            plotIT = TRUE,
            plotwk = 45,
            plotvarIN  = "temp_bottom5m",
            log_adj    = 1e-4)
        
          # rm(list=c("srvy_indices_hind","srvy_indices_hist","srvy_indices_proj"))
          # gc()
          
          if(i ==1){
            # first time through
            ACLIM_annual_hind   <- annual_adj$hind%>%dplyr::mutate(i = i,gcmcmip="hind",CMIP=CMIP,GCM ="hind", scen = "hind", mod=mod)
            ACLIM_seasonal_hind <- seasonal_adj$hind%>%dplyr::mutate(i = i,gcmcmip="hind",CMIP=CMIP,GCM ="hind", scen = "hind", mod=mod)
            ACLIM_monthly_hind  <- monthly_adj$hind%>%dplyr::mutate(i = i,gcmcmip="hind",CMIP=CMIP,GCM ="hind", scen = "hind", mod=mod)
            ACLIM_weekly_hind   <- weekly_adj$hind%>%dplyr::mutate(i = i,gcmcmip="hind",CMIP=CMIP,GCM ="hind", scen = "hind", mod=mod)
            ACLIM_surveyrep_hind<- surveyrep_adj$hind%>%dplyr::mutate(i = i,gcmcmip="hind",CMIP=CMIP,GCM ="hind", scen = "hind", mod=mod)
            
            ACLIM_annual_hist   <- annual_adj$hist%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)
            ACLIM_seasonal_hist <- seasonal_adj$hist%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)
            ACLIM_monthly_hist  <- monthly_adj$hist%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)
            ACLIM_weekly_hist   <- weekly_adj$hist%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)
            ACLIM_surveyrep_hist<- surveyrep_adj$hist%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)
            
            ACLIM_annual_fut    <- annual_adj$fut%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)
            ACLIM_seasonal_fut  <- seasonal_adj$fut%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)
            ACLIM_monthly_fut   <- monthly_adj$fut%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)
            ACLIM_weekly_fut    <- weekly_adj$fut%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)
            ACLIM_surveyrep_fut <- surveyrep_adj$fut%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)
            
          }
          
          if(i!=1){
            # next time through
            # ACLIM_annual_hind   <- rbind(ACLIM_annual_hind,annual_adj$hind%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod))
            # ACLIM_seasonal_hind <- rbind(ACLIM_seasonal_hind,seasonal_adj$hind%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod))
            # ACLIM_monthly_hind  <- rbind(ACLIM_monthly_hind,monthly_adj$hind%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod))
            # ACLIM_weekly_hind   <- rbind(ACLIM_weekly_hind,weekly_adj$hind%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod))
            # ACLIM_surveyrep_hind<- rbind(ACLIM_surveyrep_hind,surveyrep_adj$hind%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod))

            ACLIM_annual_hist   <- rbind(ACLIM_annual_hist,annual_adj$hist%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod))
            ACLIM_seasonal_hist <- rbind(ACLIM_seasonal_hist,seasonal_adj$hist%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod))
            ACLIM_monthly_hist  <- rbind(ACLIM_monthly_hist,monthly_adj$hist%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod))
            ACLIM_weekly_hist   <- rbind(ACLIM_weekly_hist,weekly_adj$hist%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod))
            ACLIM_surveyrep_hist<- rbind(ACLIM_surveyrep_hist,surveyrep_adj$hist%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod))

            ACLIM_annual_fut    <- rbind(ACLIM_annual_fut,annual_adj$fut%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod))
            ACLIM_seasonal_fut  <- rbind(ACLIM_seasonal_fut,seasonal_adj$fut%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod))
            ACLIM_monthly_fut   <- rbind(ACLIM_monthly_fut,monthly_adj$fut%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod))
            ACLIM_weekly_fut    <- rbind(ACLIM_weekly_fut,weekly_adj$fut%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod))
            ACLIM_surveyrep_fut <- rbind(ACLIM_surveyrep_fut,surveyrep_adj$fut%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod))
            
          }
          rm(list= c( 
            "reg_indices_annual_proj",
            "reg_indices_seasonal_proj",
            "reg_indices_monthly_proj",
            "reg_indices_weekly_proj",
            "srvy_indices_proj",
            "surveyrep_adj",
            "annual_adj",
            "monthly_adj",
            "weekly_adj",
            "seasonal_adj",
            "CMIP",
            "GCM",
            "RCP",
            "mod"))
          
          gc()
        }
      }
      
    
      # remove duplicates:
      ACLIM_annual_hind    <- ACLIM_annual_hind %>% dplyr::distinct(var, basin, year, units,
                                                             long_name,sim, type, sim_type, .keep_all= TRUE)
      ACLIM_seasonal_hind  <- ACLIM_seasonal_hind %>% dplyr::distinct(var, basin,season, year, units,
                                                               long_name,sim, type, sim_type, .keep_all= TRUE)
      ACLIM_monthly_hind   <- ACLIM_monthly_hind %>% dplyr::distinct(var, basin,season, mo, year, units,
                                                              long_name,sim, type, sim_type, .keep_all= TRUE)
      ACLIM_weekly_hind    <- ACLIM_weekly_hind %>% dplyr::distinct(var, basin,season, mo, wk,year, units,
                                                             long_name,sim, type, sim_type, .keep_all= TRUE)
      ACLIM_surveyrep_hind <- ACLIM_surveyrep_hind %>% dplyr::distinct(var, basin,season, year, units,
                                                                long_name,sim, type, sim_type, .keep_all= TRUE)
      
      ACLIM_annual_hist    <- ACLIM_annual_hist %>% dplyr::distinct(var, basin, year, units,
                                                             long_name,sim, type, sim_type, .keep_all= TRUE)
      ACLIM_seasonal_hist  <- ACLIM_seasonal_hist %>% dplyr::distinct(var, basin,season, year, units,
                                                               long_name,sim, type, sim_type, .keep_all= TRUE)
      ACLIM_monthly_hist   <- ACLIM_monthly_hist %>% dplyr::distinct(var, basin,season, mo, year, units,
                                                              long_name,sim, type, sim_type, .keep_all= TRUE)
      ACLIM_weekly_hist    <- ACLIM_weekly_hist %>% dplyr::distinct(var, basin,season, mo, wk,year, units,
                                                             long_name,sim, type, sim_type, .keep_all= TRUE)
      ACLIM_surveyrep_hist <- ACLIM_surveyrep_hist %>% dplyr::distinct(var, basin,season, year, units,
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
      

  # ------------------------------------
  # 5  -- save results    
      cat("-- Complete\n")
      return(list(   ACLIM_annual_hind    = ACLIM_annual_hind,
                     ACLIM_seasonal_hind  = ACLIM_seasonal_hind,
                     ACLIM_monthly_hind   = ACLIM_monthly_hind,
                     ACLIM_weekly_hind    = ACLIM_weekly_hind,
                     ACLIM_surveyrep_hind = ACLIM_surveyrep_hind,
                     
                     ACLIM_annual_hist    = ACLIM_annual_hist,
                     ACLIM_seasonal_hist  = ACLIM_seasonal_hist,
                     ACLIM_monthly_hist   = ACLIM_monthly_hist,
                     ACLIM_weekly_hist    = ACLIM_weekly_hist,
                     ACLIM_surveyrep_hist = ACLIM_surveyrep_hist,
                     
                     ACLIM_annual_fut    = ACLIM_annual_fut,
                     ACLIM_seasonal_fut  = ACLIM_seasonal_fut,
                     ACLIM_monthly_fut   = ACLIM_monthly_fut,
                     ACLIM_weekly_fut    = ACLIM_weekly_fut,
                     ACLIM_surveyrep_fut = ACLIM_surveyrep_fut))
}
    

     