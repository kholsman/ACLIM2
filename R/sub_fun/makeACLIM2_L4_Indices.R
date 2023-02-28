#'
#'
#'#'
#'
#'
#'makeACLIM2_L4_Indices_strata()
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
  CMIP_fdlr = "Data/out/K20P19_CMIP6",
  ophind = FALSE,
  CMIP      = "CMIP6",
  scenIN    = c("ssp126","ssp585"),
  hind_sim  =  "B10K-K20P19_CORECFS",
  gcmcmipLIST = gcmcmipL,
  subfldr   = "BC_ACLIMregion",
  sim_listIN  =sim_list, 
  varlistIN = NULL,
  prefix = "ACLIMregion"){ 
  
  
  #"ACLIMsurveyrep",
  
  # Rdata_pathIN = Rdata_path,
  # normlist_IN = normlist,
  # gcms= c("miroc","gfdl","cesm"),
  # sim_listIN){
  # ACLIMsurveyrep_B10K-K20P19_CMIP6_miroc_BC_hist
  # ACLIMsurveyrep_B10K-K20P19_CMIP6_miroc_ssp126_BC_fut
  # 
  
  
  #hindcast:
  fn   <- paste0(prefix,"_",hind_sim,"_BC_hind.Rdata")
  load(file.path(CMIP_fdlr,subfldr,fn))
  
  qry_date <- hind$qry_date[1]
  if(is.null(varlistIN))
    varlistIN <- unique(hind$var)
  
  ACLIM_hind<-
    get_indices_hind(datIN = hind%>%filter(var%in%varlistIN),
                     group_byIN =c("var", "units","sim","basin","type","sim_type","lognorm","qry_date") )
  cat(" -- hind complete \n")
  rm(hind)
  gc()
  
  i <- 0
  ACLIM_annual_hind   <- ACLIM_hind$annual%>%dplyr::mutate(i = i,  gcmcmip="hind",CMIP=CMIP,GCM ="hind", scen = "hind", mod=hind_sim)%>%ungroup()
  ACLIM_seasonal_hind <- ACLIM_hind$seasonal%>%dplyr::mutate(i = i,gcmcmip="hind",CMIP=CMIP,GCM ="hind", scen = "hind", mod=hind_sim)%>%ungroup()
  ACLIM_monthly_hind  <- ACLIM_hind$monthly%>%dplyr::mutate(i = i, gcmcmip="hind",CMIP=CMIP,GCM ="hind", scen = "hind", mod=hind_sim)%>%ungroup()
  ACLIM_weekly_hind   <- ACLIM_hind$weekly%>%dplyr::mutate(i = i,  gcmcmip="hind",CMIP=CMIP,GCM ="hind", scen = "hind", mod=hind_sim)%>%ungroup()
  #ACLIM_surveyrep_hind<- surveyrep_adj$hind%>%dplyr::mutate(i = i,gcmcmip="hind",CMIP=CMIP,GCM ="hind", scen = "hind", mod=mod)
  
  
  fldr<-file.path(CMIP_fdlr,"allEBS_means")
  if(!dir.exists(fldr))
    dir.create(fldr)
  if(!ophind){
    for(ss in c("annual","monthly","seasonal","weekly"))
      eval(parse(text=paste0("save(ACLIM_",ss,"_hind, file=file.path(fldr,'ACLIM_",ss,"_hind_mn.Rdata'))")))
    
    for(ss in c("annual","monthly","seasonal","weekly"))
      eval(parse(text=paste0("rm(ACLIM_",ss,"_hind)")))
  }else{
    #operational hindcast
    for(ss in c("annual","monthly","seasonal","weekly"))
      eval(parse(text=paste0("save(ACLIM_",ss,"_hind, file=file.path(fldr,'ACLIM_",ss,"_operational_hind_mn.Rdata'))")))
    
    for(ss in c("annual","monthly","seasonal","weekly"))
      eval(parse(text=paste0("rm(ACLIM_",ss,"_hind)")))
  }
  
  
  i<-0
  if(!ophind){
    for( ii in 1:length(gcmcmipLIST)){
      gcmcmip <- gcmcmipLIST[ii]
      simL    <- sim_listIN[sim_listIN%in%paste0(gcmcmip,"_",rep(scenIN,1,each=length(gcmcmip)))]
      sim     <- simL[2]
      for (sim in simL){
        i <- i +1
        cat("  -- summarizing ",sim, "all EBS means\n")
        
        #sim   <- paste0("B10K-K20P19_",gcmcmip,"_historical")
        RCP   <- rev(strsplit(sim,"_")[[1]])[1]
        mod   <- (strsplit(sim,"_")[[1]])[1]
        CMIP  <- strsplit(sim,"_")[[1]][2]
        GCM   <- strsplit(sim,"_")[[1]][3]
        
        #historical:
        fn   <- paste0(prefix,"_",gcmcmip,"_BC_hist.Rdata")
        load(file.path(CMIP_fdlr,subfldr,fn))
        
        ACLIM_hist<-
          get_indices_hist(datIN = hist%>%filter(var%in%varlistIN),
                           group_byIN =c("var", "units","sim","basin","type","sim_type","lognorm","qry_date") )
        
        rm(hist)
        cat("    -- hist complete\n")
        
        
        #projection:
        fn   <- paste0(prefix,"_",sim,"_BC_fut.Rdata")
        load(file.path(CMIP_fdlr,subfldr,fn))
        
        
        ACLIM_fut<-
          get_indices_fut(datIN = fut%>%filter(var%in%varlistIN),
                          qry_dateIN = qry_date,
                          group_byIN =c("var", "units","sim","basin","type","sim_type","lognorm","qry_date","sf") )
  
  # fut%>%filter(year %in%2024,basin=="SEBS",mo==12,
  #               var=="largeZoop_integrated",sim=="ACLIMregion_B10K-K20P19_CMIP6_cesm_ssp585")%>%
  #   select(year,val_raw,val_delta,val_biascorrected,
  #          sf_wk,mnVal_hist,mnVal_hind,val_biascorrectedyr,val_biascorrectedmo)
  
        # ACLIM_fut$seasonal%>%filter(year%in%2024,
        #                       var=="largeZoop_integrated",sim=="ACLIMregion_B10K-K20P19_CMIP6_cesm_ssp585")%>%
        #   select(basin,year,mn_val,sd_val,total_area_km2,val_biascorrected,
        #    sf_wk,mnVal_hist,mnVal_hind,val_biascorrectedyr,val_biascorrectedmo)
        # ACLIM_fut$monthly%>%filter(year%in%2024,basin=="SEBS",
        #                             var=="largeZoop_integrated",sim=="ACLIMregion_B10K-K20P19_CMIP6_cesm_ssp585")%>%
        #   select(basin,year,mn_val,sd_val,total_area_km2,val_biascorrected,
        #          sf_wk,mnVal_hist,mnVal_hind,val_biascorrectedyr,val_biascorrectedmo)
        # ACLIM_fut$weekly%>%filter(year%in%2024,basin=="SEBS",mo==12,
        #                            var=="largeZoop_integrated",sim=="ACLIMregion_B10K-K20P19_CMIP6_cesm_ssp585")%>%
        #   select(basin,year,mn_val,total_area_km2,val_biascorrected,
        #          sf_wk,mnVal_hist,mnVal_hind,val_biascorrectedyr,val_biascorrectedmo)
         if(i==1){
          ACLIM_annual_hist   <- ACLIM_hist$annual%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)%>%ungroup()
          ACLIM_seasonal_hist <- ACLIM_hist$seasonal%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)%>%ungroup()
          ACLIM_monthly_hist  <- ACLIM_hist$monthly%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)%>%ungroup()
          ACLIM_weekly_hist   <- ACLIM_hist$weekly%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)%>%ungroup()
          #ACLIM_surveyrep_hist<- surveyrep_adj$hist%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)
  
          ACLIM_annual_fut   <- ACLIM_fut$annual%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)%>%ungroup()
          ACLIM_seasonal_fut <- ACLIM_fut$seasonal%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)%>%ungroup()
          ACLIM_monthly_fut  <- ACLIM_fut$monthly%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)%>%ungroup()
          ACLIM_weekly_fut   <- ACLIM_fut$weekly%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)%>%ungroup()
          #ACLIM_surveyrep_hist<- surveyrep_adj$hist%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)
          
          
        }else{
          
          ACLIM_annual_hist   <- rbind(ACLIM_annual_hist, ACLIM_hist$annual%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)%>%ungroup())
          ACLIM_seasonal_hist <- rbind(ACLIM_seasonal_hist,ACLIM_hist$seasonal%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)%>%ungroup())
          ACLIM_monthly_hist  <- rbind(ACLIM_monthly_hist, ACLIM_hist$monthly%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)%>%ungroup())
          ACLIM_weekly_hist   <- rbind(ACLIM_weekly_hist,ACLIM_hist$weekly%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)%>%ungroup())
          #ACLIM_surveyrep_hist<- surveyrep_adj$hist%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)
          
          ACLIM_annual_fut   <- rbind(ACLIM_annual_fut,ACLIM_fut$annual%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)%>%ungroup())
          ACLIM_seasonal_fut <- rbind(ACLIM_seasonal_fut,ACLIM_fut$seasonal%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)%>%ungroup())
          ACLIM_monthly_fut  <- rbind(ACLIM_monthly_fut,ACLIM_fut$monthly%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)%>%ungroup())
          ACLIM_weekly_fut   <- rbind(ACLIM_weekly_fut,ACLIM_fut$weekly%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)%>%ungroup())
          
          
          
        }
        rm(list=c("ACLIM_fut","ACLIM_hist","fut"))
      }
    }

   fldr<-file.path(CMIP_fdlr,"allEBS_means")
   if(!dir.exists(fldr))
    dir.create(fldr)
   for(ss in c("annual","monthly","seasonal","weekly"))
    eval(parse(text=paste0("save(ACLIM_",ss,"_hist, file=file.path(fldr,'ACLIM_",ss,"_hist_mn.Rdata'))")))
        
   for(ss in c("annual","monthly","seasonal","weekly"))
    eval(parse(text=paste0("save(ACLIM_",ss,"_fut, file=file.path(fldr,'ACLIM_",ss,"_fut_mn.Rdata'))")))
  }
}

makeACLIM2_L4_Indices_survey <- function(
  CMIP_fdlr = "Data/out/K20P19_CMIP6",
  ophind = FALSE,
  CMIP      = "CMIP6",
  scenIN    = c("ssp126","ssp585"),
  hind_sim  =  "B10K-K20P19_CORECFS",
  gcmcmipLIST = gcmcmipL,
  subfldr     = "BC_ACLIMsurveyrep",
  sim_listIN  =sim_list, 
  varlistIN = NULL,
  prefix = "ACLIMsurveyrep"){ 

  
  #hindcast:

  fn   <- paste0(prefix,"_",hind_sim,"_BC_hind.Rdata")
  load(file.path(CMIP_fdlr,subfldr,fn))
  #D:\GitHub_cloud\ACLIM2\Data\out\K20P19_CMIP6\BC_ACLIMsurveyrep
  qry_date <- hind$qry_date[1]
  if(is.null(varlistIN))
    varlistIN <- unique(hind$var)
  
  ACLIM_hind<-
    get_indices_hind_srvy(datIN = hind%>%filter(var%in%varlistIN),
                     group_byIN =c("var", "units","long_name","sim","basin","type","sim_type","lognorm","qry_date"))
  cat(" -- hind complete \n")
  
  ACLIM_surveyrep_hind   <- ACLIM_hind$annual%>%dplyr::mutate(i = 0,  gcmcmip="hind",CMIP=CMIP,GCM ="hind", scen = "hind", mod=hind_sim)%>%ungroup()

  fldr<-file.path(CMIP_fdlr,"allEBS_means")
  if(!dir.exists(fldr))
    dir.create(fldr)
  if(!ophind){
    save(ACLIM_surveyrep_hind, file = file.path(fldr, "ACLIM_surveyrep_hind_mn.Rdata"))
  }else{
    save(ACLIM_surveyrep_hind, file = file.path(fldr, "ACLIM_surveyrep_operational_hind_mn.Rdata"))
  }
  rm(hind)
  
  i<-0
  ii<-1
  if(!ophind){
    for( ii in 1:length(gcmcmipLIST)){
        gcmcmip <- gcmcmipLIST[ii]
        simL    <- sim_listIN[sim_listIN%in%paste0(gcmcmip,"_",rep(scenIN,1,each=length(gcmcmip)))]
       
      for (sim in simL){
        i <- i +1
        cat("  -- summarizing ",sim, "all EBS means\n")
        
        #sim   <- paste0("B10K-K20P19_",gcmcmip,"_historical")
      
        RCP   <- rev(strsplit(sim,"_")[[1]])[1]
        mod   <- (strsplit(sim,"_")[[1]])[1]
        CMIP  <- strsplit(sim,"_")[[1]][2]
        GCM   <- strsplit(sim,"_")[[1]][3]
        
        #historical:
        cat(" -- running hist")
        fn   <- paste0(prefix,"_",gcmcmip,"_BC_hist.Rdata")
        load(file.path(CMIP_fdlr,subfldr,fn))
        
        ACLIM_hist<-
          get_indices_hist_srvy(datIN = hist%>%filter(var%in%varlistIN),
                           group_byIN =c("var", "units","long_name","sim","basin","type","sim_type","lognorm","qry_date"))
        
        rm(hist)
        
        #projection:
        fn   <- paste0(prefix,"_",sim,"_BC_fut.Rdata")
        load(file.path(CMIP_fdlr,subfldr,fn))
        cat(" --  runing projection for sim: ", sim)
        ACLIM_fut<-
          get_indices_fut_srvy(datIN = fut%>%filter(var%in%varlistIN),
                          qry_dateIN = qry_date,
                          group_byIN =c("var", "units","sim","basin","type","sim_type","lognorm","qry_date","sf"))
                          
        rm(fut)
        if(i==1){
          ACLIM_surveyrep_hist   <- ACLIM_hist$annual%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)%>%ungroup()
          
          ACLIM_surveyrep_fut   <- ACLIM_fut$annual%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)%>%ungroup()
         
          
        }else{
          
          ACLIM_surveyrep_hist   <- rbind(ACLIM_surveyrep_hist, ACLIM_hist$annual%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)%>%ungroup())
        
          ACLIM_surveyrep_fut   <- rbind(ACLIM_surveyrep_fut,ACLIM_fut$annual%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)%>%ungroup())
        
        }
        rm(list=c("ACLIM_fut","ACLIM_hist"))
      }
    }
    fldr<-file.path(CMIP_fdlr,"allEBS_means")
    if(!dir.exists(fldr))
      dir.create(fldr)
    save(ACLIM_surveyrep_hist, file = file.path(fldr, "ACLIM_surveyrep_hist_mn.Rdata"))
    save(ACLIM_surveyrep_fut, file = file.path(fldr, "ACLIM_surveyrep_fut_mn.Rdata"))
  }
  
  
}
if(1==10){
  if(!bystrata){
    ACLIM_annual_hind   <- annual_adj$hind%>%dplyr::mutate(i = i,gcmcmip="hind",CMIP=CMIP,GCM ="hind", scen = "hind", mod=mod)%>%ungroup()
    ACLIM_seasonal_hind <- seasonal_adj$hind%>%dplyr::mutate(i = i,gcmcmip="hind",CMIP=CMIP,GCM ="hind", scen = "hind", mod=mod)%>%ungroup()
    ACLIM_monthly_hind  <- monthly_adj$hind%>%dplyr::mutate(i = i,gcmcmip="hind",CMIP=CMIP,GCM ="hind", scen = "hind", mod=mod)%>%ungroup()
    ACLIM_weekly_hindold<- weekly_adj_old$hind%>%dplyr::mutate(i = i,gcmcmip="hind",CMIP=CMIP,GCM ="hind", scen = "hind", mod=mod)%>%ungroup()
    ACLIM_weekly_hind   <- weekly_adj$hind%>%dplyr::mutate(i = i,gcmcmip="hind",CMIP=CMIP,GCM ="hind", scen = "hind", mod=mod)%>%ungroup()
    ACLIM_surveyrep_hind<- surveyrep_adj$hind%>%dplyr::mutate(i = i,gcmcmip="hind",CMIP=CMIP,GCM ="hind", scen = "hind", mod=mod)%>%ungroup()
    
    ACLIM_annual_hist   <- annual_adj$hist%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)%>%ungroup()
    ACLIM_seasonal_hist <- seasonal_adj$hist%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)%>%ungroup()
    ACLIM_monthly_hist  <- monthly_adj$hist%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)%>%ungroup()
    ACLIM_weekly_histold<- weekly_adj_old$hist%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)%>%ungroup()
    ACLIM_weekly_hist   <- weekly_adj$hist%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)%>%ungroup()
    ACLIM_surveyrep_hist<- surveyrep_adj$hist%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)%>%ungroup()
    
    ACLIM_annual_fut    <- annual_adj$fut%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)%>%ungroup()
    ACLIM_seasonal_fut  <- seasonal_adj$fut%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)%>%ungroup()
    ACLIM_monthly_fut   <- monthly_adj$fut%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)%>%ungroup()
    ACLIM_weekly_futold <- weekly_adj_old$fut%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)%>%ungroup()
    ACLIM_weekly_fut    <- weekly_adj$fut%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)%>%ungroup()
    ACLIM_surveyrep_fut <- surveyrep_adj$fut%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)%>%ungroup()
  }else{
    
    ACLIM_strata_weekly_hind   <- strata_weekly_adj$hind%>%dplyr::mutate(i = i,gcmcmip="hind",CMIP=CMIP,GCM ="hind", scen = "hind", mod=mod)%>%ungroup()
    ACLIM_strata_monthly_hind  <- strata_monthly_adj$hind%>%dplyr::mutate(i = i,gcmcmip="hind",CMIP=CMIP,GCM ="hind", scen = "hind", mod=mod)%>%ungroup()
    ACLIM_strata_seasonal_hind <- strata_seasonal_adj$hind%>%dplyr::mutate(i = i,gcmcmip="hind",CMIP=CMIP,GCM ="hind", scen = "hind", mod=mod)%>%ungroup()
    ACLIM_strata_weekly_hist   <- strata_weekly_adj$hist%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)%>%ungroup()
    ACLIM_strata_monthly_hist  <- strata_monthly_adj$hist%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)%>%ungroup()
    ACLIM_strata_seasonal_hist <- strata_seasonal_adj$hist%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)%>%ungroup()
    ACLIM_strata_weekly_fut    <- strata_weekly_adj$fut%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)%>%ungroup()
    ACLIM_strata_monthly_fut   <- strata_monthly_adj$fut%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)%>%ungroup()
    ACLIM_strata_seasonal_fut  <- strata_seasonal_adj$fut%>%dplyr::mutate(i = i,gcmcmip=gcmcmip,CMIP=CMIP,GCM =GCM, scen = RCP, mod=mod)%>%ungroup()
    
  }
  

  
  ggplot()+
    geom_line(data=sub%>%filter(year==1980,strata%in%c(71,50)),
              aes(x=jday, y=mn_val,color=strata))+
    geom_line (data =ACLIM_hind$weekly%>%filter(year==1980) ,
               aes(x=jday, y=mn_val,color=basin,linetype ="weekly"),size=.8)+
    geom_segment (data =ACLIM_hind$monthly%>%filter(year==1980),
               aes(x=jday-14,xend = jday+14, y=mn_val, yend = mn_val,color=basin,linetype="monthly"),size=1.1)+
    geom_segment (data =ACLIM_hind$seasonal%>%filter(year==1980),
                  aes(x=jday-40,xend = jday+40, y=mn_val, yend = mn_val,color=basin,linetype="seasonal"),size=1.1)+
     # geom_line (data =ACLIM_hind$seasonal%>%filter(year==1980) ,
     #           aes(x=jday, y=mn_val,color=basin,linetype="seasonal"),size=1.1)+
    geom_hline (data =ACLIM_hind$annual%>%filter(year==1980) ,
               aes(yintercept=mn_val,color=basin),size=1.1)+
    facet_grid(var~basin,scales="free_y")+theme_minimal()
  
  
  
  ggplot()+
    geom_line(data=sub%>%filter(year%in%(1980:1984),strata%in%c(71,50)),
              aes(x=mnDate, y=mn_val,color=strata))+
    geom_line (data =ACLIM_hind$weekly%>%filter(year%in%(1980:1984)) ,
               aes(x=mnDate, y=mn_val,color=basin,linetype ="weekly"),size=.8)+
    geom_line (data =ACLIM_hind$monthly%>%filter(year%in%(1980:1984)) ,
               aes(x=mnDate, y=mn_val,color=basin,linetype ="Monthly"),size=.8)+
    geom_line (data =ACLIM_hind$seasonal%>%filter(year%in%(1980:1984)) ,
               aes(x=mnDate, y=mn_val,color=basin,linetype="seasonal"),size=1.1)+
    geom_line (data =ACLIM_hind$annual%>%filter(year%in%(1980:1984)) ,
               aes(x=mnDate, y=mn_val,color=basin,linetype="annual"),size=.8)+
    geom_point (data =ACLIM_hind$annual%>%filter(year%in%(1980:1984)) ,
               aes(x=mnDate, y=mn_val,color=basin),size=1.8)+
    facet_grid(var~basin,scales="free_y")+theme_minimal()
  
  
} 

