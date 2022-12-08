#'
#'
#'
#'
#'
#'make_GWLplot
#'
#'This function makes a plot of variables by GWL levels
#'

make_GWLplot <- function(
  ylablkupIN = ylablkup,
  titleIN = "",
  subtitleIN = "",
  cmipIN = cmip6,
  datIN  = dat_s,
  datIN_hind = ACLIM_seasonal_hind ){
  
  
  GWLs <- c("(2010-2021)", paste("+",sort(unique(cmipIN$warming_level))))

  test <- datIN%>%filter(season_var%in%ylablkupIN$season_var)%>%
    mutate(GWL = NA)%>%
    fuzzyjoin::fuzzy_left_join(cmipIN,
                               by = c(
                                 "scen" = "exp",
                                 "GCM"  = "GCM",
                                 "year" = "mnSTyr",
                                 "year" = "mnENDyr"
                               ),
                             match_fun = list(`==`, `==`, `>=`, `<=`))%>%
  mutate(GWL = factor(paste("+",warming_level),levels = GWLs))%>%
  select(basin,val = val_biascorrected,var,scen,season,
         GCM = GCM.x,season_var,gcmscen, warming_level,GWL)

  test_hind <- datIN_hind%>%
    mutate(
      gcmscen = paste0(GCM,"_",scen),
      season_var = paste0(season,"_",var))%>%
    filter(year>=2010,season_var%in%ylablkupIN$season_var)%>%
    mutate(GWL = factor(GWLs[1],levels = GWLs),warming_level=1.08)%>%
    select(basin, val = mn_val,var,scen,season,
           GCM,season_var,gcmscen, warming_level,GWL)
  
  test2 <-rbind(test_hind,test)%>%
    mutate(
      basin = factor(basin, levels = c("SEBS","NEBS")))%>%
    left_join(data.frame(ylablkupIN))
  
  p_gwl<-  ggplot(test2%>%filter(!is.na(GWL),season =="Summer"),aes(x = GWL,y =val,fill = basin ))+
    #geom_violin( aes(color = basin),width=.9) +
    #geom_boxplot(width=0.6, color="grey", alpha=0.9)+
    geom_boxplot()+
    facet_grid(.~lab, scales = "free_y")+
    scale_fill_viridis_d(begin=.3,end =.6)+
    scale_color_viridis_d(begin=.3,end =.6)+
    ylab("EBS modeled temperature (oC)")+
    xlab(bquote("\nGlobal Warming Levels (+ oC relative to [1850-1900])"))+
    theme_kir_EBM()+
    #coord_cartesian(ylim=c(0,16))+
    theme_minimal()+
    theme(legend.position="none",
          plot.title = element_text(color="gray30"),
          plot.caption = element_text(color="gray30")) +
    labs(title = titleIN,
         subtitle = subtitleIN,
         caption = strwrap (" Operational hindcasts: AK IEA | Projections: ACLIM2 | Model: Bering10K 30-layer",width = 150))+
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+
    ggtitle(titleIN)+
    theme(legend.position="bottom")
  p_gwl
  
  
  
  smry <- test2%>%group_by(GWL,season_var, season,var,basin)%>%
               summarize(mn = mean(val, na.rm=TRUE),
               sd = sd(val, na.rm = TRUE))
  
  return(list(pp = p_gwl, out = test2,summary = smry))
}

