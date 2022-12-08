#'
#'
#'
#'
#'
#' plot_annual
#' 

plot_annual <-function(
  datIN = dat_s,
  datIN_hind = dat_mn_s_hind,
  basinIN ="NEBS",
  addloess = T,
  season_varIN = c('Summer SST' ="Summer_temp_surface5m",
                   'Summer BT' = "Summer_temp_bottom5m" ),
  smoothyr     = 10,
  loesscol     = NULL,
  loess_line   = 0.8,
  thinline     = 0.8,
  futline      = 0.5,
  alpha_loess  = 0.4,
  alpha_fut    = 0.5, 
  alpha_annual = 0.8){
  
  pal <- colorRampPalette(RColorBrewer::brewer.pal(9,"Spectral")[5:9])
  pal <- pal(length(allyears))
  pal_sub   <- pal[which(allyears%in%subyear)]
  gg <- viridis::viridis(7)[2]
  pal  <- RColorBrewer::brewer.pal(9,"Spectral")[c(7,1,8,2,9,3)]
  palg <- rep(gg,length(pal))
  
  
  varIN     <- "temp_bottom5m"
  varIN     <- "pH_bottom5m"
  ylab      <- unique(dat%>%filter(var%in%varIN)%>%select(units ))
  sub_title <- unique(dat%>%filter(var%in%varIN)%>%select(var ))
  seasonIN  <- c("Fall","Spring", "Summer", "Winter")
  
  scen_lab <- data.frame(scen= c("ssp126","ssp585"),
                         lab = factor(c("High mitigation scenario (ssp126)","Low mitigation scenario (ssp585)"),
                                      levels = c("High mitigation scenario (ssp126)","Low mitigation scenario (ssp585)")))
  var_lab <- melt(season_varIN)%>%rename(season_var=value)
  var_lab$varlab <- rownames(var_lab)
  var_lab$season_var <- factor(var_lab$season_var,levels = season_varIN)
  var_lab$varlab <- factor(var_lab$varlab,levels = var_lab$varlab)
  
  fut <- datIN%>% filter(scen%in%scensIN,basin == basinIN,
                         season_var%in%season_varIN)%>%
    left_join(scen_lab)%>%left_join(var_lab)
  hind <- datIN_hind%>% filter(scen%in%scensIN,basin == basinIN,
                                  season_var%in%season_varIN)%>%
    left_join(scen_lab)%>%left_join(var_lab)
  

    # pp<- ggplot()+
    # scale_color_manual(values = palg)+
    # guides(color = "none", size = "none")+
    # new_scale_color()+
  
    # geom_smooth(data=fut,formula = "y~x",
    #             aes(x=year,y=val_biascorrected, fill = scen)
    #             ,alpha = .4, method = "loess")+
    # guides(color = "none", size = "none")+
    # new_scale_color()+
  if(is.null(loesscol)) loesscol = gg
  nyr<-length(unique(fut$year))
    pp <- ggplot()+
    geom_line(data=fut,
              aes(x=year,y=val_biascorrected,color=gcmscen),
              alpha=alpha_fut,size=futline, show.legend = TRUE)
    if(addloess){
      pp <-  pp +geom_smooth(data=fut,
                             aes(x=year,y=val_biascorrected,fill=scen),color = loesscol,
                             alpha = alpha_loess,size=loess_line,
                             formula = 'y ~ x',span = smoothyr/nyr, method="loess")
    }
    pp <- pp+ geom_line(data=hind,
              aes(x=year,y=mn_val),color=gg,
              alpha=alpha_annual,size=thinline, show.legend = FALSE)+
    geom_line(data=hind,
              aes(x=year,y=mnVal_hind),color=gg,
              alpha=alpha_annual,size=thinline, show.legend = FALSE)+
    geom_line(data=hind,
              aes(x=year,y=mnVal_hind+sdVal_hind),color=gg,linetype="dashed",
              alpha=alpha_annual,size=thinline*.9, show.legend = FALSE)+
    geom_line(data=hind,
              aes(x=year,y=mnVal_hind-sdVal_hind),color=gg,linetype="dashed",
              alpha=alpha_annual,size=thinline*.9, show.legend = FALSE)+
    geom_line(data=fut,
              aes(x=year,y=mnVal_hind),color=gg,
              alpha=alpha_annual,size=thinline, show.legend = FALSE)+
    geom_line(data=fut,
              aes(x=year,y=mnVal_hind+sdVal_hind),color=gg,linetype="dashed",
              alpha=alpha_annual,size=thinline*.9, show.legend = FALSE)+
    geom_line(data=fut,
              aes(x=year,y=mnVal_hind-sdVal_hind),color=gg,linetype="dashed",
              alpha=alpha_annual,size=thinline*.9, show.legend = FALSE)+
    scale_color_manual(values = pal)+
    scale_fill_manual(values = pal[c(5,4)])+
    ylab(ylab)+
    xlab("Year")+
    facet_grid(varlab~lab,scales="free_y")+ 
    labs(title = paste(basinIN, "Climate projections"),
         subtitle = "",
         caption = strwrap (" Operational hindcasts: AK IEA | Projections: ACLIM2 | Model: Bering10K 30-layer",width = 150))+
    theme_kir_EBM()+theme_minimal()+ theme(legend.title= element_blank(),legend.position="bottom") #+xlim(0,364)
    
    
      return(list(pp=pp,fut=fut,hind=hind ))
}

