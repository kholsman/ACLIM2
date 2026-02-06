#'
#'
#'
#' getINDICES_survey
#' 
#' group_byIN =c("var", "units","long_name","sim","basin","type","sim_type","lognorm","qry_date")



get_indices_hind_srvy <- function(datIN, group_byIN,qry_dateIN=NA){
  
  annual <- datIN%>%
    ungroup()%>%
    group_by(across(all_of(c(group_byIN,"year",
                             #"latitude","longitude","station_id",
                             "strata","strata_area_km2"))))%>%
    summarize_at(c("mn_val","val_raw","mnVal_hind","jday"),mean,na.rm=T)%>%
    mutate(mn_val_Area     = strata_area_km2*mn_val,
           val_raw_Area    = strata_area_km2*val_raw,
           mnVal_hind_Area = strata_area_km2*mnVal_hind,
           AREA_mn_val     = strata_area_km2*(1+(mn_val*0)),
           AREA_val_raw    = strata_area_km2*(1+(val_raw*0)),
           AREA_mnVal_hind = strata_area_km2*(1+(mnVal_hind*0)))%>%
    ungroup()%>%
    #now summarize across all of EBS Basins:
    group_by(across(all_of(c(group_byIN,"year"))))%>%
    summarize(jday             = mean(jday,na.rm=T),
              mn_valnotadj     = mean(mn_val,na.rm=T),
              AREA_mn_val        = sum(AREA_mn_val,na.rm=T),
              AREA_val_raw       = sum(AREA_val_raw,na.rm=T),
              AREA_mnVal_hind    = sum(AREA_mnVal_hind,na.rm=T),
              mn_val_Area      = sum(mn_val_Area,na.rm=T),
              val_raw_Area      = sum(val_raw_Area,na.rm=T),
              mnVal_hind_Area  = sum(mnVal_hind_Area,na.rm=T),
              total_strata_area_km2   = sum(strata_area_km2,na.rm=T))%>%
    mutate(mn_val      = mn_val_Area/AREA_mn_val,
           val_raw     = val_raw_Area/AREA_val_raw,
           mnVal_hind  = mnVal_hind_Area/AREA_mnVal_hind)%>%
    rename(total_area_km2 = total_strata_area_km2)%>%
    select(-"mn_val_Area",-"mnVal_hind_Area",-"val_raw_Area",
           -"AREA_mn_val",-"AREA_val_raw",-"AREA_mnVal_hind")%>%
    mutate(mnDate =  as.Date(paste0(year,"-01-01"))+jday)%>%ungroup()
  
  return(list(annual=annual))
  
}

get_indices_hist_srvy <- function(datIN, group_byIN,qry_dateIN=NA){
  annual <- datIN%>%
    ungroup()%>%
    group_by(across(all_of(c(group_byIN,"year",
                             #"latitude","longitude","station_id",
                             "strata","strata_area_km2"))))%>%
    summarize_at(c("mn_val","val_raw","mnVal_hist","jday"),mean,na.rm=T)%>%
    mutate(mn_val_Area     = strata_area_km2*mn_val,
           val_raw_Area    = strata_area_km2*val_raw,
           mnVal_hist_Area = strata_area_km2*mnVal_hist,
           
           AREA_mn_val     = strata_area_km2*(1+(mn_val*0)),
           AREA_val_raw    = strata_area_km2*(1+(val_raw*0)),
           AREA_mnVal_hist    = strata_area_km2*(1+(mnVal_hist*0)) )%>%
    ungroup()%>%
    #now summarize across all of EBS Basins:
    group_by(across(all_of(c(group_byIN,"year"))))%>%
    summarize(jday             = mean(jday,na.rm=T),
              mn_valnotadj     = mean(mn_val,na.rm=T),
              mn_val_Area      = sum(mn_val_Area,na.rm=T),
              val_raw_Area     = sum(val_raw_Area,na.rm=T),
              mnVal_hist_Area  = sum(mnVal_hist_Area,na.rm=T),
              
              AREA_mn_val        = sum(AREA_mn_val,na.rm=T),
              AREA_val_raw       = sum(AREA_val_raw,na.rm=T),
              AREA_mnVal_hist    = sum(AREA_mnVal_hist,na.rm=T),
              total_strata_area_km2   = sum(strata_area_km2,na.rm=T))%>%
    mutate(mn_val     = mn_val_Area/AREA_mn_val,
           val_raw     = val_raw_Area/AREA_val_raw,
           mnVal_hist = mnVal_hist_Area/AREA_mnVal_hist)%>%
    rename(total_area_km2 = total_strata_area_km2)%>%
    select(-"mn_val_Area",-"mnVal_hist_Area",-"val_raw_Area",
           -"AREA_mn_val",
           -"AREA_val_raw"  ,
           -"AREA_mnVal_hist")%>%
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
    summarize( jday      = mean(jday, na.rm=T),
               total_strata_area_km2   = sum(strata_area_km2,na.rm=T),
               sd_val    = sd(mn_val, na.rm=T),
               mn_val    = mean(mn_val, na.rm=T),
               val_raw   = mean(val_raw, na.rm=T),
               mnVal_hind= mean(mnVal_hind, na.rm=T),
               mnVal_hist = mean(mnVal_hist, na.rm=T),
               mnVal_hind = mean(mnVal_hind, na.rm=T),
               val_biascorrected = mean(val_biascorrected, na.rm=T),
               val_biascorrectedyr = mean(val_biascorrectedyr, na.rm=T),
               val_biascorrectedstrata = mean(val_biascorrectedstrata, na.rm=T),
               val_biascorrectedstation = mean(val_biascorrectedstation, na.rm=T),
               val_delta = mean(val_delta, na.rm=T),
               sf_strata = mean(sf_strata, na.rm=T),
               sf_station = mean(sf_station, na.rm=T),
               sf_yr = mean(sf_yr, na.rm=T))%>%
    mutate(
           mn_val_Area     = strata_area_km2*mn_val,
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
           
           val_biascorrectedstrata_Area = strata_area_km2*val_biascorrectedstrata,
           AREA_val_biascorrectedstrata = strata_area_km2*(1+(val_biascorrectedstrata*0)),
           
           val_biascorrectedstation_Area = strata_area_km2*val_biascorrectedstation,
           AREA_val_biascorrectedstation = strata_area_km2*(1+(val_biascorrectedstation*0)),
           
           val_delta_Area = strata_area_km2*val_delta,
           AREA_val_delta = strata_area_km2*(1+(val_delta*0)),
           
           sf_strata_Area = strata_area_km2*sf_strata,
           AREA_sf_strata = strata_area_km2*(1+(sf_strata*0)),
           
           sf_station_Area = strata_area_km2*sf_station,
           AREA_sf_station = strata_area_km2*(1+(sf_station*0)),
           
           sf_yr_Area = strata_area_km2*sf_yr,
           AREA_sf_yr = strata_area_km2*(1+(sf_yr*0)))%>%  # to get na values when applicable
    ungroup()%>%
    #now summarize across all of EBS Basins:
    group_by(across(all_of(c(group_byIN,"year")
    ))
    )%>%
    summarize(jday             = mean(jday,na.rm=T),
              mn_valnotadj     = mean(mn_val,na.rm=T),
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
              sf_yr_Area = sum(sf_yr_Area,na.rm=T),
              total_strata_area_km2   = sum(strata_area_km2,na.rm=T),
              
              AREA_mn_val      = sum(AREA_mn_val,na.rm=T),
              AREA_val_raw    = sum(AREA_val_raw,na.rm=T),
              AREA_mnVal_hind  = sum(AREA_mnVal_hind,na.rm=T),
              AREA_mnVal_hist = sum(AREA_mnVal_hist,na.rm=T),
              AREA_val_biascorrected   = sum(AREA_val_biascorrected,na.rm=T),
              AREA_val_biascorrectedyr = sum(AREA_val_biascorrectedyr,na.rm=T),
              AREA_val_biascorrectedstrata = sum(AREA_val_biascorrectedstrata,na.rm=T),
              AREA_val_biascorrectedstation = sum(AREA_val_biascorrectedstation,na.rm=T),
              AREA_val_delta = sum(AREA_val_delta,na.rm=T),
              AREA_sf_strata = sum(AREA_sf_strata,na.rm=T),
              AREA_sf_station = sum(AREA_sf_station,na.rm=T),
              AREA_sf_yr = sum(AREA_sf_yr,na.rm=T))%>%
    mutate(mn_val     = mn_val_Area/AREA_mn_val ,
           val_raw    = val_raw_Area/AREA_val_raw,
           mnVal_hist = mnVal_hist_Area/AREA_mnVal_hist,
           mnVal_hind = mnVal_hind_Area/AREA_mnVal_hind,
           val_biascorrected   = val_biascorrected_Area/AREA_val_biascorrected,
           val_biascorrectedyr = val_biascorrectedyr_Area/AREA_val_biascorrectedyr,
           val_biascorrectedstrata = val_biascorrectedstrata_Area/AREA_val_biascorrectedstrata,
           val_biascorrectedstation = val_biascorrectedstation_Area/AREA_val_biascorrectedstation,
           val_delta = val_delta_Area/AREA_val_delta,
           sf_strata = sf_strata_Area/AREA_sf_strata,
           sf_station = sf_station_Area/AREA_sf_station,
           sf_yr = sf_yr_Area/AREA_sf_yr
    )%>%
    rename(total_area_km2 = total_strata_area_km2)%>%
    select(-"mn_val_Area",-"mnVal_hist_Area",-"val_raw_Area",
           -"mnVal_hind_Area",-"val_biascorrected_Area",-"val_biascorrectedyr_Area",
           -"val_biascorrectedstrata_Area",-"val_biascorrectedstation_Area",-"val_delta_Area",
           -"sf_strata_Area",-"sf_station_Area",-"sf_yr_Area",
           -"AREA_mn_val",
           -"AREA_val_raw"  ,
           -"AREA_mnVal_hind",
           -"AREA_mnVal_hist",
           -"AREA_val_biascorrected",
           -"AREA_val_biascorrectedyr",
           -"AREA_val_biascorrectedstrata" ,
           -"AREA_val_biascorrectedstation" ,
           -"AREA_val_delta",
           -"AREA_sf_strata" ,
           -"AREA_sf_station" ,
           -"AREA_sf_yr" )%>%
    mutate(mnDate =  as.Date(paste0(year,"-01-01"))+jday)%>%ungroup()
  
  return(list(annual=annual))
  
}
