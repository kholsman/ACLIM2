#'
#'
#'
#'plotNEBS_productivity.R
#'
#'

plotNEBS_productivity<- function(varlistIN = c("largeZoop_integrated"),fldr = "K20P19_CMIP6/allEBS_means",
                                 var_defIN = weekly_var_def){
  load(file.path("Data/out",fldr,"ACLIM_weekly_hind_mn.Rdata"))
  datIN <- ACLIM_weekly_hind%>%filter(var%in%varlistIN)
  datIN <- datIN%>%left_join(var_defIN)
  ggplot(datIN)+
    geom_line(aes(x=mnDate,y = mn_val,color=basin),size=.9)+
    facet_grid(basin~.)+theme_minimal()
    
datIN2 <- datIN%>%filter(year<2020)%>%group_by(var,units,sim,basin,type,sim_type,year,season)%>%
  summarize(mnVal = mean(mn_val,na.rm=T))

ggplot(datIN2)+
  geom_line(aes(x=year,y = mnVal,color=basin),size=.9)+ylab(datIN2$units[1])+
  facet_grid(season~basin)+theme_minimal()+ggtitle(varlistIN)

}