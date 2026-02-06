#'
#'
#'
#'
#'
#' plot_weekly
#' #' 
#' # plot_weekly <- function(dat      = dat,
#' #                         dat_hind = dat_hind,
#'                         allyears = allyears
#'                         hindyrs  = hindyrs
#'                         futyrs   = futyrs
#'                         # scensIN    = scens,
#'                         # GCMsIN     = GCMs,
#'                         # varIN      = plot_vars[3],
#'                         basinIN    = "SEBS"#){
#'     
plot_weekly <- function( datIN = dat, 
                         dat_hindIN = dat_mn_hind, 
                         datIN_sub  = dat_sub,
                         datIN_mn_hind_sub = dat_mn_hind_sub,
                         varIN,  
                         subyear = seq(1970,2090,10),
                         useBiascorrected=FALSE,
                         basinIN = "SEBS", 
                         titleIN = ""){
   
    pal <- colorRampPalette(RColorBrewer::brewer.pal(9,"Spectral")[5:9])
    pal <- pal(length(allyears))
    pal[allyears<2005] <- RColorBrewer::brewer.pal(9,"Greys")[3]
    pal_sub   <- pal[which(allyears%in%subyear)]
    #RColorBrewer::display.brewer.all()
    
    
    ylab      <- unique(datIN%>%filter(var%in%varIN)%>%select(units ))
    #sub_title <- unique(datIN%>%filter(var%in%varIN)%>%select(var ))
    
    scen_lab <- data.frame(scen= c("ssp126","ssp585"),
                           lab = factor(c("High mitigation scenario (ssp126)","Low mitigation scenario (ssp585)"),
           levels = c("High mitigation scenario (ssp126)","Low mitigation scenario (ssp585)")))
    
    grplist <- c("var","sim","basin","type","sim_type","jday",
                 # "lognorm", "total_area_km2",
                 "gcmcmip","CMIP","GCM","scen", "mod")
    #, "units","longname","lab"  )
    length.na <- function(x,na.rm=F){
      if(na.rm){
        x <- as.numeric(na.omit(x))
      }
      length(x)
    }
    se <- function(x, na.rm=T){
      if(na.rm){
        x <- as.numeric(na.omit(x))
      }
      if(length(x)>0){
        sd(x)/sqrt(length(x))
      }else{
        0
      }
      
    }
    # mndat<- 
    #   dhind%>%group_by(!!!syms(grplist))%>%
    #   summarize(mn= mean(mn_val,na.rm = T),
    #             sd= sd(mn_val,na.rm = T),
    #             se= se(mn_val,na.rm = T),
    #             n= length.na(mn_val,na.rm = T),
    #             mn= mean(mn_val,na.rm = T),
    #             mn_hind= mean(mnVal_hind,na.rm = T))
    # 
    
    dhind <- dat_hindIN%>%
      filter(var==varIN,basin==basinIN,scen%in%scensIN)%>%left_join(scen_lab)
    # mndat<- 
    #   dhind%>%group_by(!!!syms(grplist))%>%
    #   summarize(mnVal_hind2 = mean(mn_val,na.rm = T),
    #             mn_hind= mean(mnVal_hind,na.rm = T),
    #             sdVal_hind = sd(mn_val,na.rm = T),
    #             seVal_hind = se(mn_val,na.rm = T),
    #             n = length.na(mn_val,na.rm = T))
    # dhind <- dhind%>%left_join(mndat)
    
    dfut <- datIN%>%
      filter(var%in%varIN,basin==basinIN,scen%in%scensIN)%>%left_join(scen_lab)
    dfut_sub <- datIN_sub%>%
      filter(var%in%varIN,basin==basinIN,scen%in%scensIN)%>%left_join(scen_lab)
    dhind_sub <- datIN_mn_hind_sub%>%
      filter(var%in%varIN,basin==basinIN,scen%in%scensIN)%>%left_join(scen_lab)
    
    pp<- ggplot()+
      geom_line(data=dhind,
                aes(x=jday,y=mn_val, color=yrFactor),
                alpha=alpha_annual,size=thinline, show.legend = FALSE)
   
    if(useBiascorrected){
      pp <- pp + geom_line(data=dfut,
                aes(x=jday,y=val_biascorrected,color=yrFactor),
                alpha=alpha_annual,size=thinline, show.legend = FALSE)+
        geom_line(data=dfut_sub,
                  aes(x=jday,y=val_biascorrected,color=yrFactor ),
                  alpha=.8,size=1.2, show.legend = TRUE)+ 
        scale_color_manual(values = pal)+
       # guides(color = "none", size = "none")+
        new_scale_color()+
        geom_line(data=dhind_sub%>%filter(year == 2010),
                  aes(x=jday,y=mn_hind,color=yrFactor  ),
                  #color=RColorBrewer::brewer.pal(9,"Spectral")[1],
                  alpha=.8,size=1.2, show.legend = FALSE)+
        geom_line(data=dhind_sub%>%filter(year == 2010),
                  aes(x=jday,y=mn_hind +sd_val,color=yrFactor  ),linetype = "dashed",
                  #color=RColorBrewer::brewer.pal(9,"Spectral")[1],
                  alpha=.8,size=.9, show.legend = FALSE)+
        geom_line(data=dhind_sub%>%filter(year == 2010),
                  aes(x=jday,y=mn_hind-sd_val,color=yrFactor  ),linetype = "dashed",
                  #color=RColorBrewer::brewer.pal(9,"Spectral")[1],
                  alpha=.8,size=.9, show.legend = FALSE)
      sub_title = "bias-corrected"
    }
    if(!useBiascorrected){
      lvls    <- levels(dfut$yrFactor)
      lvls[1] <- "[1980-2013] Historical"
        
      dfut2 <- dfut%>%filter(year == 2015)%>%
        mutate(yrFactor=factor("[1980-2013] Historical",
                               levels=lvls))
      
      sub_title = "not bias-corrected"
      pp <- pp + geom_line(data=dfut,
                           aes(x=jday,y=mn_val,color=yrFactor),
                           alpha=alpha_annual,size=thinline, show.legend = FALSE)+
        geom_line(data=dfut_sub,
                  aes(x=jday,y=mn_val,color=yrFactor ),
                  alpha=.8,size=1.2, show.legend = TRUE)+ 
        scale_color_manual(values = pal)+
      #  guides(color = "none", size = "none")+
        new_scale_color()+
        geom_line(data=dhind_sub,
                  aes(x=jday,y=mn_hist,color=yrFactor  ),
                  #color=RColorBrewer::brewer.pal(9,"Spectral")[1],
                  alpha=.8,size=1.2, show.legend = FALSE)+
        geom_line(data=dhind_sub,
                  aes(x=jday,y=mn_hist +sd_val_hist,color=yrFactor  ),linetype = "dashed",
                  #color=RColorBrewer::brewer.pal(9,"Spectral")[1],
                  alpha=.8,size=.9, show.legend = FALSE)+
        geom_line(data=dhind_sub,
                  aes(x=jday,y=mn_hist-sd_val_hist,color=yrFactor  ),linetype = "dashed",
                  #color=RColorBrewer::brewer.pal(9,"Spectral")[1],
                  alpha=.8,size=.9, show.legend = FALSE)
          }
      pp <- pp + scale_color_manual(name = "",
                                    values = c(viridis::viridis(3)[1],pal_sub[subyear%in%datIN_sub$year]))+
      ylab(ylab)+
      xlab("Day of year")+
      facet_grid(GCM~lab)+ 
      labs(title = titleIN,
           subtitle = sub_title,
           caption = strwrap (" Operational hindcasts: AK IEA | Projections: ACLIM2 | Model: Bering10K 30-layer",width = 150))+
      theme_kir_EBM()+theme_minimal() + theme(legend.position="none") #+xlim(0,364)
 return(pp)
}

