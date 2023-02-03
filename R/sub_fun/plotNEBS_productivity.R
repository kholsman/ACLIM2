#'
#'
#'
#'plotNEBS_productivity.R
#'
#'
fldr = "K20P19_CMIP6/allEBS_means"
load(file.path("Data/out",fldr,"ACLIM_weekly_hind_mn.Rdata"))
library(dplyr)
library(ggplot)
plotNEBS_productivity<- function(datIN=ACLIM_weekly_hind,angleIN=90,
                                 varlistIN = c("largeZoop_integrated")){

  datIN     <- datIN%>%filter(var%in%varlistIN)
  # var_defIN  <- var_defIN%>%rename(var=name)
  # datIN     <- datIN%>%left_join(var_defIN)
  
  p1  <-  ggplot(datIN)+
      geom_line(aes(x=mnDate,y = mn_val,color=basin),size=1.1)+
      facet_grid(basin~.)+theme_minimal()
      
  datIN2  <- datIN%>%filter(year<2020)%>%group_by(var,units,sim,basin,type,sim_type,year,season)%>%
    summarize(mnVal = mean(mn_val,na.rm=T))
  mn <- datIN%>%filter(year<2001)%>%group_by(var,units,sim,basin,type,sim_type,season)%>%
    summarize(mnVal = mean(mn_val,na.rm=T))
  
  
  p2  <-ggplot(datIN2)+
    geom_line(aes(x=year,y = mnVal,color=basin),size=1.1)+ylab(datIN2$units[1])+
    geom_hline(data=mn,aes(yintercept=mnVal, color=basin),linetype="solid",size=.8)+
    facet_grid(season~basin)+theme_minimal()+ggtitle(varlistIN)+theme(axis.text.x = element_text(angle = angleIN))
  
  return(list(p1=p1,p2=p2))
    
}
if(1==10){
  zoop<-plotNEBS_productivity(varlistIN="largeZoop_integrated")
  Cop<-plotNEBS_productivity(varlistIN="Cop_integrated")
  
  NCaS<-plotNEBS_productivity(varlistIN="NCaS_integrated")
  NCaO<-plotNEBS_productivity(varlistIN="NCaO_integrated")
  
  for(vv in normlist$var){
    fldrout <- "Figs/prod_plots"
    if(!dir.exists(fldrout))
      dir.create(fldrout)
    w<-8; h<-5; dpi <-350
    tmp <- suppressMessages(plotNEBS_productivity(varlistIN=vv))
  
    jpeg(file.path(fldrout,paste0(vv,".jpg")),width = w, height=h, res=dpi, units="in")
    print(tmp$p2)
    dev.off()
    rm(tmp)
  }

}

dev.off()



"Cop_integrated"