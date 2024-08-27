#'
#'
#'
#'Plots inspired by K Kearney
#'
#'plot_biascorrection.R
#'
#'


plot_biascorrection <- function(wkdat=weekly_adj$fut,wkdat2= weekly_adj2$fut,
                                minmax_yIN = NULL, minmax_xIN=NULL,
                                regIN = "SEBS",varIN ="temp_bottom5m" ){
  
  aa <- wkdat%>%filter(basin==regIN,var==varIN)
  aa$type3<-"A) non smoothed"
  bb <- wkdat2%>%filter(basin==regIN,var==varIN)
  bb$type3<-"B) gam smoothed"
  suba<- rbind(
    aa,bb)
  suba<-suba%>%mutate(
    mn_delta1 = mnVal_hind+(-mnVal_hist),
    mn_bc1wk  = mnVal_hind + ((sdVal_hind/sdVal_hist)*(-mnVal_hist)),
    mn_bc1mo  = mnVal_hind + ((sdVal_hind_mo/sdVal_hist_mo)*(-mnVal_hist)),
    mn_bc1yr  = mnVal_hind + ((sdVal_hind_yr/sdVal_hist_yr)*(-mnVal_hist))
  )
  suba_sf <- suba_bc <- suba
  suba<- suba%>%rename(
    '1) val_raw'= val_raw,
    '2) val_delta'= val_delta,
    '3) val_biascorrected(wk)'= val_biascorrected,
    '4) val_biascorrected(mo)'= val_biascorrectedmo,
    '5) val_biascorrected(yr)'= val_biascorrectedyr
  )
  
  suba_sf<- suba_sf%>%mutate(
    '1) val_raw'= scaling_factorwk*0+1,
    '2) val_delta'= scaling_factorwk*0+1,
    '3) val_biascorrected(wk)'= scaling_factorwk,
    '4) val_biascorrected(mo)'= scaling_factormo,
    '5) val_biascorrected(yr)'= scaling_factoryr
  )
  suba_bc<- suba_bc%>%mutate(
    '1) val_raw'= mn_delta1*0,
    '2) val_delta'= mn_delta1,
    '3) val_biascorrected(wk)'= mn_bc1wk,
    '4) val_biascorrected(mo)'= mn_bc1mo,
    '5) val_biascorrected(yr)'= mn_bc1yr
  )

  dat <- reshape2::melt(suba%>%select(year,mnDate, jday,type3, mnVal_hind,mnVal_hist,sdVal_hind,sdVal_hist,
                                      '1) val_raw','2) val_delta',
                                      '3) val_biascorrected(wk)','4) val_biascorrected(mo)','5) val_biascorrected(yr)'),
                        id.vars=c( "year", "mnDate","jday","type3","mnVal_hind","mnVal_hist","sdVal_hind","sdVal_hist"))
   
  dat2 <- reshape2::melt(suba%>%select(year,mnDate, jday,type3, mnVal_hind,mnVal_hist,sdVal_hind,sdVal_hist,
                                       mn_delta1,mn_bc1wk,mn_bc1mo,mn_bc1yr),
                        id.vars=c( "year", "mnDate","jday","type3","mnVal_hind","mnVal_hist","sdVal_hind","sdVal_hist"))
  dat3 <- reshape2::melt(suba%>%select(year,mnDate, jday,type3, mnVal_hind,mnVal_hist,sdVal_hind,sdVal_hist,
                                       scaling_factorwk,scaling_factormo,scaling_factoryr),
                         id.vars=c( "year", "mnDate","jday","type3","mnVal_hind","mnVal_hist","sdVal_hind","sdVal_hist"))
  p1 <- ggplot(dat)+geom_line(aes(x=mnDate,y=value,color=factor(variable)))+
    facet_grid(type3~.)+theme_minimal()+ggtitle(paste0(regIN,"; ", varIN))
  p2 <- ggplot(dat2)+
    geom_line(aes(x=jday,y=value,color=factor(variable)))+ facet_grid(type3~.)+  theme_minimal()+ggtitle(paste0(regIN,"; ", varIN))
  p3 <- ggplot(dat3)+
    geom_line(aes(x=jday,y=value,color=factor(variable)))+ facet_grid(type3~.)+  theme_minimal()+ggtitle(paste0(regIN,"; ", varIN))
  minmax_y <- c(min(dat$value,na.rm = T),max(dat$value,na.rm = T))
  minmax_x <- c(min(dat$jday,na.rm = T),max(dat$jday,na.rm = T))
  if(!is.null(minmax_yIN)) minmax_y <- minmax_yIN
  if(!is.null(minmax_xIN))  minmax_x <- minmax_xIN
  datsf <- reshape2::melt(suba_sf%>%select(year,mnDate, jday,type3, mnVal_hind,mnVal_hist,sdVal_hind,sdVal_hist,
                                           '1) val_raw','2) val_delta',
                                           '3) val_biascorrected(wk)','4) val_biascorrected(mo)','5) val_biascorrected(yr)'),
                          id.vars=c( "year", "mnDate","jday","type3","mnVal_hind","mnVal_hist","sdVal_hind","sdVal_hist"))
  datsf$value2 <- 1
  
  datbc <- reshape2::melt(suba_bc%>%select(year,mnDate, jday,type3, mnVal_hind,mnVal_hist,sdVal_hind,sdVal_hist,
                                           '1) val_raw','2) val_delta',
                                           '3) val_biascorrected(wk)','4) val_biascorrected(mo)','5) val_biascorrected(yr)'),
                          id.vars=c( "year", "mnDate","jday","type3","mnVal_hind","mnVal_hist","sdVal_hind","sdVal_hist"))
  datbc$value <-  datbc$value
  
  p4 <- ggplot(dat)+
    geom_line(aes(x=jday, y=value,color=factor(year)),show.legend=F)+
    scale_color_manual(values=rep("gray",length(unique(dat$year))))+
    geom_ribbon(aes(x=jday, ymin=mnVal_hind-sdVal_hind,ymax=mnVal_hind+sdVal_hind),alpha=.2,
                fill="blue")+
   
    # geom_line(aes(x=jday, y=sdVal_hind),color="blue",size=.6,linetype="dashed")+
    geom_line(aes(x=jday, y=mnVal_hind),color="blue",size=1)+
    # geom_line(aes(x=jday, y=sdVal_hist),color="black",size=.6,linetype="dashed")+ 
     geom_line(aes(x=jday, y=mnVal_hist),color="black",size=1)+
    facet_grid(type3~variable)+theme_minimal()+ggtitle(paste0(regIN,"; ", varIN))
  
  p5 <- ggplot()+
   
    geom_line(data=datsf, aes(x=jday, y=value2),color="gray",size=1)+
    geom_line(data=datsf, aes(x=jday, y=value),color="red",size=1)+
    facet_grid(type3~variable)+theme_minimal()+ggtitle(paste0("scaling factor : ",regIN,"; ", varIN))
  p6 <- ggplot()+
    geom_line(data=datbc, aes(x=jday, y=value),color="purple",size=1)+
    facet_grid(type3~variable)+theme_minimal()+ggtitle(paste0("adjustment factor : ",regIN,"; ", varIN))

  return(list(p1=p1,p2=p2,p3=p3,p4=p4,p5=p5,p6=p6, minmax_x = minmax_x, minmax_y =minmax_y))
}