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
  
  hind_clim  = mn_hind%>%filter(var==v),
  hist_clim  = mn_hist%>%filter(var==v),
  futIN2      = futIN%>%filter(var==v),
  roundn     = 5,
  sf         = "bcwk",  #bcwk  bcmo bcyr
  usehist = usehist,
  byStrata   = FALSE, # bias correct across years and regions
  seasonsIN  = seasons,
  ref_yrs    = 1980:2013,
  group_byIN = c("var","basin","season","mo","wk"),
  normlistIN =  normlist,
  smoothIT   = TRUE,
  log_adj    = 1e-4,
  group_byout = NULL,
  outlist    = c("year","units",
                 "long_name","sim","mn_val","val_delta",
                 "val_biascorrected", 
                 "val_biascorrectedwk","val_biascorrectedmo", "val_biascorrectedyr","val_raw",
                 "sf_wk","sf_mo","sf_yr",
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
  hist_clim <- hist_clim%>%select(-"season",-"strata_area_km2",-"lognorm",-"sim_type",-"RCP2")
  hind_clim <- hind_clim%>%select(-"sim_type")
  
  #load(file="data/out/tmp/futIN.Rdata")
  refout  <- left_join(hind_clim,hist_clim)
  futIN2  <- futIN2%>%left_join(refout)
  
  # Ho et al. 2012
    futIN2$sf_wk  <-NA
    if(any(group_byIN=="mo")) 
    futIN2$sf_mo  <-
      
    futIN2$sf_yr  <-
    futIN2$val_delta <-
    futIN2$val_bcwk  <-
    futIN2$val_bcmo  <-
    futIN2$val_bcyr  <-  NA
    #subA <- subB <- subC <- NULL
    sdfun<-function(x){
      x[x==0]   <- 1
      x[x==Inf] <- 1
      x  
    }
    
      if(!any(futIN2$lognorm%in%c("none","log","logit"))){
        stop("bias_correct_new_strata: problem with lognorm, must be 'none', 'log' or 'logit' for each var")
      }
       
            subA <- futIN2%>%mutate(
               sf_wk  = abs(  sdVal_hind/  sdVal_hist),
               sf_mo  = abs(  sdVal_hind_mo/  sdVal_hist_mo),
               sf_yr  = abs(  sdVal_hind_yr/  sdVal_hist_yr))%>%
              mutate_at(c("sf_wk","sf_mo","sf_yr"),sdfun)%>%
              mutate(
               val_delta =   mnVal_hind + (( mn_val-  mnVal_hist)),
               val_bcwk  =   mnVal_hind + ( sf_wk*( mn_val- mnVal_hist)),
               val_bcmo  =   mnVal_hind + ( sf_mo*( mn_val- mnVal_hist)),
               val_bcyr  =   mnVal_hind + ( sf_yr*( mn_val- mnVal_hist)))
            
            futout  <-  unlink_val(indat    = subA%>%mutate(val_bcwk_IN=val_bcwk),
                                   log_adj  = log_adj,
                                   roundn   = roundn,
                                   listIN   = c(
                                                "mnVal_hind",
                                                "mnVal_hist",
                                                "val_delta",
                                                "val_bcwk",
                                                "val_bcmo",
                                                "val_bcyr"),
                                   rmlistIN = c("sdVal_hind", "seVal_hind", "sdVal_hind_mo", "sdVal_hind_yr",
                                                "sdVal_hist", "seVal_hist", "sdVal_hist_mo", "sdVal_hist_yr",
                                                "nVal_hist","nVal_hind"))
            futout<-futout%>% rename(
                  val_biascorrectedwk = val_bcwk,
                  val_biascorrectedmo = val_bcmo,
                  val_biascorrectedyr = val_bcyr)
            
        rm(subA)
        subA <- subB <- subC <- NULL
        subA <- futout%>%filter(lognorm=="none")%>%
          mutate(val_delta_adj =   mnVal_hind + (( mn_val-  mnVal_hist)))

        subB<- futout%>%filter(lognorm=="logit")%>%
          mutate( val_delta_adj =   round(
            (inv.logit(
              logit(mnVal_hind+log_adj) + 
                        (logit(mn_val+log_adj)-logit(mnVal_hist+log_adj) ))-log_adj),roundn))
         

        subC<- futout%>%filter(lognorm=="log")%>%
          mutate( val_delta_adj =   round(
            exp(log(mnVal_hind+log_adj) + ((log( mn_val+log_adj)-log(  mnVal_hist+log_adj))))-log_adj
                                      ,roundn))
      
      futout <- rbind(subA, subB, subC)
      rm(list=c("subA","subB","subC"))
  if(sf =="val_delta")
        futout$val_biascorrected <- futout$val_delta
  if(sf =="val_delta_adj")
        futout$val_biascorrected <- futout$val_delta_adj
  if(sf =="bcwk")
    futout$val_biascorrected <- futout$val_biascorrectedwk
  if(sf =="bcmo")
    futout$val_biascorrected <- futout$val_biascorrectedmo
  if(sf =="bcyr")
    futout$val_biascorrected <- futout$val_biascorrectedyr
    futout$sf <- sf
  if(1==10){
    ggplot(data=futout%>%filter(strata==70,year%in%c(2030:2032)))+
      geom_point(aes(x=jday,y=mn_val,color="mn_val"),size=1.8)+
      geom_line(aes(x=jday,y=val_raw,linetype="raw",color=factor(year)),size=1.1)+
      geom_line(aes(x=jday,y=val_biascorrectedmo,linetype="bias correctedmo",color=factor(year)),size=1.1)+
      theme_minimal()
    ggplot(data=futout%>%filter(strata==70,year%in%c(2030:2032)))+
      geom_point(aes(x=jday,y=mn_val,color="mn_val"),size=1.8)+
      geom_line(aes(x=jday,y=val_raw,linetype="raw",color=factor(year)),size=1.1)+
      geom_line(aes(x=jday,y=val_delta,linetype="val_delta",color=factor(year)),size=1.1)+
      geom_line(aes(x=jday,y=val_biascorrectedwk,linetype="bias correctedwk",color=factor(year)),size=1.1)+
      theme_minimal()
  }
  
  
  tt      <- names(futout)[names(futout)%in%c(group_byout,outlist,"val_delta_adj")]
  futout  <- futout%>%dplyr::select(all_of(tt))%>%dplyr::arrange(var, strata,mnDate,year,mo,wk)
  
  return(futout)
}