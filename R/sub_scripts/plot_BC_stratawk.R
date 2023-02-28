#'
#'
#'
#'
#'plot_BC_stratawk.R
#'

sim_listIN <- sim_list[-grep("historical",sim_list)]
scenIN     <- c("ssp126","ssp585")
root_tmp <- "Data/out/K20P19_CMIP6/BC_ACLIMregion"
if(rplc_bcplot)
  if(dir.exists("Data/out/K20P19_CMIP6/BC_ACLIMregion/plots"))
    dir.remove("Data/out/K20P19_CMIP6/BC_ACLIMregion/plots")

if(!dir.exists("Data/out/K20P19_CMIP6/BC_ACLIMregion/plots"))
  dir.create("Data/out/K20P19_CMIP6/BC_ACLIMregion/plots")

for(ii in 1:length(gcmcmipL)){
  
gcmcmip <- gcmcmipL[ii]
simL    <- sim_listIN[sim_listIN%in%paste0(gcmcmip,"_",rep(scenIN,1,each=length(gcmcmip)))]

for (sim in simL){
  if(!dir.exists(file.path("Data/out/K20P19_CMIP6/BC_ACLIMregion/plots",sim)))
    dir.create(file.path("Data/out/K20P19_CMIP6/BC_ACLIMregion/plots",sim))
  
  load(file.path(root_tmp,paste0("ACLIMregion_",sim,"_BC_fut.Rdata")))
  

  for(varIN in unique(fut$var)){
    
    
    p <- ggplot(data=fut%>%filter(var==varIN,strata==70,year%in%c(2024,2050,2090)))+
      geom_line(aes(x=jday,y=val_raw,linetype="raw",color=factor(year)),size=.8)+
      geom_line(aes(x=jday,y=val_biascorrectedwk,
                    linetype="bias correctedwk",color=factor(year)),size=.8)+
      geom_line(aes(x=jday,y=mnVal_hind,color="mnVal_hind"),size=1.2)+
      geom_line(aes(x=jday,y=mnVal_hist,color="mnVal_hist"),size=1.2)+
      theme_minimal()+ylab(varIN)
    p
    jpeg(filename =paste0("Data/out/K20P19_CMIP6/BC_ACLIMregion/plots/",sim,"/",varIN,".jpg") , width=8,height =4,units = "in",res = 350)
    print(p)
    dev.off()
    rm(p)
    p <- ggplot(data=fut%>%filter(var==varIN,strata==70,year%in%c(2024,2050,2090)))+
      geom_line(aes(x=jday,y=val_raw,linetype="raw",color=factor(year)),size=.8)+
      geom_line(aes(x=jday,y=val_delta,
                    linetype="val_delta",color=factor(year)),size=.8)+
      geom_line(aes(x=jday,y=mnVal_hind,color="mnVal_hind"),size=1.2)+
      geom_line(aes(x=jday,y=mnVal_hist,color="mnVal_hist"),size=1.2)+
      theme_minimal()+ylab(varIN)
    p
    jpeg(filename =paste0("Data/out/K20P19_CMIP6/BC_ACLIMregion/plots/",sim,"/",varIN,"delta.jpg") , width=8,height =4,units = "in",res = 350)
    print(p)
    dev.off()
    rm(p)
  }
  rm(list=c("fut"))
}
}