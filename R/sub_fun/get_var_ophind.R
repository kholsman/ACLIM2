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


get_var_ophind <- function(
  typeIN    = "annual", #ACLIM2 Index Type"
  plotvar = "temp_bottom5m",  #variable to plot
  plothist = T,
  adjIN = "val_delta",
  ifmissingyrs = 5,
  stitchDateIN = stitchDate,
  monthIN   = NULL, #"Month
  weekIN    = NULL, #"Week"
  SeasonIN  = NULL, #,"Season",selected=seasons,choices=seasons, multiple=T),
  jday_rangeIN = NULL, #c(0,365), #
  CMIPIN    = "K20P19_CMIP6", 
  bcIN      = c("raw","bias corrected"),# "bias corrected or raw",
  GCMIN     = NULL, #
  scenIN    = NULL,
  plotbasin  = c("SEBS"),
  facet_rowIN  = "bc", #choices=c("bc","basin","scen")
  facet_colIN  = "scen", # ,"col",selected=c("scen"),choices=c("bc","basin","scen"), multiple=F),
  removeyr1    = T  #"Remove first year of projection ( burn in)"
){
  scenINuse <- scenIN
  
  for(c in 1:length(CMIPIN)){
    load(paste0("Data/out/",CMIPIN[c],"/allEBS_means/ACLIM_",typeIN,"_operational_hind_mn.Rdata"))
    eval(parse(text = paste0("dhindIN_op <- ACLIM_",typeIN,"_hind")))
    eval(parse(text = paste0("rm(ACLIM_",typeIN,"_hind)")))

    load(paste0("Data/out/",CMIPIN[c],"/allEBS_means/ACLIM_",typeIN,"_hind_mn.Rdata"))
    load(paste0("Data/out/",CMIPIN[c],"/allEBS_means/ACLIM_",typeIN,"_hist_mn.Rdata"))
    load(paste0("Data/out/",CMIPIN[c],"/allEBS_means/ACLIM_",typeIN,"_fut_mn.Rdata"))
    
    eval(parse(text = paste0("dhindIN <- ACLIM_",typeIN,"_hind")))
    eval(parse(text = paste0("dhistIN <- ACLIM_",typeIN,"_hist")))
    eval(parse(text = paste0("dfut <- ACLIM_",typeIN,"_fut")))
    
    groupbyIN <- c("year")
    
    if(typeIN == "monthly"){
      cat("monthly\n")
      months  <- unique(c(dhindIN_op$mo,dhindIN$mo))
      seasons <- unique(c(dhindIN_op$season,dhindIN$season))
      groupbyIN <- c("year","season","mo")
      print(groupbyIN)
    }
    
    if(typeIN == "seasonal"){
      cat("seasonal\n")
      seasons   <- unique(c(dhindIN_op$season,dhindIN$season))
      groupbyIN <- c("year","season")
    }
    
    if(typeIN == "weekly"){
      cat("weekly\n")
      weeks <- unique(c(dhindIN_op$wk,dhindIN$wk))
      months <- unique(c(dhindIN_op$mo,dhindIN$mo))
      seasons <- unique(c(dhindIN_op$season,dhindIN$season))
      groupbyIN <- c("year","season","mo","wk")
    }
    
    if(removeyr1){
      yrin  <- sort(unique(dfut$year))[1]
      dfut  <- dfut%>%dplyr::filter(year>yrin)
    }
    CMIP       <- CMIPIN[c]
    if(is.null(scenIN))
      scenINuse <- unique(dfut$RCP)
    
    for(s in 1:length(scenINuse)){
      
      if(s ==1){
        
        dhinda <- dhindIN%>%
          dplyr::mutate(scen = scenINuse[s],gcmcmip="hind",GCM ="hind",GCM2="hind")%>%
          filter(mnDate<=stitchDateIN)
        dhind_op <- dhindIN_op%>%
          dplyr::mutate(scen = scenINuse[s],gcmcmip="hind",GCM ="hind",GCM2="hind_op")%>%
          filter(mnDate>stitchDateIN)
        
        # combine operational and hindcast
        dhind <- rbind(dhinda,dhind_op)
        
        dhist <- dhistIN%>%
          dplyr::mutate(scen = scenINuse[s],gcmcmip="hist",GCM2="hist")
      }
      if(s>1){
        dhinda <- dhindIN%>%dplyr::mutate(scen = scenINuse[s],gcmcmip="hind",GCM ="hind",GCM2="hind")%>%
          filter(mnDate<=stitchDateIN)
        dhind_op <- dhindIN_op%>%dplyr::mutate(scen = scenINuse[s],gcmcmip="hind",GCM ="hind",GCM2="hind_op")%>%
          filter(mnDate>stitchDateIN)
        dhindb <- rbind(dhinda,dhind_op)
        
        dhind <- rbind(dhind,dhindb)
        dhist <- rbind(dhist,dhistIN%>%dplyr::mutate(scen = scenINuse[s],gcmcmip="hist",GCM2="hist"))
      }
    }
    dhind <- dhind%>%mutate(sim = "ACLIM + Operational Hindcast")
    #dhind<-dhind%>%ungroup()%>%group_by(all_of(c("var",groupbyIN)))%>%ungroup()
    dhind_op <- dhind%>%filter(GCM2 =="hind_op")
    sellist  <- c(groupbyIN,"var","basin", "jday","mnDate","val_raw","mn_val","sd_val", "sim","gcmcmip","GCM",
                  "GCM2","scen","sim_type")
    if(any(dhind_op$var%in%plotvar)){
     
      hind     <- dhind%>%dplyr::filter(var ==plotvar,basin==plotbasin)%>%
        dplyr::select(all_of(c(sellist,"mnVal_hind")))%>%
        mutate(val_delta = mn_val,val_biascorrected=mn_val)
      hist     <- dhist%>%dplyr::filter(var ==plotvar,basin==plotbasin)%>%
        dplyr::select(all_of(sellist))%>%
        mutate(mnVal_hind=NA,val_delta = mn_val,val_biascorrected=mn_val)
      
      fut      <- dfut%>%dplyr::filter(var ==plotvar,basin==plotbasin)%>%mutate(GCM2 = GCM,scen=RCP)%>%
        dplyr::select(all_of(c(sellist,"mnVal_hind","val_delta","val_biascorrected")))
     
    }else{
      # interpolate using "mean" from ACLIM hindcast (eg. pH)
      hind0     <- dhind%>%dplyr::filter(var ==plotvar,basin==plotbasin,GCM2 =="hind")%>%
        dplyr::select(all_of(c(sellist,"mnVal_hind")))%>%
        mutate(val_delta = mn_val,val_biascorrected=mn_val)
      hist     <- dhist%>%dplyr::filter(var ==plotvar,basin==plotbasin)%>%
        dplyr::select(all_of(sellist))%>%
        mutate(mnVal_hind=NA,val_delta = mn_val,val_biascorrected=mn_val)
      
      fut      <- dfut%>%dplyr::filter(var ==plotvar,basin==plotbasin)%>%mutate(GCM2 = GCM,scen=RCP)%>%
        dplyr::select(all_of(c(sellist,"mnVal_hind","val_delta","val_biascorrected")))
      
      lastyr <- max( hind0%>%select(year))
      subyr  <- (-(ifmissingyrs-1):0)+lastyr
      maxyr  <- max( dhind_op%>%select(year))
      glist <- c(sellist[!sellist%in%c("year","mnDate","jday","mn_val")])
      # which years to fill in for:
      fillyr <- (lastyr+1):maxyr
      
      # Empty matrix values from operational hindcast to fill in for missing years:
      fillmat <- dhind_op%>%
        select(all_of(c(sellist[!sellist%in%c("mn_val","var","sim","GCM2")],"mnVal_hind")))%>%
       distinct()%>%mutate(var=plotvar)%>%select(-val_raw,-sd_val,-mnVal_hind)
      
      # get mean from subset of hindcast years (ACLIM hindcast):
      mn     <- dhind%>%
        dplyr::filter(year%in%subyr)%>%
        group_by(across(glist))%>%mutate(GCM2="mean hind")%>%
        summarize(mn_val = mean(mn_val, na.rm = T),
                  sd_val = mean(sd_val, na.rm = T),
                  mnVal_hind = mean (mnVal_hind,na.rm=T))
      
      hind  <- rbind(hind0,fillmat%>%left_join(mn)%>%dplyr::filter(var ==plotvar,basin==plotbasin)%>%
                     dplyr::select(all_of(c(sellist,"mnVal_hind")))%>%
                     mutate(val_delta = mn_val,val_biascorrected=mn_val))
     # names(dhind)
    }
    
    # get raw values
    fut  <- fut%>%mutate(val_use  = val_raw)
    hist <- hist%>%mutate(val_use = mn_val)
    hind <- hind%>%mutate(val_use = mn_val)
    plotdat    <- rbind(hind,hist,fut)%>%dplyr::mutate(bc = "raw")
    
    # get adj values
    hind_bc    <- hind%>%dplyr::mutate(val_use = mn_val,   bc="bias corrected")
    eval(parse(text = paste0("fut_bc <- fut%>%dplyr::mutate(val_use  = ",
                             adjIN,",bc='bias corrected')") ))
    fut_bc     <- rbind(hind_bc,fut_bc)
    
    plotdat               <- rbind(plotdat,fut_bc)
    plotdat$bc            <- factor(plotdat$bc, levels =c("raw","bias corrected"))
    plotdat$GCM_scen      <- paste0(plotdat$GCM,"_",plotdat$scen) 
    plotdat$GCM_scen_sim  <- paste0(plotdat$GCM,"_",plotdat$scen,"_",plotdat$sim_type) 
    plotdat$GCM2_scen_sim <- paste0(plotdat$GCM2,"_",plotdat$scen,"_",plotdat$sim_type) 
    plotdat$CMIP <- CMIPIN[c]
    
    if(c ==1 ){
      plotdatout <- plotdat
    }else{
      plotdatout <- rbind(plotdatout,plotdat)
    }
    
  }
  if(is.null(scenIN))
    scenINuse <- unique(plotdatout$scen)
  
  if(is.null(GCMIN))
    GCMIN <- unique(plotdatout$GCM)
  
  gcmlist<- GCMIN
  if(!grep("hind",GCMIN)>0)
    gcmlist<- c("hind",GCMIN)
  
  if(plothist)
    gcmlist<- unique(c("hind","hist",GCMIN))
  
  plotdatout <- plotdatout%>%dplyr::filter(
    scen%in%scenINuse,GCM%in%gcmlist,
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
  #units      <- plotdatout$units[1]
  plotdatout$type <- typeIN
  
  nyrs       <- length(unique(plotdatout$year))
  spanIN     <- 5/nyrs
  dat        <- plotdatout%>%ungroup()
  #   
  #   return(list(dat=plotdatout,nyrs = nyrs, units = units,spanIN=spanIN, weeks=weeks,months=months,seasons=seasons,
  #               plotvar = plotvar,facet_row=facet_row,facet_col=facet_col,plotbasin=plotbasin))
  # })
  
  pp<- ggplot(dat)+
    
    geom_line(aes(x=mnDate,y=val_use,color= GCM_scen,linetype = basin),alpha = 0.6,show.legend = FALSE)+
    geom_smooth(aes(x=mnDate,y=val_use,color= GCM_scen,fill=GCM_scen_sim,linetype = basin),alpha=0.1,method="loess",formula='y ~ x',span = .5)+
    theme_minimal() + 
    labs(x="Date",
         #y=plotvar,"(",units,")"),
         subtitle = "",
         legend = "",
         title = paste(plotvar,"(",plotbasin,",",typeIN,")"))+
    scale_color_discrete()
  eval(parse(text = paste0("pp <-pp+facet_grid(",facet_rowIN,"~",facet_colIN,")") ))
  
  return(list(dat=plotdatout%>%select(-mn_val)%>%ungroup()%>%relocate(all_of(c(groupbyIN,"basin","var","val_use","sd_val",
                                                                   "val_raw"))), plot=pp))
}
