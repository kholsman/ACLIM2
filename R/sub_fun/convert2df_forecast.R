#' convert2df.R
#' 
#' Convert nc variable to dataframe and cat. meta data
#'  2021/04/22
convert2df_forecast<- function(ncIN, 
                               strata_gridIN    = strata_grid,
                               basin_gridIN     = basin_grid,
                               cell_area_gridIN = cell_area_grid,
                               varIN = "temp_bottom5m",originIN ="2021-04-22"){

    val      <- ncvar_get(ncIN, varid = varIN)
    unit_txt <- ncIN$var[[eval(varIN)]]$dim[[3]]$units
    mlt      <- get_mlt(unit_txt)$mlt
    ntxt     <- get_mlt(unit_txt)$ntxt
    t        <- as.POSIXct(
      ncIN$var[[eval(varIN)]]$dim[[3]]$vals*mlt, 
      origin = substr(unit_txt,ntxt+1,ntxt+10),
      tz = "GMT")
    
    lat    <-   ncvar_get(ncIN, varid = "lat_rho")
    lon    <-   ncvar_get(ncIN, varid = "lon_rho")
    xi     <-   ncIN$dim$xi_rho$vals
    eta    <-   ncIN$dim$eta_rho$vals
    xi_mat  <- matrix(rep(xi,dim(lat)[2]),dim(lat)[1],dim(lat)[2],byrow=F)
    eta_mat <- matrix(rep(eta,dim(lat)[1]),dim(lat)[1],dim(lat)[2],byrow=T)
    
    # xxi <-1; etaa <- 258
    # tmp%>%filter(xi==xxi,eta==etaa)
    # lat[xxi,etaa];lon[xxi,etaa]
    
    for(y in 1:length(t)){
      tmp           <-data.frame(
        latitude  = as.vector(lat),
        longitude = as.vector(lon),
        xi        = as.vector(xi_mat),
        eta       = as.vector(eta_mat),
        strata    = as.vector(strata_gridIN),
        basin     = as.vector(basin_gridIN),
        grid_cell_area = as.vector(cell_area_gridIN))
      tmp$var        <- varIN
      tmp$units     <- ncIN$var[[eval(varIN)]]$units
      tmp$time      <- t[y]
      tmp$t         <- y
      tmp$val       <- as.vector(val[,,y])
      tmp$long_name  <- ncIN$var[[eval(varIN)]]$longname
      if(y == 1) val_long <- tmp
      if(y !=1 ) val_long <- rbind(val_long,tmp)
    }
  return(val_long)
}
