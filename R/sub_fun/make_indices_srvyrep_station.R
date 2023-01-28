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
  STRATA_AREAIN = STRATA_AREA,
  type          = "survey replicated"
){
  
  # get large zooplankton as the sum of euph and NCaS
  tmp_var_zoop    <- simIN%>%
    dplyr::filter(var%in%vl[c("NCaS_integrated","EupS_integrated")])%>%
    dplyr::group_by(srvy_station_num,
                    station_id,
                    latitude,
                    longitude,
                    stratum,
                    doy,subregion,units,
                    year,sim)%>%
    dplyr::summarise(val =sum(val))%>%
    dplyr::mutate(var = "largeZoop_integrated",
                  longname ="Total On-shelf 
             large zooplankton concentration, 
             integrated over depth (NCa, Eup)")
  sub<-tmp_var_zoop%>%filter(var=="largeZoop_integrated")%>%
    select(var,units,longname)%>%
    rename(name=var)%>%
    distinct()
  
  var_defUSE <-rbind(srvy_var_def,sub)
  
  tmp_var    <- simIN%>%
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
  
  #tmp_var$long_name <- NA # srvy_var_def$longname[match(tmp_var$var,srvy_var_def$name)]
  tmp_var <- rbind(tmp_var,
                   data.frame(tmp_var_zoop)[,match(names(tmp_var),names(tmp_var_zoop))])
  
  
  tmp_var <- tmp_var%>%
    dplyr::left_join(STRATA_AREAIN%>%dplyr::select(stratum=STRATUM,strata_area_km2=AREA))%>%
    dplyr::ungroup()%>%
    dplyr::rename(basin  = subregion,
                  yr     = year,  
                  jday   = doy,
                  strata = stratum,
                  long_name = longname)%>%
    dplyr::group_by(station_id,latitude,longitude,
                    strata,basin,units,yr,sim,long_name,var)%>%
    dplyr::summarise(
      mn_val    = mean(val, na.rm=T),
      jday      = mean(jday, na.rm=T))%>%
    rename(year = yr)%>%
    dplyr::mutate(sim      = simIN$sim[1],
                  season   <- "srvy_rep",
                  mnDate   = as.Date(paste0(year,"-01-01"))+jday,
                  qry_date = format(Sys.time(), "%Y_%m_%d"),
                  type     = type)%>%ungroup()
  
  return(data.frame(tmp_var))
}