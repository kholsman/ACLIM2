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
plot_weekly <- function( varIN,  basinIN    = "SEBS"){
    pal <- colorRampPalette(RColorBrewer::brewer.pal(9,"Spectral")[5:9])
    pal <- pal(length(allyears))
    pal[allyears<2005] <- RColorBrewer::brewer.pal(9,"Greys")[3]
    pal_sub   <- pal[which(allyears%in%subyear)]
    #RColorBrewer::display.brewer.all()
    
    
    ylab      <- unique(dat%>%filter(var%in%varIN)%>%select(units ))
    sub_title <- unique(dat%>%filter(var%in%varIN)%>%select(var ))
    
    
    pp<- ggplot()+
      geom_line(data=dat_mn_hind%>%
                  filter(var==varIN,basin==basinIN,scen%in%scensIN),
                aes(x=jday,y=mn_val, color=yrFactor),
                alpha=alpha_annual,size=thinline, show.legend = FALSE)+
      geom_line(data=dat%>%
                  filter(var%in%varIN,basin==basinIN,scen%in%scensIN),
                aes(x=jday,y=mn_val,color=yrFactor),
                alpha=alpha_annual,size=thinline, show.legend = FALSE)+
      scale_color_manual(values = pal)+
      guides(color = "none", size = "none")+
      new_scale_color()+
      geom_line(data=dat_sub%>%
                  filter(var%in%varIN,basin==basinIN,scen%in%scensIN),
                aes(x=jday,y=mn_val,color=yrFactor ),
                alpha=.8,size=1.2, show.legend = TRUE)+
      geom_line(data=dat_mn_hind_sub%>%
                  filter(year == 2010,var%in%varIN,basin==basinIN,scen%in%scensIN),
                aes(x=jday,y=mnVal_hind,color=yrFactor  ),
                #color=RColorBrewer::brewer.pal(9,"Spectral")[1],
                alpha=.8,size=1.2, show.legend = FALSE)+
      geom_line(data=dat_mn_hind_sub%>%
                  filter(year == 2010,var%in%varIN,basin==basinIN,scen%in%scensIN),
                aes(x=jday,y=mnVal_hind +sdVal_hind,color=yrFactor  ),linetype = "dashed",
                #color=RColorBrewer::brewer.pal(9,"Spectral")[1],
                alpha=.8,size=.9, show.legend = FALSE)+
      geom_line(data=dat_mn_hind_sub%>%
                  filter(year == 2010,var%in%varIN,basin==basinIN,scen%in%scensIN),
                aes(x=jday,y=mnVal_hind-sdVal_hind,color=yrFactor  ),linetype = "dashed",
                #color=RColorBrewer::brewer.pal(9,"Spectral")[1],
                alpha=.8,size=.9, show.legend = FALSE)+
      scale_color_manual(name = "",
                         values = c(viridis::viridis(3)[1],pal_sub[subyear%in%dat_sub$year]))+
      ylab(ylab)+
      xlab("Day of year")+
      facet_grid(GCM~scen)+ 
      labs(title = paste(basinIN, "Climate projections"),
           subtitle = sub_title,
           caption = strwrap (" Projections: ACLIM2 |Operational hindcasts: AK IEA | Model: Bering10K 30-layer",width = 150))+
      theme_kir_EBM()+theme_minimal() + theme(legend.position="bottom") #+xlim(0,364)
 return(pp)
}

