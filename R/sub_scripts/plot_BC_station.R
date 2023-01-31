#'
#'
#'
#'
#'plot_BC_station.R
#'

sim_listIN <- sim_list[-grep("historical",sim_list)]
scenIN     <- c("ssp126","ssp585")
root_tmp <- "Data/out/K20P19_CMIP6/BC_ACLIMsurveyrep/"
if(rplc_bcplot)
  if(dir.exists("Data/out/K20P19_CMIP6/BC_ACLIMsurveyrep/plots"))
   # system(" rm Data/out/K20P19_CMIP6/BC_ACLIMsurveyrep/plots")

if(!dir.exists("Data/out/K20P19_CMIP6/BC_ACLIMsurveyrep/plots"))
  dir.create("Data/out/K20P19_CMIP6/BC_ACLIMsurveyrep/plots")

for(ii in 1:length(gcmcmipL)){
  
  gcmcmip <- gcmcmipL[ii]
  simL    <- sim_listIN[sim_listIN%in%paste0(gcmcmip,"_",rep(scenIN,1,each=length(gcmcmip)))]
  
  for (sim in simL){
    if(!dir.exists(file.path("Data/out/K20P19_CMIP6/BC_ACLIMsurveyrep/plots",sim)))
      dir.create(file.path("Data/out/K20P19_CMIP6/BC_ACLIMsurveyrep/plots",sim))
    
    load(file.path(root_tmp,paste0("ACLIMregion_",sim,"_BC_fut.R")))
    
    
    for(varIN in unique(fut$var)){
      library(ggplot2)
      library(dplyr)
      varIN <- "Ben"
      
      ggplot2::ggplot(data=mn_hind%>%dplyr::filter(var==varIN))+
        geom_point(
          aes(y=latitude, x=longitude, size=mnVal_hind,color="mn hind"))
      ggplot2::ggplot(data=mn_hist%>%dplyr::filter(var==varIN))+
        geom_point(
          aes(y=latitude, x=longitude, size=mnVal_hist,color="mn hind"))
      
      ggplot2::ggplot(data=futIN22%>%dplyr::filter(var==varIN))+
        geom_point(
          aes(y=latitude, x=longitude, size=mnVal_hist,color="mn val"))
      
      ggplot2::ggplot(data=subC%>%dplyr::filter(var==varIN))+
        geom_point(
          aes(y=latitude, x=longitude, size=val_raw,color="raw"))
      
      ggplot2::ggplot(data=subC%>%dplyr::filter(var==varIN))+
        geom_point(
          aes(y=latitude, x=longitude, size=mn_val,color="raw"))
      
      
      ggplot2::ggplot(data=%>%dplyr::filter(var==varIN))+
        geom_point(
          aes(y=latitude, x=longitude, size=mnVal_hist,color="mn hist"))
      
      varIN<-"Ben"
      
      ggplot2::ggplot(data=futtmp%>%dplyr::filter(var==varIN))+
        geom_point(
          aes(y=latitude, x=longitude, size=val_biascorrected,color="mn hind"))
      
      
      
      
      ggplot2::ggplot(data=futout%>%dplyr::filter(var==varIN))+
        geom_point(
          aes(y=latitude, x=longitude, size=val_biascorrected,color="mn hind"))
      library(ggplot2)
      library(dplyr)
      varIN <- "Ben"
      p <- ggplot2::ggplot(data=fut%>%dplyr::filter(var==varIN))+
       # geom_point(aes(y=latitude, x=longitude, size=mnVal_hind,color="mn hind"))+
        #geom_point(aes(y=latitude, x=longitude, size=mnVal_hist,color="mn hist"),alpha=.2)+
        geom_point(aes(y=latitude, x=longitude, size=val_raw,color="raw"),alpha=.2)+
        geom_point(aes(y=latitude, x=longitude, size=val_biascorrected,color="bias corrected"),alpha=.2)
      
      
      p <- ggplot(data=fut%>%filter(var==varIN,strata==70,year%in%c(2024,2050,2090)))+
        geom_line(aes(x=mnjday,y=val_raw,linetype="raw",color=factor(year)),size=.8)+
        geom_line(aes(x=mnjday,y=val_biascorrectedwk,
                      linetype="bias correctedwk",color=factor(year)),size=.8)+
        geom_line(aes(x=mnjday,y=mnVal_hind,color="mnVal_hind"),size=1.2)+
        geom_line(aes(x=mnjday,y=mnVal_hist,color="mnVal_hist"),size=1.2)+
        theme_minimal()+ylab(varIN)
      p
      jpeg(filename =paste0("Data/out/K20P19_CMIP6/BC_ACLIMsurveyrep/plots/",sim,"/",varIN,".jpg") , width=8,height =4,units = "in",res = 350)
      print(p)
      dev.off()
      rm(p)
    }
    rm(list=c("fut"))
  }
}