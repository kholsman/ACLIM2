#'get_mn_srvy_var.R
#'
#'
#'
get_mn_srvy_var <- function(modset = aclim[m_set],varUSE){
  
  for(tt in 1:length(modset)){
    
    # open a "region" or strata specific nc file:
    ncfl      <- file.path(modset[tt],paste0(srvy_txt,modset[tt],".nc"))
    nc        <- nc_open(file.path(data_path,ncfl))
    
    # convert the nc files into a data.frame
    tmp_var    <- convert2df(ncIN = nc, type = 2, varIN = varUSE)
    
    # get mean var val for each time segment
    for(i in 1:length(time_seg)){
      mn_tmp_var <- tmp_var%>%
        filter(year%in%time_seg[[i]],!is.na(val))%>%
        group_by(srvy_station_num, station_id, latitude, 
                 longitude, stratum,doy,subregion,var,units)%>%
        summarise(mnval = mean(val,rm.na=T))
      mn_tmp_var$time_period = names(time_seg)[i]
      if(i == 1) mn_var <- mn_tmp_var
      if(i >  1) mn_var <- rbind(mn_var,mn_tmp_var)
      rm(mn_tmp_var)
      
    }
    sims <- substr(aclim[m_set],25,30)
    mn_var$simulation <- factor(sims[tt],levels=sims)
    if(tt == 1) mn_var_all <- mn_var
    if(tt >  1) mn_var_all <- rbind(mn_var_all,mn_var)
    rm(mn_var)
  }
return(mn_var_all)
}