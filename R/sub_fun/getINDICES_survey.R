#'
#'
#'
#' getINDICES_survey
#' 
#' group_byIN =c("var", "units","long_name","sim","basin","type","sim_type","lognorm","qry_date")



get_indices_hind_srvy <- function(datIN, group_byIN){
  annual <- datIN%>%
    ungroup()%>%
    group_by(across(all_of(c(group_byIN,"year",
                             #"latitude","longitude","station_id",
                             "strata","strata_area_km2"))))%>%
    summarize_at(c("mn_val","val_raw","mnVal_hind","jday"),mean,na.rm=T)%>%
    mutate(mn_val_Area     = strata_area_km2*mn_val,
           val_raw_Area    = strata_area_km2*val_raw,
           mnVal_hind_Area = strata_area_km2*mnVal_hind)%>%
    ungroup()%>%
    #now summarize across all of EBS Basins:
    group_by(across(all_of(c(group_byIN,"year"))))%>%
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
  
  return(list(annual=annual))
  
}

get_indices_hist_srvy <- function(datIN, group_byIN){
  annual <- datIN%>%
    ungroup()%>%
    group_by(across(all_of(c(group_byIN,"year",
                             #"latitude","longitude","station_id",
                             "strata","strata_area_km2"))))%>%
    summarize_at(c("mn_val","val_raw","mnVal_hist","jday"),mean,na.rm=T)%>%
    mutate(mn_val_Area     = strata_area_km2*mn_val,
           val_raw_Area    = strata_area_km2*val_raw,
           mnVal_hist_Area = strata_area_km2*mnVal_hist)%>%
    ungroup()%>%
    #now summarize across all of EBS Basins:
    group_by(across(all_of(c(group_byIN,"year"))))%>%
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
  
  return(list(annual=annual))
  
}

get_indices_fut_srvy <- function(datIN, group_byIN,qry_dateIN=NA){
  annual <- datIN%>%
    mutate(qry_date = qry_dateIN)%>%
    ungroup()%>%
    mutate(mn_val = val_raw )%>%
    group_by(across(all_of(c(group_byIN,"year",
                             #"latitude","longitude","station_id",
                             "strata","strata_area_km2"))))%>%
    
    #### PICK UP HERE AND LIST ALL THE COLUKMNS IN FUT
    summarize_at(c("mn_val","val_raw","mnVal_hind","mnVal_hist","jday",
                   "val_biascorrected","val_biascorrectedyr","val_biascorrectedstrata",
                   "val_biascorrectedstation","val_delta",
                   "sf_strata","sf_station","sf_yr"),mean,na.rm=T)%>%
    mutate(mn_val_Area     = strata_area_km2*mn_val,
           val_raw_Area    = strata_area_km2*val_raw,
           mnVal_hist_Area = strata_area_km2*mnVal_hist,
           mnVal_hind_Area = strata_area_km2*mnVal_hind,
           val_biascorrected_Area = strata_area_km2*val_biascorrected,
           val_biascorrectedyr_Area = strata_area_km2*val_biascorrectedyr,
           val_biascorrectedstrata_Area = strata_area_km2*val_biascorrectedstrata,
           val_biascorrectedstation_Area = strata_area_km2*val_biascorrectedstation,
           val_delta_Area = strata_area_km2*val_delta,
           sf_strata_Area = strata_area_km2*sf_strata,
           sf_station_Area = strata_area_km2*sf_station,
           sf_yr_Area = strata_area_km2*sf_yr)%>%
    ungroup()%>%
    #now summarize across all of EBS Basins:
    group_by(across(all_of(c(group_byIN,"year")
    ))
    )%>%
    summarize(jday             = mean(jday,na.rm=T),
              mn_valnotadj     = mean(mn_val,na.rm=T),
              totalArea        = sum(strata_area_km2,na.rm=T),
              mn_val_Area      = sum(mn_val_Area,na.rm=T),
              val_raw_Area      = sum(val_raw_Area,na.rm=T),
              mnVal_hist_Area  = sum(mnVal_hist_Area,na.rm=T),
              mnVal_hind_Area = sum(mnVal_hind_Area,na.rm=T),
              val_biascorrected_Area = sum(val_biascorrected_Area,na.rm=T),
              val_biascorrectedyr_Area = sum(val_biascorrectedyr_Area,na.rm=T),
              val_biascorrectedstrata_Area = sum(val_biascorrectedstrata,na.rm=T),
              val_biascorrectedstation_Area = sum(val_biascorrectedstation_Area,na.rm=T),
              val_delta_Area = sum(val_delta_Area,na.rm=T),
              sf_strata_Area = sum(sf_strata_Area,na.rm=T),
              sf_station_Area = sum(sf_station_Area,na.rm=T),
              sf_yr_Area = sum(sf_yr_Area,na.rm=T)
    )%>%
    mutate(mn_val     = mn_val_Area/totalArea,
           val_raw    = val_raw_Area/totalArea,
           mnVal_hist = mnVal_hist_Area/totalArea,
           mnVal_hind = mnVal_hind_Area/totalArea,
           val_biascorrected   = val_biascorrected_Area/totalArea,
           val_biascorrectedyr = val_biascorrectedyr_Area/totalArea,
           val_biascorrectedstrata = val_biascorrectedstrata_Area/totalArea,
           val_biascorrectedstation = val_biascorrectedstation_Area/totalArea,
           val_delta = val_delta_Area/totalArea,
           sf_strata = sf_strata_Area/totalArea,
           sf_station = sf_station_Area/totalArea,
           sf_yr = sf_yr_Area/totalArea
    )%>%
    rename(total_area_km2 = totalArea)%>%
    select(-"mn_val_Area",-"mnVal_hist_Area",-"val_raw_Area",
           -"mnVal_hind_Area",-"val_biascorrected_Area",-"val_biascorrectedyr_Area",
           -"val_biascorrectedstrata_Area",-"val_biascorrectedstation_Area",-"val_delta_Area",
           -"sf_strata_Area",-"sf_station_Area",-"sf_yr_Area")%>%
    mutate(mnDate =  as.Date(paste0(year,"-01-01"))+jday)%>%ungroup()
  
  return(list(annual=annual))
  
}
