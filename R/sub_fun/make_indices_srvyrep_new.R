#'
#'
#'
#'make_indices_srvyrep.R
#'
#' converts the polygon weekly values into
#' annual indices by season
#' 

make_indices_srvyrep<-function(
  simIN         = ACLIMsurveyrep,
  seasonsIN     = seasons,
  refyrs        = 1970:2000,
  STRATA_AREAIN = STRATA_AREA,
  type          = "survey replicated"
){
  
  vl <- c(
    "temp_bottom5m",
    "NCaS_integrated", # Large Cop
    "Cop_integrated",  # Small Cop
    "EupS_integrated") # Euphausiids
  
 
  # get large zooplankton as the sum of euph and NCaS
  tmp_var_zoop    <- simIN%>%
    filter(var%in%vl[c(2,4)])%>%
    group_by(srvy_station_num,
             station_id,
             latitude,
             longitude,
             stratum,
             doy,subregion,units,
             year,sim)%>%
    summarise(val =sum(val))%>%
    mutate(var       = "largeZoop_integrated",
           long_name ="Total On-shelf 
             large zooplankton concentration, 
             integrated over depth (NCa, Eup)")
  
  tmp_var    <- simIN%>%
    select(srvy_station_num,
             station_id,
             latitude,
             longitude,
             stratum,
             doy,subregion,units,
             year,sim,val,
             var)
  
  tmp_var$long_name <- srvy_var_def$longname[match(tmp_var$var[1],srvy_var_def$name)]
  tmp_var           <- rbind(tmp_var,
                             tmp_var_zoop[,match(names(tmp_var),names(tmp_var_zoop))])
  tmp_var           <- tmp_var%>%rename(basin  = subregion,
                              yr     = year, 
                              jday   = doy, 
                              strata = stratum)
  
  #tmp_var$date   <- strptime(as.Date(tmp_var$jday, origin = paste0(tmp_var$yr,"-01-01")),format="%Y-%m-%d")
  tmp_var$date   <- as.Date(tmp_var$jday, origin = paste0(tmp_var$yr,"-01-01"))
  
  # get the strata average values:
   tmp_var_mn <- tmp_var%>%
    group_by(strata,basin,units,yr,sim,long_name,var)%>%
    summarise(val= mean(val, na.rm=T),date = mean(date))
   
   # add the strata area for averaging
   tmp_var_mn <- merge(tmp_var_mn,STRATA_AREAIN%>%dplyr::select(STRATUM,strata_area_km2=AREA),
                  by.x="strata",by.y="STRATUM",all.x=T)
   
  # To get the average value for a set of strata, weight the val by the area: (slow...)
  mn_NEBS_season <- getAVGnSUM(
    mn       = T,
    tot      = T,
    strataIN = c(SEBS_strata,NEBS_strata),
    dataIN   = tmp_var_mn%>%filter(basin=="NEBS"),
    tblock   = c("yr"))
  mn_NEBS_season$basin = "NEBS"
  
  mn_SEBS_season <- getAVGnSUM(
    mn       = T,
    tot      = T,
    strataIN = c(SEBS_strata,NEBS_strata),
    dataIN   = tmp_var_mn%>%filter(basin=="SEBS"),
    tblock   = c("yr"))
  mn_SEBS_season$basin = "SEBS"
  
  out_data          <- rbind(mn_NEBS_season,mn_SEBS_season)
  out_data$season   <- "srvy_rep"
  
  out_data          <- out_data%>%rename(mn_val=mn_val,year=yr)
  out_data$sim      <- simIN$sim[1]
  out_data$qry_date <- format(Sys.time(), "%Y_%m_%d")
  out_data$type     <- type
  return(out_data)
}