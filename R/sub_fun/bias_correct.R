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

bias_correct <- function(
  target     = "mn_val",
  hindIN     = hnd,
  histIN     = hist,
  futIN      = fut,
  group_byIN = c("var","basin","season"), #c("strata","var","basin","season"),
  byStrata   = FALSE, # bias correct across years and regions
  seasonsIN  = seasons,
  ref_yrs    = 1980:2013,
  normlistIN =  normlist,
  plotIT     = TRUE,
  plotwk     = 2,
  plotvarIN  = "temp_bottom5m",
  log_adj    = 1e-4,
  outlist    = c("year","units",
                 "long_name","sim","bcIT","val_biascorrected",
                 "jday","mnDate","type","lognorm",
                 "sim_type","mnVal_hind","sdVal_hind",
                 "seVal_hind","seVal_hind","mnVal_hist","sdVal_hist","seVal_hist")
){
  
  # rename the target:
  eval(parse(text = paste0("hindIN <- hindIN%>%dplyr::rename(bcIT=",target,")") ))
  eval(parse(text = paste0("histIN <- histIN%>%dplyr::rename(bcIT=",target,")") ))
  eval(parse(text = paste0("futIN  <- futIN%>%dplyr::rename(bcIT=",target,")") ))
  
  # select those that are within the normlist table:
  hindIN <- hindIN%>%dplyr::filter(var%in%normlistIN$var)
  histIN <- histIN%>%dplyr::filter(var%in%normlistIN$var)
  futIN  <- futIN%>%dplyr::filter(var%in%normlistIN$var)

  # this will throw error for the normally dist parameters
  hindIN$LNval <- log(hindIN$bcIT + log_adj)
  histIN$LNval <- log(histIN$bcIT + log_adj)
  futIN$LNval  <- log(futIN$bcIT  + log_adj)

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
 
  hindIN2 <- merge(hindIN,refout, 
                     by = group_byIN,all.x=T)
  histIN2 <- merge(histIN,refout, 
                   by = group_byIN,all.x=T)
  futIN2 <- merge(futIN,refout, 
                    by = group_byIN,all.x=T)
  
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
  
  futIN2  <- futIN2%>%dplyr::select(all_of(c(group_byIN,outlist)))%>%dplyr::arrange(var,year)
  tt      <- names(hindIN2)[names(hindIN2)%in%c(group_byIN,outlist)]
  hindIN2 <- hindIN2%>%dplyr::select(all_of(tt))%>%dplyr::arrange(var,year)
  tt      <- names(histIN2)[names(histIN2)%in%c(group_byIN,outlist)]
  histIN2 <- histIN2%>%dplyr::select(all_of(tt))%>%dplyr::arrange(var,year)
  
  hindIN2$mn_val_raw <- hindIN2$mn_val
  histIN2$mn_val_raw <- histIN2$mn_val
  futIN2$mn_val_raw  <- futIN2$mn_val
  
  # rename the target:
  eval(parse(text = paste0("hindIN2 <- hindIN2%>%dplyr::rename(",target,"= bcIT)") ))
  eval(parse(text = paste0("histIN2 <- histIN2%>%dplyr::rename(",target,"= bcIT)") ))
  eval(parse(text = paste0("futIN2  <- futIN2%>%dplyr::rename(",target,"= bcIT)") ))
  
  
  return( list(fut = futIN2, hind = hindIN2,hist = histIN2))
}