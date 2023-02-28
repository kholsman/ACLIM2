#'
#'
#'
#'make_indices_strata.R
#'
#' converts the polygon weekly values into
#' annual indices by season
#' Kirstin.holsman@noaa.gov
#' 2023

make_indices_strata <- function(
  timeblockIN = c("yr","season"),
  simIN     = ACLIMregion,
  svIN      = sv,
  seasonsIN = seasons,
  type      = "",
  typeIN     =  "hind", #"hist" "proj"
  ref_yrs    = 1980:2013,
  normlistIN = normlist_IN,
  group_byIN = c("var","basin","strata","strata_area_km2","season","mo","wk","lognorm"),
  smoothIT     = FALSE,
  log_adj    = 1e-4
){
  

  var_defUSE <- (weekly_var_def)

  if("largeZoop_integrated"%in%svIN){
    # get large zooplankton as the sum of euph and NCaS
    cat("adding large Zoop \n")
    tmp_var_zoop    <- simIN%>%
      dplyr::filter(var%in%c("NCaS_integrated","EupS_integrated"))%>%
      dplyr::group_by(time,
                      strata,
                      strata_area_km2,
                      basin,
                      units, 
                      sim)%>%
      dplyr::summarise(val =sum(val))%>%
      dplyr::mutate(var = "largeZoop_integrated",
                    longname ="Total On-shelf large Zoop integrated over depth (NCa, Eup)")%>%ungroup()
    sub <- tmp_var_zoop%>%filter(var=="largeZoop_integrated")%>%ungroup()%>%
      select(var,units,longname)%>%
      rename(name=var)%>%
      distinct()
    
    var_defUSE <- rbind(weekly_var_def,sub)
    rm(sub)
    
    datIN    <- simIN%>%
      dplyr::filter(var%in%svIN)%>%
      dplyr::select(time,
                    strata,
                    strata_area_km2,
                    basin,
                    units,
                    sim, val, var)
    
    datIN <- datIN%>%
      dplyr::left_join(var_defUSE%>%select(name,units), by=c("units"="units","var"="name"))
    datIN <- rbind(datIN,
                     data.frame(tmp_var_zoop)[,match(names(datIN),names(tmp_var_zoop))])
  }else{
    datIN    <- simIN%>%
      dplyr::filter(var%in%svIN)%>%
      dplyr::select(time,
                    strata,
                    strata_area_km2,
                    basin,
                    units,
                    sim, val, var)
    
    datIN <- datIN%>%
      dplyr::left_join(var_defUSE%>%select(name,units), by=c("units"="units","var"="name"))
  }
  
  datIN<-datIN%>%
    dplyr::left_join(normlistIN)%>%mutate(tmpval = val)
  
  
  
  # log or logit transform data for bias correcting
  # -------------------------------------
  

  # if(!any(datIN$lognorm%in%c("none","log","logit")))
  #   stop("problem with lognorm, must be 'none', 'log' or 'logit' for each var")
  # if(any(datIN$lognorm=="none")){
  #   rr <- which(datIN$lognorm=="none")
  #   datIN[rr,]$tmpval <- (datIN[rr,]$val)
  #   rm(rr)
  # }
  # if(any(datIN$lognorm=="logit")){
  #   myfun <- function(x){
  #    # x <- logit(x)
  #    # if(any(x==-Inf&!is.na(x))) x[x==-Inf&!is.na(x)] <- logit(log_adj)
  #    # if(any(x==Inf&!is.na(x))) x[x==Inf&!is.na(x)]   <- logit(1-log_adj)
  #    # return(x)
  #    
  #    if(any(x>.5&!is.na(x)))  x[x>.5&!is.na(x)]   <- logit(x[x>.5&!is.na(x)]-log_adj)
  #    if(any(x<.5&!is.na(x))) x[x<.5&!is.na(x)]    <- logit(x[x<.5&!is.na(x)]+log_adj)
  #    if(any(x==0.5&!is.na(x))) x[x==0.5&!is.na(x)]    <- logit(x[x==0.5&!is.na(x)])
  #    return(x)
  #    
  #   }
  #   rr <- which(datIN$lognorm=="logit")
  #   datIN[rr,]$tmpval <- suppressWarnings(myfun(datIN[rr,]$val))
  #   rm(rr)
  # }
  # if(any(datIN$lognorm=="log")){
  #   rr <- which(datIN$lognorm=="log")
  #   datIN[rr,]$tmpval <- suppressWarnings(log(datIN[rr,]$val + log_adj))
  #   rm(rr)
  # }
  
  # get weekly by year mean values
  # -------------------------------------
  datIN <- datIN%>%
    dplyr::mutate(tmptt =strptime(as.Date(time),format="%Y-%m-%d"))%>%
    dplyr::mutate(
      yr     = date_fun(tmptt,type="yr"),
      mo     = date_fun(tmptt,type="mo"),
      jday   = date_fun(tmptt,type="jday"),
      season = date_fun(tmptt,type="season"),
      wk     = date_fun(tmptt,type="wk"))%>%
    dplyr::ungroup()%>%
    dplyr::group_by(across(all_of(c("units","sim","yr",group_byIN))))%>%
    dplyr::summarise(
      val_raw    = mean(val, na.rm=T),
      mn_val     = mean(tmpval, na.rm=T),
      sd_val     = sd(tmpval, na.rm=T),
      n_val      = length.na(tmpval),
      jday       = mean(jday, na.rm=T))%>%
    rename(year = yr)%>%
    dplyr::mutate(
                  sim      = simIN$sim[1],
                  mnDate   = as.Date(paste0(year,"-01-01"))+jday,
                  qry_date = format(Sys.time(), "%Y_%m_%d"),
                  type     = type)%>%ungroup()
  
  # get weekly mean values (across years)
  # -------------------------------------
  tmp_var <- datIN
  if(!is.null(ref_yrs)){
    tmp_var <- datIN%>%filter(year%in%ref_yrs)%>%
      dplyr::ungroup()
  }
  tmp_var <- tmp_var%>%
    dplyr::group_by(across(all_of(group_byIN)))%>%
    dplyr::summarize(mnVal_x   = mean(mn_val,na.rm=T),
                     sdVal_x   = sd(mn_val, na.rm = T),
                     nVal_x    = length(!is.na(mn_val)))%>%ungroup()
  
  # get sd for monthly scaling factor
  # -------------------------------------  
  if(any(group_byIN=="mo")){
    sub_mo <- datIN
    if(!is.null(ref_yrs)){
      sub_mo <- datIN%>%filter(year%in%ref_yrs)%>%
        dplyr::ungroup()
    }
    
    sub_mo <- sub_mo%>%
      dplyr::group_by(var,basin,strata,mo)%>%
      dplyr::summarize(sdVal_x_mo   = sd(mn_val, na.rm = T))%>%
      ungroup()%>%
      select(var,basin,strata,mo,sdVal_x_mo)
  }
  
  # get sd for annual scaling factor
  # -------------------------------------   
  sub_yr <- datIN
  if(!is.null(ref_yrs)){
    sub_yr <- datIN%>%filter(year%in%ref_yrs)%>%
      dplyr::ungroup()
  }
  sub_yr<- sub_yr%>%
    dplyr::group_by(var,basin,strata)%>%
    dplyr::summarize(sdVal_x_yr   = sd(mn_val, na.rm = T))%>%
    ungroup()%>%
    select(var,basin,strata,sdVal_x_yr)
  
  # combine into one data.frame
  # -------------------------------------    
  tmp_var$seVal_x <- tmp_var$sdVal_x/sqrt(tmp_var$nVal_x)
  
  if(any(group_byIN=="mo"))
    tmp_var <- tmp_var%>%left_join(sub_mo)%>%ungroup()
  tmp_var <- tmp_var%>%left_join(sub_yr)%>%ungroup()
  rm(sub_yr)
  if(any(group_byIN=="mo")) rm(sub_mo)
  
  # smooth with gam to remove artifacts
  # -------------------------------------    
  if(smoothIT){
    
    tmpvar    <- unique(tmp_var$var)
    nvar      <- length(tmpvar)
    tmpstrata <- unique(tmp_var$strata)
    nstrata   <- length(tmpstrata)
    cat("       -- running gam smoother\n")
    for(b in 1:nstrata){
      for(bb in 1:nvar){
        
        sub <- tmp_var%>%filter(strata==tmpstrata[b],var==tmpvar[bb])
        sub$mnVal_x   <- getgam(x =sub$wk, y = sub$mnVal_x,pos=FALSE)
        sub$sdVal_x   <- getgam(x =sub$wk, y = sub$sdVal_x,pos=TRUE)
        sub$seVal_x   <- getgam(x =sub$wk, y = sub$seVal_x,pos=TRUE)
        
        if(1==10){
          sub <- tmp_var%>%filter(strata==tmpstrata[b],var==tmpvar[bb])
          sub$sdVal0_x  <- getgam(x =sub$wk, y = (sub$sdVal_x))
          sub$sdVal2_x  <- exp(getgam(x =sub$wk, y = log(sub$sdVal_x+0.001)))-0.001
          ggplot(sub)+
            ylab("aice")+ xlab("week")+
            geom_line(aes(x=wk,y=inv.logit(sdVal_x),color="original sd "),size=1.1)+
            geom_line(aes(x=wk,y=inv.logit(sdVal0_x),color="gam smoothed sd"))+
            geom_line(aes(x=wk,y=inv.logit(sdVal2_x),color="gam smoothed log(sd)"))+theme_minimal()
        }
        
        if(bb==1&b==1){
          subout <- sub
        }else{
          subout <- rbind(subout,sub)
        }
        rm(sub)
        
      }}
    #subout$seVal_hist <- subout$sdVal_hist/sqrt(subout$nVal_hist)
    tmp_var <- subout
    rm(subout)
    cat("       -- gam smoother complete \n")
  }
  
  
  datIN <- datIN%>%
    left_join(tmp_var)%>%ungroup()
  datIN$sim_type   <- typeIN
  tmp_var$sim_type <- typeIN

  return(list(fullDat = datIN, mnDat = data.frame(tmp_var)))
}