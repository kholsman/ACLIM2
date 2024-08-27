#'
#'
#'
#'make_indices_srvyrep_station.R
#'
#' converts the polygon weekly values into
#' annual indices by season
#' 

make_indices_srvyrep_station<-function(
  simIN         = ACLIMsurveyrep,
  seasonsIN     = seasons,
  svIN      = sv,
  typeIN     =  "hind",
  ref_yrs    = 1980:2013,
  normlistIN = normlist_IN,
  STRATA_AREAIN = STRATA_AREA,
  type          = "survey replicated",
  group_byIN    = c("station_id","latitude","longitude",
                    "strata","strata_area_km2","basin","units","sim","long_name","var"),
  log_adj    = 1e-4
){

  var_defUSE <-srvy_var_def
  
  
  if("largeZoop_integrated"%in%svIN){ 
    # get large zooplankton as the sum of euph and NCaS
    tmp_var_zoop    <- simIN%>%
      dplyr::filter(var%in%c("NCaS_integrated","EupS_integrated"))%>%
      dplyr::group_by(srvy_station_num,
                      station_id,
                      latitude,
                      longitude,
                      stratum,
                      doy,subregion,units,
                      year,sim)%>%
      dplyr::summarise(val =sum(val))%>%
      dplyr::mutate(var = "largeZoop_integrated",
                    longname ="Total On-shelf large Zoop integrated over depth (NCa, Eup)")
    sub <- tmp_var_zoop%>%filter(var=="largeZoop_integrated")%>%ungroup()%>%
      select(var,units,longname)%>%
      rename(name=var)%>%
      distinct()
  
  var_defUSE <-rbind(srvy_var_def,sub)
  rm(sub)
  
  datIN    <- simIN%>%
    dplyr::filter(var%in%svIN)%>%
    dplyr::select(srvy_station_num,
                  station_id,
                  latitude,
                  longitude,
                  stratum,
                  doy,subregion,units,
                  year,sim,val,
                  var)%>%
    dplyr:: left_join(var_defUSE, by=c("units"="units","var"="name"))%>%
    dplyr:: mutate(stratum = as.numeric(as.character(stratum)))
  
  datIN <- datIN%>%
    dplyr::left_join(var_defUSE%>%select(name,units), by=c("units"="units","var"="name"))
  datIN <- rbind(datIN,
                   data.frame(tmp_var_zoop)[,match(names(datIN),names(tmp_var_zoop))])
  }else{
    datIN    <- simIN%>%
      dplyr::filter(var%in%svIN)%>%
      dplyr::select(srvy_station_num,
                    station_id,
                    latitude,
                    longitude,
                    stratum,
                    doy,subregion,units,
                    year,sim,val,
                    var)%>%
      dplyr:: left_join(var_defUSE, by=c("units"="units","var"="name"))%>%
      dplyr:: mutate(stratum = as.numeric(as.character(stratum)))
    
    datIN <- datIN%>%
      dplyr::left_join(var_defUSE%>%select(name,units), by=c("units"="units","var"="name"))
    
  }
  

  datIN<-datIN%>%
    dplyr::left_join(normlistIN)%>%mutate(tmpval = val)
  
  # get station annual mean values
  # -------------------------------------
  slevels       <- unique(c(levels(datIN$stratum), unique(STRATA_AREA$STRATUM)))
  STRATA_AREAIN <-STRATA_AREAIN%>%mutate(STRATUM = factor(STRATUM, levels = slevels))
  
  datIN <- datIN%>%
    mutate(stratum = factor(stratum, levels = slevels))%>%
    dplyr::left_join(STRATA_AREAIN%>%dplyr::select(stratum=STRATUM,strata_area_km2=AREA))%>%
    dplyr::rename(basin  = subregion,
                  jday   = doy,
                  strata = stratum,
                  long_name = longname)%>%
    dplyr::ungroup()%>%
    dplyr::group_by(across(all_of(c("year",group_byIN))))%>%
    dplyr::summarise(
      val_raw    = mean(val, na.rm=T),
      mn_val     = mean(tmpval, na.rm=T),
      sd_val     = sd(tmpval, na.rm=T),
      n_val      = length.na(tmpval),
      jday       = mean(jday, na.rm=T))%>%
    dplyr::mutate(sim      = simIN$sim[1],
                  season   = "srvy_rep",
                  mnDate   = as.Date(paste0(year,"-01-01"))+jday,
                  qry_date = format(Sys.time(), "%Y_%m_%d"),
                  type     = type)%>%ungroup()
  
  # get strata mean values (average across years)
  # -------------------------------------
  tmp_var <- datIN
  if(!is.null(ref_yrs)){
    tmp_var <- datIN%>%filter(year%in%ref_yrs)
  }
  
   # filter(year%in%ref_yrs)%>%
  tmp_var <- tmp_var%>%
    dplyr::group_by(across(all_of(group_byIN)))%>%
    dplyr::summarize(mnVal_x   = mean(mn_val,na.rm=T),
                     sdVal_x   = sd(mn_val, na.rm = T),
                     nVal_x    = length(!is.na(mn_val)))%>%ungroup()
  
  tmp_var$seVal_x <- tmp_var$sdVal_x/sqrt(tmp_var$nVal_x)
  
  # get sd for annual scaling factor
  # -------------------------------------   
  sub_strata <- datIN
  if(!is.null(ref_yrs)){
    sub_strata <- datIN%>%filter(year%in%ref_yrs)
  }
  
  sub_strata<-sub_strata%>%
    dplyr::group_by(var,basin,strata)%>%
    dplyr::summarize(sdVal_x_strata   = sd(mn_val, na.rm = T))%>%
    ungroup()%>%
    select(var,basin,strata,sdVal_x_strata)
  
  # get sd strata for annual scaling factor
  # -------------------------------------   
  sub_yr <- datIN
  if(!is.null(ref_yrs)){
    sub_yr <- datIN%>%filter(year%in%ref_yrs)
  }
  
  sub_yr <- sub_yr%>%
    dplyr::group_by(var,basin)%>%
    dplyr::summarize(sdVal_x_yr   = sd(mn_val, na.rm = T))%>%
    ungroup()%>%
    select(var,basin,sdVal_x_yr)
  
  # combine into one data.frame
  # -------------------------------------    
  tmp_var <- tmp_var%>%left_join(sub_strata)%>%ungroup()
  tmp_var <- tmp_var%>%left_join(sub_yr)%>%ungroup()
  rm(sub_yr)
  rm(sub_strata)
  
  datIN <- datIN%>%
    left_join(tmp_var)%>%ungroup()
  datIN$sim_type   <- typeIN
  tmp_var$sim_type <- typeIN
  
  return(list(fullDat = datIN, mnDat = data.frame(tmp_var)))
}