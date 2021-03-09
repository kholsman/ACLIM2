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
  #areaIN   = region_area,
  strataIN = NEBS_strata, 
  dataIN   = val_long,
  tblock   = "time",
  mn       = T,
  tot      = F){
  
  
  eval(parse(text = paste0("tmp <- dataIN%>%
      filter(strata%in%strataIN)%>%
      group_by(var,",paste0(tblock,collapse=", "),",units,long_name)%>%
      mutate(valArea = val*strata_area_km2)%>%
      summarize(
        tot_val = sum(valArea), 
        sumArea=sum(strata_area_km2))%>%
      mutate(mn_val=tot_val/sumArea)") ))
  
  if(mn & tot)
    eval(parse(text = paste0("tmp <- tmp%>%dplyr::select(var,mn_val,tot_val,",paste0(tblock,collapse=", "),",units,long_name)") ))
  if(mn & tot == F)
    eval(parse(text = paste0("tmp <- tmp%>%dplyr::select(var,mn_val,",paste0(tblock,collapse=", "),",units,long_name)") ))
  if(mn == F & tot)
    eval(parse(text = paste0("tmp <- tmp%>%dplyr::select(var,tot_val,",paste0(tblock,collapse=", "),",units,long_name)") ))
  return(tmp)
}