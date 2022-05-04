

library(dplyr)
library(ggplot2)

input<-list()
input$bc         <- c("raw","bias corrected")
input$GCM        <- c("miroc","gfdl","cesm")
input$scen       <- c("ssp126","ssp585")

input$CMIP       <- c("K20P19_CMIP5","K20P19_CMIP6")
input$plotvar    <- "temp_bottom5m"
input$plotbasin  <- "SEBS"
input$facet_row  <- "bc"
input$facet_col  <- "scen"


load("Data/out/K20P19_CMIP6/allEBS_means/ACLIM_annual_hind_mn.Rdata")
load("Data/out/K20P19_CMIP6/allEBS_means/ACLIM_annual_hist_mn.Rdata")
load("Data/out/K20P19_CMIP6/allEBS_means/ACLIM_annual_fut_mn.Rdata")

#bc         <- input$bc
#GCM        <- input$GCM
#scen       <- input$scen
CMIP       <- input$CMIP
plotvar    <- input$plotvar
plotbasin  <- input$plotbasin
facet_row  <- input$facet_row
facet_col  <- input$facet_col

hind       <- ACLIM_annual_hind%>%dplyr::filter(var ==plotvar,basin==plotbasin)%>%select(basin,year, mnDate,mn_val, sim,gcmcmip,GCM,scen,sim_type ,units)
hist       <- ACLIM_annual_hist%>%dplyr::filter(var ==plotvar,basin==plotbasin)%>%select(basin,year, mnDate,mn_val, sim,gcmcmip,GCM,scen,sim_type ,units)
fut        <- ACLIM_annual_fut%>%dplyr::filter(var ==plotvar,basin==plotbasin)%>%select(basin,year, mnDate,mn_val, sim,gcmcmip,GCM,scen,sim_type ,units)
plotdat    <- rbind(hind,hist,fut)%>%mutate(bc = "raw")

hind_bc    <- ACLIM_annual_hind%>%dplyr::filter(var ==plotvar,basin==plotbasin)%>%select(basin,year, mnDate,mn_val, sim,gcmcmip,GCM,scen,sim_type ,units)%>%mutate(bc="bias corrected")
fut_bc     <- ACLIM_annual_fut%>%dplyr::filter(var ==plotvar,basin==plotbasin)%>%select(basin,year, mnDate,val_biascorrected, sim,gcmcmip,GCM,scen,sim_type ,units)
fut_bc     <- fut_bc%>%mutate(bc="bias corrected")%>%rename(mn_val = val_biascorrected)

fut_bc     <-rbind(hind_bc,fut_bc)

plotdat    <- rbind(plotdat,fut_bc)
plotdat$bc <- factor(plotdat$bc, levels =c("raw","bias corrected"))
plotdat$GCM_scen <- paste0(plotdat$GCM,"_",plotdat$scen) 

plotdat$GCM_scen_sim <- paste0(plotdat$GCM,"_",plotdat$scen,"_",plotdat$sim_type) 

plotdat <- plotdat%>%filter(
	scen%in%input$scen,
	GCM%in%input$GCM,
	bc%in%input$bc)

units <- plotdat$units[1]

nyrs <- length(unique(plotdat$year))
spanIN <- 5/nyrs

pp <- ggplot(plotdat)+
  geom_line(aes(x=mnDate,y=mn_val,color= GCM_scen_sim,linetype = basin))+
  geom_line(aes(x=mnDate,y=mn_val,color= GCM_scen_sim,linetype = basin),alpha = 0.6)+
  geom_line(aes(x=mnDate,y=mn_val,color= GCM_scen_sim,linetype = basin),alpha = 0.6)+
  geom_smooth(aes(x=mnDate,y=mn_val,color= GCM_scen_sim,fill=GCM_scen_sim,linetype = basin),alpha=0.1,method="loess",span = .5)+
  theme_minimal() + ylab(paste(plotvar,"(",units,")"))

eval(parse(text = paste0("pp <-pp+facet_grid(",facet_row,"~",facet_col,")") ))
pp






