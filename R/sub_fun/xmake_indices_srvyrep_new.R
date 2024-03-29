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
    dplyr::filter(var%in%vl[c(2,4)])%>%
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
             var)
  tmp_var <- tmp_var%>%left_join(var_defUSE, by=c("units"="units","var"="name"))
  #tmp_var$long_name <- NA # srvy_var_def$longname[match(tmp_var$var,srvy_var_def$name)]
  tmp_var           <- rbind(tmp_var,
                             data.frame(tmp_var_zoop)[,match(names(tmp_var),names(tmp_var_zoop))])

  
  tmp_var           <- tmp_var%>%
    dplyr::rename(basin  = subregion,
                  yr     = year,  
                  jday   = doy,
                  strata = stratum,
                  long_name = longname)
  
  coldpool <-function(x,temp){
    sumx <- length(x)
    out <- length(x[x<=temp])/sumx
    return(out)
  }
  
  # get the strata average values:
  tmp_cp <- tmp_var%>%
    dplyr::filter(var =="temp_bottom5m")%>%
    dplyr::group_by(strata,basin,units,yr,sim,long_name,var)%>%
    dplyr::summarise(date = mean(jday, na.rm=T),
                     fracbelow200 =coldpool(val,200),
                     fracbelow2 =coldpool(val,2),
                     fracbelow1 =coldpool(val,1),
                     fracbelow0 =coldpool(val,0))%>%
    dplyr::mutate(units ="")%>%ungroup()%>%
    dplyr::select(strata,date, basin, units, yr, sim, fracbelow2, fracbelow1, fracbelow0)
  
  tt<-reshape2::melt(tmp_cp, id.vars=c("strata","date", "basin", "units", "yr", "sim"))
  tt <- tt%>%dplyr::rename(var = variable,val = value)
  tt$long_name <- paste("cold pool as number of stations where",tt$variable)
  
  
  #tmp_var$date   <- strptime(as.Date(tmp_var$jday, origin = paste0(tmp_var$yr,"-01-01")),format="%Y-%m-%d")
  #tmp_var$date   <- as.Date(tmp_var$jday, origin = paste0(tmp_var$yr,"-01-01"))
  
  # get the strata average values:
   tmp_var_mn <- tmp_var%>%
     dplyr::group_by(strata,basin,units,yr,sim,long_name,var)%>%
     dplyr::summarise(val= mean(val, na.rm=T),
                      date = mean(jday, na.rm=T))
   
   tmp_var_mn<- rbind(tmp_var_mn,tt[,match(names(tmp_var_mn),names(tt))])
     #dplyr::summarise(val= mean(val, na.rm=T),date = mean(date, na.rm=T))
   
   # add the strata area for averaging
   tmp_var_mn <- merge(tmp_var_mn,STRATA_AREAIN%>%dplyr::select(STRATUM,strata_area_km2=AREA),
                  by.x="strata",by.y="STRATUM",all.x=T)
   
  # To get the average value for a set of strata, weight the val by the area: (slow...)
  mn_NEBS_season <- getAVGnSUM(
    mn       = T,
    tot      = T,
    strataIN = c(SEBS_strata,NEBS_strata),
    dataIN   = tmp_var_mn%>%dplyr::filter(basin=="NEBS"),
    tblock   = c("yr"))
  mn_NEBS_season$basin = "NEBS"
  
  mn_SEBS_season <- getAVGnSUM(
    mn       = T,
    tot      = T,
    strataIN = c(SEBS_strata,NEBS_strata),
    dataIN   = tmp_var_mn%>%dplyr::filter(basin=="SEBS"),
    tblock   = c("yr"))
  mn_SEBS_season$basin = "SEBS"
  
  out_data          <- rbind(mn_NEBS_season,mn_SEBS_season)
  out_data$season   <- "srvy_rep"
  
  out_data          <- out_data%>%dplyr::rename(mn_val=mn_val,year=yr)
  out_data$sim      <- simIN$sim[1]
  out_data$qry_date <- format(Sys.time(), "%Y_%m_%d")
  out_data$type     <- type
  return(out_data)
}