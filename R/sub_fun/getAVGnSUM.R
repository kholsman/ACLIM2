#' getAVGnSUM.R
#' 
#' Get average and/or sum of a given ACLIM index across the range of strata:
#' @param area The area in KM2 of the given strata
#' @param strataIN which strata to include in the average
#' @param dataIN the long_format data.frame with columns for 
#' "strata", "strata_area_km2" "time","var"
#' "val","units","long_name","basin" 
#' mn  # calculate area weighted mean val for each timestep?
#' tot # sum the total for each timestep?
getAVGnSUM <- function(
  areaIN   = area,
  strataIN = NEBS_strata, 
  dataIN   = val_long,
  mn       = T,
  tot      = F){
  
  tmp <- dataIN%>%
    filter(strata%in%strataIN)%>%
    group_by(time,units,long_name)%>%
    mutate(valArea = val*strata_area_km2)%>%
    summarize(
      tot_val = sum(valArea), 
      sumArea=sum(strata_area_km2))%>%
    mutate(mn_val=tot_val/sumArea)
  if(mn & tot)
    tmp <- tmp%>%select(mn_val,tot_val,time,units,long_name)
  if(mn & tot == F)
    tmp <- tmp%>%select(mn_val,time,units,long_name)
  if(mn == F & tot)
    tmp <- tmp%>%select(tot_val,time,units,long_name)
  return(tmp)
}