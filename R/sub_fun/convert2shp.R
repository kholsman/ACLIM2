#' convert2shp.R
#' 
#' 
convert2shp <- function(dfIN=station_info){
  grps <- names(dfIN)
  cc   <- which(grps%in%c("latitude","longitude"))
  
  # convert to shapefile:
  station_out <- st_as_sf(dfIN,
                         coords = c("longitude", "latitude"),
                         crs    ="+init=epsg:3571 +proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0" , 
                         agr    = "constant")
  eval(parse(text=paste0("station_out <- station_out%>%group_by(",paste0(grps[-cc],collapse=", "),")%>%
    summarise() %>%st_cast('MULTIPOINT')") ))
  return(station_out)
  
}