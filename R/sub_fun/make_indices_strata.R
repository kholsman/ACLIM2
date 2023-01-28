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
  
  date_fun <-function(x,type="yr"){
    if(type=="yr")
      return(x$year+1900)
    if(type=="mo")
      return(x$mon+1)
    if(type=="jday")
      return(x$yday+1)
    if(type=="wk")
      return(as.numeric(format(x, "%W"))+1)
    if(type=="season")
      return(seasonsIN[x$mon+1,2])
  }
  
  getgam <- function ( x =sub$wk, y = sub$mnVal_x, kin = .8){
    df <- na.omit(data.frame(x,y))
    nobs <- length(unique(df$x))
    if(dim(df)[1]>2){
      Gam   <- mgcv::gam( y ~ 1 + s(x, k=round(nobs*kin),bs= "cc"),data=df)
      out <- as.numeric(predict(Gam, newdata=data.frame(x=x), se.fit=FALSE ))
    }else{
      out<- y
    }
    
    return(out)
  }

  if(svIN == "largeZoop_integrated"){
    # get large zooplankton as the sum of euph and NCaS
    cat("adding large Zoop \n")
    tmp_var_zoop    <- simIN%>%
      dplyr::filter(var%in%vl[c("NCaS_integrated","EupS_integrated")])%>%
      dplyr::group_by(time,
                      strata,
                      strata_area_km2,
                      basin,
                      units, 
                      sim)%>%
      dplyr::summarise(val =sum(val))%>%
      dplyr::mutate(var = "largeZoop_integrated",
                    longname ="Large zooplankton concentration,integrated over depth (NCa, Eup)")%>%ungroup()
    sub <- tmp_var_zoop%>%filter(var=="largeZoop_integrated")%>%
      select(var,units,longname)%>%
      rename(name=var)%>%
      distinct()
    
    var_defUSE <- rbind(srvy_var_def,sub)
    
    datIN    <- simIN%>%
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
      dplyr::left_join(srvy_var_def%>%select(name,units), by=c("units"="units","var"="name"))
  }
  
  datIN<-datIN%>%
    dplyr::left_join(normlistIN)
  
  datIN$tmpval <- datIN$val
  if(!any(datIN$lognorm%in%c("none","log","logit")))
    stop("problem with lognorm, must be 'none', 'log' or 'logit' for each var")
  if(any(datIN$lognorm=="none")){
    rr <- which(datIN$lognorm=="none")
    datIN[rr,]$tmpval <- (datIN[rr,]$val)
    rm(rr)
  }
  if(any(datIN$lognorm=="logit")){
    rr <- which(datIN$lognorm=="logit")
    datIN[rr,]$tmpval <- logit(datIN[rr,]$val + log_adj)
    rm(rr)
  }
  if(any(datIN$lognorm=="log")){
    rr <- which(datIN$lognorm=="log")
    datIN[rr,]$tmpval <- log(datIN[rr,]$val + log_adj)
    rm(rr)
  }
  
    #dplyr::rename(long_name=longname)%>%
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
    # dplyr::group_by(basin,strata,strata_area_km2,
    #                 yr,season, mo, wk,var,units,sim)%>%
    dplyr::summarise(
      val_raw = mean(val, na.rm=T),
      mn_val     = mean(tmpval, na.rm=T),
      mnjday     = mean(jday, na.rm=T))%>%
    rename(year = yr)%>%
    dplyr::mutate(
      #LNval    = suppressWarnings(log(mn_val + log_adj)),
                  sim      = simIN$sim[1],
                  mnDate   = as.Date(paste0(year,"-01-01"))+mnjday,
                  qry_date = format(Sys.time(), "%Y_%m_%d"),
                  type     = type)%>%ungroup()
  #datIN$val_raw = datIN$mn_val
  
  tmp_var <- datIN%>%
    dplyr::group_by(across(all_of(group_byIN)))%>%
    dplyr::summarize(mnVal_x   = mean(mn_val,na.rm=T),
                     sdVal_x   = sd(mn_val, na.rm = T),
                     nVal_x    = length(!is.na(mn_val)))%>%ungroup()
  # tmp_var <- datIN%>%
  #   dplyr::group_by(across(all_of(group_byIN)))%>%
  #   dplyr::summarize(mnVal_x   = mean(mn_val,na.rm=T),
  #                    sdVal_x   = sd(mn_val, na.rm = T),
  #                    nVal_x    = length(!is.na(mn_val)),
  #                    mnLNVal_x = mean(LNval,na.rm=T),
  #                    sdLNVal_x = sd(LNval, na.rm = T),
  #                    nLNVal_x  = length(!is.na(LNval)))%>%ungroup()
  
  if(any(group_byIN=="mo"))
    sub_mo <- datIN%>%
    dplyr::group_by(var,basin,strata,mo)%>%
    #dplyr::mutate(LNval = suppressWarnings(log(mn_val + log_adj)))%>%
    dplyr::summarize(sdVal_x_mo   = sd(mn_val, na.rm = T))%>%
                     # sdLNVal_x_mo = sd(LNval, na.rm = T))%>%
    ungroup()%>%
    select(var,basin,strata,mo,sdVal_x_mo)
    # select(var,basin,strata,mo,sdVal_x_mo,sdLNVal_x_mo)
  
  sub_yr <- datIN%>%
    dplyr::group_by(var,basin,strata)%>%
   # dplyr::mutate(LNval    = suppressWarnings(log(mn_val + log_adj)))%>%
    dplyr::summarize(sdVal_x_yr   = sd(mn_val, na.rm = T))%>%
                     #sdLNVal_x_yr = sd(LNval, na.rm = T))%>%
    ungroup()%>%
    select(var,basin,strata,sdVal_x_yr)
    # select(var,basin,strata,sdVal_x_yr,sdLNVal_x_yr)
  
  tmp_var$seVal_x <- tmp_var$sdVal_x/sqrt(tmp_var$nVal_x)
  if(any(group_byIN=="mo"))
    tmp_var <- tmp_var%>%
    left_join(sub_mo,by=c("var"="var","basin"="basin","strata"="strata","mo"="mo"))
  tmp_var <- tmp_var%>%
    left_join(sub_yr,by=c("var"="var","basin"="basin","strata"="strata"))
  rm(sub_yr)
  if(any(group_byIN=="mo")) rm(sub_mo)
  


  
  
  if(smoothIT){
    
    tmpvar    <- unique(tmp_var$var)
    nvar      <- length(tmpvar)
    tmpstrata <- unique(tmp_var$strata)
    jj <- 0
    cat("running gam smoother \n")
    for(b in 1:length(tmpstrata)){
      for(v in 1:nvar){
        jj<- jj +1
        
        sub <- tmp_var%>%filter(strata==tmpstrata[b],var==tmpvar[v])
        sub$mnVal_x   <- getgam(x =sub$wk, y = sub$mnVal_x)
        sub$sdVal_x   <- exp(getgam(x =sub$wk, y = log(sub$sdVal_x+0.001)))-0.001
        sub$seVal_x   <- exp(getgam(x =sub$wk, y = log(sub$seVal_x+0.001)))-0.001
        if(jj == 1){
          subout <- sub
        }else{
          subout <- rbind(subout,sub)
        }
        rm(sub)
        
      }}
    #subout$seVal_hist <- subout$sdVal_hist/sqrt(subout$nVal_hist)
    tmp_var <- subout
    rm(subout)
    cat(" gam smoother complete \n")
  }
  
  
  datIN <- datIN%>%
    left_join(tmp_var)
  datIN$sim_type <- typeIN
  tmp_var$sim_type <- typeIN

  return(list(datIN=datIN,datout = data.frame(tmp_var)))
}