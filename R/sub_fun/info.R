#' info.R
#' 
#' Get metadata info for each model:
#' 
info<-function(model_list=aclim[1:2],type=1){
  nmod <- length(model_list)
  
  if(!type%in%1:2) stop("type must be 1 (weekly regional indices) or 2 (survey replicated indices)")
  i   <- 1
  mod <- model_list[i]
  if(type==1) ncfl    <- file.path(mod,paste0(reg_txt,mod,".nc"))
  if(type==2) ncfl    <- file.path(mod,paste0(srvy_txt,mod,".nc"))
  nc      <- nc_open(file.path(data_path,ncfl))
  vars    <- names(nc$var)
  k       <- which(vars=="temp_bottom5m")
  
  # get the timestep for each value:
  if(type == 1) tmpstart <- as.POSIXct(3946881600, 
                                       origin = substr(nc$var[[k]]$dim[[2]]$units,15,36),
                                       tz = "GMT")
  if(type == 2) tmpstart <- -999
  out  <- data.frame(
    name        = model_list,
    Type        = factor(NA,levels = c("Weekly regional indices","Survey replicated")),
    B10KVersion = "",
    CMIP        = "",
    GCM         = "", 
    BIO         = "",
    Carbon_scenario = "",
    Start       = tmpstart,
    End         = tmpstart,
    nvars       = -999,stringsAsFactors = F)
  nc_close(nc)
  for(i in 1:nmod){
    mod <- model_list[i]
    if(type==1) ncfl    <- file.path(mod,paste0(reg_txt,mod,".nc"))
    if(type==2) ncfl    <- file.path(mod,paste0(srvy_txt,mod,".nc"))
    
    nc      <- nc_open(file.path(data_path,ncfl))
    vars    <- names(nc$var)
    
    # get the timestep for each value:
    k  <- which(vars=="temp_bottom5m")
  
    if(type == 1) t  <- as.POSIXct(nc$var[[k]]$dim[[2]]$vals, 
                         origin = substr(nc$var[[k]]$dim[[2]]$units,15,36),
                         tz = "GMT")
    if(type == 2) t <- nc$var[[k]]$dim[[2]]$vals
    txt <- strsplit(strsplit(mod,"B10K-")[[1]][2],"_")[[1]]

    out[i,]$Type = c("Weekly regional indices","Survey replicated")[type]
    out[i,]$B10KVersion = txt[1]
    out[i,]$CMIP = txt[2]
    out[i,]$GCM = txt[3]
    out[i,]$BIO = FALSE
    if(length(txt)>4)
      out[i,]$BIO = TRUE
    if(txt[2] == "CMIP6")
      out[i,]$BIO = TRUE
    out[i,]$Carbon_scenario = rev(txt)[1]
    out[i,]$Start = t[1]
    out[i,]$End   = rev(t)[1]
    out[i,]$nvars = length(vars[-1])
    #out[i,]$vars  = vars[-1]
    nc_close(nc)
  }
  
  
  return(out)
}
