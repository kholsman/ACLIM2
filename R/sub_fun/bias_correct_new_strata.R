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

bias_correct_new_strata <- function(
  
  hind_clim  = mn_hind,
  hist_clim  = mn_hist,
  fut_clim   = mn_fut, 
  sf = "bcwk",  #bcwk  bcmo bcyr
  byStrata   = FALSE, # bias correct across years and regions
  seasonsIN  = seasons,
  ref_yrs    = 1980:2013,
  group_byIN = c("var","basin","season","mo","wk"),
  normlistIN =  normlist,
  smoothIT     = TRUE,
  log_adj    = 1e-4,
  group_byout =NULL,
  outlist    = c("year","units",
                 "long_name","sim","mn_val","val_delta",
                 "val_biascorrected", 
                 "val_biascorrectedwk","val_biascorrectedmo", "val_biascorrectedyr","val_raw",
                 "scaling_factorwk","scaling_factormo","scaling_factoryr",
                 "mnjday","mnDate","type","lognorm",
                 "sim_type",
                 "mnVal_hind","sdVal_hind","sdVal_hind_mo","sdVal_hind_yr",
                 "mnVal_hist","sdVal_hist","sdVal_hist_mo","sdVal_hist_yr")
  
){
 
  if(is.null(group_byout)){
    group_byout <- group_byIN
  }else{
    group_byout <- c(group_byIN,group_byout)
  }
  
  load(file="data/out/tmp/futIN.Rdata")
  eval(parse(text = paste0("refout <-left_join(hind_clim,hist_clim,
                           by =c(",paste0(paste0(paste0("'",group_byIN,"'"),
                                                 sep=" = ",each=
                                                   paste0("'",group_byIN,"'")),collapse=", "),"))") ))
  eval(parse(text = paste0("futIN2 <- futIN%>%left_join(refout, 
                   by =c(",paste0(paste0(paste0("'",group_byIN,"'"),
                                         sep=" = ",each=
                                           paste0("'",group_byIN,"'")),collapse=", "),"))") ))

   
    
    eval(parse(text = paste0("hindIN2 <- hindIN%>%left_join(refout, 
                     by =c(",paste0(paste0(paste0("'",group_byIN,"'"),
                                           sep=" = ",each=
                                             paste0("'",group_byIN,"'")),collapse=", "),"))") ))
    eval(parse(text = paste0("histIN2 <- histIN%>%left_join(refout, 
                     by =c(",paste0(paste0(paste0("'",group_byIN,"'"),
                                           sep=" = ",each=
                                             paste0("'",group_byIN,"'")),collapse=", "),"))") ))
  
    
  # Ho et al. 2012
  if(any(group_byIN=="mo"))
    # futIN2<- futIN2%>%
    # dplyr::mutate(
    #   sf_1wk  = (sdVal_hind/sdVal_hist),
    #   sf_1mo  = (sdVal_hind_mo/sdVal_hist_mo),
    #   sf_1yr  = (sdVal_hind_yr/sdVal_hist_yr),
    #   # 
    #   # sf_2wk  = (sdLNVal_hind/sdLNVal_hist),
    #   # sf_2mo  = (sdLNVal_hind_mo/sdLNVal_hist_mo),
    #   # sf_2yr  = (sdLNVal_hind_yr/sdLNVal_hist_yr),
    #   
    #   val_delta  = mnVal_hind + ((mn_val-mnVal_hist)),
    #   val_bc1wk  = mnVal_hind + ((sdVal_hind/sdVal_hist)*(mn_val-mnVal_hist)),
    #   val_bc1mo  = mnVal_hind + ((sdVal_hind_mo/sdVal_hist_mo)*(mn_val-mnVal_hist)),
    #   val_bc1yr  = mnVal_hind + ((sdVal_hind_yr/sdVal_hist_yr)*(mn_val-mnVal_hist)))
    #   
    # 
    
    futIN2$sf_wk  <-
    futIN2$sf_mo  <-
    futIN2$sf_yr  <-
    futIN2$val_delta <-
    futIN2$val_bcwk  <-
    futIN2$val_bcmo  <-
    futIN2$val_bcyr  <-  NA
    subA <- subB <- subC <-NULL
    
      if(!any(futIN2$lognorm%in%c("none","log","logit"))){
        stop("bias_correct_new_strata: problem with lognorm, must be 'none', 'log' or 'logit' for each var")
      }else{
        subA <- futIN2%>%filter(lognorm=="none")%>%mutate(
           mnval_adj = mn_val,
           sf_wk  = abs(  sdVal_hind/  sdVal_hist),
           sf_mo  = abs(  sdVal_hind_mo/  sdVal_hist_mo),
           sf_yr  = abs(  sdVal_hind_yr/  sdVal_hist_yr),
           val_delta =   mnVal_hind + (( mn_val-  mnVal_hist)),
           val_bcwk  =   mnVal_hind + ( sf_wk*( mn_val- mnVal_hist)),
           val_bcmo  =   mnVal_hind + ( sf_mo*( mn_val- mnVal_hist)),
           val_bcyr  =   mnVal_hind + ( sf_yr*( mn_val- mnVal_hist)))
        
        subB<- futIN2%>%filter(lognorm=="logit")%>%mutate(
          mnval_adj = inv.logit(mn_val)-log_adj,
          sf_wk  = abs(  sdVal_hind/  sdVal_hist),
            sf_mo  = abs(  sdVal_hind_mo/  sdVal_hist_mo),
            sf_yr  = abs(  sdVal_hind_yr/  sdVal_hist_yr),
            val_delta =   inv.logit(mnVal_hind + (( mn_val-  mnVal_hist)))-log_adj,
            val_bcwk  =   inv.logit(mnVal_hind + ( sf_wk*( mn_val- mnVal_hist)))-log_adj,
            val_bcmo  =   inv.logit(mnVal_hind + ( sf_mo*( mn_val- mnVal_hist)))-log_adj,
            val_bcyr  =   inv.logit(mnVal_hind + ( sf_yr*( mn_val- mnVal_hist)))-log_adj)
        subC<- futIN2%>%filter(lognorm=="log")%>%mutate(
          mnval_adj = log(mn_val)-log_adj,
          sf_wk  = abs(  sdVal_hind/  sdVal_hist),
            sf_mo  = abs(  sdVal_hind_mo/  sdVal_hist_mo),
            sf_yr  = abs(  sdVal_hind_yr/  sdVal_hist_yr),
            val_delta =   exp(mnVal_hind + (( mn_val-  mnVal_hist)))-log_adj,
            val_bcwk  =   exp(mnVal_hind + ( sf_wk*( mn_val- mnVal_hist)))-log_adj,
            val_bcmo  =   exp(mnVal_hind + ( sf_mo*( mn_val- mnVal_hist)))-log_adj,
            val_bcyr  =   exp(mnVal_hind + ( sf_yr*( mn_val- mnVal_hist)))-log_adj)
        
      }
    futout <- rbind(subA, subB, subC)%>%
      rename(
        val_biascorrectedwk = val_bcwk,
        val_biascorrectedmo = val_bcmo,
        val_biascorrectedyr = val_bcyr)%>%
      mutate(mn_val=round(mnval_adj,8))%>%select(-mnval_adj)
    
    ggplot(data=futout%>%filter(strata==70,year%in%c(2030:2032)))+
      geom_point(aes(x=mnjday,y=mn_val,color="mn_val"))+
      geom_point(aes(x=mnjday,y=val_raw,color="raw"))+
      geom_line(aes(x=mnjday,y=val_biascorrectedwk,color=factor(year)))
  
  if(sf =="bcwk")
    futIN2$val_biascorrected <- futIN2$val_biascorrectedwk
  if(sf =="bcmo")
    futIN2$val_biascorrected <- futIN2$val_biascorrectedmo
  if(sf =="bcyr")
    futIN2$val_biascorrected <- futIN2$val_biascorrectedyr
  futIN2$sf <- sf
  
  
  
  futIN2  <- futIN2%>%dplyr::select(all_of(c(group_byout,outlist)))%>%dplyr::arrange(var,year)
  tt      <- names(hindIN2)[names(hindIN2)%in%c(group_byout,outlist)]
  hindIN2 <- hindIN2%>%dplyr::select(all_of(tt))%>%dplyr::arrange(var,year)
  tt      <- names(histIN2)[names(histIN2)%in%c(group_byout,outlist)]
  histIN2 <- histIN2%>%dplyr::select(all_of(tt))%>%dplyr::arrange(var,year)
  
  return( list(fut = futIN2, hind = hindIN2,hist = histIN2))
}