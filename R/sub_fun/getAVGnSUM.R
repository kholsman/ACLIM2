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
  bysim    = FALSE,
  tblock   = "time",
  mn       = T,
  tot      = F){
  
  if(bysim){
    grpBy <- cc("sim","var","units","long_name",tblock)
  }else{
    grpBy <- c("var","units","long_name",tblock)
  }

    tmp <- dataIN%>%
      filter(strata%in%strataIN)%>%
      group_by(across(all_of(grpBy)))%>%
      mutate(valArea = val*strata_area_km2)%>%
      summarize(
        tot_val = sum(valArea,na.rm=T), 
        sumArea = sum(strata_area_km2,na.rm=T),
        mnDate  = mean(date,na.rm=T))%>%
      mutate(mn_val=tot_val/sumArea)
    
    if(mn & tot)
      tmp <- tmp%>%dplyr::select(all_of(c("mn_val","tot_val",grpBy)))
    if(mn & tot == F)
      tmp <- tmp%>%dplyr::select(all_of(c("mn_val",grpBy)))
    if(mn == F & tot)
      tmp <- tmp%>%dplyr::select(all_of(c("tot_val",grpBy)))

   return(tmp)
}