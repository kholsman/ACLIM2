#' convert2df.R
#' 
#' Convert nc variable to dataframe and cat. meta data
#'  2021/04/22
convert2df_coldpool<- function(ncIN,
                               varIN = "average_bottom_temp",originIN ="1900-01-01"){
  
  val      <- ncvar_get(ncIN, varid = varIN)
  thresholds <- ncIN$var[[eval(varIN)]]$dim[[1]]$val
  unit_txt <- ncIN$var[[eval(varIN)]]$dim[[4]]$units
  mlt      <- get_mlt(unit_txt)$mlt
  ntxt     <- get_mlt(unit_txt)$ntxt
  t        <- as.POSIXct(
    ncIN$var[[eval(varIN)]]$dim[[4]]$vals*mlt, 
    origin = substr(unit_txt,ntxt+1,ntxt+10),
    tz = "GMT")
  
  region    <-   ncvar_get(ncIN, varid = "region_label")
  method    <-   ncvar_get(ncIN, varid = "method_label")
  avgBT    <-   ncvar_get(ncIN, varid = "average_bottom_temp")

  for(tt in 1:length(thresholds)){
    for(r in 1:length(region)){
      for(m in 1:length(method)){
        for(y in 1:length(t)){
        tmp           <-data.frame(
          region      = region[r],
          method      = method[m],
          varIN       = varIN,
          time        = t,
          year        = as.numeric(substr(t,1,4)),
          val         = val[tt,r,m,],
          units       = ncIN$var[[eval(varIN)]]$units,
          def         = "frac less than",
          threshold   = threholds[tt])
          #long_name   = ncIN$var[[eval(varIN)]]$longname)
        
    
        if(y == 1) val_long <- tmp
        if(y !=1 ) val_long <- rbind(val_long,tmp)
        }
      }
    }
  }
  return(val_long)
}
