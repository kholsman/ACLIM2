#'
#'
#'
#'plot_RKC_Indices_Andre
#'ALCIM3 K. Holsman
#'2024
#'

# rmlist=ls()
message("Set outfldr to your local folder with the RKC indiceies \n e.g., /Users/KKH/Documents/GitHub_mac/ACLIM2/Data/out/RKC_indices")
outfldr <- "Data/out/RKC_indices"

# ------------------------------------
# Load packages
# ------------------------------------  
load(file.path(outfldr,"RKC_indices_setup.Rdata"))
library(ggplot2)
library(dplyr)
library(RColorBrewer)
# 
# # load ACLIM packages and functions
# suppressMessages(source("R/make.R"))

# ------------------------------------
# Load Data
# ------------------------------------ 



load(file.path(outfldr,"AVG_hind_TC_small_males.Rdata"))
load(file.path(outfldr,"AVG_hind_RKC_immature_males.Rdata"))
load(file.path(outfldr,"AVG_fut_TC_small_males.Rdata"))
load(file.path(outfldr,"AVG_fut_RKC_immature_males.Rdata"))

load(file.path(outfldr,"fut_TC_small_males_monthly.Rdata"))
load(file.path(outfldr,"fut_TC_small_males_monthly_avg.Rdata"))
load(file.path(outfldr,"fut_RKC_immature_males_monthly.Rdata"))
load(file.path(outfldr,"fut_RKC_immature_males_monthly_avg.Rdata"))

load(file.path(outfldr,"hind_TC_small_males_monthly.Rdata"))
load(file.path(outfldr,"hind_TC_small_males_monthly_avg.Rdata"))
load(file.path(outfldr,"hind_RKC_immature_males_monthly.Rdata"))
load(file.path(outfldr,"hind_RKC_immature_males_monthly_avg.Rdata"))

load(file.path(outfldr,"hind_TC_small_males.Rdata"))
load(file.path(outfldr,"hind_RKC_immature_males.Rdata"))
load(file.path(outfldr,"fut_TC_small_males.Rdata"))
load(file.path(outfldr,"fut_RKC_immature_males.Rdata"))

# ------------------------------------
# Plot results
# ------------------------------------  
  
  # Set color palette
  # ------------------------------------
    display.brewer.all()
    
    GCM_scens <-  c("hind",unique(AVG_fut_RKC_immature_males$GCM_scen))
    GCM_scens <- GCM_scens[ 
      c(1,
      grep("ssp126",GCM_scens), 
      grep("rcp45",GCM_scens), 
      grep("rcp85",GCM_scens),
      grep("ssp585",GCM_scens))]
    
    cc <- brewer.pal(n = 11, name ="Spectral") [c(10,9,4,3)]
    
    nn <- length(grep("ssp126",GCM_scens))
    c1 <- rep(cc[1],nn)
    nn <- length(grep("rcp45",GCM_scens))
    c2 <- rep(cc[2],nn)
    nn <- length(grep("rcp85",GCM_scens))
    c3 <- rep(cc[3],nn)
    nn <- length(grep("ssp585",GCM_scens))
    c4 <- rep(cc[4],nn)
    
    cols <- c("gray",c1,c2,c3,c4)
    valuesIN <- cols
    names(valuesIN) <- GCM_scens
    
  # Plot AVG across subset stations:
  # --------------------------------------
    AVGfut_RKC <- AVG_fut_RKC_immature_males
    plot_stationAVG <- plotTS(AVGfut_RKC%>%
                                mutate(mn_val = mn_val_use,
                                       scen   = GCM,
                                       GCM_scen = factor(GCM_scen,levels = GCM_scens)))+
      labs(title="average variables (RKC_immature_males) ")+
      scale_color_manual(name = "Scenario",
                         values = valuesIN)+
      scale_fill_manual(name = "Scenario",
                         values = valuesIN)
    plot_stationAVG

  # Plot Indiv station:
  # --------------------------------------
    stN <- 3
    fut_RKC <- fut_RKC_immature_males
    station_set <- unique(fut_RKC$station_id)
    
    plot_station <- plotTS(fut_RKC%>%mutate(mn_val=val_use,
                                            scen=GCM,
                                            GCM_scen = factor(GCM_scen,levels = GCM_scens))%>%
      filter(station_id==station_set[stN]) )+
      labs(title=paste("Station: ", station_set[stN]))+
      scale_color_manual(name = "Scenario",
                         values = valuesIN)+
      scale_fill_manual(name = "Scenario",
                        values = valuesIN)
    plot_station
    

# ------------------------------------
# Plot restults with hindcast
# ------------------------------------ 
    
    # Plot AVG across subset stations:
    # --------------------------------------
    stN <- 3 # for further down
    vlN <- 1:length(varlist)
    
    
    AVGfut_RKC  <- AVG_fut_RKC_immature_males%>%mutate(mn_val   = mn_val_use,
                                                       scen     = GCM,
                                                       GCM_scen = factor(GCM_scen,levels = GCM_scens))
    AVGhind_RKC <- AVG_hind_RKC_immature_males%>%mutate(mn_val   = mn_val_use,
                                                        scen     = "hind",
                                                        GCM_scen = factor("hind",levels = GCM_scens))
    
    hindfut_avg <- ggplot( )+
      geom_line(data=AVGfut_RKC%>%mutate(scen=GCM)%>%filter(var%in%varlist[vlN]),
                aes(x=mnDate,y=mn_val_use,color= GCM_scen,linetype = basin),
                alpha = 0.2,show.legend = FALSE)+
      geom_smooth(data=AVGfut_RKC%>%mutate(scen=GCM)%>%filter(var%in%varlist[vlN]),
                  aes(x=mnDate,y=mn_val_use,color= GCM_scen,
                      fill=GCM_scen,linetype = basin),
                  alpha=0.1,method="loess",formula='y ~ x',span = .5)+facet_grid(var~GCM,scales="free_y")+
      
      geom_line(data=AVGhind_RKC%>%filter(var%in%varlist[vlN]),
                aes(x=mnDate,y=mn_val_use,color="hind",linetype = basin),
                alpha = 0.2,show.legend = FALSE)+
      geom_smooth(data=AVGhind_RKC%>%filter(var%in%varlist[vlN]),
                  aes(x=mnDate,y=mn_val_use,color= "hind",
                      fill="hind",linetype = basin),
                  alpha=0.1,method="loess",formula='y ~ x',span = .5)+
      theme_minimal() + 
      labs(x="Year",
           subtitle = "",
           title = "cross-station average (RKC_immature_males)",
           legend = "")+
      scale_color_manual(name = "Scenario",
                         values = valuesIN)+
      scale_fill_manual(name = "Scenario",
                        values = valuesIN)
    
    hindfut_avg
    
    
    
    # Plot Indiv station:
    # --------------------------------------
  hind_RKC <- hind_RKC_immature_males%>%mutate(mn_val   = val_use,
                                               scen     = "hind",
                                               GCM_scen = factor("hind",levels = GCM_scens))
  fut_RKC  <- fut_RKC_immature_males%>%mutate(mn_val   = val_use,
                                              scen     = GCM,
                                              GCM_scen = factor(GCM_scen,levels = GCM_scens))
  
  
  hindfut_station <- ggplot( )+
    geom_line(data=fut_RKC%>%mutate(mn_val=val_use,scen=GCM)%>%filter(station_id==station_set[stN],var%in%varlist[vlN]),
              aes(x=mnDate,y=val_use,color= GCM_scen,linetype = basin),
              alpha = 0.2,show.legend = FALSE)+
    geom_smooth(data=fut_RKC%>%mutate(mn_val=val_use,scen=GCM)%>%filter(station_id==station_set[stN],var%in%varlist[vlN]),
                aes(x=mnDate,y=val_use,color= GCM_scen,
                    fill=GCM_scen,linetype = basin),
                alpha=0.1,method="loess",formula='y ~ x',span = .5)+facet_grid(var~GCM,scales="free_y")+
    
    geom_line(data=hind_RKC%>%filter(station_id%in%station_set[stN],var%in%varlist[vlN]),
              aes(x=mnDate,y=val_use,color="hind",linetype = basin),
              alpha = 0.2,show.legend = FALSE)+
    geom_smooth(data=hind_RKC%>%filter(station_id==station_set[stN],var%in%varlist[vlN]),
                aes(x=mnDate,y=val_use,color= "hind",
                    fill="hind",linetype = basin),
                alpha=0.1,method="loess",formula='y ~ x',span = .5)+
    theme_minimal() + 
    labs(x="Year",
         subtitle = "",
         title = paste("Station:", station_set[stN]),
         legend = "")+
    scale_color_manual(name = "Scenario",
                       values = valuesIN)+
    scale_fill_manual(name = "Scenario",
                      values = valuesIN)
  
  hindfut_station
  
  
  # plot monthly indices
  # ------------------------------------  
  
  # ggplot(hind_TC_small_males_monthly)+
  #   geom_line(aes(x= mnDate,y = val_use,color=var))+facet_grid(var~strata,scales="free_y")
  # 
  stratalist<-unique( fut_TC_small_males_monthly$strata)
  sin <- 1
  hindfut_station_monthly <- ggplot()+
    geom_line(data=fut_TC_small_males_monthly%>%mutate(mn_val=val_use,scen=GCM)%>%
                filter(strata==stratalist[sin],var%in%varlist[vlN]),
              aes(x=mnDate,y=val_use,color= GCM_scen,linetype = basin),
              alpha = 0.2,show.legend = FALSE)+
    geom_smooth(data=fut_TC_small_males_monthly%>%mutate(mn_val=val_use,scen=GCM)%>%
                  filter(strata==stratalist[sin],var%in%varlist[vlN]),
                aes(x=mnDate,y=val_use,color= GCM_scen,
                    fill=GCM_scen,linetype = basin),
                alpha=0.1,method="loess",formula='y ~ x',span = .5)+
    facet_grid(var~GCM,scales="free_y")+
    geom_line(data=hind_TC_small_males_monthly%>%filter(strata==stratalist[sin],var%in%varlist[vlN]),
              aes(x=mnDate,y=val_use,color="hind",linetype = basin),
              alpha = 0.2,show.legend = FALSE)+
    geom_smooth(data=hind_TC_small_males_monthly%>%filter(strata==stratalist[sin],var%in%varlist[vlN]),
                aes(x=mnDate,y=val_use,color= "hind",
                    fill="hind",linetype = basin),
                alpha=0.1,method="loess",formula='y ~ x',span = .5)+
    theme_minimal() + 
    labs(x="Year",
         subtitle = "",
         title = paste("Monthly by strata:",stratalist[sin] ),
         legend = "")+
    scale_color_manual(name = "Scenario",
                       values = valuesIN)+
    scale_fill_manual(name = "Scenario",
                      values = valuesIN)
  
  hindfut_station_monthly
  

  # Save plots
  # ------------------------------------  
 
  sclr <- 1.2
  jpeg(filename = file.path(outfldr,"Station_Averaged_RKC_vars.jpg"),
       width=8*sclr, height=7*sclr, units="in", res = 350)
  print(plot_stationAVG)
  dev.off()
  
  jpeg(filename = file.path(outfldr,paste0("RKC_vars_",station_set[stN],".jpg")),
       width=8*sclr, height=7*sclr, units="in", res = 350)
  print(plot_station)
  dev.off()
  
  
  sclr <- 1.2
  jpeg(filename = file.path(outfldr,"RKC_indices_station_W_hind.jpg"),
       width=8*sclr,height=7*sclr,units="in",res=350)
  print(hindfut_station)
  dev.off()
  
  jpeg(filename = file.path(outfldr,"RKC_indices_avg_W_hind.jpg"),
       width=8*sclr,height=7*sclr,units="in",res=350)
  print(hindfut_avg)
  dev.off()
  
  jpeg(filename = file.path(outfldr,"TC_small_males_monthly.jpg"),
       width=8*sclr,height=7*sclr,units="in",res=350)
  print(hindfut_station_monthly)
  dev.off()
  
  