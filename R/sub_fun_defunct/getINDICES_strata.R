#'
#'
#'
#' getINDICES_strata
#' 


get_indices_hind <- function(datIN, group_byIN,qry_dateIN=NA){
  weekly <- datIN%>%
    ungroup()%>%
    group_by(across(all_of(c(group_byIN,"year","season","mo","wk","jday",
                             "strata","strata_area_km2"))))%>%
    mutate(mn_val_Area     = strata_area_km2*mn_val,
           val_raw_Area    = strata_area_km2*val_raw,
           mnVal_hind_Area = strata_area_km2*mnVal_hind,
           AREA_mn_val     = strata_area_km2*(1+(mn_val*0)),
           AREA_val_raw    = strata_area_km2*(1+(val_raw*0)),
           AREA_mnVal_hind    = strata_area_km2*(1+(mnVal_hind*0))
           )%>%  # to get na values when applicable
    ungroup()%>%
    #now summarize across all of EBS Basins:
    group_by(across(all_of(c(group_byIN,"year","season","mo","wk"
                             ))))%>%
    summarize(jday             = mean(jday,na.rm=T),
              mn_valnotadj     = mean(mn_val,na.rm=T),
              mn_val_Area      = sum(mn_val_Area,na.rm=T),
              val_raw_Area     = sum(val_raw_Area,na.rm=T),
              mnVal_hind_Area  = sum(mnVal_hind_Area,na.rm=T),
              
              AREA_mn_val        = sum(AREA_mn_val,na.rm=T),
              AREA_val_raw       = sum(AREA_val_raw,na.rm=T),
              AREA_mnVal_hind    = sum(AREA_mnVal_hind,na.rm=T),
              total_strata_area_km2   = sum(strata_area_km2,na.rm=T)
              )%>%
    mutate(mn_val      = mn_val_Area/AREA_mn_val,
           val_raw     = val_raw_Area/AREA_val_raw,
           mnVal_hind  = mnVal_hind_Area/AREA_mnVal_hind)%>%
    rename(total_area_km2 = total_strata_area_km2)%>%
    select(-"mn_val_Area",-"mnVal_hind_Area",-"val_raw_Area",
           -"AREA_mn_val",-"AREA_val_raw",-"AREA_mnVal_hind")%>%
    mutate(mnDate =  as.Date(paste0(year,"-01-01"))+jday)%>%ungroup()
  
  monthly <- weekly%>%group_by(across(all_of(c("year","season","mo",
                                               group_byIN))))%>%
    summarize(jday = mean(jday, na.rm=T),
              total_area_km2 = mean(total_area_km2, na.rm=T),
              
              sd_val    = sd(mn_val, na.rm=T),
              mn_val    = mean(mn_val, na.rm=T),
              val_raw   = mean(val_raw, na.rm=T),
              mnVal_hind= mean(mnVal_hind, na.rm=T))%>%
    mutate(mnDate =  as.Date(paste0(year,"-01-01"))+jday)%>%ungroup()
  
  seasonal <- weekly%>%group_by(across(all_of(c("year","season",
                                                group_byIN))))%>%
    summarize(jday = mean(jday, na.rm=T),
              total_area_km2 = mean(total_area_km2, na.rm=T),
              
              sd_val    = sd(mn_val, na.rm=T),
              mn_val    = mean(mn_val, na.rm=T),
              val_raw   = mean(val_raw, na.rm=T),
              mnVal_hind= mean(mnVal_hind, na.rm=T))%>%
    mutate(mnDate =  as.Date(paste0(year,"-01-01"))+jday)%>%ungroup()
  
  annual <- weekly%>%group_by(across(all_of(c("year",
                                              group_byIN))))%>%
    summarize(jday = mean(jday, na.rm=T),
              total_area_km2 = mean(total_area_km2, na.rm=T),
             
               
              sd_val    = sd(mn_val, na.rm=T),
              mn_val    = mean(mn_val, na.rm=T),
              val_raw   = mean(val_raw, na.rm=T),
              mnVal_hind= mean(mnVal_hind, na.rm=T))%>%
    mutate(mnDate =  as.Date(paste0(year,"-01-01"))+jday)%>%ungroup()
  return(list(weekly=weekly,monthly=monthly, seasonal = seasonal, annual=annual))
  
}

get_indices_hist <- function(datIN, group_byIN,qry_dateIN=NA){
  weekly <- datIN%>%
    ungroup()%>%
    group_by(across(all_of(c(group_byIN,"year","season","mo","wk","jday",
                             "strata",
                             "strata_area_km2"))))%>%
    mutate(mn_val_Area     = strata_area_km2*mn_val,
           val_raw_Area    = strata_area_km2*val_raw,
           mnVal_hist_Area = strata_area_km2*mnVal_hist,
           
           AREA_mn_val     = strata_area_km2*(1+(mn_val*0)),
           AREA_val_raw    = strata_area_km2*(1+(val_raw*0)),
           AREA_mnVal_hist = strata_area_km2*(1+(mnVal_hist*0)) )%>%  # to get na values when applicable
    ungroup()%>%
    #now summarize across all of EBS Basins:
    group_by(across(all_of(c(group_byIN,"year","season","mo","wk"
                             ))))%>%
    summarize(jday             = mean(jday,na.rm=T),
              mn_valnotadj     = mean(mn_val,na.rm=T),
              mn_val_Area      = sum(mn_val_Area,na.rm=T),
              val_raw_Area     = sum(val_raw_Area,na.rm=T),
              mnVal_hist_Area  = sum(mnVal_hist_Area,na.rm=T),
              
              AREA_mn_val        = sum(AREA_mn_val,na.rm=T),
              AREA_val_raw       = sum(AREA_val_raw,na.rm=T),
              AREA_mnVal_hist    = sum(AREA_mnVal_hist,na.rm=T),
              total_strata_area_km2   = sum(strata_area_km2,na.rm=T))%>%
    mutate(mn_val      = mn_val_Area/AREA_mn_val,
           val_raw     = val_raw_Area/AREA_val_raw,
           mnVal_hist  = mnVal_hist_Area/AREA_mnVal_hist)%>%
    rename(total_area_km2 = total_strata_area_km2)%>%
    select(-"mn_val_Area",-"mnVal_hist_Area",-"val_raw_Area",
           -"AREA_mn_val",
           -"AREA_val_raw"  ,
           -"AREA_mnVal_hist")%>%
    mutate(mnDate =  as.Date(paste0(year,"-01-01"))+jday)%>%ungroup()
  rm(datIN)
  gc()
  
  monthly <- weekly%>%group_by(across(all_of(c("year","season","mo",
                                               group_byIN))))%>%
    summarize(jday = mean(jday, na.rm=T),
              total_area_km2 = mean(total_area_km2, na.rm=T),
              
              sd_val    = sd(mn_val, na.rm=T),
              mn_val    = mean(mn_val, na.rm=T),
              val_raw   = mean(val_raw, na.rm=T),
              mnVal_hist= mean(mnVal_hist, na.rm=T))%>%
    mutate(mnDate =  as.Date(paste0(year,"-01-01"))+jday)%>%ungroup()
  
  seasonal <- weekly%>%group_by(across(all_of(c("year","season",
                                                group_byIN))))%>%
    summarize(jday = mean(jday, na.rm=T),
              total_area_km2 = mean(total_area_km2, na.rm=T),
                             
              sd_val    = sd(mn_val, na.rm=T),
              mn_val    = mean(mn_val, na.rm=T),
              val_raw   = mean(val_raw, na.rm=T),
              mnVal_hist= mean(mnVal_hist, na.rm=T))%>%
    mutate(mnDate =  as.Date(paste0(year,"-01-01"))+jday)%>%ungroup()
  
  annual <- weekly%>%group_by(across(all_of(c("year",
                                              group_byIN))))%>%
    summarize(jday = mean(jday, na.rm=T),
              total_area_km2 = mean(total_area_km2, na.rm=T),
                             
              sd_val    = sd(mn_val, na.rm=T),
              mn_val    = mean(mn_val, na.rm=T),
              val_raw   = mean(val_raw, na.rm=T),
              mnVal_hist= mean(mnVal_hist, na.rm=T))%>%
    mutate(mnDate =  as.Date(paste0(year,"-01-01"))+jday)%>%ungroup()
  return(list(weekly=weekly,monthly=monthly, seasonal = seasonal, annual=annual))
  
}

get_indices_fut <- function(datIN, group_byIN,qry_dateIN=NA){
  x <-0
  for(vtmp in unique(datIN$var)){
     cat("      -- ",vtmp,"\n")
     x<-x +1
   
       weekly_tmp <- datIN%>%
        filter(var%in%vtmp)%>%
        mutate(qry_date = qry_dateIN)%>%
        ungroup()%>%
        mutate(mn_val = val_raw )%>%
        group_by(across(all_of(c(group_byIN,"year","season","mo","wk","jday",
                                 "strata","strata_area_km2")
                               )))%>%
         mutate(mn_val_Area     = strata_area_km2*mn_val,
                AREA_mn_val     = strata_area_km2*(1+(mn_val*0)),
                
                val_raw_Area    = strata_area_km2*val_raw,
                AREA_val_raw    = strata_area_km2*(1+(val_raw*0)),
                
                mnVal_hind_Area = strata_area_km2*mnVal_hind,
                AREA_mnVal_hind = strata_area_km2*(1+(mnVal_hind*0)),
                
                mnVal_hist_Area = strata_area_km2*mnVal_hist,
                AREA_mnVal_hist = strata_area_km2*(1+(mnVal_hist*0)),
                
                val_biascorrected_Area   = strata_area_km2*val_biascorrected,
                AREA_val_biascorrected = strata_area_km2*(1+(val_biascorrected*0)),
                
                val_biascorrectedyr_Area = strata_area_km2*val_biascorrectedyr,
                AREA_val_biascorrectedyr = strata_area_km2*(1+(val_biascorrectedyr*0)),
                
                val_biascorrectedmo_Area = strata_area_km2*val_biascorrectedmo,
                AREA_val_biascorrectedmo = strata_area_km2*(1+(val_biascorrectedmo*0)),
                
                val_biascorrectedwk_Area = strata_area_km2*val_biascorrectedwk,
                AREA_val_biascorrectedwk = strata_area_km2*(1+(val_biascorrectedwk*0)),
                
                val_delta_Area = strata_area_km2*val_delta,
                AREA_val_delta = strata_area_km2*(1+(val_delta*0)),
                
                sf_wk_Area = strata_area_km2*sf_wk,
                AREA_sf_wk = strata_area_km2*(1+(sf_wk*0)),
                
                sf_mo_Area = strata_area_km2*sf_mo,
                AREA_sf_mo = strata_area_km2*(1+(sf_mo*0)),
                
                sf_yr_Area = strata_area_km2*sf_yr,
                AREA_sf_yr = strata_area_km2*(1+(sf_yr*0)))%>%  # to get na values when applicable
        ungroup()%>%
        group_by(across(all_of(c(group_byIN,"year","season","mo","wk")
                               )))%>%
        summarize(jday             = mean(jday,na.rm=T),
                  mn_valnotadj     = mean(mn_val,na.rm=T),
                  mn_val_Area      = sum(mn_val_Area,na.rm=T),
                  val_raw_Area    = sum(val_raw_Area,na.rm=T),
                  mnVal_hist_Area  = sum(mnVal_hist_Area,na.rm=T),
                  mnVal_hind_Area = sum(mnVal_hind_Area,na.rm=T),
                  val_biascorrected_Area   = sum(val_biascorrected_Area,na.rm=T),
                  val_biascorrectedyr_Area = sum(val_biascorrectedyr_Area,na.rm=T),
                  val_biascorrectedmo_Area = sum(val_biascorrectedmo_Area,na.rm=T),
                  val_biascorrectedwk_Area = sum(val_biascorrectedwk_Area,na.rm=T),
                  val_delta_Area = sum(val_delta_Area,na.rm=T),
                  sf_wk_Area = sum(sf_wk_Area,na.rm=T),
                  sf_mo_Area = sum(sf_mo_Area,na.rm=T),
                  sf_yr_Area = sum(sf_yr_Area,na.rm=T),
                  total_strata_area_km2   = sum(strata_area_km2,na.rm=T),
                  
                  AREA_mn_val      = sum(AREA_mn_val,na.rm=T),
                  AREA_val_raw    = sum(AREA_val_raw,na.rm=T),
                  AREA_mnVal_hind  = sum(AREA_mnVal_hind,na.rm=T),
                  AREA_mnVal_hist = sum(AREA_mnVal_hist,na.rm=T),
                  AREA_val_biascorrected   = sum(AREA_val_biascorrected,na.rm=T),
                  AREA_val_biascorrectedyr = sum(AREA_val_biascorrectedyr,na.rm=T),
                  AREA_val_biascorrectedmo = sum(AREA_val_biascorrectedmo,na.rm=T),
                  AREA_val_biascorrectedwk = sum(AREA_val_biascorrectedwk,na.rm=T),
                  AREA_val_delta = sum(AREA_val_delta,na.rm=T),
                  AREA_sf_wk = sum(AREA_sf_wk,na.rm=T),
                  AREA_sf_mo = sum(AREA_sf_mo,na.rm=T),
                  AREA_sf_yr = sum(AREA_sf_yr,na.rm=T))%>%
         
        mutate(mn_val     = mn_val_Area/AREA_mn_val ,
               val_raw    = val_raw_Area/AREA_val_raw,
               mnVal_hist = mnVal_hist_Area/AREA_mnVal_hist,
               mnVal_hind = mnVal_hind_Area/AREA_mnVal_hind,
               val_biascorrected   = val_biascorrected_Area/AREA_val_biascorrected,
               val_biascorrectedyr = val_biascorrectedyr_Area/AREA_val_biascorrectedyr,
               val_biascorrectedmo = val_biascorrectedmo_Area/AREA_val_biascorrectedmo,
               val_biascorrectedwk = val_biascorrectedwk_Area/AREA_val_biascorrectedwk,
               val_delta = val_delta_Area/AREA_val_delta,
               sf_wk = sf_wk_Area/AREA_sf_wk,
               sf_mo = sf_mo_Area/AREA_sf_mo,
               sf_yr = sf_yr_Area/AREA_sf_yr
        )%>%
        rename(total_area_km2 = total_strata_area_km2)%>%
        select(-"mn_val_Area",-"mnVal_hist_Area",-"val_raw_Area",
               -"mnVal_hind_Area",-"val_biascorrected_Area",-"val_biascorrectedyr_Area",
               -"val_biascorrectedmo_Area",-"val_biascorrectedwk_Area",-"val_delta_Area",
               -"sf_wk_Area",-"sf_mo_Area",-"sf_yr_Area",
               -"AREA_mn_val",
               -"AREA_val_raw"  ,
               -"AREA_mnVal_hind",
               -"AREA_mnVal_hist",
               -"AREA_val_biascorrected",
               -"AREA_val_biascorrectedyr",
               -"AREA_val_biascorrectedmo" ,
               -"AREA_val_biascorrectedwk" ,
               -"AREA_val_delta",
               -"AREA_sf_wk" ,
               -"AREA_sf_mo" ,
               -"AREA_sf_yr" )%>%
        mutate(mnDate =  as.Date(paste0(year,"-01-01"))+jday)%>%ungroup()
       if(x==1){
         weekly <- weekly_tmp
      }else{
       weekly <- rbind(weekly, weekly_tmp)
       rm(weekly_tmp)
      }
  }
  
  monthly <- weekly%>%group_by(across(all_of(c("year","season","mo",
                                               group_byIN))))%>%
    summarize( jday      = mean(jday, na.rm=T),
               total_area_km2 = mean(total_area_km2, na.rm=T),
               sd_val    = sd(mn_val, na.rm=T),
               mn_val    = mean(mn_val, na.rm=T),
               val_raw   = mean(val_raw, na.rm=T),
               mnVal_hind= mean(mnVal_hind, na.rm=T),
               mnVal_hist = mean(mnVal_hist, na.rm=T),
               mnVal_hind = mean(mnVal_hind, na.rm=T),
               val_biascorrected = mean(val_biascorrected, na.rm=T),
               val_biascorrectedyr = mean(val_biascorrectedyr, na.rm=T),
               val_biascorrectedmo = mean(val_biascorrectedmo, na.rm=T),
               val_biascorrectedwk = mean(val_biascorrectedwk, na.rm=T),
               val_delta = mean(val_delta, na.rm=T),
               sf_wk = mean(sf_wk, na.rm=T),
               sf_mo = mean(sf_mo, na.rm=T),
               sf_yr = mean(sf_yr, na.rm=T))%>%
    mutate(mnDate =  as.Date(paste0(year,"-01-01"))+jday)%>%ungroup()
  
  seasonal <- weekly%>%group_by(across(all_of(c("year","season",
                                                group_byIN))))%>%
    summarize( jday      = mean(jday, na.rm=T),
               total_area_km2 = mean(total_area_km2, na.rm=T),
               sd_val    = sd(mn_val, na.rm=T),
               mn_val    = mean(mn_val, na.rm=T),
               val_raw   = mean(val_raw, na.rm=T),
               mnVal_hind= mean(mnVal_hind, na.rm=T),
               mnVal_hist = mean(mnVal_hist, na.rm=T),
               mnVal_hind = mean(mnVal_hind, na.rm=T),
               val_biascorrected = mean(val_biascorrected, na.rm=T),
               val_biascorrectedyr = mean(val_biascorrectedyr, na.rm=T),
               val_biascorrectedmo = mean(val_biascorrectedmo, na.rm=T),
               val_biascorrectedwk = mean(val_biascorrectedwk, na.rm=T),
               val_delta = mean(val_delta, na.rm=T),
               sf_wk = mean(sf_wk, na.rm=T),
               sf_mo = mean(sf_mo, na.rm=T),
               sf_yr = mean(sf_yr, na.rm=T))%>%
    mutate(mnDate =  as.Date(paste0(year,"-01-01"))+jday)%>%ungroup()
  
  annual <- weekly%>%group_by(across(all_of(c("year",
                                              group_byIN))))%>%
    summarize( jday      = mean(jday, na.rm=T),
               total_area_km2 = mean(total_area_km2, na.rm=T),
               sd_val    = sd(mn_val, na.rm=T),
               mn_val    = mean(mn_val, na.rm=T),
               val_raw   = mean(val_raw, na.rm=T),
               mnVal_hind= mean(mnVal_hind, na.rm=T),
               mnVal_hist = mean(mnVal_hist, na.rm=T),
               mnVal_hind = mean(mnVal_hind, na.rm=T),
               val_biascorrected = mean(val_biascorrected, na.rm=T),
               val_biascorrectedyr = mean(val_biascorrectedyr, na.rm=T),
               val_biascorrectedmo = mean(val_biascorrectedmo, na.rm=T),
               val_biascorrectedwk = mean(val_biascorrectedwk, na.rm=T),
               val_delta = mean(val_delta, na.rm=T),
               sf_wk = mean(sf_wk, na.rm=T),
               sf_mo = mean(sf_mo, na.rm=T),
               sf_yr = mean(sf_yr, na.rm=T))%>%
    mutate(mnDate =  as.Date(paste0(year,"-01-01"))+jday)%>%ungroup()
  return(list(weekly=weekly,monthly=monthly, seasonal = seasonal, annual=annual))
  
}
