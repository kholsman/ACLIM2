#'
#'
#'
#' getINDICES_strata
#' 


get_indices_hind <- function(datIN, group_byIN){
  weekly <- datIN%>%
    ungroup()%>%
    group_by(across(all_of(c(group_byIN,"year","season","mo","wk","jday",
                             "strata",
                             "strata_area_km2"))))%>%
    mutate(mn_val_Area     = strata_area_km2*mn_val,
           val_raw_Area    = strata_area_km2*val_raw,
           mnVal_hind_Area = strata_area_km2*mnVal_hind)%>%
    ungroup()%>%
    #now summarize across all of EBS Basins:
    group_by(across(all_of(c(group_byIN,"year","season","mo","wk"
                             ))))%>%
    summarize(jday             = mean(jday,na.rm=T),
              mn_valnotadj     = mean(mn_val,na.rm=T),
              totalArea        = sum(strata_area_km2,na.rm=T),
              mn_val_Area      = sum(mn_val_Area,na.rm=T),
              val_raw_Area      = sum(val_raw_Area,na.rm=T),
              mnVal_hind_Area  = sum(mnVal_hind_Area,na.rm=T))%>%
    mutate(mn_val     = mn_val_Area/totalArea,
           val_raw     = val_raw_Area/totalArea,
           mnVal_hind = mnVal_hind_Area/totalArea)%>%
    rename(total_area_km2 = totalArea)%>%
    select(-"mn_val_Area",-"mnVal_hind_Area",-"val_raw_Area")%>%
    mutate(mnDate =  as.Date(paste0(year,"-01-01"))+jday)%>%ungroup()
  
  monthly <- weekly%>%group_by(across(all_of(c("year","season","mo",
                                               group_byIN))))%>%
    summarize(jday = mean(jday, na.rm=T),
              total_area_km2 = mean(total_area_km2, na.rm=T),
              mn_val    = mean(mn_val, na.rm=T),
              val_raw   = mean(val_raw, na.rm=T),
              mnVal_hind= mean(mnVal_hind, na.rm=T))%>%
    mutate(mnDate =  as.Date(paste0(year,"-01-01"))+jday)%>%ungroup()
  
  seasonal <- weekly%>%group_by(across(all_of(c("year","season",
                                                group_byIN))))%>%
    summarize(jday = mean(jday, na.rm=T),
              total_area_km2 = mean(total_area_km2, na.rm=T),
              mn_val    = mean(mn_val, na.rm=T),
              val_raw   = mean(val_raw, na.rm=T),
              mnVal_hind= mean(mnVal_hind, na.rm=T))%>%
    mutate(mnDate =  as.Date(paste0(year,"-01-01"))+jday)%>%ungroup()
  
  annual <- weekly%>%group_by(across(all_of(c("year",
                                              group_byIN))))%>%
    summarize(jday = mean(jday, na.rm=T),
              total_area_km2 = mean(total_area_km2, na.rm=T),
              mn_val    = mean(mn_val, na.rm=T),
              val_raw   = mean(val_raw, na.rm=T),
              mnVal_hind= mean(mnVal_hind, na.rm=T))%>%
    mutate(mnDate =  as.Date(paste0(year,"-01-01"))+jday)%>%ungroup()
  return(list(weekly=weekly,monthly=monthly, seasonal = seasonal, annual=annual))
  
}

get_indices_hist <- function(datIN, group_byIN){
  weekly <- datIN%>%
    ungroup()%>%
    group_by(across(all_of(c(group_byIN,"year","season","mo","wk","jday",
                             "strata",
                             "strata_area_km2"))))%>%
    mutate(mn_val_Area     = strata_area_km2*mn_val,
           val_raw_Area    = strata_area_km2*val_raw,
           mnVal_hist_Area = strata_area_km2*mnVal_hist)%>%
    ungroup()%>%
    #now summarize across all of EBS Basins:
    group_by(across(all_of(c(group_byIN,"year","season","mo","wk"
                             ))))%>%
    summarize(jday             = mean(jday,na.rm=T),
              mn_valnotadj     = mean(mn_val,na.rm=T),
              totalArea        = sum(strata_area_km2),
              mn_val_Area      = sum(mn_val_Area,na.rm=T),
              val_raw_Area     = sum(val_raw_Area,na.rm=T),
              mnVal_hist_Area  = sum(mnVal_hist_Area,na.rm=T))%>%
    mutate(mn_val     = mn_val_Area/totalArea,
           val_raw     = val_raw_Area/totalArea,
           mnVal_hist = mnVal_hist_Area/totalArea)%>%
    rename(total_area_km2 = totalArea)%>%
    select(-"mn_val_Area",-"mnVal_hist_Area",-"val_raw_Area")%>%
    mutate(mnDate =  as.Date(paste0(year,"-01-01"))+jday)%>%ungroup()
  
  monthly <- weekly%>%group_by(across(all_of(c("year","season","mo",
                                               group_byIN))))%>%
    summarize(jday = mean(jday, na.rm=T),
              total_area_km2 = mean(total_area_km2, na.rm=T),
              mn_val    = mean(mn_val, na.rm=T),
              val_raw   = mean(val_raw, na.rm=T),
              mnVal_hist= mean(mnVal_hist, na.rm=T))%>%
    mutate(mnDate =  as.Date(paste0(year,"-01-01"))+jday)%>%ungroup()
  
  seasonal <- weekly%>%group_by(across(all_of(c("year","season",
                                                group_byIN))))%>%
    summarize(jday = mean(jday, na.rm=T),
              total_area_km2 = mean(total_area_km2, na.rm=T),
              mn_val    = mean(mn_val, na.rm=T),
              val_raw   = mean(val_raw, na.rm=T),
              mnVal_hist= mean(mnVal_hist, na.rm=T))%>%
    mutate(mnDate =  as.Date(paste0(year,"-01-01"))+jday)%>%ungroup()
  
  annual <- weekly%>%group_by(across(all_of(c("year",
                                              group_byIN))))%>%
    summarize(jday = mean(jday, na.rm=T),
              total_area_km2 = mean(total_area_km2, na.rm=T),
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
               val_raw_Area    = strata_area_km2*val_raw,
               mnVal_hist_Area = strata_area_km2*mnVal_hist,
               mnVal_hind_Area = strata_area_km2*mnVal_hind,
               val_biascorrected_Area = strata_area_km2*val_biascorrected,
               val_biascorrectedyr_Area = strata_area_km2*val_biascorrectedyr,
               val_biascorrectedmo_Area = strata_area_km2*val_biascorrectedmo,
               val_biascorrectedwk_Area = strata_area_km2*val_biascorrectedwk,
               val_delta_Area = strata_area_km2*val_delta,
               sf_wk_Area = strata_area_km2*sf_wk,
               sf_mo_Area = strata_area_km2*sf_mo,
               sf_yr_Area = strata_area_km2*sf_yr)%>%
        ungroup()%>%
        group_by(across(all_of(c(group_byIN,"year","season","mo","wk")
                               )))%>%
        summarize(jday             = mean(jday,na.rm=T),
                  mn_valnotadj     = mean(mn_val,na.rm=T),
                  totalArea        = sum(strata_area_km2,na.rm=T),
                  mn_val_Area      = sum(mn_val_Area,na.rm=T),
                  val_raw_Area    = sum(val_raw_Area,na.rm=T),
                  mnVal_hist_Area  = sum(mnVal_hist_Area,na.rm=T),
                  mnVal_hind_Area = sum(mnVal_hind_Area,na.rm=T),
                  val_biascorrected_Area = sum(val_biascorrected_Area,na.rm=T),
                  val_biascorrectedyr_Area = sum(val_biascorrectedyr_Area,na.rm=T),
                  val_biascorrectedmo_Area = sum(val_biascorrectedmo_Area,na.rm=T),
                  val_biascorrectedwk_Area = sum(val_biascorrectedwk_Area,na.rm=T),
                  val_delta_Area = sum(val_delta_Area,na.rm=T),
                  sf_wk_Area = sum(sf_wk_Area,na.rm=T),
                  sf_mo_Area = sum(sf_mo_Area,na.rm=T),
                  sf_yr_Area = sum(sf_yr_Area,na.rm=T))%>%
        mutate(mn_val     = mn_val_Area/totalArea,
               val_raw    = val_raw_Area/totalArea,
               mnVal_hist = mnVal_hist_Area/totalArea,
               mnVal_hind = mnVal_hind_Area/totalArea,
               val_biascorrected   = val_biascorrected_Area/totalArea,
               val_biascorrectedyr = val_biascorrectedyr_Area/totalArea,
               val_biascorrectedmo = val_biascorrectedmo_Area/totalArea,
               val_biascorrectedwk = val_biascorrectedwk_Area/totalArea,
               val_delta = val_delta_Area/totalArea,
               sf_wk = sf_wk_Area/totalArea,
               sf_mo = sf_mo_Area/totalArea,
               sf_yr = sf_yr_Area/totalArea
        )%>%
        rename(total_area_km2 = totalArea)%>%
        select(-"mn_val_Area",-"mnVal_hist_Area",-"val_raw_Area",
               -"mnVal_hind_Area",-"val_biascorrected_Area",-"val_biascorrectedyr_Area",
               -"val_biascorrectedmo_Area",-"val_biascorrectedwk_Area",-"val_delta_Area",
               -"sf_wk_Area",-"sf_mo_Area",-"sf_yr_Area")%>%
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
    summarise_at(all_of(c("jday","total_area_km2","mn_val","val_raw",
                          "mnVal_hist","mnVal_hind",
                          "val_biascorrected",
                          "val_biascorrectedyr" ,"val_biascorrectedmo",
                          "val_biascorrectedwk" ,"val_delta" ,"sf_wk",
                          "sf_mo","sf_yr" )), mean, na.rm=T)%>%
    mutate(mnDate =  as.Date(paste0(year,"-01-01"))+jday)%>%ungroup()
  
  seasonal <- weekly%>%group_by(across(all_of(c("year","season",
                                                group_byIN))))%>%
    summarise_at(all_of(c("jday","total_area_km2","mn_val","val_raw",
                          "mnVal_hist","mnVal_hind",
                          "val_biascorrected",
                          "val_biascorrectedyr" ,"val_biascorrectedmo",
                          "val_biascorrectedwk" ,"val_delta" ,"sf_wk",
                          "sf_mo","sf_yr" )), mean, na.rm=T)%>%
    mutate(mnDate =  as.Date(paste0(year,"-01-01"))+jday)%>%ungroup()
  
  annual <- weekly%>%group_by(across(all_of(c("year",
                                              group_byIN))))%>%
    summarise_at(all_of(c("jday","total_area_km2","mn_val","val_raw",
                          "mnVal_hist","mnVal_hind",
                          "val_biascorrected",
                          "val_biascorrectedyr" ,"val_biascorrectedmo",
                          "val_biascorrectedwk" ,"val_delta" ,"sf_wk",
                          "sf_mo","sf_yr" )), mean, na.rm=T)%>%
    mutate(mnDate =  as.Date(paste0(year,"-01-01"))+jday)%>%ungroup()
  return(list(weekly=weekly,monthly=monthly, seasonal = seasonal, annual=annual))
  
}
