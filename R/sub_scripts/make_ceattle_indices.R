#'
#'
#'
#'get_ceattle_indices.R
#'

    # Load setup
    #--------------------------------------
    suppressMessages(source("R/make.R"))
    
    CMIPset <- c("K20P19_CMIP6","K20P19_CMIP5")
    # preview possible variables
    load(file = "Data/out/weekly_vars.Rdata")
    load(file = "Data/out/srvy_vars.Rdata")
    load(file = file.path(Rdata_path,
                          "../","normlist.Rdata"))
    
    #load hind data to get var names
    load(paste0("Data/out/K20P19_CMIP6/allEBS_means/ACLIM_annual_hind_mn.Rdata"))
    varall  <- unique(ACLIM_annual_hind$var)
   
    # set the date to stitch the ACLIM hindcast to the operational hindcats to the proj
    stitchDate     <- "2019-12-30"  # last date of the ACLIM hindcast
    #stitchDate_op  <- "2022-05-16"  #last operational hindcast date # can't be mid year for these
    stitchDate_op  <- "2021-12-30"  #last operational hindcast date
    scens   <- c("ssp126", "ssp585")
    GCMs    <- c("miroc", "gfdl", "cesm" )
    
    # Now compile the indices:
    #--------------------------------------
    grpby <- c("type","var","basin",
               "year","sim","gcmcmip","GCM","scen","sim_type",
               "bc","GCM_scen","GCM_scen_sim", "CMIP" )
    
    sumat  <- c("jday","mnDate","val_use","mnVal_hind",
                "val_delta","val_biascorrected","val_raw")
    
    
    # make CEATTLE_indices.csv using the ACLIM hindcast only as well as 
    #      CEATTLE_indices_op.csv, the operational hindcast filled in for 2019-2022
    #--------------------------------------
    
    
    # Ph In Jan- Mar (Winter)
    #--------------------------------------
    
    varlist <- "pH_depthavg"
    for(v in varlist){
      # get the variable you want:
      dfop <- get_var_ophind(stitchDateIN = stitchDate, 
                             typeIN    = "seasonal", 
                             SeasonIN  =  "Winter",
                             plotbasin = c("SEBS"),
                             plotvar   = v,
                             bcIN      = "bias corrected",
                             CMIPIN    = CMIPset,
                             plothist     = T,  # ignore the hist runs
                             removeyr1    = T,
                             adjIN        = "val_delta",
                             ifmissingyrs = 5,
                             weekIN       = NULL, #"Week"
                             monthIN      = NULL, 
                             GCMIN        = NULL, 
                             scenIN       = NULL,
                             facet_rowIN  = "bc", # choices=c("bc","basin","scen")
                             facet_colIN  = "scen")  # "Remove first year of proj ( burn in)")
      tmpdop <- dfop$dat%>%
        group_by(across(all_of(c(grpby,"season","GCM2","GCM2_scen_sim"))))%>%
        summarize_at(all_of(sumat), mean, na.rm=T)%>%
        mutate(mn_val=val_use, var_raw = var, var = paste0(season,"_",var))%>%
        select(-season)
      tmpdop <- stitchTS(dat = tmpdop, stitchDate_op)
      tmpdop <- tmpdop%>%mutate(type = "ceattle indices")
      ceattle_vars_op <- tmpdop
      rm(dfop)
      rm(tmpdop)    
      
    }
    
    # summer values  (Jul-Aug)
    #--------------------------------------
    
    varlist <- c("fracbelow1","fracbelow2")
    for(v in varlist){
      # now for operational hindcasts:
      dfop <- get_var_ophind(stitchDateIN = stitchDate, 
                             typeIN    = "seasonal", 
                             SeasonIN =  "Summer",
                             plotbasin  = c("SEBS"),
                             plotvar   = v,
                             bcIN      = "bias corrected",
                             CMIPIN    = CMIPset,
                             plothist     = T,  # ignore the hist runs
                             removeyr1    = T,
                             adjIN        = "val_delta",
                             ifmissingyrs = 5,
                             weekIN       = NULL, #"Week"
                             monthIN     = NULL, 
                             GCMIN        = NULL, 
                             scenIN       = NULL,
                             facet_rowIN  = "bc", # choices=c("bc","basin","scen")
                             facet_colIN  = "scen") 
      tmpdop <- dfop$dat%>%
        group_by(across(all_of(c(grpby,"season","GCM2","GCM2_scen_sim"))))%>%
        summarize_at(all_of(sumat), mean, na.rm=T)%>%mutate(mn_val=val_use, var_raw = var, var = paste0(season,"_",var))%>%select(-season)
      tmpdop <- stitchTS(dat = tmpdop, stitchDate_op)
      tmpdop <- tmpdop%>%mutate(type = "ceattle indices")
      ceattle_vars_op <- rbind(ceattle_vars_op,tmpdop)
      rm(dfop)
      rm(tmpdop)    
    }
    
    # spring values
    #--------------------------------------
    
    varlist <- c("vNorth_surface5m","uEast_surface5m",
                 "PhL_integrated","PhS_integrated")
    for(v in varlist){
      # now for operational hindcasts:
      dfop <- get_var_ophind(stitchDateIN = stitchDate, 
                             typeIN    = "seasonal", 
                             SeasonIN =  "Spring",
                             plotbasin  = c("SEBS"),
                             plotvar   = v,
                             bcIN      = "bias corrected",
                             CMIPIN    = CMIPset,
                             plothist     = T,  # ignore the hist runs
                             removeyr1    = T,
                             adjIN        = "val_delta",
                             ifmissingyrs = 5,
                             weekIN       = NULL, #"Week"
                             monthIN     = NULL, 
                             GCMIN        = NULL, 
                             scenIN       = NULL,
                             facet_rowIN  = "bc", # choices=c("bc","basin","scen")
                             facet_colIN  = "scen")
      tmpdop <- dfop$dat%>%
        group_by(across(all_of(c(grpby,"season","GCM2","GCM2_scen_sim"))))%>%
        summarize_at(all_of(sumat), mean, na.rm=T)%>%mutate(mn_val=val_use, var_raw = var, var = paste0(season,"_",var))%>%select(-season)
      tmpdop <- stitchTS(dat = tmpdop, stitchDate_op)
      tmpdop <- tmpdop%>%mutate(type = "ceattle indices")
      ceattle_vars_op <- rbind(ceattle_vars_op,tmpdop)
      rm(dfop)
      rm(tmpdop)    
    }
    
    # every seasonal values
    #--------------------------------------
    
    varlist <- c("temp_surface5m", "temp_bottom5m",
                 "oxygen_bottom5m","Cop_integrated","EupS_integrated",
                 "NCaS_integrated","largeZoop_integrated")
    for(v in varlist){
      
      # now for operational hindcasts:
      dfop <- get_var_ophind(stitchDateIN = stitchDate, 
                             typeIN    = "seasonal", 
                             SeasonIN =  levels(seasons$season),
                             plotbasin  = c("SEBS"),
                             plotvar   = v,
                             bcIN      = "bias corrected",
                             CMIPIN    = CMIPset,
                             plothist     = T,  # ignore the hist runs
                             removeyr1    = T,
                             adjIN        = "val_delta",
                             ifmissingyrs = 5,
                             weekIN       = NULL, #"Week"
                             monthIN     = NULL, 
                             GCMIN        = NULL, 
                             scenIN       = NULL,
                             facet_rowIN  = "bc", # choices=c("bc","basin","scen")
                             facet_colIN  = "scen") 
      tmpdop <- dfop$dat%>%
        group_by(across(all_of(c(grpby,"season","GCM2","GCM2_scen_sim"))))%>%
        summarize_at(all_of(sumat), mean, na.rm=T)%>%mutate(mn_val=val_use, var_raw = var, var = paste0(season,"_",var))%>%select(-season)
      tmpdop <- stitchTS(dat = tmpdop, stitchDate_op)
      tmpdop <- tmpdop%>%mutate(type = "ceattle indices")
      ceattle_vars_op <- rbind(ceattle_vars_op,tmpdop)
      rm(dfop)
      rm(tmpdop)    
    }
    
    # annual values
    #--------------------------------------
    
    varlist <- c("temp_surface5m", "temp_bottom5m")
    for(v in varlist){
      
      # now for operational hindcasts:
      dfop <- get_var_ophind(stitchDateIN = stitchDate, 
                             typeIN    = "annual", 
                             plotbasin  = c("SEBS"),
                             plotvar   = v,
                             bcIN      = "bias corrected",
                             CMIPIN    = CMIPset,
                             plothist     = T,  # ignore the hist runs
                             removeyr1    = T,
                             adjIN        = "val_delta",
                             ifmissingyrs = 5,
                             weekIN       = NULL, #"Week"
                             monthIN      = NULL, 
                             SeasonIN     = NULL, 
                             GCMIN        = NULL, 
                             scenIN       = NULL,
                             facet_rowIN  = "bc", # choices=c("bc","basin","scen")
                             facet_colIN  = "scen") 
      tmpdop <- dfop$dat%>%mutate(season="annual")%>%
        group_by(across(all_of(c(grpby,"season","GCM2","GCM2_scen_sim"))))%>%
        summarize_at(all_of(sumat), mean, na.rm=T)%>%mutate(mn_val=val_use, var_raw = var, var = paste0("annual_",var))%>%select(-season)
      tmpdop <- stitchTS(dat = tmpdop, stitchDate_op)
      tmpdop <- tmpdop%>%mutate(type = "ceattle indices")
      ceattle_vars_op <- rbind(ceattle_vars_op,tmpdop)
      rm(dfop)
      rm(tmpdop)    
    }
    
    # seasonal values
    #--------------------------------------
    
    varlist <- c("vNorth_surface5m","uEast_surface5m")
    
      
      # now for operational hindcasts:
      dN <- get_var_ophind(stitchDateIN = stitchDate, 
                             typeIN    = "seasonal", 
                             SeasonIN =  levels(seasons$season),
                             plotbasin  = c("SEBS"),
                             plotvar   = "vNorth_surface5m",
                             bcIN      = "bias corrected",
                             CMIPIN    = CMIPset,
                             plothist     = T,  # ignore the hist runs
                             removeyr1    = T,
                             adjIN        = "val_delta",
                             ifmissingyrs = 5,
                             weekIN       = NULL, #"Week"
                             monthIN     = NULL, 
                             GCMIN        = NULL, 
                             scenIN       = NULL,
                             facet_rowIN  = "bc", # choices=c("bc","basin","scen")
                             facet_colIN  = "scen") 
      # now for operational hindcasts:
      dE <- get_var_ophind(stitchDateIN = stitchDate, 
                              typeIN    = "seasonal", 
                              SeasonIN =  levels(seasons$season),
                              plotbasin  = c("SEBS"),
                              plotvar   = "uEast_surface5m",
                              bcIN      = "bias corrected",
                             CMIPIN    = CMIPset,
                             plothist     = T,  # ignore the hist runs
                             removeyr1    = T,
                             adjIN        = "val_delta",
                             ifmissingyrs = 5,
                             weekIN       = NULL, #"Week"
                             monthIN     = NULL, 
                             GCMIN        = NULL, 
                             scenIN       = NULL,
                             facet_rowIN  = "bc", # choices=c("bc","basin","scen")
                             facet_colIN  = "scen") 
      
      dfopE <-dE$dat%>%rename(uE = val_use,uE_raw = val_raw)%>%mutate(var="NE_winds",units="meter second-1")%>%select(-sd_val)
      dfopN <-dN$dat%>%rename(vN = val_use,vN_raw = val_raw)%>%mutate(var="NE_winds",units="meter second-1")%>%select(-sd_val)
      dfop<-dfopN%>%left_join(dfopE%>%select(all_of(c(grpby,"season","uE","uE_raw"))))
    
      dfop$val_use <-getNE_winds(vNorth=dfop$vN,uEast=dfop$uE)
      dfop$val_raw <-getNE_winds(vNorth=dfop$vN_raw,uEast=dfop$uE_raw)
      head(data.frame(dfop%>%filter(year>2030,GCM=="miroc",scen=="ssp585")))
      tmpdop <- dfop%>%
        group_by(across(all_of(c(grpby,"season","GCM2","GCM2_scen_sim"))))%>%
        summarize_at(all_of(sumat), mean, na.rm=T)%>%mutate(mn_val=val_use, var_raw = var, var = paste0(season,"_",var))%>%select(-season)
      tmpdop <- stitchTS(dat = tmpdop, stitchDate_op)
      tmpdop <- tmpdop%>%mutate(type = "ceattle indices")
      ceattle_vars_op <- rbind(ceattle_vars_op,tmpdop)
      rm(dfop)
      rm(tmpdop)   
      
       
      # now for operational hindcasts:
      #--------------------------------------
      
      dN <- get_var_ophind(stitchDateIN = stitchDate, 
                           typeIN    = "annual", 
                           plotbasin  = c("SEBS"),
                           plotvar   = "vNorth_surface5m",
                           bcIN      = "bias corrected",
                           CMIPIN    = CMIPset,
                           plothist     = T,  # ignore the hist runs
                           removeyr1    = T,
                           adjIN        = "val_delta",
                           ifmissingyrs = 5,
                           weekIN       = NULL, #"Week"
                           monthIN     = NULL, 
                           GCMIN        = NULL, 
                           scenIN       = NULL,
                           facet_rowIN  = "bc", # choices=c("bc","basin","scen")
                           facet_colIN  = "scen") 
      # now for operational hindcasts:
      dE <- get_var_ophind(stitchDateIN = stitchDate, 
                           typeIN    = "annual", 
                           plotbasin  = c("SEBS"),
                           plotvar   = "uEast_surface5m",
                           bcIN      = "bias corrected",
                           CMIPIN    = CMIPset,
                           plothist     = T,  # ignore the hist runs
                           removeyr1    = T,
                           adjIN        = "val_delta",
                           ifmissingyrs = 5,
                           weekIN       = NULL, #"Week"
                           monthIN     = NULL, 
                           GCMIN        = NULL, 
                           scenIN       = NULL,
                           facet_rowIN  = "bc", # choices=c("bc","basin","scen")
                           facet_colIN  = "scen") 
      
      dfopE <-dE$dat%>%rename(uE = val_use,uE_raw = val_raw)%>%mutate(var_raw = "NE_winds",var="NE_winds",units="meter second-1")%>%select(-sd_val)
      dfopN <-dN$dat%>%rename(vN = val_use,vN_raw = val_raw)%>%mutate(var_raw = "NE_winds",var="NE_winds",units="meter second-1")%>%select(-sd_val)
      dfop<-dfopN%>%left_join(dfopE%>%select(all_of(c(grpby,"uE","uE_raw"))))
      
      dfop$val_use <-getNE_winds(vNorth=dfop$vN,uEast=dfop$uE)
      dfop$val_raw <-getNE_winds(vNorth=dfop$vN_raw,uEast=dfop$uE_raw)
      
      head(data.frame(dfop%>%filter(year>2030,GCM=="miroc",scen=="ssp585")))
      
      
      tmpdop <- dfop%>%mutate(season="annual")%>%
        group_by(across(all_of(c(grpby,"season",
                                 "GCM2","GCM2_scen_sim"))))%>%
        summarize_at(all_of(sumat), mean, na.rm=T)%>%mutate(mn_val=val_use, var_raw = var, var = paste0("annual_",var))%>%select(-season)
      head(data.frame(tmpdop%>%filter(year>2030,GCM=="miroc",scen=="ssp585")))
      
      
      tmpdop <- stitchTS(dat = tmpdop, stitchDate_op)
      tmpdop <- tmpdop%>%mutate(type = "ceattle indices")
      ceattle_vars_op <- rbind(ceattle_vars_op,tmpdop)
      rm(dfop)
      rm(tmpdop)    
      
    
      normlist <- rbind(normlist, data.frame(var="NE_winds", lognorm = "none"))%>%
        rename(var_raw = var)
      ceattle_vars_op <- ceattle_vars_op%>%left_join(normlist)%>%
        mutate(mn_val=val_use)%>%ungroup()
      
      ceattle_vars_op  <-  unlink_val(indat    = ceattle_vars_op,
                           log_adj  = 1e-4,
                           roundn   = 5,
                           listIN   = c("val_delta","val_biascorrected","mn_val","mnVal_hind"),
                           rmlistIN = NULL)
      
      
      # fix the caps issue:
      ceattle_vars_op<-ceattle_vars_op%>%
        mutate(GCM = gsub("MIROC","miroc",GCM))%>%
        mutate(GCM = gsub("GFDL","gfdl",GCM))%>%
        mutate(GCM = gsub("CESM","cesm",GCM))%>%
        mutate(GCM_scen = gsub("MIROC","miroc",GCM_scen))%>%
        mutate(GCM_scen = gsub("GFDL","gfdl",GCM_scen))%>%
        mutate(GCM_scen = gsub("CESM","cesm",GCM_scen))%>%
        mutate(GCM_scen_sim = gsub("MIROC","miroc",GCM_scen_sim))%>%
        mutate(GCM_scen_sim = gsub("GFDL","gfdl",GCM_scen_sim))%>%
        mutate(GCM_scen_sim = gsub("CESM","cesm",GCM_scen_sim))%>%
        mutate(GCM = factor(GCM, levels =c("hind","gfdl","cesm","miroc")))
      
    # save indices
    if(!dir.exists("Data/out/CEATTLE_indices"))
      dir.create("Data/out/CEATTLE_indices")
      
      
    
    # Now creat .dat file
    #--------------------------------------
    
    
    # Plot results
    #--------------------------------------
    
    sclr<-1.2
    varlist <- unique(ceattle_vars_op$var)
    grep("annual",varlist)
    jpeg(filename = file.path("Data/out/CEATTLE_indices/ceattle_vars_op.jpg"),
         width=12*sclr, height=12*sclr, units="in", res = 350)
    print(
      plotTS(ceattle_vars_op)+facet_wrap(.~var,scales="free")+
            ylab("val")+
            labs(title="CEATTLE Indices, with operational hind")
          )
    dev.off()
    
    jpeg(filename = file.path("Data/out/CEATTLE_indices/ceattle_vars_op_winds.jpg"),
         width=6*sclr, height=9*sclr, units="in", res = 350)
    print(plotTS(ceattle_vars_op%>%filter(var%in%varlist[grep("NE_winds",varlist)]) )+labs(title="CEATTLE Indices, with operational hind"))
    dev.off()
    
    save(ceattle_vars_op, file="Data/out/CEATTLE_indices/ceattle_vars_op.Rdata")
    write.csv(ceattle_vars_op, file="Data/out/CEATTLE_indices/ceattle_vars_op.csv")
    cat("Indices saved in : ACLIM2/Data/out/CEATTLE_indices/ceattle_vars_op.Rdata")
    
    
    # recast with vars for each column:
    ceattle_vars_wide_op<- ceattle_vars_op%>%
      group_by(across(all_of(grpby[!grpby%in%
                                     c("units","long_name","lognorm")])))%>%
      summarize_at(all_of(c("val_use")), mean, na.rm=T)%>%
      tidyr::pivot_wider(names_from = "var", values_from = "val_use")
   
    save(ceattle_vars_wide_op, file="Data/out/CEATTLE_indices/ceattle_vars_wide_op.Rdata")
    write.csv(ceattle_vars_wide_op, file="Data/out/CEATTLE_indices/ceattle_vars_wide_op.csv")
    cat("Indices saved in : ACLIM2/Data/out/CEATTLE_indices/ceattle_vars_wide_op.Rdata")
    
    pp<- ggplot(ceattle_vars_wide_op)+
      geom_line(aes(x=year,y=annual_NE_winds,color= GCM_scen,linetype = basin),
                alpha = 0.2,show.legend = FALSE)+
      geom_smooth(aes(x=year,y=annual_NE_winds,color= GCM_scen,
                      fill=GCM_scen,linetype = basin),
                  alpha=0.1,method="loess",formula='y ~ x',span = .5)+
      theme_minimal() + 
      labs(x="Year",
           y="NE_winds (m s^-1)",
           subtitle = "",
           title = "NE_winds annual, operational hindcast",
           legend = "")+
      scale_color_discrete()+ facet_grid(scen~bc)
    
    pp
    
    pp_winds<- ggplot(ceattle_vars_wide_op)+
      geom_line(aes(x=year,y=Spring_NE_winds,color= GCM_scen,linetype = basin),
                alpha = 0.2,show.legend = FALSE)+
      geom_smooth(aes(x=year,y=Spring_NE_winds,color= GCM_scen,
                      fill=GCM_scen,linetype = basin),
                  alpha=0.1,method="loess",formula='y ~ x',span = .5)+
      theme_minimal() + 
      labs(x="Year",
           y="NE_winds (m s^-1)",
           subtitle = "",
           title = "NE_winds spring, operational hindcast",
           legend = "")+
      scale_color_discrete()+ facet_grid(scen~bc)
    
    pp_winds
    jpeg(filename = file.path("Data/out/CEATTLE_indices/CEATTLE_indices2_spring_op.jpg"),
         width=8,height=7,units="in",res=350)
    print(pp_winds)
    dev.off()