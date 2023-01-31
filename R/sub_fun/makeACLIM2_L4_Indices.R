#'
#'
#'#'
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

makeACLIM2_L4_Indices_strata <- function(
  CMIP_fdlr = "CMIP6",
  scenIN    = c("ssp126","ssp585"),
  hind_sim  =  "B10K-K20_CORECFS",
  histLIST,
  mod  = "10K-K20P19",
  usehist   = TRUE,
  regnm     = "ACLIMregion",
  srvynm    = "ACLIMsurveyrep",
  
  Rdata_pathIN = Rdata_path,
  normlist_IN = normlist,
  gcms= c("miroc","gfdl","cesm"),
  sim_listIN){
  
  ACLIMsurveyrep_B10K-K20P19_CMIP6_cesm_BC_hist.Rdata
  
  for(gcm in gcms){
    nm <- paste0(regnm,"_",mod,"_",CMIP_fdlr,"_",gcm,"_BC_hist.Rdata")
    load(nm)
    
    
    ACLIM_annual_hist   <- annual_adj$hist%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)
    ACLIM_seasonal_hist <- seasonal_adj$hist%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)
    ACLIM_monthly_hist  <- monthly_adj$hist%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)
    ACLIM_weekly_histold<- weekly_adj_old$hist%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)
    ACLIM_weekly_hist   <- weekly_adj$hist%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)
    ACLIM_surveyrep_hist<- surveyrep_adj$hist%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)
    
  }
  
  
  
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
  
  i  <- 0
  ii <- 1
  
  for( ii in 1:length(gcmcmipLIST)){
    
    #sim   <- paste0("B10K-K20P19_",gcmcmip,"_historical")
    gcmcmip <- gcmcmipLIST[ii]
    simL    <- sim_listIN[sim_listIN%in%paste0(gcmcmip,"_",rep(scenIN,1,each=length(gcmcmip)))]
    
   
    # Now for each projection get the index and bias correct it 
    cat("-- making projection indices....\n")
    sim<-simL[1]
    for (sim in simL){
      i <- i + 1
      cat("-- ",sim,"...\n-----------------------------------\n")
      #gcmcmipLIST = c("B10K-K20P19_CMIP6_miroc","B10K-K20P19_CMIP6_gfdl","B10K-K20P19_CMIP6_cesm")
      sim_listIN
      RCP   <- rev(strsplit(sim,"_")[[1]])[1]
      mod   <- (strsplit(sim,"_")[[1]])[1]
      CMIP  <- strsplit(sim,"_")[[1]][2]
      GCM   <- strsplit(sim,"_")[[1]][3]
      
     
      if(i ==1){
        # first time through
        if(!bystrata){
          ACLIM_annual_hind   <- annual_adj$hind%>%dplyr::mutate(i = i,gcmcmip="hind",CMIP=CMIP,GCM ="hind", scen = "hind", mod=mod)
          ACLIM_seasonal_hind <- seasonal_adj$hind%>%dplyr::mutate(i = i,gcmcmip="hind",CMIP=CMIP,GCM ="hind", scen = "hind", mod=mod)
          ACLIM_monthly_hind  <- monthly_adj$hind%>%dplyr::mutate(i = i,gcmcmip="hind",CMIP=CMIP,GCM ="hind", scen = "hind", mod=mod)
          ACLIM_weekly_hindold<- weekly_adj_old$hind%>%dplyr::mutate(i = i,gcmcmip="hind",CMIP=CMIP,GCM ="hind", scen = "hind", mod=mod)
          ACLIM_weekly_hind   <- weekly_adj$hind%>%dplyr::mutate(i = i,gcmcmip="hind",CMIP=CMIP,GCM ="hind", scen = "hind", mod=mod)
          ACLIM_surveyrep_hind<- surveyrep_adj$hind%>%dplyr::mutate(i = i,gcmcmip="hind",CMIP=CMIP,GCM ="hind", scen = "hind", mod=mod)
          
          ACLIM_annual_hist   <- annual_adj$hist%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)
          ACLIM_seasonal_hist <- seasonal_adj$hist%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)
          ACLIM_monthly_hist  <- monthly_adj$hist%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)
          ACLIM_weekly_histold<- weekly_adj_old$hist%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)
          ACLIM_weekly_hist   <- weekly_adj$hist%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)
          ACLIM_surveyrep_hist<- surveyrep_adj$hist%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)
          
          ACLIM_annual_fut    <- annual_adj$fut%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)
          ACLIM_seasonal_fut  <- seasonal_adj$fut%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)
          ACLIM_monthly_fut   <- monthly_adj$fut%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)
          ACLIM_weekly_futold <- weekly_adj_old$fut%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)
          ACLIM_weekly_fut    <- weekly_adj$fut%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)
          ACLIM_surveyrep_fut <- surveyrep_adj$fut%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)
        }else{
          
          ACLIM_strata_weekly_hind   <-   strata_weekly_adj$hind%>%dplyr::mutate(i = i,gcmcmip="hind",CMIP=CMIP,GCM ="hind", scen = "hind", mod=mod)
          ACLIM_strata_monthly_hind  <-  strata_monthly_adj$hind%>%dplyr::mutate(i = i,gcmcmip="hind",CMIP=CMIP,GCM ="hind", scen = "hind", mod=mod)
          ACLIM_strata_seasonal_hind <- strata_seasonal_adj$hind%>%dplyr::mutate(i = i,gcmcmip="hind",CMIP=CMIP,GCM ="hind", scen = "hind", mod=mod)
          ACLIM_strata_weekly_hist   <- strata_weekly_adj$hist%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)
          ACLIM_strata_monthly_hist  <- strata_monthly_adj$hist%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)
          ACLIM_strata_seasonal_hist <- strata_seasonal_adj$hist%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)
          ACLIM_strata_weekly_fut    <- strata_weekly_adj$fut%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)
          ACLIM_strata_monthly_fut   <- strata_monthly_adj$fut%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)
          ACLIM_strata_seasonal_fut  <- strata_seasonal_adj$fut%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)
          
        }
      }
      
      if(i!=1){
        # next time through
        # ACLIM_annual_hind   <- rbind(ACLIM_annual_hind,annual_adj$hind%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod))
        # ACLIM_seasonal_hind <- rbind(ACLIM_seasonal_hind,seasonal_adj$hind%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod))
        # ACLIM_monthly_hind  <- rbind(ACLIM_monthly_hind,monthly_adj$hind%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod))
        # ACLIM_weekly_hind   <- rbind(ACLIM_weekly_hind,weekly_adj_old$hind%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod))
        # ACLIM_surveyrep_hind<- rbind(ACLIM_surveyrep_hind,surveyrep_adj$hind%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod))
        if(!bystrata){
          ACLIM_annual_hist   <- rbind(ACLIM_annual_hist,annual_adj$hist%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod))
          ACLIM_seasonal_hist <- rbind(ACLIM_seasonal_hist,seasonal_adj$hist%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod))
          ACLIM_monthly_hist  <- rbind(ACLIM_monthly_hist,monthly_adj$hist%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod))
          ACLIM_weekly_histold<- rbind(ACLIM_weekly_histold,weekly_adj_old$hist%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod))
          ACLIM_weekly_hist   <- rbind(ACLIM_weekly_hist,weekly_adj$hist%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod))
          ACLIM_surveyrep_hist<- rbind(ACLIM_surveyrep_hist,surveyrep_adj$hist%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod))
          
          ACLIM_annual_fut    <- rbind(ACLIM_annual_fut,annual_adj$fut%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod))
          ACLIM_seasonal_fut  <- rbind(ACLIM_seasonal_fut,seasonal_adj$fut%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod))
          ACLIM_monthly_fut   <- rbind(ACLIM_monthly_fut,monthly_adj$fut%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod))
          ACLIM_weekly_futold <- rbind(ACLIM_weekly_futold,weekly_adj_old$fut%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod))
          ACLIM_weekly_fut    <- rbind(ACLIM_weekly_fut,weekly_adj$fut%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod))
          ACLIM_surveyrep_fut     <- rbind(ACLIM_surveyrep_fut,surveyrep_adj$fut%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod))
        }else{
          ACLIM_strata_weekly_hist<- rbind(ACLIM_strata_weekly_hist,strata_weekly_adj$hist%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod))
          ACLIM_strata_monthly_hist<- rbind(ACLIM_strata_monthly_hist,strata_monthly_adj$hist%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod))
          ACLIM_strata_seasonal_hist<- rbind(ACLIM_strata_seasonal_hist,strata_seasonal_adj$hist%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod))
          ACLIM_strata_weekly_fut<- rbind(ACLIM_strata_weekly_fut,strata_weekly_adj$fut%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod))
          ACLIM_strata_monthly_fut<- rbind(ACLIM_strata_monthly_fut,strata_monthly_adj$fut%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod))
          ACLIM_strata_seasonal_fut<- rbind(ACLIM_strata_seasonal_fut,strata_seasonal_adj$fut%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod))
          
        }
      }
      if(!bystrata){
        rm(list= c( 
          # "reg_indices_annual_proj",
          # "reg_indices_seasonal_proj",
          # "reg_indices_monthly_proj",
          "reg_indices_weekly_proj",
          "srvy_indices_proj",
          "surveyrep_adj",
          "annual_adj",
          "monthly_adj",
          "weekly_adj",
          "seasonal_adj",
          "weekly_adj_old",
          "CMIP",
          "GCM",
          "RCP",
          "mod"))
      }else{
        rm(list= c( 
          # "reg_indices_annual_proj",
          # "reg_indices_seasonal_proj",
          # "reg_indices_monthly_proj",
          "reg_indices_weekly_proj",
          "srvy_indices_proj",
          "strata_monthly_adj",
          "strata_weekly_adj",
          "strata_seasonal_adj",
          "CMIP",
          "GCM",
          "RCP",
          "mod"))
      }
      
      gc()
    }
  }
  
  mi <- 6
  # remove duplicates:
  if(!bystrata){
    ACLIM_annual_hind    <- ACLIM_annual_hind %>% dplyr::distinct(var, basin, year, units,
                                                                  long_name,sim, type, sim_type, .keep_all= TRUE)%>%mutate(i = factor(i, levels = 1:mi ))
    ACLIM_seasonal_hind  <- ACLIM_seasonal_hind %>% dplyr::distinct(var, basin,season, year, units,
                                                                    long_name,sim, type, sim_type, .keep_all= TRUE)%>%mutate(i = factor(i, levels = 1:mi ))
    ACLIM_monthly_hind   <- ACLIM_monthly_hind %>% dplyr::distinct(var, basin,season, mo, year, units,
                                                                   long_name,sim, type, sim_type, .keep_all= TRUE)%>%mutate(i = factor(i, levels = 1:mi ))
    ACLIM_weekly_hindold <- ACLIM_weekly_hindold %>% dplyr::distinct(var, basin,season, mo, wk,year, units,
                                                                     long_name,sim, type, sim_type, .keep_all= TRUE)%>%mutate(i = factor(i, levels = 1:mi ))
    ACLIM_weekly_hind    <- ACLIM_weekly_hind  %>% dplyr::distinct(var, basin,season, mo, wk,year, units,
                                                                   long_name,sim, type, sim_type, .keep_all= TRUE)%>%mutate(i = factor(i, levels = 1:mi ))
    ACLIM_surveyrep_hind <- ACLIM_surveyrep_hind %>% dplyr::distinct(var, basin,season, year, units,
                                                                     long_name,sim, type, sim_type, .keep_all= TRUE)%>%mutate(i = factor(i, levels = 1:mi ))
    
    
    ACLIM_annual_hist    <- ACLIM_annual_hist %>% dplyr::distinct(var, basin, year, units,
                                                                  long_name,sim, type, sim_type, .keep_all= TRUE)%>%mutate(i = factor(i, levels = 1:mi ))
    ACLIM_seasonal_hist  <- ACLIM_seasonal_hist %>% dplyr::distinct(var, basin,season, year, units,
                                                                    long_name,sim, type, sim_type, .keep_all= TRUE)%>%mutate(i = factor(i, levels = 1:mi ))
    ACLIM_monthly_hist   <- ACLIM_monthly_hist %>% dplyr::distinct(var, basin,season, mo, year, units,
                                                                   long_name,sim, type, sim_type, .keep_all= TRUE)%>%mutate(i = factor(i, levels = 1:mi ))
    ACLIM_weekly_histold <- ACLIM_weekly_histold %>% dplyr::distinct(var, basin,season, mo, wk,year, units,
                                                                     long_name,sim, type, sim_type, .keep_all= TRUE)%>%mutate(i = factor(i, levels = 1:mi ))
    ACLIM_weekly_hist     <- ACLIM_weekly_hist %>% dplyr::distinct(var, basin,season, mo, wk,year, units,
                                                                   long_name,sim, type, sim_type, .keep_all= TRUE)%>%mutate(i = factor(i, levels = 1:mi ))
    ACLIM_surveyrep_hist <- ACLIM_surveyrep_hist %>% dplyr::distinct(var, basin,season, year, units,
                                                                     long_name,sim, type, sim_type, .keep_all= TRUE)%>%mutate(i = factor(i, levels = 1:mi ))
  }else{
    ACLIM_strata_weekly_hind <- ACLIM_strata_weekly_hind %>% dplyr::distinct(var, basin,season, year, units,
                                                                             long_name,sim, type, sim_type, .keep_all= TRUE)%>%mutate(i = factor(i, levels = 1:mi ))
    ACLIM_strata_monthly_hind <- ACLIM_strata_monthly_hind %>% dplyr::distinct(var, basin,season, year, units,
                                                                               long_name,sim, type, sim_type, .keep_all= TRUE)%>%mutate(i = factor(i, levels = 1:mi ))
    ACLIM_strata_seasonal_hind <- ACLIM_strata_seasonal_hind %>% dplyr::distinct(var, basin,season, year, units,
                                                                                 long_name,sim, type, sim_type, .keep_all= TRUE)%>%mutate(i = factor(i, levels = 1:mi ))
    ACLIM_strata_weekly_hist <- ACLIM_strata_weekly_hist %>% dplyr::distinct(var, basin,season, year, units,
                                                                             long_name,sim, type, sim_type, .keep_all= TRUE)%>%mutate(i = factor(i, levels = 1:mi ))
    ACLIM_strata_monthly_hist <- ACLIM_strata_monthly_hist %>% dplyr::distinct(var, basin,season, year, units,
                                                                               long_name,sim, type, sim_type, .keep_all= TRUE)%>%mutate(i = factor(i, levels = 1:mi ))
    ACLIM_strata_seasonal_hist <- ACLIM_strata_seasonal_hist %>% dplyr::distinct(var, basin,season, year, units,
                                                                                 long_name,sim, type, sim_type, .keep_all= TRUE)%>%mutate(i = factor(i, levels = 1:mi ))
    
  }
  
  
  # ------------------------------------
  # 5  -- save results    
  cat("-- Complete\n")
  if(!bystrata){
    return(list(   ACLIM_annual_hind    = ACLIM_annual_hind,
                   ACLIM_seasonal_hind  = ACLIM_seasonal_hind,
                   ACLIM_monthly_hind   = ACLIM_monthly_hind,
                   ACLIM_weekly_hindold = ACLIM_weekly_hindold,
                   ACLIM_weekly_hind    = ACLIM_weekly_hind,
                   ACLIM_surveyrep_hind = ACLIM_surveyrep_hind,
                   
                   
                   ACLIM_annual_hist    = ACLIM_annual_hist,
                   ACLIM_seasonal_hist  = ACLIM_seasonal_hist,
                   ACLIM_monthly_hist   = ACLIM_monthly_hist,
                   ACLIM_weekly_histold = ACLIM_weekly_histold,
                   ACLIM_weekly_hist    = ACLIM_weekly_hist,
                   ACLIM_surveyrep_hist = ACLIM_surveyrep_hist,
                   
                   ACLIM_annual_fut    = ACLIM_annual_fut,
                   ACLIM_seasonal_fut  = ACLIM_seasonal_fut,
                   ACLIM_monthly_fut   = ACLIM_monthly_fut,
                   ACLIM_weekly_futold = ACLIM_weekly_futold,
                   ACLIM_weekly_fut    = ACLIM_weekly_fut,
                   ACLIM_surveyrep_fut = ACLIM_surveyrep_fut))
    
  }else{
    return(list(    ACLIM_strata_weekly_hind = ACLIM_strata_weekly_hind,
                    ACLIM_strata_monthly_hind = ACLIM_strata_monthly_hind,
                    ACLIM_strata_seasonal_hind = ACLIM_strata_seasonal_hind,
                    ACLIM_strata_weekly_hist = ACLIM_strata_weekly_hist,
                    ACLIM_strata_monthly_hist = ACLIM_strata_monthly_hist,
                    ACLIM_strata_seasonal_hist = ACLIM_strata_seasonal_hist,
                    ACLIM_strata_weekly_fut = ACLIM_strata_weekly_fut,
                    ACLIM_strata_monthly_fut = ACLIM_strata_monthly_fut,
                    ACLIM_strata_seasonal_fut = ACLIM_strata_seasonal_fut))
    
  }
}



