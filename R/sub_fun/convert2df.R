#' convert2df.R
#' 
#' Convert nc variable to dataframe and cat. meta data
#'  
convert2df <- function(ncIN, type=1,varIN = "temp_bottom5m"){
  
  if(!type%in%1:2) stop("type must be 1 (weekly regional indices) or 2 (survey replicated indices)")

  if(type == 1){
    k        <- which(weekly_vars%in%varIN)
    val      <- ncvar_get(ncIN, varid = varIN)
    unit_txt <- ncIN$var[[eval(varIN)]]$dim[[2]]$units
    mlt      <- get_mlt(unit_txt)$mlt
    ntxt     <-  get_mlt(unit_txt)$ntxt
    t        <- as.POSIXct(
                    ncIN$var[[eval(varIN)]]$dim[[2]]$vals*mlt, 
                       origin = substr(unit_txt,ntxt+1,ntxt+10),
                       tz = "GMT")
    area_nc   <- ncvar_get(ncIN, varid = "region_area") 
    strata_nc <- ncIN$var[["region_area"]]$dim[[1]]$vals
    
    for(s in 1:length(strata_nc)){
      tmp    <- data.frame(
        #scenario = 
        strata          = strata_nc[s],
        strata_area_km2 = area_nc[s],
        time   = t, 
        var    = weekly_vars[k],
        val    = val[s,],
        units  = ncIN$var[[eval(varIN)]]$units,
        long_name = ncIN$var[[eval(varIN)]]$longname)
      if(s == 1) val_long <- tmp
      if(s !=1 ) val_long <- rbind(val_long,tmp)
    }
    val_long$basin <- "Other"
    val_long$basin[abs(val_long$strata)%in%NEBS_strata] <- "NEBS"
    val_long$basin[abs(val_long$strata)%in%SEBS_strata] <- "SEBS"
    val_long$basin  <- factor(val_long$basin, levels =c("NEBS","SEBS","Other"))
    val_long$strata <-  factor(val_long$strata,
                               levels=(unique(weekly_strata)))
  }else{
    k      <- which(srvy_vars%in%varIN)
    val    <- ncvar_get(ncIN, varid = varIN)
    t      <- ncIN$var[[eval(varIN)]]$dim[[2]]$vals
    
    for(y in 1:length(t)){
      tmp           <- station_info
      tmp$var       <- varIN
      tmp$units     <- srvy_var_def[srvy_var_def$name==varIN,]$units
      tmp$year      <- t[y]
      tmp$val       <- val[,y]
      if(y == 1) val_long <- tmp
      if(y !=1 ) val_long <- rbind(val_long,tmp)
    }
  }
  return(val_long)
}
