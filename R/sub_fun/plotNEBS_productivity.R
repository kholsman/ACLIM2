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
    select(var,units,basin,sim, year, season,mn_val, GCM,gcmcmip, scen, CMIP,sim_type,type)%>%
    mutate(val = mn_val)%>%rename(val_biascorrected=mn_val)
  dat2 <- datIN_fut%>%filter(var%in%varlistIN$name, basin%in%basinIN, year >2014)%>%
    select(var,units,basin,sim, year, season,val_biascorrected, GCM,gcmcmip, scen, CMIP,sim_type,type,val_delta)%>%
    rename(val=val_delta )
    #rename(val=val_biascorrected )
  # var_defIN  <- var_defIN%>%rename(var=name)
  # datIN     <- datIN%>%left_join(var_defIN)
  dat <- rbind(dat1,dat2)
  sub_name <- strsplit(varlistIN$name,"_")[[1]][1]
  if(varlistIN$name %in% c("aice", "fracbelow0","fracbelow1","fracbelow2" )){
    dat$val[dat$val<0] <-0
    dat$val[dat$val>1] <-1
  }

  if(!sub_name%in%c( "pH",
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
           upper = mnVal+1*sdVal,
           lower = mnVal-1*sdVal,
           upper2 = mnVal+1.95*seVal,
           lower2 = mnVal-1.95*seVal)
  
  mn_all_mn <- mn_all%>%group_by(var,units,basin,type,scen, CMIP,sim_type,season)%>%
    filter(scen=="hind")%>%
    summarize(mnVal = mean(mnVal, na.rm = T),
              upper = mean(upper, na.rm = T),
              lower = mean(lower, na.rm = T))
  
  mfun<-function(x){
    out <- x
    for(i in 1:length(x)){
      out[i]<- strsplit(x[i],"ACLIMregion_B10K-K20P19_")[[1]][2]
    }
   return(out)
  }
  mn_allGCM <- dat%>%mutate(sub_sim = mfun(sim))%>%
    group_by(var,units,basin,type,scen,gcmcmip,GCM, CMIP,sim_type,year,season,sub_sim)%>%
    summarize(mnVal = mean(val,na.rm=T),
              sdVal = sd(val, na.rm = T),
              n     = length(val))%>%
    mutate(seVal = sdVal/sqrt(n),
           upper = mnVal+1*sdVal,
           lower = mnVal-1*sdVal,
           upper2 = mnVal+1.95*seVal,
           lower2 = mnVal-1.95*seVal)
  
  
  mn_allGCM_mn <- mn_allGCM%>%
    group_by(var,units,basin,type,scen,gcmcmip,GCM, CMIP,sim_type,season,sub_sim)%>%
    filter(scen=="hind")%>%
    mutate(seVal = sdVal/sqrt(n),
           upper = mnVal+1.95*seVal,
           lower = mnVal-1.95*seVal)
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
    labs(title = paste(varlistIN$name,", Delta corrected"),
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
    labs(title = paste(varlistIN$name,", Delta corrected"),
         subtitle = varlistIN$longname,
         caption = "ACLIM2 2023")
  p3  <-ggplot()+
    #geom_line(data=datIN2%>%filter(GCM=="hind"),aes(x=year,y = mnVal,color=scen),size=.8,alpha=.8)+
    ylab(dat$units[1])+
    geom_hline(data = mn_allGCM_mn, aes(yintercept = mnVal, color = scen),linetype="solid",size=.8)+
    geom_ribbon(data = mn_allGCM%>%filter(scen!="hind"), aes(x = year, ymin = lower,ymax = upper, fill = scen,linetype=GCM),alpha = alphaIN)+
    geom_ribbon(data = mn_allGCM%>%filter(scen=="hind"), aes(x = year, ymin = lower,ymax = upper, fill = scen,linetype=GCM),alpha = alphaIN)+
    geom_line(data = mn_allGCM%>%filter(scen!="hind"), aes(x = year,y = mnVal,color = scen,linetype=GCM),size=1)+
    geom_line(data = mn_allGCM%>%filter(scen=="hind"), aes(x = year,y = mnVal,color = scen,linetype=GCM),size=1)+
    ylab(dat$units[1])+
    facet_grid(season~basin,scales="free_y")+
    theme_minimal()+
    #ggtitle(varlistIN)+
    theme(axis.text.x = element_text(angle = angleIN))+
    scale_fill_viridis_d(end = .2, begin =.7)+
    scale_color_viridis_d(end = .2, begin =.7)+
    labs(title = paste(varlistIN$name,", Delta corrected"),
         subtitle = varlistIN$longname,
         caption = "ACLIM2 2023")
  
  return(list(p1=p1,p2=p2,p3=p3))
  
}

plotNEBS_productivity_futBC<- function(datIN=ACLIM_weekly_hind,
                                     datIN_fut=ACLIM_weekly_fut,angleIN=90,
                                     basinIN = c("SEBS","NEBS"),alphaIN =0.5,
                                     varlistIN = vardef[61,]){
  
  varlistIN$longname
  dat1     <- datIN%>%
    filter(var%in%varlistIN$name, basin%in%basinIN, year <2020)%>%
    select(var,units,basin,sim, year, season,mn_val, GCM,gcmcmip, scen, CMIP,sim_type,type)%>%
    mutate(val_delta = mn_val)%>%rename(val=mn_val)
  dat2 <- datIN_fut%>%filter(var%in%varlistIN$name, basin%in%basinIN, year >2014)%>%
    select(var,units,basin,sim, year, season,val_biascorrected, GCM,gcmcmip, scen, CMIP,sim_type,type,val_delta)%>%
    rename(val=val_biascorrected )
  #rename(val=val_biascorrected )
  # var_defIN  <- var_defIN%>%rename(var=name)
  # datIN     <- datIN%>%left_join(var_defIN)
  dat <- rbind(dat1,dat2)
  sub_name <- strsplit(varlistIN$name,"_")[[1]][1]
  if(varlistIN$name %in% c("aice", "fracbelow0","fracbelow1","fracbelow2" )){
    dat$val[dat$val<0] <-0
    dat$val[dat$val>1] <-1
  }
  
  if(!sub_name%in%c( "pH",
                     "temp",
                     "Ben",
                     "Hsbl",
                     "shflux",
                     "ssflux",
                     "vNorth",
                     "uEast")){
    dat$val[dat$val<0] <-0
    
  }
  

  
  mn_all <- dat%>%
    group_by(var,units,basin,type,scen, CMIP,sim_type,year,season)%>%
    summarize(mnVal = mean(val,na.rm=T),
              sdVal = sd(val, na.rm = T),
              n     = length(val))%>%
    mutate(seVal = sdVal/sqrt(n),
           upper = mnVal+1*sdVal,
           lower = mnVal-1*sdVal,
           upper2 = mnVal+1.95*seVal,
           lower2 = mnVal-1.95*seVal)
  
  mn_all_mn <- mn_all%>%group_by(var,units,basin,type,scen, CMIP,sim_type,season)%>%
    filter(scen=="hind")%>%
    summarize(mnVal = mean(mnVal, na.rm = T),
              upper = mean(upper, na.rm = T),
              lower = mean(lower, na.rm = T))
  
  mfun<-function(x){
    out <- x
    for(i in 1:length(x)){
      out[i]<- strsplit(x[i],"ACLIMregion_B10K-K20P19_")[[1]][2]
    }
    return(out)
  }
  mn_allGCM <- dat%>%mutate(sub_sim = mfun(sim))%>%
    group_by(var,units,basin,type,scen,gcmcmip,GCM, CMIP,sim_type,year,season,sub_sim)%>%
    summarize(mnVal = mean(val,na.rm=T),
              sdVal = sd(val, na.rm = T),
              n     = length(val))%>%
    mutate(seVal = sdVal/sqrt(n),
           upper = mnVal+1*sdVal,
           lower = mnVal-1*sdVal,
           upper2 = mnVal+1.95*seVal,
           lower2 = mnVal-1.95*seVal)
  
  
  mn_allGCM_mn <- mn_allGCM%>%
    group_by(var,units,basin,type,scen,gcmcmip,GCM, CMIP,sim_type,season,sub_sim)%>%
    filter(scen=="hind")%>%
    mutate(seVal = sdVal/sqrt(n),
           upper = mnVal+1.95*seVal,
           lower = mnVal-1.95*seVal)
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
    labs(title = paste(varlistIN$name,", Bias corrected"),
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
    labs(title = paste(varlistIN$name,", Bias corrected"),
         subtitle = varlistIN$longname,
         caption = "ACLIM2 2023")
  p3  <-ggplot()+
    #geom_line(data=datIN2%>%filter(GCM=="hind"),aes(x=year,y = mnVal,color=scen),size=.8,alpha=.8)+
    ylab(dat$units[1])+
    geom_hline(data = mn_allGCM_mn, aes(yintercept = mnVal, color = scen),linetype="solid",size=.8)+
    geom_ribbon(data = mn_allGCM%>%filter(scen!="hind"), aes(x = year, ymin = lower,ymax = upper, fill = scen,linetype=GCM),alpha = alphaIN)+
    geom_ribbon(data = mn_allGCM%>%filter(scen=="hind"), aes(x = year, ymin = lower,ymax = upper, fill = scen,linetype=GCM),alpha = alphaIN)+
    geom_line(data = mn_allGCM%>%filter(scen!="hind"), aes(x = year,y = mnVal,color = scen,linetype=GCM),size=1)+
    geom_line(data = mn_allGCM%>%filter(scen=="hind"), aes(x = year,y = mnVal,color = scen,linetype=GCM),size=1)+
    ylab(dat$units[1])+
    facet_grid(season~basin,scales="free_y")+
    theme_minimal()+
    #ggtitle(varlistIN)+
    theme(axis.text.x = element_text(angle = angleIN))+
    scale_fill_viridis_d(end = .2, begin =.7)+
    scale_color_viridis_d(end = .2, begin =.7)+
    labs(title = paste(varlistIN$name,", Bias corrected"),
         subtitle = varlistIN$longname,
         caption = "ACLIM2 2023")
  
  return(list(p1=p1,p2=p2,p3=p3))
  
}
