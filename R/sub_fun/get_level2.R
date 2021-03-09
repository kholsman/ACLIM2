#'
#'get_level2
#'
get_level2<- function(ncIN, 
                      varIN,
                      xi_range  = 1:182,  # 182
                      eta_range = 1:258,  # 258
                      originIN = originIN,
                      time_range  = c("2006-01-22 12:00:00 GMT","2006-02-05 12:00:00 GMT")){
  
    # get the number of dimensions (time is often the last one)
    ndims <- ncIN$var[[eval(varIN)]]$ndims
    
    # convert time_range to POSIXct
    time_range <- as.POSIXct(time_range,
                             origin =   originIN,
                             tz = "GMT")
    
    # get time variable from .nc file
    t   <- as.POSIXct(
        ncIN$var[[eval(varIN)]]$dim[[ndims]]$vals, 
        origin = substr(ncIN$var[[eval(varIN)]]$dim[[ndims]]$units,15,36),
        tz = "GMT")
    
    # subset the lat and lon values
    lat    <- ncvar_get(ncIN, varid = "lat_rho")[xi_range,eta_range]
    lon    <- ncvar_get(ncIN, varid = "lon_rho")[xi_range,eta_range]
    
    # get the length of the timesteps, and lat, lon
    # if(!length(time_range)==1){
    #     subt <- intersect(which(t>=time_range[1]), which(t<=time_range[2]))
    # }else{
    subt <- which(t>=time_range[1])[1]
    for(tt in 1:length(time_range)){
      if(any(t>=time_range[[tt]]))
        subt <- c(subt,which(t>=time_range[tt])[1])
    }
        
    #}
    nt   <- length(subt)
    if(!nt>0) message("Invalid time range or format (e.g., '2006-01-22 12:00:00 GMT') ")
    nlat    <- length(xi_range)
    nlon    <- length(eta_range)
    varsize <- ncIN$var[[eval(varIN)]]$varsize
    
    val <- array(NA,c(nlat,nlon,nt))
    cat(paste("getting data for ",nt," timeperiods\n"))
    for( i in 1:nt ) {
      cat('\r',round(100*i/nt),"%")
        flush.console() 
      
      
      # Initialize start and count to read one timestep of the variable.
      start        <- rep(1,ndims)	# begin with start=(1,1,1,...,1)
      start[ndims] <- subt[i]	      # change to start=(1,1,1,...,i) to read timestep i
      count        <- varsize	      # begin w/count=(nx,ny,nz,...,nt), reads entire var
      count[ndims] <- 1	            # change to count=(nx,ny,nz,...,1) to read 1 tstep
      tmpdat       <- ncvar_get( ncIN, varIN, start=start, count=count )
      time[i]      <- 
      val[,,i]     <- tmpdat[xi_range,eta_range]
      
    }
    cat("\n")
    return(list(var = varIN, lat =lat, lon = lon ,time = t[subt],val=val ))
    
}
