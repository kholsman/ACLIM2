#'
#'
#'
#'make_RKC_Indices_Andre.R
#'
#'This script generates the indices for the NRS and pcod papers
#'for Punt et al. 2024
#'
#' staion info for
#' I-11
#' K-14
#' Z-05
#' D-10
#' 
#' 
#' 

# rm(list=ls())

# load ACLIM packages and functions
  suppressMessages(source("R/make.R"))

# Set up stations
  RKC_immature_males_stations <- c(
    "D-10 ",
    "E-12 ",
    "F-11 ",
    "G-10 ",
    "H-10 ",
    "H-11 ",
    "H-13 ",
    "I-10 ",
    "I-11 ",
    "I-12 ",
    "J-11 ",
    "J-13 "
  )
  
  
  TC_small_males_stations <- c(
    "A-02 ",
    "C-18 ",
    "D-18 ",
    "F-19 ",
    "F-24 ",
    "G-25 ",
    "I-21 ",
    "I-26 ",
    "I-20 ",
    "H-19 ",
    "J-21 ",
    "I-20 ",
    "L-27 ",
    "M-26 ")
  
  
# set up paths
  outfldr <- "Data/out/RKC_indices"
  if(!dir.exists(outfldr)) dir.create(outfldr)

# specific the stations, variables, and projection sets
  station_set    <- c("D-10 ","Z-05 ", "K-14 ","I-11 ")
  varlist        <- c("pH_bottom5m","pH_depthavg","pH_integrated","pH_surface5m","temp_surface5m", "temp_bottom5m")
  CMIPset        <- c("K20P19_CMIP6","K20P19_CMIP5")
  stitchDate_op  <- "2021-12-30"  #last operational hindcast date

# preview possible variables
  load(file = "Data/out/weekly_vars.Rdata")
  load(file = "Data/out/srvy_vars.Rdata")

# save setup for plotting
  save(list=ls(),file=file.path(outfldr,"RKC_indices_setup.Rdata"))

  
# ------------------------------------
# Hindcast First
# ------------------------------------
  
  # Load and select stations (survey replicated hindcast):
  
  load("Data/out/K20P19_CMIP6/BC_ACLIMsurveyrep/ACLIMsurveyrep_B10K-K20P19_CORECFS_BC_hind.Rdata")
  
  # first for RCK Immature Males
    # preview the data
    station_set <- RKC_immature_males_stations
    head(hind%>%filter(station_id%in%station_set,var%in%varlist)%>%data.frame())
    
    # select the subset for RKC
    hind_RKC_immature_males <- hind%>%filter(station_id%in%station_set,var%in%varlist)%>%
      mutate(val_use = val_raw)%>%ungroup()
    
    # output the data as Rdata and CSV
    write_csv(hind_RKC_immature_males, file.path(outfldr,"hind_RKC_immature_males.csv"))
    save(hind_RKC_immature_males, file=file.path(outfldr,"hind_RKC_immature_males.Rdata"))
    
    #  Then for TC_small_males
    # preview the data
    station_set <- TC_small_males_stations
    head(hind%>%filter(station_id%in%station_set,var%in%varlist)%>%data.frame())
    
    # select the subset for RKC
    hind_TC_small_males <- hind%>%filter(station_id%in%station_set,var%in%varlist)%>%
      mutate(val_use = val_raw)%>%ungroup()
    
    # output the data as Rdata and CSV
    write_csv(hind_TC_small_males, file.path(outfldr,"hind_TC_small_males.csv"))
    save(hind_TC_small_males, file=file.path(outfldr,"hind_TC_small_males.Rdata"))
    
    # ------------------------------------
    # now get monthly values:
    # ------------------------------------
    # SST, Ph and SBT values. predictions for 1/15, 2/15 .. 12/15..
    # Load bias corrected weekly strata data:
    
    rm(hind)
    load("Data/out/K20P19_CMIP6/BC_ACLIMregion/ACLIMregion_B10K-K20P19_CORECFS_BC_hind.Rdata")
    
    for(outType in c("RKC_immature_males","TC_small_males")){
      if(outType == "TC_small_males")
        hindDat <- hind_TC_small_males
      
      if(outType == "RKC_immature_males")
        hindDat <- hind_RKC_immature_males
      
      unique(hindDat$strata)
      unique(hind$mo)
      unique(hind$year)
      tmp_mat <- expand_grid(year =unique(hind$year),  mo = unique(hind$mo))%>%
        rowwise()%>%mutate(targetdate = as.Date(paste0(year,"-",mo,"-",15)))
      tt <- strptime(tmp_mat$targetdate,format = "%Y-%m-%d")
      tmp_mat$target_jday <- tt$yday+1
      tmp_mat$target_mday <- tt$mday
      
      hindDat_monthly <- hind%>%
        filter(strata%in%unique(hindDat$strata),
               var%in%varlist)%>%
        mutate(val_use = val_raw)%>%left_join(tmp_mat)%>%
        rowwise()%>%mutate(mday=strptime(mnDate,format = "%Y-%m-%d")$mday)%>%ungroup()%>%
        mutate(keepA = mday>=target_mday-3,keepB = mday<=target_mday+3)%>%
        filter(keepA,keepB)%>%
        ungroup()
      
      grp_names <- names(hindDat_monthly)[!names(hindDat_monthly)%in%c("strata","strata_area_km2", "keepA","keepB")]
      nms  <- c("val_use","val_raw","mn_val","sd_val",     
                     "n_val","jday","mnDate",
                     "mnVal_hind","sdVal_hind","nVal_hind",
                     "seVal_hind","sdVal_hind_mo", "sdVal_hind_yr")
      
      nms2 <- grp_names[!grp_names%in%nms]
      
      hindDat_monthly_avg <- hindDat_monthly%>%
        select(!!!syms(grp_names))%>%group_by(!!!syms(nms2))%>%
        summarize_at(nms,mean,na.rm=T)%>%ungroup()
      
      if(outType == "TC_small_males"){
        hind_TC_small_males_monthly <- hindDat_monthly
          hind_TC_small_males_monthly_avg <- hindDat_monthly_avg
          
        # output the data as Rdata and CSV
        write_csv(hind_TC_small_males_monthly, file.path(outfldr,"hind_TC_small_males_monthly.csv"))
        save(hind_TC_small_males_monthly, file=file.path(outfldr,"hind_TC_small_males_monthly.Rdata"))
        
        write_csv(hind_TC_small_males_monthly_avg, file.path(outfldr,"hind_TC_small_males_monthly_avg.csv"))
        save(hind_TC_small_males_monthly_avg, file=file.path(outfldr,"hind_TC_small_males_monthly_avg.Rdata"))
      }
       
      if(outType == "RKC_immature_males"){
        hind_RKC_immature_males_monthly <- hindDat_monthly
        hind_RKC_immature_males_monthly_avg <- hindDat_monthly_avg
        # output the data as Rdata and  CSV
        write_csv(hind_RKC_immature_males_monthly, file.path(outfldr,"hind_RKC_immature_males_monthly.csv"))
        save(hind_RKC_immature_males_monthly, file=file.path(outfldr,"hind_RKC_immature_males_monthly.Rdata"))
        
        write_csv(hind_RKC_immature_males_monthly_avg, file.path(outfldr,"hind_RKC_immature_males_monthly_avg.csv"))
        save(hind_RKC_immature_males_monthly_avg, file=file.path(outfldr,"hind_RKC_immature_males_monthly_avg.Rdata"))
      }
      rm(tmp_mat)
      rm(hindDat_monthly)
      rm(hindDat_monthly_avg)
     
    }  
      
# ------------------------------------
# Projections Next
# ------------------------------------
    select_list <- unique(c(names(hind_RKC_immature_males),"long_name","qry_date","station_id",
                     "sim_type","GCM","RCP","mod", "CMIP", "val_raw","mnVal_hind","sdVal_hind","val_delta"))
    jj <- 0 
    
for (CMIP in c("CMIP6","CMIP5")){
  
  if(CMIP == "CMIP6"){
    
    fl_base_srv <- "ACLIMsurveyrep_B10K-K20P19_CMIP6_"
    fl_path_srv <- "Data/out/K20P19_CMIP6/BC_ACLIMsurveyrep"
      
    fl_base_reg <- "ACLIMregion_B10K-K20P19_CMIP6_"
    fl_path_reg <- "Data/out/K20P19_CMIP6/BC_ACLIMregion"
    
   
    # CMIP6
    ssps <- c("ssp126","ssp585")
    gcms <- c("cesm","miroc","gfdl")
    set  <- expand.grid(gcms,ssps,stringsAsFactors = F)
    
  }
  
  if(CMIP == "CMIP5"){
    #now get monthly
    fl_base_srv <- "ACLIMsurveyrep_B10K-K20P19_CMIP5_"
    fl_path_srv <- "Data/out/K20P19_CMIP5/BC_ACLIMsurveyrep"
    
    fl_base_reg <- "ACLIMregion_B10K-K20P19_CMIP5_"
    fl_path_reg <- "Data/out/K20P19_CMIP5/BC_ACLIMregion"
    
    # now for CMIP5
    gcms <- c("CESM","MIROC","GFDL")
    ssps <- c("rcp45","rcp85")
    set  <- expand.grid(gcms,ssps,stringsAsFactors = F)
    
  }
  
  for(outType in c("RKC_immature_males","TC_small_males")){
  
  eval(parse(text = paste0("station_set <- ",outType,"_stations") ))
  
  # for each scenario
  for(i in 1:dim(set)[1]){
    
    cat("set = ",set[i,1],set[i,2],"\n")
    fl <- paste0(fl_base_srv,set[i,1],"_",set[i,2],"_BC_fut.Rdata")
    load(file.path(fl_path_srv,fl))
    
    tmp     <- fut%>%filter(station_id%in%station_set,var%in%varlist)%>%data.frame()
    
    my_vars <- function() select_list[select_list%in%names(tmp)]
    
    tmp <- tmp%>%ungroup()%>%
      dplyr::select(my_vars())%>%
      mutate(val_use = val_delta)%>%data.frame()
    
    if(i==1){
      fut_RKC_all <- tmp
    }else{
      fut_RKC_all <- rbind(fut_RKC_all,tmp)
    }
    rm(fut)
   
    #now get monthly
    fl <- paste0(fl_base_reg,set[i,1],"_",set[i,2],"_BC_fut.Rdata")
    load(file.path(fl_path_reg,fl))
    
      tmp_mat <- expand_grid(year =unique(tmp$year),  mo = unique(substr(fut$mnDate,6,7)))%>%
        rowwise()%>%mutate(targetdate = as.Date(paste0(year,"-",mo,"-",15)))
      tt <- strptime(tmp_mat$targetdate,format = "%Y-%m-%d")
      tmp_mat$target_jday <- tt$yday+1
      tmp_mat$target_mday <- tt$mday
      
      futDat_monthly <- fut%>%
        filter(strata%in%unique(tmp$strata),
               var%in%varlist)%>%mutate(mo = substr(mnDate,6,7))%>%
        mutate(val_use = val_delta)%>%left_join(tmp_mat)%>%rowwise()%>%
        rowwise()%>%mutate(mday=strptime(mnDate,format = "%Y-%m-%d")$mday)%>%ungroup()%>%
        mutate(keepA = mday>=target_mday-3,keepB = mday<=target_mday+3)%>%
        filter(keepA,keepB)%>%
        ungroup()
      
      if(i==1){
        fut_RKC_all_monthly <- futDat_monthly
        }else{
        fut_RKC_all_monthly <- rbind(fut_RKC_all_monthly,futDat_monthly)
      }
      rm(futDat_monthly)
      rm(fut)
      
      rm(tmp)
      
    }  
    
  jj <- jj + 1
  if(jj==1){
    fut_RKC_all_tmp         <- fut_RKC_all
    fut_RKC_all_tmp_monthly <- fut_RKC_all_monthly
  }else{
    fut_RKC_all             <- rbind(fut_RKC_all_tmp,fut_RKC_all)
    fut_RKC_all_monthly     <- rbind(fut_RKC_all_tmp_monthly,fut_RKC_all_monthly)
    
  }
  
  # fix the caps issue:
  fut_RKC <- fut_RKC_all%>%
    mutate(GCM = gsub("MIROC","miroc",GCM))%>%
    mutate(GCM = gsub("GFDL","gfdl",GCM))%>%
    mutate(GCM = gsub("CESM","cesm",GCM))%>%
    mutate(sim = gsub("MIROC","miroc",sim))%>%
    mutate(sim = gsub("GFDL","gfdl",sim))%>%
    mutate(sim = gsub("CESM","cesm",sim))%>%
    mutate(GCM = factor(GCM, levels =c("hind","gfdl","cesm","miroc")))%>%
    mutate(GCM_scen = paste0(GCM,"_",RCP))%>%data.frame()
  
  # fix the caps issue:
  fut_RKC_monthly <- fut_RKC_all_monthly%>%
    mutate(GCM = gsub("MIROC","miroc",GCM))%>%
    mutate(GCM = gsub("GFDL","gfdl",GCM))%>%
    mutate(GCM = gsub("CESM","cesm",GCM))%>%
    mutate(sim = gsub("MIROC","miroc",sim))%>%
    mutate(sim = gsub("GFDL","gfdl",sim))%>%
    mutate(sim = gsub("CESM","cesm",sim))%>%
    mutate(GCM = factor(GCM, levels =c("hind","gfdl","cesm","miroc")))%>%
    mutate(GCM_scen = paste0(GCM,"_",RCP))%>%data.frame()
  
  
   if(outType =="RKC_immature_males"){
     fut_RKC_immature_males <- fut_RKC
     # output the data as Rdata and CSV
     write_csv(fut_RKC_immature_males, file.path(outfldr,"fut_RKC_immature_males.csv"))
     save(fut_RKC_immature_males, file=file.path(outfldr,"fut_RKC_immature_males.Rdata"))
     
     fut_RKC_immature_males_monthly <- fut_RKC_monthly
     # output the data as Rdata and  CSV
     write_csv(fut_RKC_immature_males_monthly, file.path(outfldr,"fut_RKC_immature_males_monthly.csv"))
     save(fut_RKC_immature_males_monthly, file=file.path(outfldr,"fut_RKC_immature_males_monthly.Rdata"))
     
     
   }else{
     if(outType =="TC_small_males"){
       
       fut_TC_small_males <- fut_RKC
       # output the data as Rdata and CSV
       write_csv(fut_TC_small_males, file.path(outfldr,"fut_TC_small_males.csv"))
       save(fut_TC_small_males, file=file.path(outfldr,"fut_TC_small_males.Rdata"))
       
       fut_TC_small_males_monthly     <- fut_RKC_monthly
       # output the data as Rdata and CSV
       write_csv(fut_TC_small_males_monthly, file.path(outfldr,"fut_TC_small_males_monthly.csv"))
       save(fut_TC_small_males_monthly, file=file.path(outfldr,"fut_TC_small_males_monthly.Rdata"))
       
       
     }else{
       stop("outType doesn't match options")
     }
   }
  
  
   rm(fut_RKC)
   rm(fut_RKC_monthly)
  }
  
} 

    if(1 == 10){
          load(file=file.path(outfldr,"fut_RKC_immature_males.Rdata")) #fut_RKC_immature_males
          load(file.path(outfldr,"fut_TC_small_males.Rdata"))   #fut_TC_small_males
          
          load(file=file.path(outfldr,"hind_RKC_immature_males.Rdata")) #hind_RKC_immature_males
          load(file.path(outfldr,"hind_TC_small_males.Rdata"))   #hind_TC_small_males
    }
    
    # now summarize across stations
    AVG_hind_RKC_immature_males <- hind_RKC_immature_males%>%ungroup()%>%
      group_by(var,units,year,basin,sim,type,sim_type)%>%
      summarize(mn_val_use = mean(val_use,na.rm=T),
                sd_val_use = sd(val_use,na.rm=T),
                n_val_use  = length.na(val_use),
                mnDate     = mean(mnDate, na.rm =T))%>%data.frame()
    AVG_hind_TC_small_males <- hind_TC_small_males%>%ungroup()%>%
      group_by(var,units,year,basin,sim,type,sim_type)%>%
      summarize(mn_val_use = mean(val_use,na.rm=T),
                sd_val_use = sd(val_use,na.rm=T),
                n_val_use  = length.na(val_use),
                mnDate     = mean(mnDate, na.rm =T))%>%data.frame()
    
  AVG_fut_RKC_immature_males <- fut_RKC_immature_males%>%ungroup()%>%
    group_by(var,units,year,basin,sim,type,sim_type,GCM,RCP,mod,CMIP,GCM_scen)%>%
    summarize(mn_val_use = mean(val_use,na.rm=T),
              sd_val_use = sd(val_use,na.rm=T),
              n_val_use  = length.na(val_use),
              mnDate     = mean(mnDate, na.rm =T))%>%data.frame()
  AVG_fut_TC_small_males <- fut_TC_small_males%>%ungroup()%>%
    group_by(var,units,year,basin,sim,type,sim_type,GCM,RCP,mod,CMIP,GCM_scen)%>%
    summarize(mn_val_use = mean(val_use,na.rm=T),
              sd_val_use = sd(val_use,na.rm=T),
              n_val_use  = length.na(val_use),
              mnDate     = mean(mnDate, na.rm =T))%>%data.frame()
  
  
  # average across strata monhtly
  
  futDat_monthly <- fut_TC_small_males_monthly
  
  grp_names <- names(futDat_monthly)[!names(futDat_monthly)%in%c("strata","strata_area_km2", "keepA","keepB")]
  nms  <- c("val_use","val_raw","mnVal_hind","sdVal_hind",         
            "sdVal_hind_mo","sdVal_hind_yr","mnVal_hist",
            "sdVal_hist","sdVal_hist_mo","sdVal_hist_yr",
            "sf_wk","val_biascorrectedyr" ,"val_biascorrectedmo",
            "sf_mo","val_delta_adj","val_biascorrected",
            "val_biascorrectedwk", "val_delta",       
            "sf_yr","val_use" )
  
  nms2 <- grp_names[!grp_names%in%nms]
  
  futDat_monthly_avg <- futDat_monthly%>%
    select(!!!syms(grp_names))%>%group_by(!!!syms(nms2))%>%
    summarize_at(nms,mean,na.rm=T)%>%ungroup()
  
  fut_TC_small_males_monthly_avg <- futDat_monthly_avg
  
  futDat_monthly <- fut_RKC_immature_males_monthly
  
  rm(futDat_monthly_avg)
  grp_names <- names(futDat_monthly)[!names(futDat_monthly)%in%c("strata","strata_area_km2", "keepA","keepB")]
  nms  <- c("val_use","val_raw","mnVal_hind","sdVal_hind",         
            "sdVal_hind_mo","sdVal_hind_yr","mnVal_hist",
            "sdVal_hist","sdVal_hist_mo","sdVal_hist_yr",
            "sf_wk","val_biascorrectedyr" ,"val_biascorrectedmo",
            "sf_mo","val_delta_adj","val_biascorrected",
            "val_biascorrectedwk", "val_delta",       
            "sf_yr","val_use" )
  
  nms2 <- grp_names[!grp_names%in%nms]
  
  futDat_monthly_avg <- futDat_monthly%>%
    select(!!!syms(grp_names))%>%group_by(!!!syms(nms2))%>%
    summarize_at(nms,mean,na.rm=T)%>%ungroup()
  
  fut_RKC_immature_males_monthly_avg <- futDat_monthly_avg
  
  
  write_csv(AVG_hind_TC_small_males, file.path(outfldr,"AVG_hind_TC_small_males.csv"))
  save(AVG_hind_TC_small_males, file=file.path(outfldr,"AVG_hind_TC_small_males.Rdata"))
  
  write_csv(AVG_hind_RKC_immature_males, file.path(outfldr,"AVG_hind_RKC_immature_males.csv"))
  save(AVG_hind_RKC_immature_males, file=file.path(outfldr,"AVG_hind_RKC_immature_males.Rdata"))
  
  write_csv(AVG_fut_TC_small_males, file.path(outfldr,"AVG_fut_TC_small_males.csv"))
  save(AVG_fut_TC_small_males, file=file.path(outfldr,"AVG_fut_TC_small_males.Rdata"))
  
  write_csv(AVG_fut_RKC_immature_males, file.path(outfldr,"AVG_fut_RKC_immature_males.csv"))
  save(AVG_fut_RKC_immature_males, file=file.path(outfldr,"AVG_fut_RKC_immature_males.Rdata"))
  
  write_csv(fut_TC_small_males_monthly_avg, file.path(outfldr,"fut_TC_small_males_monthly_avg.csv"))
  save(fut_TC_small_males_monthly_avg, file=file.path(outfldr,"fut_TC_small_males_monthly_avg.Rdata"))
  
  write_csv(fut_TC_small_males_monthly_avg, file.path(outfldr,"fut_TC_small_males_monthly_avg.csv"))
  save(fut_TC_small_males_monthly_avg, file=file.path(outfldr,"fut_TC_small_males_monthly_avg.Rdata"))
  
  write_csv(fut_RKC_immature_males_monthly_avg, file.path(outfldr,"fut_RKC_immature_males_monthly_avg.csv"))
  save(fut_RKC_immature_males_monthly_avg, file=file.path(outfldr,"fut_RKC_immature_males_monthly_avg.Rdata"))
  

