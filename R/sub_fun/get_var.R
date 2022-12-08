#'
#'
#'
#'get_var
#'


get_var <- function(
  typeIN    = "annual", #ACLIM2 Index Type"
  plotvar = "temp_bottom5m",  #variable to plot
  plothist = T,
  monthIN   = 6:9, #"Month
  weekIN    = 1:10, #"Week"
  SeasonIN  = "Summer", #,"Season",selected=seasons,choices=seasons, multiple=T),
  CMIPIN    = "K20P19_CMIP6", 
  bcIN      = c("raw","bias corrected"),# "bias corrected or raw",
  GCMIN     = c("miroc" ,"gfdl" , "cesm" ), #
  scenIN    = c("ssp126", "ssp585"),
  jday_rangeIN = c(0,365), #"
  plotbasin  = c("SEBS"),
  facet_rowIN  = "bc", #choices=c("bc","basin","scen")
  facet_colIN  = "scen", # ,"col",selected=c("scen"),choices=c("bc","basin","scen"), multiple=F),
  removeyr1    = T  #"Remove first year of projection ( burn in)"
  ){
  
  for(c in 1:length(CMIPIN)){
    load(paste0("Data/out/",CMIPIN[c],"/allEBS_means/ACLIM_",typeIN,"_hind_mn.Rdata"))
    load(paste0("Data/out/",CMIPIN[c],"/allEBS_means/ACLIM_",typeIN,"_hist_mn.Rdata"))
    load(paste0("Data/out/",CMIPIN[c],"/allEBS_means/ACLIM_",typeIN,"_fut_mn.Rdata"))
    
    eval(parse(text = paste0("dhindIN <- ACLIM_",typeIN,"_hind")))
    eval(parse(text = paste0("dhistIN <- ACLIM_",typeIN,"_hist")))
    eval(parse(text = paste0("dfut <- ACLIM_",typeIN,"_fut")))
    #load(paste0("Data/out/",CMIP[c],"/allEBS_means/ACLIM_annual_fut_mn.Rdata"))
    #plotvars   <- unique(ACLIM_annual_hind$var)
    if(typeIN == "monthly"){
     
        months <- unique(dhindIN$mo)
        seasons <- unique(dhindIN$season)
        }

    if(typeIN == "seasonal"){
      seasons <- unique(dhindIN$season)}
    
    if(typeIN == "weekly"){
      weeks <- unique(dhindIN$wk)
      months <- unique(dhindIN$mo)
      seasons <- unique(dhindIN$season)}
    
    
    if(removeyr1){
      yrin <- sort(unique(dfut$year))[1]
      dfut  <- dfut%>%dplyr::filter(year>yrin)
    }
    CMIP       <- CMIPIN[c]
    
    for(s in 1:length(scenIN)){
      
      if(s ==1){
        dhind <- dhindIN%>%dplyr::mutate(scen = scenIN[s],gcmcmip="hind",GCM ="hind")
        dhist <- dhistIN%>%dplyr::mutate(scen = scenIN[s],gcmcmip="hist")
      }
      if(s>1){
        dhind <- rbind(dhind,dhindIN%>%dplyr::mutate(scen = scenIN[s],gcmcmip="hind",GCM ="hind"))
        dhist <- rbind(dhist,dhistIN%>%dplyr::mutate(scen = scenIN[s],gcmcmip="hist"))
      }
        
      
    }
    
    hind     <- dhind%>%dplyr::filter(var ==plotvar,basin==plotbasin)%>%dplyr::select(var,basin,year, jday,mnDate,mn_val, sim,gcmcmip,GCM,scen,sim_type ,units)
    hist     <- dhist%>%dplyr::filter(var ==plotvar,basin==plotbasin)%>%dplyr::select(var,basin,year, jday,mnDate,mn_val, sim,gcmcmip,GCM,scen,sim_type ,units)
  
    fut      <- dfut%>%dplyr::filter(var ==plotvar,basin==plotbasin)%>%dplyr::select(var,basin,year, jday,mnDate,mn_val, sim,gcmcmip,GCM,scen,sim_type ,units)
    
    
    plotdat    <- rbind(hind,hist,fut)%>%dplyr::mutate(bc = "raw")
   
    # print(head(plotdat))
    # print(plotdat$GCM[1:3])
    # print(plotdat$scen[1:3])
    
    hind_bc    <- dhind%>%dplyr::filter(var ==plotvar,basin==plotbasin)%>%dplyr::select(var,basin,year, jday,mnDate,mn_val, sim,gcmcmip,GCM,scen,sim_type ,units)%>%dplyr::mutate(bc="bias corrected")
    fut_bc     <- dfut%>%dplyr::filter(var ==plotvar,basin==plotbasin)%>%dplyr::select(var,basin,year, jday,mnDate,val_biascorrected, sim,gcmcmip,GCM,scen,sim_type ,units)
    fut_bc     <- fut_bc%>%dplyr::mutate(bc="bias corrected")%>%rename(mn_val = val_biascorrected)
    fut_bc     <-rbind(hind_bc,fut_bc)
    
    plotdat          <- rbind(plotdat,fut_bc)
    plotdat$bc       <- factor(plotdat$bc, levels =c("raw","bias corrected"))
    plotdat$GCM_scen <- paste0(plotdat$GCM,"_",plotdat$scen) 
    
    plotdat$GCM_scen_sim <- paste0(plotdat$GCM,"_",plotdat$scen,"_",plotdat$sim_type) 
    plotdat$CMIP <- CMIPIN[c]
    
    if(c ==1 ){
      plotdatout <- plotdat
    }else{
      plotdatout <- rbind(plotdatout,plotdat)
    }
    
  }
  
  gcmlist<- c("hind",GCMIN)
  if(plothist)
    gcmlist<- c("hind","hist",GCMIN)
  plotdatout <- plotdatout%>%dplyr::filter(
    scen%in%scenIN,GCM%in%gcmlist,
    bc%in%bcIN,
    dplyr::between(jday, jday_rangeIN[1], jday_rangeIN[2]))
  if(!plothist)
    plotdatout<- plotdatout%>%dplyr::filter(gcmcmip!="hist")
  units      <- plotdatout$units[1]
  plotdatout$type <- typeIN
  
  nyrs       <- length(unique(plotdatout$year))
  spanIN     <- 5/nyrs
  dat        <- plotdatout%>%ungroup()
#   
#   return(list(dat=plotdatout,nyrs = nyrs, units = units,spanIN=spanIN, weeks=weeks,months=months,seasons=seasons,
#               plotvar = plotvar,facet_row=facet_row,facet_col=facet_col,plotbasin=plotbasin))
# })

  pp<- ggplot(dat)+
    
    geom_line(aes(x=mnDate,y=mn_val,color= GCM_scen,linetype = basin),alpha = 0.6,show.legend = FALSE)+
    geom_smooth(aes(x=mnDate,y=mn_val,color= GCM_scen,fill=GCM_scen_sim,linetype = basin),alpha=0.1,method="loess",formula='y ~ x',span = .5)+
    theme_minimal() + 
    labs(x="Date",
         y=paste(plotvar,"(",units,")"),
         subtitle = "",
         legend = "",
         title = paste(plotvar,"(",plotbasin,",",typeIN,")"))+
    scale_color_discrete()
  eval(parse(text = paste0("pp <-pp+facet_grid(",facet_rowIN,"~",facet_colIN,")") ))
  
  return(list(dat=plotdatout, plot=pp))
}
