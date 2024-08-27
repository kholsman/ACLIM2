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
  ref_yrsIN = 1980:2013,
  CMIP      = "CMIP6",
  scenIN    = c("ssp126","ssp585"),
  hind_sim  =  "B10K-K20P19_CORECFS",
  gcmcmipLIST = gcmcmipL,
  subfldrIN   = "BC_ACLIMregion",
  sim_listIN  =sim_list, 
  varlistIN = NULL,
  prefix = "ACLIMregion"){ 
  
  
  fldr<-file.path(CMIP_fdlr,"allEBS_means")
  #hindcast:
  fn   <- paste0(prefix,"_",hind_sim,"_BC_hind.Rdata")
  load(file.path(CMIP_fdlr,subfldrIN,fn))
  
  qry_date <- hind$qry_date[1]
  if(is.null(varlistIN))
    varlistIN <- unique(hind$var)
  
  ACLIM_hind<-
    get_indices_hind(datIN = hind%>%filter(var%in%varlistIN),
                     qry_dateIN = qry_date,
                     group_byIN =c("var","sim","basin",
                                   "type","sim_type","lognorm") )
  cat(" -- hind complete \n")
  rm(hind)
  gc()
  
  i <- 0
  ACLIM_annual_hind   <- ACLIM_hind$annual%>%dplyr::mutate(i = i,  gcmcmip="hind",CMIP=CMIP,GCM ="hind", scen = "hind", mod=hind_sim)%>%ungroup()
  ACLIM_seasonal_hind <- ACLIM_hind$seasonal%>%dplyr::mutate(i = i,gcmcmip="hind",CMIP=CMIP,GCM ="hind", scen = "hind", mod=hind_sim)%>%ungroup()
  ACLIM_monthly_hind  <- ACLIM_hind$monthly%>%dplyr::mutate(i = i, gcmcmip="hind",CMIP=CMIP,GCM ="hind", scen = "hind", mod=hind_sim)%>%ungroup()
  ACLIM_weekly_hind   <- ACLIM_hind$weekly%>%dplyr::mutate(i = i,  gcmcmip="hind",CMIP=CMIP,GCM ="hind", scen = "hind", mod=hind_sim)%>%ungroup()
  #ACLIM_surveyrep_hind<- surveyrep_adj$hind%>%dplyr::mutate(i = i,gcmcmip="hind",CMIP=CMIP,GCM ="hind", scen = "hind", mod=mod)
  
  
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
  
  
  if(!ophind){ 
    fn   <- paste0(prefix,"_BC_hist.Rdata")
    load(file.path(CMIP_fdlr,subfldrIN,fn))
    
    ACLIM_hist<-
      get_indices_hist(datIN = hist%>%filter(var%in%varlistIN),
                       qry_dateIN = qry_date,
                       group_byIN =c("var","sim","basin",
                                     "type","sim_type","lognorm") )
    myf<-function(x,out="RCP"){
      RCP = unlist(lapply(strsplit(x,"_"),"[",5))
      GCM = unlist(lapply(strsplit(x,"_"),"[",4))
      CMIP = unlist(lapply(strsplit(x,"_"),"[",3))
      mod = unlist(lapply(strsplit(x,"_"),"[",2))
      gcmcmip = paste(mod,CMIP,GCM,sep="_")
      if(out =="RCP")
        return(RCP)
      if(out == "GCM")
        return(GCM)
      if(out == "CMIP")
        return(CMIP)
      if (out=="mod")
        return(mod)
      if(out=="gcmcmip")
        return(gcmcmip)
      
    }

    ACLIM_annual_hist   <- ACLIM_hist$annual%>%mutate(RCP = myf(sim,out="RCP"),
                                                      CMIP = myf(sim,out="CMIP"),
                                                      GCM = myf(sim,out="GCM"),
                                                      mod = myf(sim,out="mod"),
                                                      gcmcmip = myf(sim,out="gcmcmip"))%>%ungroup()
    ACLIM_seasonal_hist <- ACLIM_hist$seasonal%>%mutate(RCP = myf(sim,out="RCP"),
                                                        CMIP = myf(sim,out="CMIP"),
                                                        GCM = myf(sim,out="GCM"),
                                                        mod = myf(sim,out="mod"),
                                                        gcmcmip = myf(sim,out="gcmcmip"))%>%ungroup()
    ACLIM_monthly_hist  <- ACLIM_hist$monthly%>%mutate(RCP = myf(sim,out="RCP"),
                                                       CMIP = myf(sim,out="CMIP"),
                                                       GCM = myf(sim,out="GCM"),
                                                       mod = myf(sim,out="mod"),
                                                       gcmcmip = myf(sim,out="gcmcmip"))%>%ungroup()
    ACLIM_weekly_hist   <- ACLIM_hist$weekly%>%mutate(RCP = myf(sim,out="RCP"),
                                                      CMIP = myf(sim,out="CMIP"),
                                                      GCM = myf(sim,out="GCM"),
                                                      mod = myf(sim,out="mod"),
                                                      gcmcmip = myf(sim,out="gcmcmip"))%>%ungroup()
    for(ss in c("annual","monthly","seasonal","weekly"))
      eval(parse(text=paste0("save(ACLIM_",ss,"_hist, file=file.path(fldr,'ACLIM_",ss,"_hist_mn.Rdata'))")))
    for(ss in c("annual","monthly","seasonal","weekly"))
      eval(parse(text=paste0("rm(ACLIM_",ss,"_hist)")))
    rm(hist)
    rm(ACLIM_hist)
    cat(" Complete\n")
   
 
    i<-0
    ii <- 1
    for( ii in 1:length(gcmcmipLIST)){
      gcmcmip <- gcmcmipLIST[ii]
      simL    <- sim_listIN[sim_listIN%in%paste0(gcmcmip,"_",rep(scenIN,1,each=length(gcmcmip)))]
      sim     <- simL[2]
      for (sim in simL){
        i <- i +1
        cat("    -- summarizing fut ",sim, "all EBS means ...")
        
        #projection:
        fn   <- paste0(prefix,"_",sim,"_BC_fut.Rdata")
        load(file.path(CMIP_fdlr,subfldrIN,fn))
        
        ACLIM_fut <- get_indices_fut(datIN = fut%>%filter(var%in%varlistIN),
                          qry_dateIN = qry_date,
                          group_byIN =c("var","sim","basin",
                                        "type","sim_type","lognorm","sf") )
        
       if(i==1){
         
        ACLIM_annual_fut   <- ACLIM_fut$annual%>%mutate(i = i,RCP = myf(sim,out="RCP"),CMIP = myf(sim,out="CMIP"),GCM = myf(sim,out="GCM"),mod = myf(sim,out="mod"),gcmcmip = myf(sim,out="gcmcmip"))%>%ungroup()
        ACLIM_seasonal_fut <- ACLIM_fut$seasonal%>%mutate(i = i,RCP = myf(sim,out="RCP"),CMIP = myf(sim,out="CMIP"),GCM = myf(sim,out="GCM"),mod = myf(sim,out="mod"),gcmcmip = myf(sim,out="gcmcmip"))%>%ungroup()
        ACLIM_monthly_fut  <- ACLIM_fut$monthly%>%mutate(i = i,RCP = myf(sim,out="RCP"),CMIP = myf(sim,out="CMIP"),GCM = myf(sim,out="GCM"),mod = myf(sim,out="mod"),gcmcmip = myf(sim,out="gcmcmip"))%>%ungroup()
        ACLIM_weekly_fut   <- ACLIM_fut$weekly%>%mutate(i = i,RCP = myf(sim,out="RCP"),CMIP = myf(sim,out="CMIP"),GCM = myf(sim,out="GCM"),mod = myf(sim,out="mod"),gcmcmip = myf(sim,out="gcmcmip"))%>%ungroup()
        
        for(ss in c("annual","monthly","seasonal","weekly"))
          eval(parse(text=paste0("save(ACLIM_",ss,"_fut, file=file.path(fldr,'ACLIM_",ss,"_fut_mn.Rdata'))")))
        for(ss in c("annual","monthly","seasonal","weekly"))
          eval(parse(text=paste0("rm(ACLIM_",ss,"_fut)")))
       }else{
         for(ss in c("annual","monthly","seasonal","weekly"))
           eval(parse(text=paste0("load(file=file.path(fldr,'ACLIM_",ss,"_fut_mn.Rdata'))")))
         ACLIM_annual_fut   <- rbind(ACLIM_annual_fut,ACLIM_fut$annual%>%mutate(i = i,RCP = myf(sim,out="RCP"),CMIP = myf(sim,out="CMIP"),GCM = myf(sim,out="GCM"),mod = myf(sim,out="mod"),gcmcmip = myf(sim,out="gcmcmip"))%>%ungroup())
         ACLIM_seasonal_fut <- rbind(ACLIM_seasonal_fut,ACLIM_fut$seasonal%>%mutate(i = i,RCP = myf(sim,out="RCP"),CMIP = myf(sim,out="CMIP"),GCM = myf(sim,out="GCM"),mod = myf(sim,out="mod"),gcmcmip = myf(sim,out="gcmcmip"))%>%ungroup())
         ACLIM_monthly_fut  <- rbind(ACLIM_monthly_fut,ACLIM_fut$monthly%>%mutate(i = i,RCP = myf(sim,out="RCP"),CMIP = myf(sim,out="CMIP"),GCM = myf(sim,out="GCM"),mod = myf(sim,out="mod"),gcmcmip = myf(sim,out="gcmcmip"))%>%ungroup())
         ACLIM_weekly_fut   <- rbind(ACLIM_weekly_fut,ACLIM_fut$weekly%>%mutate(i = i,RCP = myf(sim,out="RCP"),CMIP = myf(sim,out="CMIP"),GCM = myf(sim,out="GCM"),mod = myf(sim,out="mod"),gcmcmip = myf(sim,out="gcmcmip"))%>%ungroup())
         for(ss in c("annual","monthly","seasonal","weekly"))
          eval(parse(text=paste0("save(ACLIM_",ss,"_fut, file=file.path(fldr,'ACLIM_",ss,"_fut_mn.Rdata'))")))
        for(ss in c("annual","monthly","seasonal","weekly"))
          eval(parse(text=paste0("rm(ACLIM_",ss,"_fut)")))
      }
      rm(list=c("ACLIM_fut","fut"))
      cat(" Complete\n")
     }
    }
  }
}

makeACLIM2_L4_Indices_survey <- function(
  CMIP_fdlr = "Data/out/K20P19_CMIP6",
  ophind = FALSE,
  CMIP      = "CMIP6",
  scenIN    = c("ssp126","ssp585"),
  hind_sim  =  "B10K-K20P19_CORECFS",
  gcmcmipLIST = gcmcmipL,
  subfldrIN     = "BC_ACLIMsurveyrep",
  sim_listIN  =sim_list, 
  varlistIN = NULL,
  prefix = "ACLIMsurveyrep"){ 

  
  
  fldr<-file.path(CMIP_fdlr,"allEBS_means")
  if(!dir.exists(fldr))
    dir.create(fldr)
  #hindcast:
  fn   <- paste0(prefix,"_",hind_sim,"_BC_hind.Rdata")
  load(file.path(CMIP_fdlr,subfldrIN,fn))
  
  qry_date <- hind$qry_date[1]
  if(is.null(varlistIN))
    varlistIN <- unique(hind$var)
  
  ACLIM_hind<-
    get_indices_hind_srvy(datIN = hind%>%filter(var%in%varlistIN),
                          qry_dateIN = qry_date,
                          group_byIN =c("var","sim","basin",
                                        "type","sim_type","lognorm") )
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
  
  if(!ophind){ 
    fn   <- paste0(prefix,"_BC_hist.Rdata")
    load(file.path(CMIP_fdlr,subfldrIN,fn))
    
    ACLIM_hist<-
      get_indices_hist_srvy(datIN = hist%>%filter(var%in%varlistIN),
                       qry_dateIN = qry_date,
                       group_byIN =c("var","sim","basin",
                                     "type","sim_type","lognorm") )
    myf<-function(x,out="RCP"){
      RCP = unlist(lapply(strsplit(x,"_"),"[",5))
      GCM = unlist(lapply(strsplit(x,"_"),"[",4))
      CMIP = unlist(lapply(strsplit(x,"_"),"[",3))
      mod = unlist(lapply(strsplit(x,"_"),"[",2))
      gcmcmip = paste(mod,CMIP,GCM,sep="_")
      if(out =="RCP")
        return(RCP)
      if(out == "GCM")
        return(GCM)
      if(out == "CMIP")
        return(CMIP)
      if (out=="mod")
        return(mod)
      if(out=="gcmcmip")
        return(gcmcmip)
      
    }
    
    ACLIM_surveyrep_hist   <- ACLIM_hist$annual%>%mutate(RCP = myf(sim,out="RCP"),
                                                  CMIP = myf(sim,out="CMIP"),
                                                  GCM = myf(sim,out="GCM"),
                                                  mod = myf(sim,out="mod"),
                                                  gcmcmip = myf(sim,out="gcmcmip"))%>%ungroup()
    save(ACLIM_surveyrep_hist, file = file.path(fldr, "ACLIM_surveyrep_hist_mn.Rdata"))
    rm(ACLIM_surveyrep_hist)
    rm(ACLIM_hist)
    cat(" Complete\n")
    
    i<-0
    ii <- 1
    for( ii in 1:length(gcmcmipLIST)){
          
      gcmcmip <- gcmcmipLIST[ii]
      simL    <- sim_listIN[sim_listIN%in%paste0(gcmcmip,"_",rep(scenIN,1,each=length(gcmcmip)))]
      
      for (sim in simL){
            i <- i +1
            cat("    -- summarizing fut ",sim, "all EBS means ...")
            
          
            
          #projection:
          fn   <- paste0(prefix,"_",sim,"_BC_fut.Rdata")
          load(file.path(CMIP_fdlr,subfldrIN,fn))
          cat("    -- summarizing fut sim: ", sim," ...")
          ACLIM_fut <- get_indices_fut_srvy(datIN = fut%>%filter(var%in%varlistIN),
                                 qry_dateIN = qry_date,
                                 group_byIN =c("var","sim","basin",
                                               "type","sim_type","lognorm","sf") )
                            
          rm(fut)
          if(i==1){
            ACLIM_surveyrep_fut   <- ACLIM_fut$annual%>%mutate(RCP = myf(sim,out="RCP"),
                                                               CMIP = myf(sim,out="CMIP"),
                                                               GCM = myf(sim,out="GCM"),
                                                               mod = myf(sim,out="mod"),
                                                               gcmcmip = myf(sim,out="gcmcmip"))%>%ungroup()
            save(ACLIM_surveyrep_fut, file = file.path(fldr, "ACLIM_surveyrep_fut_mn.Rdata"))
            rm(ACLIM_surveyrep_fut)
            
          }else{
            load( file.path(fldr, "ACLIM_surveyrep_fut_mn.Rdata"))
            ACLIM_surveyrep_fut   <- rbind(ACLIM_surveyrep_fut,ACLIM_fut$annual%>%mutate(RCP = myf(sim,out="RCP"),
                                                                                         CMIP = myf(sim,out="CMIP"),
                                                                                         GCM = myf(sim,out="GCM"),
                                                                                         mod = myf(sim,out="mod"),
                                                                                         gcmcmip = myf(sim,out="gcmcmip"))%>%ungroup())
            save(ACLIM_surveyrep_fut, file = file.path(fldr, "ACLIM_surveyrep_fut_mn.Rdata"))
            rm(ACLIM_surveyrep_fut)
          }
          rm(list=c("ACLIM_fut"))
        }
      }
    cat(" Complete\n")
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

