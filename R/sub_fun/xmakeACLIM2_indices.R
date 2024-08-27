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
  bystrata    = TRUE,
  BC_target = "mn_val",
  CMIP_fdlr = "CMIP6",
  scenIN    = c("ssp126","ssp585"),
  hind_sim  =  "B10K-K20_CORECFS",
  histLIST,
  usehist   = TRUE,
  regnm     = "ACLIMregion",
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
    if(!bystrata){
      # area weighted  means for survey indices (annual)
      cat("    -- get srvy_indices_hind ... \n")
      srvy_indices_hind  <-  make_indices_srvyrep(simIN = hnd_srvy,
                                                  seasonsIN   = seasons, 
                                                  refyrs      = deltayrs, # not used
                                                  type        = "survey replicated")
      
      # area weighted weekly means for the NEBS and SEBS separately
      cat("    -- get reg_indices_weekly_hind ... \n")
      reg_indices_weekly_hind <- make_indices_region(simIN = hnd,
                                                     timeblockIN = c("yr","season","mo","wk"),
                                                     seasonsIN   = seasons,
                                                     refyrs      = deltayrs, # not used
                                                     type        = "weekly means")
      
      reg_indices_weekly_hind <- reg_indices_weekly_hind%>%
        dplyr::mutate(type = "weekly means",
                      jday = mnDate,
                      mnDate = as.Date(paste0(year,"-01-01"))+mnDate)
      
      
      
      srvy_indices_hind <- srvy_indices_hind%>%
        dplyr::mutate(jday = mnDate,
                      mnDate = as.Date(paste0(year,"-01-01"))+mnDate)
    }else{
      # area weighted weekly means for the NEBS and SEBS separately
      cat("    -- get strata_indices_weekly_hind ... \n")
      strata_indices_weekly_hind <- make_indices_region(simIN = hnd,
                                                     timeblockIN = c("strata","strata_area_km2",
                                                                     "yr","season","mo","wk"),
                                                     seasonsIN   = seasons,
                                                     refyrs      = deltayrs, # not used
                                                     type        = "strata monthly means")
      strata_indices_weekly_hind <- strata_indices_weekly_hind%>%
        dplyr::mutate(type = "strata monthly means",
                      jday = mnDate,
                      mnDate = as.Date(paste0(year,"-01-01"))+mnDate)
    
    }

   rm(list=c("hnd","hnd_srvy"))
   gc()
   
  # ------------------------------------
  # 2  -- loop across GCMs and create historical run indices
   
   i  <- 0
   ii <- 1
   for( ii in 1:length(gcmcmipLIST)){
       
    #sim   <- paste0("B10K-K20P19_",gcmcmip,"_historical")
    gcmcmip <- gcmcmipLIST[ii]
    simL    <- sim_listIN[sim_listIN%in%paste0(gcmcmip,"_",rep(scenIN,1,each=length(gcmcmip)))]
          
    if(usehist){
            sim     <- histLIST[ii]
            load(file.path(Rdata_pathIN,file.path(sim,paste0(reg_txtIN,sim,".Rdata"))))
            load(file.path(Rdata_pathIN,file.path(sim,paste0(srvy_txtIN,sim,".Rdata"))))
    
            eval(parse(text=paste0("hist       <- ",regnm,"; rm(",regnm,")")))
            eval(parse(text=paste0("hist_srvy  <- ",srvynm,"; rm(",srvynm,")")))
            gc()
            
            
            # Get Historical Indices: 
            # -------------------------
            cat("-- making historical indices ...\n" )
            cat("-- ",sim,"...\n-----------------------------------\n")
            # area weighted  means for survey indices (annual)
            if(!bystrata){
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
              
              reg_indices_weekly_hist <- reg_indices_weekly_hist%>%
                dplyr::mutate(type = "weekly means",
                              jday = mnDate,
                              mnDate = as.Date(paste0(year,"-01-01"))+mnDate)
              
              
              srvy_indices_hist <- srvy_indices_hist%>%
                dplyr::mutate(jday = mnDate,
                              mnDate = as.Date(paste0(year,"-01-01"))+mnDate)
            
            }else{
              # area weighted weekly means for the NEBS and SEBS separately
              cat("    -- get strata_indices_weekly_hist ... \n")
              strata_indices_weekly_hist <- make_indices_region(simIN = hist,
                                                                 timeblockIN = c("strata","strata_area_km2",
                                                                                 "yr","season","mo","wk"),
                                                                 seasonsIN   = seasons,
                                                                 refyrs      = deltayrs, # not used
                                                                 type        = "strata monthly means")
              strata_indices_weekly_hist <- strata_indices_weekly_hist%>%
                dplyr::mutate(type = "strata monthly means",
                              jday = mnDate,
                              mnDate = as.Date(paste0(year,"-01-01"))+mnDate)
            }
            
              rm(list=c("hist","hist_srvy"))
              gc()
            
         
        }
            
    # ------------------------------------
    # 3  -- create projection indices

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
        
            
          if(!usehist){
              load(file.path(Rdata_pathIN,file.path(sim,paste0(reg_txtIN,sim,".Rdata"))))
              load(file.path(Rdata_pathIN,file.path(sim,paste0(srvy_txtIN,sim,".Rdata"))))
              
              eval(parse(text=paste0("hist       <- ",regnm,"; rm(",regnm,")")))
              eval(parse(text=paste0("hist_srvy  <- ",srvynm,"; rm(",srvynm,")")))
              gc()
              
              # Get Historical Indices: 
              # -------------------------
              cat("-- making historical indices....\n")
              # area weighted  means for survey indices (annual)
              if(!bystrata){
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
                reg_indices_weekly_hist <- reg_indices_weekly_hist%>%
                  dplyr::mutate(type = "weekly means",
                                jday = mnDate,
                                mnDate = as.Date(paste0(year,"-01-01"))+mnDate)
                
                
                
                srvy_indices_hist <- srvy_indices_hist%>%
                  dplyr::mutate(jday = mnDate,
                                mnDate = as.Date(paste0(year,"-01-01"))+mnDate)
              }else{
                # area weighted weekly means for the NEBS and SEBS separately
                cat("    -- get reg_indices_weekly_hind ... \n")
                strata_indices_weekly_hist <- make_indices_region(simIN = hist,
                                                                   timeblockIN = c("strata","strata_area_km2",
                                                                                   "yr","season","mo","wk"),
                                                                   seasonsIN   = seasons,
                                                                   refyrs      = deltayrs, # not used
                                                                   type        = "strata monthly means")
                strata_indices_weekly_hist <- strata_indices_weekly_hist%>%
                  dplyr::mutate(type = "strata monthly means",
                                jday = mnDate,
                                mnDate = as.Date(paste0(year,"-01-01"))+mnDate)
              }
               
                
                rm(list=c("hist","hist_srvy"))
                gc()
              
            }
          
          # Get Projection Indices: 
          # -------------------------
          
          load(file.path(Rdata_pathIN,file.path(sim,paste0(reg_txtIN,sim,".Rdata"))))
          load(file.path(Rdata_pathIN,file.path(sim,paste0(srvy_txtIN,sim,".Rdata"))))
          eval(parse(text=paste0("proj_wk       <- ",regnm,"; rm(",regnm,")")))
          eval(parse(text=paste0("proj_srvy  <- ",srvynm,"; rm(",srvynm,")")))
          gc()
          
          # area weighted  means for survey indices (annual)
          if(!bystrata){
            cat("    -- make srvy_indices_proj ... \n")
            srvy_indices_proj <- suppressMessages( make_indices_srvyrep(simIN  = proj_srvy,
                                                       seasonsIN   = seasons, 
                                                       refyrs      = deltayrs,
                                                       type        = "survey replicated"))
            cat("    -- make reg_indices_weekly_proj ... \n")
            # area weighted weekly means for the NEBS and SEBS separately
            reg_indices_weekly_proj <- suppressMessages(make_indices_region(simIN  = proj_wk,
                                                           timeblockIN = c("yr","season","mo","wk"),
                                                           seasonsIN   = seasons,
                                                           refyrs      = deltayrs,
                                                           type        = "weekly means"))
            reg_indices_weekly_proj <- reg_indices_weekly_proj%>%
              dplyr::mutate(type = "weekly means",
                            jday = mnDate,
                            mnDate = as.Date(paste0(year,"-01-01"))+mnDate)
            
            
            srvy_indices_proj <- srvy_indices_proj%>%
              dplyr::mutate(jday = mnDate,
                            mnDate = as.Date(paste0(year,"-01-01"))+mnDate)
          }else{
            # area weighted weekly means for the NEBS and SEBS separately
            cat("    -- get reg_indices_weekly_hind ... \n")
            strata_indices_weekly_proj <- make_indices_region(simIN = proj_wk,
                                                               timeblockIN = c("strata","strata_area_km2",
                                                                               "yr","season","mo","wk"),
                                                               seasonsIN   = seasons,
                                                               refyrs      = deltayrs, # not used
                                                               type        = "strata monthly means")
            strata_indices_weekly_proj <- strata_indices_weekly_proj%>%
              dplyr::mutate(type = "strata monthly means",
                            jday = mnDate,
                            mnDate = as.Date(paste0(year,"-01-01"))+mnDate)
          }
          
          #New Nov 2022 Bias correct weekly then bin up:
          # ------------------------------------
          # 4  -- bias correct the projections
          
            outlistUSE <- c("year","units",
                         "long_name","sim","bcIT","val_delta",
                         "val_biascorrected", "val_biascorrectedmo", "val_biascorrectedyr","val_raw",
                         "scaling_factorwk",
                         "scaling_factormo",
                         "scaling_factoryr",
                         "jday","mnDate","type","lognorm",
                         "sim_type",
                         "mnVal_hind","sdVal_hind",
                         "sdVal_hind_mo",
                         "sdVal_hind_yr",
                         "mnLNVal_hind","sdLNVal_hind",
                         "sdLNVal_hind_mo","sdLNVal_hind_yr",
                         "mnVal_hist","sdVal_hist","sdVal_hist_mo","sdVal_hist_yr",
                         "mnLNVal_hist","sdLNVal_hist","sdLNVal_hist_mo","sdLNVal_hist_yr")
         
          if(!bystrata){
            cat("    -- bias correct surveyrep_adj ... \n")
            surveyrep_adj <- suppressMessages(bias_correct_new( 
              target     = BC_target,
              hindIN = srvy_indices_hind,
              histIN = srvy_indices_hist,
              futIN  = srvy_indices_proj,
              ref_yrs    = ref_years,
              smoothIT = FALSE,
              group_byIN = c("var","basin","season"),
              normlistIN = normlist_IN,
              outlist    = outlistUSE[-grep("mo",outlistUSE)],
              log_adj    = 1e-4))
            
            cat("    -- bias correct weekly_adj ... \n")
            weekly_adj <- suppressMessages(bias_correct_new( 
              target     = BC_target,
              smoothIT = TRUE,
              hindIN = reg_indices_weekly_hind,
              histIN = reg_indices_weekly_hist,     # this can result in weird values bc of /sd~0
              futIN  = reg_indices_weekly_proj,
              normlistIN = normlist_IN,
              group_byIN = c("var","basin","season","mo","wk"),
              outlist    = outlistUSE, 
              ref_yrs    = ref_years,   # currently set to 1980-2013 change to 1985?
              log_adj    = 1e-4))
            
            cat("    -- bias correct weekly_adj_old ... \n")
            weekly_adj_old <- suppressMessages(bias_correct_new( 
              target     = BC_target,
              smoothIT = FALSE,
              hindIN = reg_indices_weekly_hind,
              histIN = reg_indices_weekly_hist,     # this can result in weird values bc of /sd~0
              futIN  = reg_indices_weekly_proj,
              ref_yrs    = ref_years,   # currently set to 1980-2013 change to 1985?
              normlistIN = normlist_IN,
              group_byIN = c("var","basin","season","mo","wk"),
              outlist    = outlistUSE, 
              log_adj    = 1e-4))
          }else{
              cat("    -- bias correct strata_weekly_adj ... \n")
              strata_weekly_adj <- suppressMessages(bias_correct_new( 
                target     = BC_target,
                smoothIT = TRUE,
                byStrata   = TRUE,
                hindIN = strata_indices_weekly_hind ,
                histIN = strata_indices_weekly_hist,     # this can result in weird values bc of /sd~0
                futIN  = strata_indices_weekly_proj,
                normlistIN = normlist_IN,
                group_byIN = c("var","basin","strata","strata_area_km2","season","mo","wk"),
                outlist    = outlistUSE, 
                ref_yrs    = ref_years,   # currently set to 1980-2013 change to 1985?
                log_adj    = 1e-4))
          }
          
          # save.image(file="tmp_bc.Rdata")
          # load("tmp_bc.Rdata")
          if(i==10){
            if(!dir.exists("Figs/bc_plots")) dir.create("Figs/bc_plots")
            varrs<- unique(weekly_adj_old$fut$var)
            sclr <- 1.5
            w <- 9*sclr
            h <- 5*sclr
            for(v in varrs){
              tt <- plot_biascorrection(wkdat=weekly_adj_old$fut,
                                        wkdat2= weekly_adj$fut,
                                        regIN = "SEBS",
                                        varIN=v)
              if(v%in%c("aice","hice"))
                tt <- plot_biascorrection(wkdat=weekly_adj_old$fut,
                                          wkdat2= weekly_adj$fut,
                                          minmax_yIN = c(0,1.1),
                                          regIN = "SEBS",
                                          varIN=v)
              p <- tt$p4 + 
                annotate("text", x = tt$minmax_x[1]+20, y = tt$minmax_y[2], label = "Hind", color= "black")+
                annotate("text", x = tt$minmax_x[1]+20, y = tt$minmax_y[2]*.9, label = "Hist", color= "blue")
                
              if(v%in%c("aice","hice"))
                p <- tt$p4+coord_cartesian(ylim = c(0,1))+ 
                annotate("text", x = tt$minmax_x[1]+20, y = 1, label = "Hind", color= "blue")+
                annotate("text", x = tt$minmax_x[1]+20, y = .9, label = "Hist", color= "black")
              
              
              png(file=paste0("Figs/bc_plots/",v,"_bcplot.png"),width=w, height=h, units="in",res=250)
              print(p)
              dev.off()
              
              
              png(file=paste0("Figs/bc_plots/",v,"_sfplot.png"),width=w, height=h, units="in",res=250)
              print( tt$p5+coord_cartesian(ylim = c(0,2)))
              dev.off()
              
              png(file=paste0("Figs/bc_plots/",v,"_afplot.png"),width=w, height=h, units="in",res=250)
              print( tt$p6)
              dev.off()
              
            }
           
            # 
            # aa <- weekly_adj_old$fut%>%filter(basin=="SEBS",var=="temp_bottom5m")
            # aa$type3<-"A) non smoothed"
            # bb <- weekly_adj$fut%>%filter(basin=="SEBS",var=="temp_bottom5m")
            # bb$type3<-"B) gam smoothed"
            # suba<- rbind(
            #   aa,bb)
            # suba<-suba%>%mutate(
            #   mn_delta1 = mnVal_hind,
            #   mn_bc1wk  = mnVal_hind + ((sdVal_hind/sdVal_hist)),
            #   mn_bc1mo  = mnVal_hind + ((sdVal_hind_mo/sdVal_hist_mo)),
            #   mn_bc1yr  = mnVal_hind + ((sdVal_hind_yr/sdVal_hist_yr)),
            # )
            # dat <- reshape2::melt(suba%>%select(year, jday,type3, mnVal_hind,mnVal_hist,
            #                                     val_raw,val_delta,
            #                                     val_biascorrected,val_biascorrectedmo,val_biascorrectedyr),
            # id.vars=c( "year", "jday","type3","mnVal_hind","mnVal_hist"))
            # 
            # ggplot(dat)+
            #   geom_line(aes(x=jday, y=value,color=factor(year)),show.legend=F)+
            #   scale_color_manual(values=rep("gray",length(unique(dat$year))))+
            #   geom_line(aes(x=jday, y=mnVal_hind),color="black",size=1)+
            #   geom_line(aes(x=jday, y=mnVal_hist),color="blue",size=1)+
            #   facet_grid(type3~variable)+theme_minimal()
            #   
  
          }
        
          # new method
          # roll weekly means up into mo, seasonal, annual
          if(!bystrata){
            cat("    -- bias correct annual_adj ... \n")
            annual_adj   <- suppressMessages(get_bc_mean(  bcdatIN    = weekly_adj,
                                                           poolby = c("year")))
            
            cat("    -- bias correct seasonal_adj ... \n")
            seasonal_adj <- suppressMessages(get_bc_mean( bcdatIN    = weekly_adj,
                                                          poolby = c("year","season")))
            
            cat("    -- bias correct monthly_adj ... \n")
            monthly_adj  <- suppressMessages(get_bc_mean( bcdatIN    = weekly_adj,
                                                          poolby = c("year","season","mo")))
            
            weekly_adj<- suppressMessages(get_bc_mean( bcdatIN    = weekly_adj,
                                                       plotIT=F,
                                                       poolby = c("year","season","mo","wk")))
          
          }else{
            cat("    -- bias correct strata seasonal_adj ... \n")
            strata_seasonal_adj <- suppressMessages(get_bc_mean( bcdatIN    = strata_weekly_adj,
                                                          poolby = c("strata","strata_area_km2","year","season")))
            
            cat("    -- bias correct strata monthly_adj ... \n")
            strata_monthly_adj  <- suppressMessages(get_bc_mean( bcdatIN    = strata_weekly_adj,
                                                          poolby = c("strata","strata_area_km2","year","season","mo")))
            
            strata_weekly_adj<- suppressMessages(get_bc_mean( bcdatIN    = strata_weekly_adj,
                                                       plotIT=F,
                                                       poolby = c("strata","strata_area_km2","year","season","mo","wk")))
          }
          # annual_adj$p
          # seasonal_adj$p 
          # monthly_adj$p 
         
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
    

     