#' clip_spdt.R
#' 
#' Clip spatial layers based on lon and lat limits
#' 
clip_spdt <-function(lon_lim=c(-180,180),lat_lim=c(60,85),crsIN="+init=epsg:4326",idIN="arctic_boundary"){
  sp::SpatialPolygons(
    list(sp::Polygons(
      list(sp::Polygon(
        data.frame(lon = c(lon_lim[1], lon_lim[2], lon_lim[2], lon_lim[1]), 
                   lat = c(lat_lim[1], lat_lim[1], lat_lim[2], lat_lim[2])))), 
      ID = idIN)
    ), proj4string = sp::CRS(paste0("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0 ",crsIN)))
  
} 