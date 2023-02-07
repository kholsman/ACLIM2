#'
#'
#'
#'plotNEBS_productivity.R
#'
#'

# suppressMessages(source("R/make.R"))
# fldr = "K20P19_CMIP6/allEBS_means"
# load(file.path("Data/out",fldr,"ACLIM_weekly_hind_mn.Rdata"))
# library(dplyr)
# library(ggplot)
# load("Data/out/weekly_vars.Rdata")
# source("R/make.R")

plotNEBS_productivity<- function(datIN=ACLIM_weekly_hind,angleIN=90,
                                 basinIN = c("SEBS","NEBS"),
                                 varlistIN = vardef[61,]){

  datIN     <- datIN%>%filter(var%in%varlistIN$name, basin%in%basinIN)
  # var_defIN  <- var_defIN%>%rename(var=name)
  # datIN     <- datIN%>%left_join(var_defIN)
  if(varlistIN$name %in% c("aice", "fracbelow0","fracbelow1","fracbelow2" )){
    datIN$mn_val[datIN$mn_val<0] <-0
    datIN$mn_val[datIN$mn_val>1] <-1
  }
  if(!varlistIN$name %in% c( "pH",
                      "temp",
                      "Ben",
                      "Hsbl",
                      "shflux",
                      "ssflux",
                      "vNorth",
                      "uEast")){
    datIN$mn_val[datIN$mn_val<0] <-0
    
  }
  
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
    facet_grid(season~basin)+theme_minimal()+
    theme(axis.text.x = element_text(angle = angleIN))+
    scale_fill_viridis_d(end = .5, begin =.2)+
    scale_color_viridis_d(end = .5, begin =.2)+
    labs(title = varlistIN$name,
         subtitle = varlistIN$longname,
         caption = "ACLIM2 2023")
  
  return(list(p1=p1,p2=p2))
    
}

plotNEBS_productivity_fut<- function(datIN=ACLIM_weekly_hind,
                                     datIN_fut=ACLIM_weekly_fut,angleIN=90,
                                     basinIN = c("SEBS","NEBS"),alphaIN =0.5,
                                 varlistIN = vardef[61,]){
  
  varlistIN$longname
  dat1     <- datIN%>%
    filter(var%in%varlistIN$name, basin%in%basinIN, year <2020)%>%
    select(var,units,basin,sim, year, season,mn_val, GCM, scen, CMIP,sim_type,type)%>%rename(val=mn_val)
  dat2 <- datIN_fut%>%filter(var%in%varlistIN$name, basin%in%basinIN, year >2014)%>%
    select(var,units,basin,sim, year, season,val_biascorrected, GCM, scen, CMIP,sim_type,type )%>%
    rename(val=val_biascorrected )
  # var_defIN  <- var_defIN%>%rename(var=name)
  # datIN     <- datIN%>%left_join(var_defIN)
  dat <- rbind(dat1,dat2)
  if(varlistIN$name %in% c("aice", "fracbelow0","fracbelow1","fracbelow2" )){
    dat$val[dat$val<0] <-0
    dat$val[dat$val>1] <-1
  }
  if(!varlistIN$name%in% c( "pH",
     "temp",
     "Ben",
     "Hsbl",
     "shflux",
     "ssflux",
     "vNorth",
     "uEast")){
    dat$val[dat$val<0] <-0
    
  }
  
 
  # datIN2  <- dat%>%group_by(var,units,sim,basin,type,GCM, scen, CMIP,sim_type,year,season)%>%
  #   summarize(mnVal = mean(val,na.rm=T))%>%mutate(GCM = factor(GCM, levels =c("hind","gfdl","miroc","cesm")))
  # mn <- dat1%>%filter(year<2001)%>%group_by(var,units,sim,basin,type,GCM, scen, CMIP,sim_type,season)%>%
  #   summarize(mnVal = mean(val,na.rm=T))
  # mn <- dat%>%
  #   filter(var%in%varlistIN$name, basin%in%basinIN,year<2001)%>%
  #   group_by(var,units,sim,basin,type,sim_type,season)%>%
  #   summarize(mnVal = mean(mn_val,na.rm=T))%>%mutate(scen="hind")
  # 
  
  mn_all <- dat%>%
    group_by(var,units,basin,type,scen, CMIP,sim_type,year,season)%>%
    summarize(mnVal = mean(val,na.rm=T),
              sdVal = sd(val, na.rm = T),
              n     = length(val))%>%
    mutate(seVal = sdVal/sqrt(n),
           upper = mnVal+1.95*seVal,
           lower = mnVal-1.95*seVal)
  mn_all_mn <- mn_all%>%group_by(var,units,basin,type,scen, CMIP,sim_type,season)%>%
    filter(scen=="hind")%>%
    summarize(mnVal = mean(mnVal, na.rm = T),
              upper = mean(upper, na.rm = T),
              lower = mean(lower, na.rm = T))
  
  # if(mn_all$var %in% c("aice", "fracbelow0","fracbelow1","fracbelow2" )){
  # 
  #   mn_all$mnVal[mn_all$mnVal<0] <-0
  #   mn_all$upper[mn_all$upper<0] <-0
  #   mn_all$lower[mn_all$lower<0] <-0
  #   mn_all$mnVal[mn_all$mnVal>1] <-1
  #   mn_all$upper[mn_all$upper>1] <-1
  #   mn_all$lower[mn_all$lower>1] <-1
  # }
  # if(!mn_all$var %in% c( "pH",
  #                     "temp",
  #                     "Ben",
  #                     "Hsbl",
  #                     "shflux",
  #                     "ssflux",
  #                     "vNorth",
  #                     "uEast")){
  #   mn_all$mnVal[mn_all$mnVal<0] <-0
  #   mn_all$upper[mn_all$upper<0] <-0
  #   mn_all$lower[mn_all$lower<0] <-0
  #   
  # }
  p1  <-ggplot()+
    #geom_line(data=datIN2%>%filter(GCM=="hind"),aes(x=year,y = mnVal,color=scen),size=.8,alpha=.8)+
    ylab(dat$units[1])+
    geom_ribbon(data = mn_all%>%filter(scen=="hind"), aes(x = year, ymin = lower,ymax = upper, fill = scen),alpha = alphaIN)+
    geom_hline(data = mn_all_mn%>%filter(scen=="hind"), aes(yintercept = mnVal, color = scen),linetype="solid",size=.8)+
    geom_line(data = mn_all%>%filter(scen=="hind"), aes(x = year,y = mnVal,color = scen),size=1)+
    ylab(dat$units[1])+
    facet_grid(season~basin,scales="free_y")+
    theme_minimal()+
    #ggtitle(varlistIN)+
    theme(axis.text.x = element_text(angle = angleIN))+
    scale_fill_viridis_d(end = .2, begin =.7)+
    scale_color_viridis_d(end = .2, begin =.7)+
    labs(title = varlistIN$name,
         subtitle = varlistIN$longname,
         caption = "ACLIM2 2023")
  p2  <-ggplot()+
    #geom_line(data=datIN2%>%filter(GCM=="hind"),aes(x=year,y = mnVal,color=scen),size=.8,alpha=.8)+
    ylab(dat$units[1])+
     geom_hline(data = mn_all_mn, aes(yintercept = mnVal, color = scen),linetype="solid",size=.8)+
    geom_ribbon(data = mn_all%>%filter(scen!="hind"), aes(x = year, ymin = lower,ymax = upper, fill = scen),alpha = alphaIN)+
    geom_line(data = mn_all%>%filter(scen!="hind"), aes(x = year,y = mnVal,color = scen),size=1)+
    geom_ribbon(data = mn_all%>%filter(scen=="hind"), aes(x = year, ymin = lower,ymax = upper, fill = scen),alpha = alphaIN)+
    geom_line(data = mn_all%>%filter(scen=="hind"), aes(x = year,y = mnVal,color = scen),size=1)+
    ylab(dat$units[1])+
    facet_grid(season~basin,scales="free_y")+
    theme_minimal()+
    #ggtitle(varlistIN)+
    theme(axis.text.x = element_text(angle = angleIN))+
    scale_fill_viridis_d(end = .2, begin =.7)+
    scale_color_viridis_d(end = .2, begin =.7)+
    labs(title = varlistIN$name,
         subtitle = varlistIN$longname,
         caption = "ACLIM2 2023")
  
  return(list(p1=p1,p2=p2))
  
}
if(1==10){
  load("Data/out/K20P19_CMIP6/allEBS_means/ACLIM_weekly_hind_mn.Rdata")
  
  load("Data/out/K20P19_CMIP6/allEBS_means/ACLIM_weekly_fut_mn.Rdata")
  varz <- unique(ACLIM_weekly_hind$var)
  vardef <- rbind(weekly_var_def,data.frame(name = "largeZoop_integrated", units = "(mg C m^-3)*m", 
                                            longname = "On-shelf euph. + large cop., integrated over depth" ))
  vardef <- rbind(vardef,
                  data.frame(name = varz[which(!varz%in%vardef$name)],units = "",longname=""))
  
  vardef <- vardef%>%filter(name%in%unique(ACLIM_weekly_hind$var))
 
  i <-61
  w<-9; h<-6; dpi <-350
  w2<-6; h2<-4 
  sclr <- 1.3
   for(i in 1:length(vardef$name)){
   
    lgn <- vardef[i,]$longname
    vv  <- vardef[i,]$name
    unt <- vardef[i,]$units
      cat(vv,"\n")
    
    fldrout <- "Figs/prod_plots"
    if(!dir.exists(fldrout))
      dir.create(fldrout)

    tmp <- suppressMessages(plotNEBS_productivity(datIN=ACLIM_weekly_hind,
                                                  varlistIN=vardef[i,]))
    tmp2 <- suppressMessages(plotNEBS_productivity_fut(datIN=ACLIM_weekly_hind,
                                                      datIN_fut=ACLIM_weekly_fut,
                                                      varlistIN=vardef[i,]))
    
    jpeg(file.path(fldrout,paste0(vv,".jpg")),width = w, height=h, res=dpi, units="in")
    print(tmp$p2)
    dev.off()
   
    
    fldrout <- "Figs/prod_plots"
    if(!dir.exists(fldrout))
      dir.create(fldrout)
   
    jpeg(file.path(fldrout,paste0(vv,"_fut.jpg")),width = w*sclr, height=h*sclr, res=dpi, units="in")
    print(tmp2$p2)
    dev.off()
    jpeg(file.path(fldrout,paste0(vv,"_hind.jpg")),width = w2*sclr, height=h2*sclr, res=dpi, units="in")
    print(tmp2$p1)
    dev.off()
    rm(tmp2)
    rm(tmp)
  }

}

