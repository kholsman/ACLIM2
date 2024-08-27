#'
#'
#'
#'plot_salmon_Indices
#'ALCIM3 K. Holsman
#'2024
#'

# rmlist=ls()
message("Set outfldr to your local folder with the salmon indiceies \n e.g., /Users/KKH/Documents/GitHub_mac/ACLIM2/Data/out/salmon_indices")
outfldr <- "Data/out/salmon_indices"

# ------------------------------------
# Load packages
# ------------------------------------  
load(file.path(outfldr,"salmon_indices_setup.Rdata"))
library(ggplot2)
library(dplyr)
library(RColorBrewer)
# 
# # load ACLIM packages and functions
# suppressMessages(source("R/make.R"))

# ------------------------------------
# Load Data
# ------------------------------------ 

dirlist <- dir(outfldr)
dirlist <- dirlist[grep("Dat",dirlist)]
dirlist <- dirlist[grep("Rdata",dirlist)]

for(d in dirlist)
  load(file.path(outfldr,d))

# ------------------------------------
# Plot results
# ------------------------------------  

# Set color palette
# ------------------------------------
display.brewer.all()

GCM_scens <-  c("hind",unique(futDat_weekly_strata$GCM_scen))
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
var_salmons <- unique(futDat_avg$var_salmon)

AVGfut <- futDat_avg
plot_stationAVG <- plotTS(AVGfut%>%
                            mutate(mn_val = val_use,
                                   scen   = RCP,
                                   basin = var_salmon,
                                   GCM_scen = factor(GCM_scen,levels = GCM_scens)))+
  labs(title="average variables (RKC_immature_males) ")+
  scale_color_manual(name = "Scenario",
                     values = valuesIN)+
  scale_fill_manual(name = "Scenario",
                    values = valuesIN)+
  facet_grid(var~scen,scales='free_y')
plot_stationAVG


plot_stationAVG2 <- plotTS(AVGfut%>%
                            mutate(mn_val = val_use,
                                   scen   = GCM,
                                   basin = var_salmon,
                                   GCM_scen = factor(GCM_scen,levels = GCM_scens)))+
  labs(title="average variables (RKC_immature_males) ")+
  scale_color_manual(name = "Scenario",
                     values = valuesIN)+
  scale_fill_manual(name = "Scenario",
                    values = valuesIN)+
  facet_grid(var~scen,scales='free_y')
plot_stationAVG2


# ------------------------------------
# Plot restults with hindcast
# ------------------------------------ 

# Plot AVG across subset stations:
# --------------------------------------
varlist <- unique(futDat_avg$var)
var_sal_set <- var_salmons


vlN <- 1:length(varlist)


AVGfut  <- futDat_avg%>%mutate(mn_val   = val_use,
                                                   scen     = GCM,
                                                   GCM_scen = factor(GCM_scen,levels = GCM_scens))
AVGhind_salmon <- hindDat_avg%>%mutate(mn_val   = val_use,
                                                    scen     = "hind",
                                                    GCM_scen = factor("hind",levels = GCM_scens))

hindfut_avg <- ggplot( )+
  geom_line(data=AVGfut%>%mutate(scen=GCM)%>%filter(var%in%varlist[vlN]),
            aes(x=mnDate,y=val_use,color= GCM_scen,linetype = var_salmon),
            alpha = 0.2,show.legend = FALSE)+
  geom_smooth(data=AVGfut%>%mutate(scen=GCM)%>%filter(var%in%varlist[vlN]),
              aes(x=mnDate,y=val_use,color= GCM_scen,
                  fill=GCM_scen,linetype = var_salmon),
              alpha=0.1,method="loess",formula='y ~ x',span = .5)+facet_grid(var~GCM,scales="free_y")+
  
  geom_line(data=AVGhind_salmon%>%filter(var%in%varlist[vlN]),
            aes(x=mnDate,y=val_use,color="hind",linetype = var_salmon),
            alpha = 0.2,show.legend = FALSE)+
  geom_smooth(data=AVGhind_salmon%>%filter(var%in%varlist[vlN]),
              aes(x=mnDate,y=val_use,color= "hind",
                  fill="hind",linetype = var_salmon),
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
hind_salmon <- hindDat_avg%>%mutate(mn_val   = val_use,
                                             scen     = "hind",
                                             GCM_scen = factor("hind",levels = GCM_scens))
fut_salmon  <- futDat_avg%>%mutate(mn_val   = val_use,
                                            scen     = GCM,
                                            GCM_scen = factor(GCM_scen,levels = GCM_scens))


stN <- 3 
for(stN in 1:length(var_sal_set)){
  var_sal_set[stN]
  
  hindfut_station <- ggplot( )+
    geom_line(data=fut_salmon%>%mutate(mn_val=val_use,scen=GCM)%>%filter(var_salmon==var_sal_set[stN],var%in%varlist[vlN]),
              aes(x=mnDate,y=val_use,color= GCM_scen,linetype = var_salmon),
              alpha = 0.2,show.legend = FALSE)+
    geom_smooth(data=fut_salmon%>%mutate(mn_val=val_use,scen=GCM)%>%filter(var_salmon==var_sal_set[stN],var%in%varlist[vlN]),
                aes(x=mnDate,y=val_use,color= GCM_scen,
                    fill=GCM_scen,linetype = var_salmon),
                alpha=0.1,method="loess",formula='y ~ x',span = .5)+facet_grid(var~GCM,scales="free_y")+
    
    geom_line(data=hind_salmon%>%filter(var_salmon%in%var_sal_set[stN],var%in%varlist[vlN]),
              aes(x=mnDate,y=val_use,color="hind",linetype = var_salmon),
              alpha = 0.2,show.legend = FALSE)+
    geom_smooth(data=hind_salmon%>%filter(var_salmon==var_sal_set[stN],var%in%varlist[vlN]),
                aes(x=mnDate,y=val_use,color= "hind",
                    fill="hind",linetype = var_salmon),
                alpha=0.1,method="loess",formula='y ~ x',span = .5)+
    theme_minimal() + 
    labs(x="Year",
         subtitle = "",
         title = paste("Salmon strata/mo:", var_sal_set[stN]),
         legend = "")+
    scale_color_manual(name = "Scenario",
                       values = valuesIN)+
    scale_fill_manual(name = "Scenario",
                      values = valuesIN)
  
  hindfut_station

    jpeg(filename = file.path(outfldr,paste0("salmon_indices_indiv_hind",stN,".jpg")),
         width=8*sclr,height=7*sclr,units="in",res=350)
    print(hindfut_avg)
    dev.off()
}


sclr <- 1.2
jpeg(filename = file.path(outfldr,"salmon_vars.jpg"),
     width=8*sclr, height=7*sclr, units="in", res = 350)
print(plot_stationAVG)
dev.off()


sclr <- 1.2
jpeg(filename = file.path(outfldr,"salmon_indices_fut_hind.jpg"),
     width=8*sclr,height=7*sclr,units="in",res=350)
print(hindfut_station)
dev.off()




