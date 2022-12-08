#'
#'
#'
#'make_indices_region.R
#'
#' converts the polygon weekly values into
#' annual indices by season
#' 

make_indices_region<-function(
  timeblockIN = c("yr","season"),
  simIN     = ACLIMregion,
  seasonsIN = seasons,
  refyrs    = 1970:2000,
  type      = ""
){
  
  vl <- c(
    "temp_bottom5m",
    "NCaS_integrated", # Large Cop
    "Cop_integrated",  # Small Cop
    "EupS_integrated") # Euphausiids
  
  # get large zooplankton as the sum of euph and NCaS
  tmp_var_zoop    <- simIN%>%
    dplyr::filter(var%in%vl[c(2,4)])%>%
    dplyr::group_by(time,
             strata,
             strata_area_km2,
             basin,
             units, 
             sim)%>%
    dplyr::summarise(val =sum(val))%>%
    dplyr::mutate(var = "largeZoop_integrated",
                  longname ="Total On-shelf 
             large zooplankton concentration, 
             integrated over depth (NCa, Eup)")
  
  tmp_var    <- simIN%>%
    dplyr::select(time,
             strata,
             strata_area_km2,
             basin,
             units,
             sim, val, var)
  
  #tmp_var$long_name <- srvy_var_def$longname[match(tmp_var$var,srvy_var_def$name)]
  tmp_var <- tmp_var%>%left_join(srvy_var_def, by=c("units"="units","var"="name"))
  tmp_var<-rbind(tmp_var,
                 data.frame(tmp_var_zoop)[,match(names(tmp_var),names(tmp_var_zoop))])
  tmp_var <- tmp_var%>%rename(long_name=longname)
  
  tmp_var$date   <- tmp_var$time
  tmptt          <- strptime(as.Date(tmp_var$time),format="%Y-%m-%d")
  
  #tmp_var$date   <- as.Date(tmp_var$time)
  # define some columns for year mo and julian day
  tmp_var$yr     <- tmptt$year + 1900
  tmp_var$mo     <- tmptt$mon  + 1
  tmp_var$jday   <- tmptt$yday + 1
  tmp_var$season <- seasonsIN[tmp_var$mo,2]
  tmp_var$wk     <- as.numeric(format(tmptt, "%W"))+1

  # get the strata average values:
  # Checked and there are not repeating values for each week so skip this?
  tmp_var_mn <- data.frame(tmp_var%>%
                             dplyr::group_by(strata,strata_area_km2, basin,units,season,
             yr, mo, wk,sim,long_name,var)%>%
              dplyr::summarise(
                val  = mean(val, na.rm=T),
                jday = mean(jday, na.rm=T),
                date = mean(jday, na.rm=T)))
              #date = mean(date, na.rm=T)))

  # To get the average value for a set of strata, weight the val by the area: (slow...)
  mn_NEBS_season <- getAVGnSUM(
    mn       = T,
    tot      = T,
    strataIN = c(SEBS_strata,NEBS_strata),
    dataIN   = tmp_var_mn%>%dplyr::filter(basin=="NEBS"),
    tblock   = timeblockIN)
  mn_NEBS_season$basin = "NEBS"
  
  mn_SEBS_season <- getAVGnSUM(
    strataIN = c(SEBS_strata,NEBS_strata),
    dataIN   = tmp_var_mn%>%dplyr::filter(basin=="SEBS"),
    tblock   = timeblockIN)
  mn_SEBS_season$basin = "SEBS"
  
  out_data      <- rbind(mn_NEBS_season,mn_SEBS_season)
  out_data               <- out_data%>%dplyr::rename(mn_val=mn_val,year=yr)
  out_data$sim           <- simIN$sim[1]
  out_data$qry_date      <- format(Sys.time(), "%Y_%m_%d")
  out_data$type          <- type
  return(out_data)
}