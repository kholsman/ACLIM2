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
thinline     <- 0.8
alpha_annual <- 0.8

pal <- colorRampPalette(RColorBrewer::brewer.pal(9,"Spectral")[5:9])
pal <- pal(length(allyears))
#pal[allyears<2005] <- RColorBrewer::brewer.pal(9,"Greys")[3]
pal_sub   <- pal[which(allyears%in%subyear)]
#RColorBrewer::display.brewer.all()
gg <- viridis::viridis(7)[2]
pal  <- RColorBrewer::brewer.pal(9,"Spectral")[c(7,1,8,2,9,3)]
palg <- rep(gg,length(pal))

# test<-dat_s%>%mutate(bc_mn_val = biascorrect(B = mn_val, 
#             mnA = mnVal_hind, 
#             sdA = sdVal_hind, 
#             sdB = sdVal_hist,
#             mnB = mnVal_hist))
#alpha_annual <- .4

varIN     <- "temp_bottom5m"
varIN     <- "pH_bottom5m"
ylab      <- unique(dat%>%filter(var%in%varIN)%>%select(units ))
sub_title <- unique(dat%>%filter(var%in%varIN)%>%select(var ))
seasonIN  <- c("Fall","Spring", "Summer", "Winter")
fut <- dat_s%>% filter(scen%in%scensIN,basin == basinIN,
                       season_var%in%season_varIN)
hind <- dat_mn_s_hind%>% filter(scen%in%scensIN,basin == basinIN,
                                season_var%in%season_varIN)

pp<- ggplot()+
 
  # scale_color_manual(values = palg)+
  # guides(color = "none", size = "none")+
  # new_scale_color()+

  # geom_smooth(data=fut,formula = "y~x",
  #             aes(x=year,y=val_biascorrected, fill = scen)
  #             ,alpha = .4, method = "loess")+
  # guides(color = "none", size = "none")+
  # new_scale_color()+
  geom_line(data=fut,
            aes(x=year,y=val_biascorrected,color=gcmscen),
            alpha=alpha_annual,size=thinline, show.legend = TRUE)+
  geom_line(data=hind,
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
  ylab(ylab)+
  xlab("Day of year")+
  facet_grid(var~scen,scales="free_y")+ 
  labs(title = paste(basinIN, "Climate projections"),
       subtitle = "",
       caption = strwrap (" Operational hindcasts: AK IEA | Projections: ACLIM2 | Model: Bering10K 30-layer",width = 150))+
  theme_kir_EBM()+theme_minimal()+ theme(legend.position="bottom") #+xlim(0,364)
pp
#     return(pp)
# }

