#'
#'
#'
#'get_var_ophind.R
#'

#'
#'
#'
#'get_var
#'


get_var<- function(
  typeIN    = "annual", #ACLIM2 Index Type"
  plotvar   = "temp_bottom5m",  #variable to plot
  plothist     = T,
  ifmissingyrs = 5,
  stitchDateIN = stitchDate,
  monthIN   = NULL, #"Month
  weekIN    = NULL, #"Week"
  SeasonIN  = NULL, #,"Season",selected=seasons,choices=seasons, multiple=T),
  jday_rangeIN = NULL, #c(0,365), #
  CMIPIN    = "K20P19_CMIP6", 
  bcIN      = c("raw","bias corrected"),# "bias corrected or raw",
  GCMIN     = c("miroc" ,"gfdl" , "cesm" ), #
  scenIN    = c("ssp126", "ssp585"),
  plotbasin    = c("SEBS"),
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
    
    groupbyIN <- c("year")
    
    if(typeIN == "monthly"){
      cat("monthly\n")
      months  <- unique(c(dhindIN$mo))
      seasons <- unique(c(dhindIN$season))
      groupbyIN <- c("year","season","mo")
      print(groupbyIN)
    }
    
    if(typeIN == "seasonal"){
      cat("seasonal\n")
      seasons   <- unique(c(dhindIN$season))
      groupbyIN <- c("year","season")
    }
    
    if(typeIN == "weekly"){
      cat("weekly\n")
      weeks <- unique(c(dhindIN$wk))
      months <- unique(c(dhindIN$mo))
      seasons <- unique(c(dhindIN$season))
      groupbyIN <- c("year","season","mo","wk")
    }
    
    if(removeyr1){
      yrin  <- sort(unique(dfut$year))[1]
      dfut  <- dfut%>%dplyr::filter(year>yrin)
    }
    CMIP       <- CMIPIN[c]
    
    for(s in 1:length(scenIN)){
      
      if(s ==1){
        dhind <- dhindIN%>%
          dplyr::mutate(scen = scenIN[s],gcmcmip="hind",GCM ="hind",GCM2="hind")
        dhist <- dhistIN%>%
          dplyr::mutate(scen = scenIN[s],gcmcmip="hist",GCM2="hist")
      }
      if(s>1){
        dhind <- rbind(dhind,dhindIN%>%dplyr::mutate(scen = scenIN[s],gcmcmip="hind",GCM ="hind",GCM2="hind"))
        dhist <- rbind(dhist,dhistIN%>%dplyr::mutate(scen = scenIN[s],gcmcmip="hist",GCM2="hist"))
      }
    }
    
    #dhind<-dhind%>%ungroup()%>%group_by(all_of(c("var",groupbyIN)))%>%ungroup()
    sellist  <- c(groupbyIN,"var","basin", "jday","mnDate","val_raw","mn_val","sd_val", "sim","gcmcmip","GCM",
                  "GCM2","scen","sim_type" ,"units")
   
      
      hind     <- dhind%>%dplyr::filter(var ==plotvar,basin==plotbasin,GCM2 =="hind")%>%
        dplyr::select(all_of(c(sellist,"mnVal_hind")))%>%
        mutate(val_delta = mn_val,val_biascorrected=mn_val)
      hist     <- dhist%>%dplyr::filter(var ==plotvar,basin==plotbasin)%>%
        dplyr::select(all_of(sellist))%>%
        mutate(mnVal_hind=NA,val_delta = mn_val,val_biascorrected=mn_val)
      
      fut      <- dfut%>%dplyr::filter(var ==plotvar,basin==plotbasin)%>%mutate(GCM2 = GCM)%>%
        dplyr::select(all_of(c(sellist,"mnVal_hind","val_delta","val_biascorrected")))
      
    fut  <- fut%>%mutate(val_use=mn_val)
    hist <- hist%>%mutate(val_use=mn_val)
    hind <- hind%>%mutate(val_use=mn_val)
    plotdat    <- rbind(hind,hist,fut)%>%dplyr::mutate(bc = "raw")
    hind_bc    <- hind%>%dplyr::mutate(val_use = mn_val, bc="bias corrected")
    fut_bc     <- fut%>%dplyr::mutate(val_use = val_delta,bc="bias corrected")
    fut_bc     <-rbind(hind_bc,fut_bc)
    
    plotdat          <- rbind(plotdat,fut_bc)
    plotdat$bc       <- factor(plotdat$bc, levels =c("raw","bias corrected"))
    plotdat$GCM_scen <- paste0(plotdat$GCM,"_",plotdat$scen) 
    plotdat$GCM_scen_sim  <- paste0(plotdat$GCM,"_",plotdat$scen,"_",plotdat$sim_type) 
    plotdat$GCM2_scen_sim <- paste0(plotdat$GCM2,"_",plotdat$scen,"_",plotdat$sim_type) 
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
    bc%in%bcIN)
  
  if(!is.null(SeasonIN))
    plotdatout <- plotdatout%>%dplyr::filter(season%in% SeasonIN)
  if(!is.null(monthIN))
    plotdatout <- plotdatout%>%dplyr::filter(mo%in% monthIN)
  if(!is.null(weekIN))
    plotdatout <- plotdatout%>%dplyr::filter(wk%in% weekIN)
  if(!is.null(jday_rangeIN))
    plotdatout <- plotdatout%>%dplyr::filter(dplyr::between(jday, jday_rangeIN[1], jday_rangeIN[2]))
  
  if(!plothist)
    plotdatout<- plotdatout%>%dplyr::filter(gcmcmip!="hist")
  units      <- plotdatout$units[1]
  plotdatout$type <- typeIN
  
  nyrs       <- length(unique(plotdatout$year))
  spanIN     <- 5/nyrs
  dat        <- plotdatout%>%ungroup()

  pp<- ggplot(dat)+
    
    geom_line(aes(x=mnDate,y=val_use,color= GCM_scen,linetype = basin),alpha = 0.6,show.legend = FALSE)+
    geom_smooth(aes(x=mnDate,y=val_use,color= GCM_scen,fill=GCM_scen_sim,linetype = basin),alpha=0.1,method="loess",formula='y ~ x',span = .5)+
    theme_minimal() + 
    labs(x="Date",
         y=paste(plotvar,"(",units,")"),
         subtitle = "",
         legend = "",
         title = paste(plotvar,"(",plotbasin,",",typeIN,")"))+
    scale_color_discrete()
  eval(parse(text = paste0("pp <-pp+facet_grid(",facet_rowIN,"~",facet_colIN,")") ))
  
  return(list(dat=plotdatout%>%select(-mn_val)%>%ungroup()%>%relocate(all_of(c(groupbyIN,"basin","var","val_use","sd_val",
                                                                               "val_raw"))), plot=pp))
}
