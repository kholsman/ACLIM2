#'
#'get_mn_rd
#'

get_mn_rd <-  function(modset,names=NULL,varUSE){
  
  
  for(tt in 1:length(modset)){
    # open a "region" or strata specific nc file:
    fl      <- file.path(modset[tt],paste0(srvy_txt,modset[tt],".Rdata"))
    load(file.path(Rdata_path,fl))
    
    tmp_var <- ACLIMsurveyrep%>%
                  filter(var%in%varUSE)
    
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
    rm(ACLIMsurveyrep)
    
    if(is.null(names)){
      sims <- strsplit(modset,"_")
      nl   <- lengths(sims)
      sims <- unlist(sims)[cumsum(nl)]
    }else{
      sims <- names
    }
    
    mn_var$simulation <- factor(sims[tt],levels=unique(sims))
    if(tt == 1) mn_var_all <- mn_var
    if(tt >  1) mn_var_all <- rbind(mn_var_all,mn_var)
    rm(mn_var)
  }
  return(mn_var_all)
}