#'
#'
#'bias_correct_new.R
#'
#'This function bias corrects
#'projections using reference 
#'time periods and time series
#'Revised version reflects methodology from 
#'the 2022 bias correction workshop
#'
#'ACLIM2 updated
#'
# 

bias_correct_new <- function(
  target     = "mn_val",
  hindIN     = hnd,
  histIN     = hist,
  futIN      = fut,
  byStrata   = FALSE, # bias correct across years and regions
  seasonsIN  = seasons,
  ref_yrs    = 1980:2013,
  group_byIN = c("var","basin","season","mo","wk"),
  normlistIN =  normlist,
  smoothIT     = TRUE,
  log_adj    = 1e-4,
  group_byout =NULL,
  outlist    = c("year","units",
                 "long_name","sim","bcIT","val_delta",
                 "val_biascorrected", "val_biascorrectedmo", "val_biascorrectedyr","val_raw",
                 "scaling_factorwk","scaling_factormo","scaling_factoryr",
                 "jday","mnDate","type","lognorm",
                 "sim_type",
                 "mnVal_hind","sdVal_hind","sdVal_hind_mo","sdVal_hind_yr",
                 "mnLNVal_hind","sdLNVal_hind","sdLNVal_hind_mo","sdLNVal_hind_yr",
                 "mnVal_hist","sdVal_hist","sdVal_hist_mo","sdVal_hist_yr",
                 "mnLNVal_hist","sdLNVal_hist","sdLNVal_hist_mo","sdLNVal_hist_yr")
                 
){
  if(is.null(group_byout)){
    group_byout <- group_byIN
  }else{
    group_byout <- c(group_byIN,group_byout)
  }
  
  hindIN$val_raw <- hindIN$mn_val
  histIN$val_raw <- histIN$mn_val
  futIN$val_raw  <- futIN$mn_val
  # rename the target:
  eval(parse(text = paste0("hindIN <- hindIN%>%dplyr::rename(bcIT=",target,")") ))
  eval(parse(text = paste0("histIN <- histIN%>%dplyr::rename(bcIT=",target,")") ))
  eval(parse(text = paste0("futIN  <- futIN%>%dplyr::rename(bcIT=",target,")") ))
  
  # select those that are within the normlist table:
  hindIN <- hindIN%>%dplyr::filter(var%in%normlistIN$var)
  histIN <- histIN%>%dplyr::filter(var%in%normlistIN$var)
  futIN  <- futIN%>%dplyr::filter(var%in%normlistIN$var)
  
  # this will throw error for the normally dist parameters
  hindIN$LNval <- suppressWarnings(log(hindIN$bcIT + log_adj))
  histIN$LNval <- suppressWarnings(log(histIN$bcIT + log_adj))
  futIN$LNval  <- suppressWarnings(log(futIN$bcIT  + log_adj))
  
  
  hindIN$sim_type <- "hind"
  histIN$sim_type <- "hist"
  futIN$sim_type  <- "proj"
  
  # get scaling factor (sd_hind/sd_hist)
  #--------------------------------------
  
  # first get hist vals
  hist_clim <- histIN%>%dplyr::filter(year%in%ref_yrs)%>%
    dplyr::group_by(across(all_of(group_byIN)))%>%
    dplyr::summarize(mnVal_hist = mean(bcIT,na.rm=T),
                     sdVal_hist   = sd(bcIT, na.rm = T),
                     nVal_hist    = length(!is.na(bcIT)),
                     mnLNVal_hist = mean(LNval,na.rm=T),
                     sdLNVal_hist = sd(LNval, na.rm = T),
                     nLNVal_hist  = length(!is.na(LNval)))
  if(any(group_byIN=="mo"))
    sub_mo <- histIN%>%dplyr::filter(year%in%ref_yrs)%>%
    dplyr::group_by(var,basin,mo)%>%
    dplyr::summarize(sdVal_hist_mo   = sd(bcIT, na.rm = T),
                     sdLNVal_hist_mo = sd(LNval, na.rm = T))
  sub_yr <- histIN%>%dplyr::filter(year%in%ref_yrs)%>%
    dplyr::group_by(var,basin)%>%
    dplyr::summarize(sdVal_hist_yr   = sd(bcIT, na.rm = T),
                     sdLNVal_hist_yr = sd(LNval, na.rm = T))
  hist_clim$seVal_hist <- hist_clim$sdVal_hist/sqrt(hist_clim$nVal_hist)
  if(any(group_byIN=="mo"))
    hist_clim <- hist_clim%>%
    left_join(sub_mo,by=c("var"="var","basin"="basin","mo"="mo"))
  hist_clim   <- hist_clim%>%
    left_join(sub_yr,by=c("var"="var","basin"="basin"))
  rm(sub_yr)
  if(any(group_byIN=="mo")) rm(sub_mo)
  
  
  # then get hind vals
  hind_clim <- hindIN%>%dplyr::filter(year%in%ref_yrs)%>%
    dplyr::group_by(across(all_of(group_byIN)))%>%
    dplyr::summarize(mnVal_hind = mean(bcIT,na.rm=T),
                     sdVal_hind   = sd(bcIT, na.rm = T),
                     nVal_hind    = length(!is.na(bcIT)),
                     mnLNVal_hind = mean(LNval,na.rm=T),
                     sdLNVal_hind = sd(LNval, na.rm = T),
                     nLNVal_hind  = length(!is.na(LNval)))
  
  if(any(group_byIN=="mo"))
     sub_mo <- hindIN%>%dplyr::filter(year%in%ref_yrs)%>%
    dplyr::group_by(var,basin,mo)%>%
    dplyr::summarize(sdVal_hind_mo   = sd(bcIT, na.rm = T),
                     sdLNVal_hind_mo = sd(LNval, na.rm = T))
  
  sub_yr <- hindIN%>%dplyr::filter(year%in%ref_yrs)%>%
    dplyr::group_by(var,basin)%>%
    dplyr::summarize(sdVal_hind_yr   = sd(bcIT, na.rm = T),
                     sdLNVal_hind_yr = sd(LNval, na.rm = T))
  
  hind_clim$seVal_hind <- hind_clim$sdVal_hind/sqrt(hind_clim$nVal_hind)
  if(any(group_byIN=="mo"))
    hind_clim <- hind_clim%>%
    left_join(sub_mo,by=c("var"="var","basin"="basin","mo"="mo"))
  hind_clim <- hind_clim%>%
    left_join(sub_yr,by=c("var"="var","basin"="basin"))
  rm(sub_yr)
  if(any(group_byIN=="mo")) rm(sub_mo)
  

  getgam <- function ( y =  sub$mnVal_hist, x = sub$wk,kin =.8){
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
  
  if(smoothIT){
    
    tmpvar <- unique(hist_clim$var)
    nvar   <- length(tmpvar)
    tmpbasin <- unique(hist_clim$basin)
    jj <- 0
    
    for(b in 1:length(tmpbasin)){
      for(v in 1:nvar){
        jj<- jj +1
        sub <- hist_clim%>%filter(basin==tmpbasin[b],var==tmpvar[v])
        sub$mnVal_hist   <- getgam(x =sub$wk, y = sub$mnVal_hist)
        sub$sdVal_hist   <- getgam(x =sub$wk, y = sub$sdVal_hist)
        sub$seVal_hist   <- getgam(x =sub$wk, y = sub$seVal_hist)
        sub$mnLNVal_hist <- getgam(x =sub$wk, y = sub$mnLNVal_hist)
        sub$sdLNVal_hist <- getgam(x =sub$wk, y = sub$sdLNVal_hist)
        
        # plot(sub$wk,sub$mnLNVal_hist);lines(sub$wk,sub$mnLNVal_hist2)
        if(jj == 1){
          subout <- sub
        }else{
          subout <- rbind(subout,sub)
        }
        rm(sub)
        
      }}
    hist_clim <- subout
    rm(subout)
    
  }
  
  
  if(smoothIT){
    
    tmpvar <- unique(hind_clim$var)
    nvar   <- length(tmpvar)
    tmpbasin <- unique(hind_clim$basin)
    jj <- 0
    
    for(b in 1:length(tmpbasin)){
      for(v in 1:nvar){
        jj<- jj +1
        sub <- hind_clim%>%filter(basin==tmpbasin[b],var==tmpvar[v])
        sub$mnVal_hind   <- getgam(x =sub$wk, y = sub$mnVal_hind)
        sub$sdVal_hind   <- getgam(x =sub$wk, y = sub$sdVal_hind)
        sub$seVal_hind   <- getgam(x =sub$wk, y = sub$seVal_hind)
        sub$mnLNVal_hind <- getgam(x =sub$wk, y = sub$mnLNVal_hind)
        sub$sdLNVal_hind <- getgam(x =sub$wk, y = sub$sdLNVal_hind)
        
        # plot(sub$wk,sub$mnLNVal_hist);lines(sub$wk,sub$mnLNVal_hist2)
        if(jj == 1){
          subout <- sub
        }else{
          subout <- rbind(subout,sub)
        }
        rm(sub)
        
      }}
    #subout$seVal_hist <- subout$sdVal_hist/sqrt(subout$nVal_hist)
    hind_clim <- subout
    rm(subout)
    
  }
  
  
  
  eval(parse(text = paste0("refout <-left_join(hind_clim,hist_clim,
                           by =c(",paste0(paste0(paste0("'",group_byIN,"'"),
                                         sep=" = ",each=
                                           paste0("'",group_byIN,"'")),collapse=", "),"))") ))
  
  fut_clim <- futIN%>%dplyr::filter(year%in%ref_yrs)%>%
    dplyr::group_by(across(all_of(group_byIN)))%>%
    dplyr::summarize(mnVal_fut = mean(bcIT,na.rm=T),
                  sdVal_fut    = sd(bcIT, na.rm = T),
                  nVal_fut     = length(!is.na(bcIT)),
                  mnLNVal_fut  = mean(LNval,na.rm=T),
                  sdLNVal_fut  = sd(LNval, na.rm = T),
                  nLNVal_fut   = length(!is.na(LNval)))
   sub_yr <- futIN%>%dplyr::filter(year%in%ref_yrs)%>%
        dplyr::group_by(var,basin)%>%
        dplyr::summarize(sdVal_fut_yr = sd(bcIT, na.rm = T),
                         sdLNVal_fut_yr = sd(LNval, na.rm = T))
   fut_clim$seVal_fut <- fut_clim$sdVal_fut/sqrt(fut_clim$nVal_fut)
   fut_clim           <- fut_clim%>%left_join(sub_yr,by=c("var"="var","basin"="basin"))
   rm(sub_yr)
   
   eval(parse(text = paste0("hindIN2 <- hindIN%>%left_join(refout, 
                   by =c(",paste0(paste0(paste0("'",group_byIN,"'"),
                                         sep=" = ",each=
                                           paste0("'",group_byIN,"'")),collapse=", "),"))") ))
   eval(parse(text = paste0("histIN2 <- histIN%>%left_join(refout, 
                   by =c(",paste0(paste0(paste0("'",group_byIN,"'"),
                                         sep=" = ",each=
                                           paste0("'",group_byIN,"'")),collapse=", "),"))") ))
   eval(parse(text = paste0("futIN2 <- futIN%>%left_join(refout, 
                   by =c(",paste0(paste0(paste0("'",group_byIN,"'"),
                                         sep=" = ",each=
                                           paste0("'",group_byIN,"'")),collapse=", "),"))") ))
   
  # Ho et al. 2012
   if(any(group_byIN=="mo"))
     futIN2<- futIN2%>%
     dplyr::mutate(
       sf_1wk  = (sdVal_hind/sdVal_hist),
       sf_1mo  = (sdVal_hind_mo/sdVal_hist_mo),
       sf_1yr  = (sdVal_hind_yr/sdVal_hist_yr),
       
       sf_2wk  = (sdLNVal_hind/sdLNVal_hist),
       sf_2mo  = (sdLNVal_hind_mo/sdLNVal_hist_mo),
       sf_2yr  = (sdLNVal_hind_yr/sdLNVal_hist_yr),
       
       val_delta1 = mnVal_hind + ((bcIT-mnVal_hist)),
       val_bc1wk  = mnVal_hind + ((sdVal_hind/sdVal_hist)*(bcIT-mnVal_hist)),
       val_bc1mo  = mnVal_hind + ((sdVal_hind_mo/sdVal_hist_mo)*(bcIT-mnVal_hist)),
       val_bc1yr  = mnVal_hind + ((sdVal_hind_yr/sdVal_hist_yr)*(bcIT-mnVal_hist)),
       
       val_delta2 =exp(mnLNVal_hind + ((LNval-mnLNVal_hist)))-log_adj,
       val_bc2wk = exp(mnLNVal_hind + ((sdLNVal_hind/sdLNVal_hist)*(LNval-mnLNVal_hist)))-log_adj,
       val_bc2mo = exp(mnLNVal_hind + ((sdLNVal_hind_mo/sdLNVal_hist_mo)*(LNval-mnLNVal_hist)))-log_adj,
       val_bc2yr = exp(mnLNVal_hind + ((sdLNVal_hind_yr/sdLNVal_hist_yr)*(LNval-mnLNVal_hist)))-log_adj)
   if(!any(group_byIN=="mo"))
     futIN2<- futIN2%>%
     dplyr::mutate(
       sf_1wk  = (sdVal_hind/sdVal_hist),
       #sf_1mo  = (sdVal_hind_mo/sdVal_hist_mo),
       sf_1yr  = (sdVal_hind_yr/sdVal_hist_yr),
       
       sf_2wk  = exp(sdLNVal_hind/sdLNVal_hist),
       #sf_2mo  = (sdLNVal_hind_mo/sdLNVal_hist_mo),
       sf_2yr  = exp(sdLNVal_hind_yr/sdLNVal_hist_yr),
       
       val_delta1 = mnVal_hind + ((bcIT-mnVal_hist)),
       val_bc1wk  = mnVal_hind + ((sdVal_hind/sdVal_hist)*(bcIT-mnVal_hist)),
       #val_bc1mo  = mnVal_hind + ((sdVal_hind_mo/sdVal_hist_mo)*(bcIT-mnVal_hist)),
       val_bc1yr  = mnVal_hind + ((sdVal_hind_yr/sdVal_hist_yr)*(bcIT-mnVal_hist)),
       
       val_delta2 =exp(mnLNVal_hind + ((LNval-mnLNVal_hist)))-log_adj,
       val_bc2wk = exp(mnLNVal_hind + ((sdLNVal_hind/sdLNVal_hist)*(LNval-mnLNVal_hist)))-log_adj,
       #val_bc2mo = exp(mnLNVal_hind + ((sdLNVal_hind_mo/sdLNVal_hist_mo)*(LNval-mnLNVal_hist)))-log_adj,
       val_bc2yr = exp(mnLNVal_hind + ((sdLNVal_hind_yr/sdLNVal_hist_yr)*(LNval-mnLNVal_hist)))-log_adj)
   
  futIN2         <- merge(futIN2,normlistIN, by = "var", all.x =T)
  futIN2$val_delta     <- 
    futIN2$val_biascorrected   <-
    futIN2$val_biascorrectedmo <-
    futIN2$val_biascorrectedyr <-
    futIN2$scaling_factorwk    <- 
    futIN2$scaling_factormo    <- 
    futIN2$scaling_factoryr    <- -9999
  
  rr <- which(futIN2$lognorm==TRUE)
    futIN2$val_delta[rr]          <- futIN2$val_delta2[rr]
    futIN2$val_biascorrected[rr]  <- futIN2$val_bc2wk[rr]
    futIN2$val_biascorrectedyr[rr]<- futIN2$val_bc2yr[rr]
    futIN2$scaling_factorwk[rr]   <- futIN2$sf_2wk[rr]
    futIN2$scaling_factoryr[rr]   <- futIN2$sf_2yr[rr]
    if(any(group_byIN=="mo")){
     futIN2$val_biascorrectedmo[rr]<- futIN2$val_bc2mo[rr]
     futIN2$scaling_factormo[rr]   <- futIN2$sf_2mo[rr]
    }
  rr <- which(futIN2$lognorm==FALSE)
    futIN2$val_delta[rr]          <- futIN2$val_delta1[rr]
    futIN2$val_biascorrected[rr]  <- futIN2$val_bc1wk[rr]
    futIN2$val_biascorrectedyr[rr]<- futIN2$val_bc1yr[rr]
    futIN2$scaling_factorwk[rr]   <- futIN2$sf_1wk[rr]
    futIN2$scaling_factoryr[rr]   <- futIN2$sf_1yr[rr]
    if(any(group_byIN=="mo")){
      futIN2$val_biascorrectedmo[rr]<- futIN2$val_bc1mo[rr]
      futIN2$scaling_factormo[rr]   <- futIN2$sf_1mo[rr]
    }
  futIN2  <- futIN2%>%dplyr::select(all_of(c(group_byout,outlist)))%>%dplyr::arrange(var,year)
  tt      <- names(hindIN2)[names(hindIN2)%in%c(group_byout,outlist)]
  hindIN2 <- hindIN2%>%dplyr::select(all_of(tt))%>%dplyr::arrange(var,year)
  tt      <- names(histIN2)[names(histIN2)%in%c(group_byout,outlist)]
  histIN2 <- histIN2%>%dplyr::select(all_of(tt))%>%dplyr::arrange(var,year)
  
  # rename the target:
  eval(parse(text = paste0("hindIN2 <- hindIN2%>%dplyr::rename(",target,"= bcIT)") ))
  eval(parse(text = paste0("histIN2 <- histIN2%>%dplyr::rename(",target,"= bcIT)") ))
  eval(parse(text = paste0("futIN2  <- futIN2%>%dplyr::rename(",target,"= bcIT)") ))
  
  
  return( list(fut = futIN2, hind = hindIN2,hist = histIN2))
}