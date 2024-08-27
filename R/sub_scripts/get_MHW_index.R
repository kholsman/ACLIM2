#'
#'
#'
#'
#'get_MHW.R
#'K.Holsman
#'ACLIM NOAA Fisheries
#' 
#'generate frequency of MHW for future scenarios:
#' 2024
#'

# load setup
suppressMessages(source("R/make.R"))  
# vars to select from for weekly data:
weekly_vars

# Annual Indices
#df <- get_var(typeIN = "weekly",plotvar = "temp_bottom5m",plothist = F)
#df$plot
#head(df$dat)
stitchDate <- "2020-12-30"

# Get high res weekly indices
df <- get_var(typeIN = "annual",plotvar = "temp_bottom5m",plothist = F)
df$plot
head(df$dat)


if(!dir.exists( file.path("Data/NotShared/MHW")))
  dir.create( file.path("Data/NotShared/MHW"))


# Get data:

for(varIN in c("temp_surface5m","temp_bottom5m","EupS_integrated")){
  figpath <- file.path("Data/NotShared/MHW",varIN)
  if(!dir.exists( figpath))
    dir.create( figpath)
  for(basinIN in c("SEBS","NEBS")){  
    df      <- get_var(typeIN = "weekly",plotvar = varIN,plothist = F,plotbasin    = basinIN,bcIN      = c("bias corrected"))
    MHW     <- get_MHW(datIN= df$dat)
    save(MHW, file = paste0("Data/NotShared/MHW/", "MHW_",varIN,"_",basinIN,".Rdata"))
    rm(df)
  }
}

# create plots and summaries

i <- 0
for(varIN in c("temp_surface5m","temp_bottom5m","EupS_integrated")){
  figpath <- file.path("Data/NotShared/MHW",varIN)
  if(!dir.exists( figpath))
    dir.create( figpath)
  tmax <- 10
  if(varIN=="temp_surface5m") tmax <- 16
  if(varIN=="EupS_integrated") tmax <- 30
  for(basinIN in c("SEBS","NEBS")){  
    i <- i + 1
   
    load(file = paste0("Data/NotShared/MHW/", "MHW_",varIN,"_",basinIN,".Rdata"))
    gcmlist <- unique(MHW$MHW$GCM)
    dat_ld_tmp <- melt(MHW$MHW_decade%>%select(decade, sim, scen,GCM, basin,var,
                                               Category1, Category2, Category3, Category4, Category5,
                                               CategoryNeg1, CategoryNeg2, CategoryNeg3, CategoryNeg4, CategoryNeg5),  
                   id.vars =c("decade", "sim","scen","GCM","basin","var"),
                   variable_name = "MHWCategory")
    
    dat_lq_tmp  <- melt(MHW$MHW_quarter%>%select(quarter, sim, scen,GCM, basin,var,
                                                 Category1, Category2, Category3, Category4, Category5,
                                                 CategoryNeg1, CategoryNeg2, CategoryNeg3, CategoryNeg4, CategoryNeg5), 
                   id.vars =c("quarter", "sim","scen","GCM","basin","var"),
                   variable_name = "MHWCategory")
    
    mn_d_tmp <- MHW$MHW%>%
      group_by(season,decade, basin, var, sim, scen, GCM)%>%
      summarise(mnval = mean(val_use,na.rm=T),
                sdval  = sd(val_use,na.rm=T))%>%
      left_join(MHW$MHW%>%
                  group_by(decade, basin, var, sim, scen, GCM)%>%
                  summarise(mnval_yr = mean(val_use,na.rm=T),
                            sdval_yr  = sd(val_use,na.rm=T)))%>%data.frame()
    mn_q_tmp <- MHW$MHW%>%
      group_by(season,quarter, basin, var, sim, scen, GCM)%>%
      summarise(mnval = mean(val_use,na.rm=T),
                sdval  = sd(val_use,na.rm=T))%>%
      left_join(MHW$MHW%>%
                  group_by(quarter, basin, var, sim, scen, GCM)%>%
                  summarise(mnval_yr = mean(val_use,na.rm=T),
                            sdval_yr  = sd(val_use,na.rm=T)))%>%data.frame()
    

    
    if(i==1){
      dat_ld <- dat_ld_tmp
      dat_lq <- dat_lq_tmp
      mn_d   <- mn_d_tmp
      mn_q   <- mn_q_tmp
    }else{
      dat_ld <- rbind(dat_ld,dat_ld_tmp)
      dat_lq <- rbind(dat_lq,dat_lq_tmp)
      mn_d   <- rbind(mn_d,mn_d_tmp)
      mn_q   <- rbind(mn_q,mn_q_tmp)
    }
    
    P_hind <- plot_MHW (datIN = MHW$MHW%>%mutate(scen="Hindcast"), 
                        yr_range = c(2010,2026), 
                        subtitleIN = MHW$MHW$var[1],
                        titleIN = MHW$MHW$basin[1],
                        alpha2 = 0, simIN = "ACLIMregion_B10K-K20P19_CORECFS", 
                        scenIN = "Hindcast",gcmIN = "hind")+
      coord_cartesian(ylim=c(-2,tmax))
      
    fn <- file.path(figpath,paste0("p_hind_",basinIN,".jpg"))
    sclr <- 1.5
    jpeg(filename = fn, width = 5*sclr,height =3*sclr, units = "in", res = 350)
    print(P_hind)
    dev.off()
    rm(P_hind)
    
    P_hind2 <- plot_anomly (datIN = MHW$MHW%>%mutate(scen="Hindcast"), 
                        yr_range = c(1970,2026), 
                        subtitleIN = MHW$MHW$var[1],
                        titleIN = MHW$MHW$basin[1],
                        alpha2 = 0, simIN = "ACLIMregion_B10K-K20P19_CORECFS", 
                        scenIN = "Hindcast",gcmIN = "hind")+
      coord_cartesian(ylim=c(-2,tmax))
    
    fn <- file.path(figpath,paste0("p_hind_",basinIN,"long.jpg"))
    sclr <- 1.5
    jpeg(filename = fn, width = 8*sclr,height =2*sclr, units = "in", res = 350)
    print(P_hind2)
    dev.off()
    rm(P_hind2)

    rm(list=c("dat_lq_mn","dat_ld_mn","df","mn_d_tmp","mn_q_tmp"))
    tt <-plot_anomly (datIN = MHW$MHW, 
                               yr_range = c(2050,2060),
                               subtitleIN = MHW$MHW$var[1],
                               titleIN = MHW$MHW$basin[1],
                               alpha2 = 0, 
                               simIN = NULL,gcmIN = NULL)
    #+coord_cartesian(ylim=c(-2,tmax))
    fn <- file.path(figpath,paste0("p_fut_",basinIN,"_all.jpg"))
    sclr <- 1.5
    jpeg(filename = fn, width = 6*sclr,height =4*sclr, units = "in", res = 350)
    print(tt)
    dev.off()
    rm(tt)
 
   for(ssp in c("ssp126","ssp585")){
     p_fut <- plot_anomly (datIN = MHW$MHW%>%filter(scen==ssp), 
                        yr_range = c(2050,2060),
                        subtitleIN = MHW$MHW$var[1],
                        titleIN = MHW$MHW$basin[1],
                        alpha2 = 0, 
                        simIN = NULL, 
                        scenIN = ssp,gcmIN = NULL)+
       coord_cartesian(ylim=c(-2,tmax))
    
     fn <- file.path(figpath,paste0("p_fut_",basinIN,"_",ssp,".jpg"))
     jpeg(filename = fn, width = 6,height =4, units = "in", res = 350)
     print(p_fut)
     dev.off()
     rm(p_fut)
   }
   rm(MHW)
  
  }
}

  save(mn_d, file = paste0("Data/NotShared/MHW/", "Temp_summary_10yr.Rdata"))
  save(mn_q, file = paste0("Data/NotShared/MHW/", "Temp_summary_25yr.Rdata"))
  save(dat_lq, file = paste0("Data/NotShared/MHW/", "MHW_summary_25yr.Rdata"))
  save(dat_ld, file = paste0("Data/NotShared/MHW/", "MHW_summary_10yr.Rdata"))

  dat_lq_mn <- dat_lq%>%rowwise()%>%mutate(type = ifelse(GCM !="hind",scen,"hind"))%>%
    group_by(quarter,type, MHWCategory, basin, var)%>%
    summarize(mn = mean(value,na.rm=T), 
              sd   = sd(value,na.rm=T) )%>%data.frame()
  
  dat_ld_mn <- dat_ld%>%rowwise()%>%mutate(type = ifelse(GCM !="hind",scen,"hind"))%>%
    group_by(decade,type, MHWCategory, basin, var)%>%
    summarize(mn = mean(value,na.rm=T), 
              sd    = sd(value,na.rm=T) )%>%data.frame()
  
  for(varIN in c("temp_surface5m","temp_bottom5m", "EupS_integrated")){
    tmax <- 10
    if(varIN=="temp_surface5m") tmax <- 16
    for(basinIN in c("SEBS","NEBS")){ 
     p_mn_d <-  ggplot(dat_ld_mn%>%filter(var==varIN,basin==basinIN))+
       ylab("% time")+xlab("")+
        geom_bar(aes(x= factor(decade), y= mn*100, fill=MHWCategory), color=NA,stat = "identity", position = position_stack(reverse = TRUE))+
        scale_fill_manual(values = c(RColorBrewer::brewer.pal(6,"YlOrRd")[2:6],RColorBrewer::brewer.pal(6,"Blues")[2:6]))+
       facet_grid(~type)+theme_minimal()+ 
       theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+
       coord_cartesian(ylim=c(0,100))+ theme(panel.spacing = unit(2, "lines"))
     
     GCMIN <- "cesm"
     plotdT <- mn_d%>%filter(var==varIN,basin==basinIN,GCM!="hind")
     plotdT <- plotdT%>%left_join(plotdT%>%filter(decade<2015)%>%group_by(GCM, scen,season)%>%summarize(baseline = mean(mnval,na.rm=T)))%>%
       rowwise()%>%mutate(mn_val_delta = mnval-baseline)%>%group_by(decade,var,basin,scen,season)%>%
       summarize(mn_val_delta = mean(mn_val_delta,na.rm=T), sd_val_delta = sd(mn_val_delta, na.rm=T))%>%data.frame()
     
     p_mnT_d <-  ggplot(plotdT)+
       ylab(expression("Change"))+xlab("")+
       geom_bar(aes(x= factor(decade), y= mn_val_delta, fill=mn_val_delta), color=NA,stat = "identity", position = position_stack(reverse = F))+
       scale_fill_distiller(palette = "Spectral", direction = -1) +
       facet_grid(season~scen)+theme_minimal()+ 
       ggtitle(paste(basinIN,", ",GCMIN),subtitle = varIN)+
       theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+theme(panel.spacing = unit(2, "lines"))
     
     
     qrts    <- dat_lq_mn%>%filter(type!="hind")%>%select(quarter)%>%unique()%>%unlist()
     plotdat <- dat_lq_mn%>%filter(var==varIN,basin==basinIN)
     plotdat2 <- plotdat%>%
       left_join( plotdat%>%filter(quarter==as.numeric(qrts[1]))%>%select(-var,-sd,-quarter)%>%rename(mn_ref = mn) )%>%
       group_by(quarter, basin, type, var, MHWCategory)%>%summarize(mn_tot = sum(mn), mn_tot_ref = sum(mn_ref))%>%
       mutate(delta_mn = round(mn_tot/mn_tot_ref))%>%rowwise()%>%mutate(delta_mn_txt = ifelse(delta_mn<=1,"",paste0("x ",delta_mn)))%>%data.frame()
     plotdat3 <- plotdat%>%
       left_join( plotdat%>%filter(quarter==as.numeric(qrts[1]))%>%select(-var,-sd,-quarter)%>%rename(mn_ref = mn) )%>%
       group_by(quarter, basin, type, var)%>%summarize(mn_tot2 = sum(mn), mn_tot_ref2 = sum(mn_ref))%>%
       mutate(delta_mn2 = round(mn_tot2/mn_tot_ref2,1))%>%rowwise()%>%mutate(delta_mn_txt2 = ifelse(delta_mn2<=1,"",paste0("x ",delta_mn2)))%>%data.frame()

     
     
     p_mn_q <-  ggplot( plotdat%>%left_join(plotdat2)%>%filter(type!="hind"))+
        geom_bar(aes(x= factor(quarter), y= mn*100, fill=MHWCategory), color=NA,stat = "identity", width = 0.9,
                 position = position_stack(reverse = TRUE))+
       geom_text(data=plotdat3%>%filter(type!="hind"),aes(x= factor(quarter), y= mn_tot2*100, 
                                                          label =delta_mn_txt2),size = 4,position = position_stack(vjust = 1.05))+ 
      # geom_text(aes(x= factor(quarter), y= mn*100, label =delta_mn_txt),size = 3, position = position_stack(reverse = TRUE,vjust = 0.5))+  #position = position_stack(vjust = 0.5))+  #position = position_stacknudge(y = -60)
        ggtitle(basinIN,subtitle = varIN)+
        ylab("% time")+xlab("")+
        scale_fill_manual(values = c(RColorBrewer::brewer.pal(6,"YlOrRd")[2:6],RColorBrewer::brewer.pal(6,"Blues")[2:6]))+
       facet_grid(~type)+theme_minimal()+ theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+
       coord_cartesian(ylim=c(0,105))+ theme(panel.spacing = unit(2, "lines"))
     
     p_mn_q2 <-  ggplot( plotdat%>%left_join(plotdat2))+
       geom_bar(aes(x= factor(quarter), y= mn*100, fill=MHWCategory), color=NA,stat = "identity", width = 0.9,
                position = position_stack(reverse = TRUE))+
       ggtitle(basinIN,subtitle = varIN)+
       ylab("% time")+xlab("")+
       scale_fill_manual(values = c(RColorBrewer::brewer.pal(6,"YlOrRd")[2:6],RColorBrewer::brewer.pal(6,"Blues")[2:6]))+
       facet_grid(~type)+theme_minimal()+ theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+
       coord_cartesian(ylim=c(0,100))+ theme(panel.spacing = unit(2, "lines"))
     
     
     fn <- file.path("Data/NotShared/MHW",paste0("p_mn_25yr_abrv_",varIN,"_",basinIN,".jpg"))
     sclr <- 1.5
     jpeg(filename = fn, width = 5*sclr,height =3*sclr, units = "in", res = 350)
     print(p_mn_q)
     dev.off()
     
     
     fn <- file.path("Data/NotShared/MHW",paste0("p_mn_25yr_",varIN,"_",basinIN,".jpg"))
     sclr <- 1.5
     jpeg(filename = fn, width = 5*sclr,height =3*sclr, units = "in", res = 350)
     print(p_mn_q2)
     dev.off()
     
     fn <- file.path("Data/NotShared/MHW",paste0("p_mn_10yr_",varIN,"_",basinIN,".jpg"))
     jpeg(filename = fn, width = 5*sclr,height =3*sclr, units = "in", res = 350)
     print(p_mn_d)
     dev.off()
     
    }
  }
  
  
# Now make mean temperature plots:
  
  
  
    
