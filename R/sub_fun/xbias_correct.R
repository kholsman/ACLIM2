#'
#'
#'bias_correct.R
#'
#'This function bias corrects
#'projections using reference 
#'time periods and time series
#'
#'ACLIM2 updated
#'
# 

bias_correctOLD <- function(
  target     = "mn_val",
  hindIN     = hnd,
  histIN     = hist,
  futIN      = fut,
  group_byIN = c("var","basin","season"), #c("strata","var","basin","season"),
  group_byout = NULL,
  byStrata   = FALSE, # bias correct across years and regions
  seasonsIN  = seasons,
  ref_yrs    = 1980:2013,
  normlistIN =  normlist,
  smoothIT     = FALSE,
  log_adj    = 1e-4,
  outlist    = c("year","units",
                 "long_name","sim","bcIT","val_biascorrected",
                 "jday","mnDate","type","lognorm",
                 "sim_type","mnVal_hind","sdVal_hind",
                 "seVal_hind","seVal_hind","mnVal_hist","sdVal_hist","seVal_hist")
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

  eval(parse( text=paste0("sub <- histIN%>%dplyr::filter(year%in%ref_yrs)%>%
      dplyr::group_by(",paste(group_byIN,collapse=","),")%>%
      dplyr::summarize(mnVal_hist = mean(bcIT,na.rm=T),
                sdVal_hist   = sd(bcIT, na.rm = T),
                nVal_hist    = length(!is.na(bcIT)),
                mnLNVal_hist = mean(LNval,na.rm=T),
                sdLNVal_hist = sd(LNval, na.rm = T),
                nLNVal_hist  = length(!is.na(LNval)))") ))

  sub$seVal_hist <- sub$sdVal_hist/sqrt(sub$nVal_hist)
  hist_clim <- sub
  rm(sub)
  
  getgam <- function ( y =  sub$mnVal_hist, x = sub$wk,kin =.8){
    df <- na.omit(data.frame(x,y))
    if(dim(df)[1]>2){
      Gam   <- mgcv::gam( y ~ 1 + s(x, k=round(dim(df)[1]*kin),bs= "cr"),data=df)
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
  
  
  eval(parse( text=paste0("sub <- hindIN%>%dplyr::filter(year%in%ref_yrs)%>%
      dplyr::group_by(",paste(group_byIN,collapse=","),")%>%
      dplyr::summarize(mnVal_hind = mean(bcIT,na.rm=T),
                sdVal_hind = sd(bcIT, na.rm = T),
                nVal_hind  = length(!is.na(bcIT)),
                mnLNVal_hind = mean(LNval,na.rm=T),
                sdLNVal_hind = sd(LNval, na.rm = T),
                nLNVal_hind  = length(!is.na(LNval)))") ))
  
  sub$seVal_hind <- sub$sdVal_hind/sqrt(sub$nVal_hind)
  hind_clim      <- sub
  rm(sub)
  
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
  
  
  
  
  
  
  refout <- merge(hind_clim,hist_clim,by = group_byIN,all.x=T)
  

  eval(parse( text=paste0("sub <- futIN%>%dplyr::filter(year%in%ref_yrs)%>%
      dplyr::group_by(",paste(group_byIN,collapse=","),")%>%
      dplyr::summarize(mnVal_fut = mean(bcIT,na.rm=T),
                sdVal_fut = sd(bcIT, na.rm = T),
                nVal_fut  = length(!is.na(bcIT)),
                mnLNVal_fut = mean(LNval,na.rm=T),
                sdLNVal_fut = sd(LNval, na.rm = T),
                nLNVal_fut  = length(!is.na(LNval)))") ))
  
  sub$seVal_fut <- sub$sdVal_fut/sqrt(sub$nVal_fut)

  fut_clim <- sub
  rm(sub)
  # 
  # hindIN2 <- merge(hindIN,refout, 
  #                    by = group_byIN,all.x=T)
  # histIN2 <- merge(histIN,refout, 
  #                  by = group_byIN,all.x=T)
  # futIN2 <- merge(futIN,refout, 
  #                   by = group_byIN,all.x=T)
  
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

  
  
  futIN2<- futIN2%>%
    dplyr::mutate(
           val_bc1 = mnVal_hind + ((sdVal_hind/sdVal_hist)*(bcIT-mnVal_hist)),
           val_bc2 = exp(mnLNVal_hind + ((sdLNVal_hind/sdLNVal_hist)*(LNval-mnLNVal_hist)))-log_adj,
           val_bc3 = exp((mnLNVal_hind-mnLNVal_hist)+LNval)-log_adj )
          
  futIN2         <- merge(futIN2,normlistIN, by = "var", all.x =T)
  futIN2$val_biascorrected <- -9999
  #futIN2$val_biascorrected <- futIN2$val_bc2
  futIN2$val_biascorrected[futIN2$lognorm==TRUE]  <- futIN2$val_bc2[futIN2$lognorm==TRUE]
  futIN2$val_biascorrected[futIN2$lognorm==FALSE] <- futIN2$val_bc1[futIN2$lognorm==FALSE]
  
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