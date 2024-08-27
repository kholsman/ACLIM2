#'
#'
#'
#'make_pcod_indices_Andre.R
#'
#'This script generates the indices for the NRS and pcod papers
#'for Punt et al. 20220
#'
#' SST SBT and pH in mar-April
#' SST and SBT for June-Aug 
#' 
#' 

# rm(list=ls())
suppressMessages(source("R/make.R"))

CMIPset <- c("K20P19_CMIP6","K20P19_CMIP5")

# preview possible variables
load(file = "Data/out/weekly_vars.Rdata")
load(file = "Data/out/srvy_vars.Rdata")
load(paste0("Data/out/K20P19_CMIP6/allEBS_means/ACLIM_annual_hind_mn.Rdata"))

varall  <- unique(ACLIM_annual_hind$var)

# varall
load(paste0("Data/out/K20P19_CMIP6/allEBS_means/ACLIM_annual_fut_mn.Rdata"))
load(paste0("Data/out/K20P19_CMIP6/allEBS_means/ACLIM_surveyrep_fut_mn.Rdata"))

stitchDate     <- "2019-12-30"  # last date of the ACLIM hindcast
#stitchDate_op  <- "2022-05-16"  #last operational hindcast date # can't be mid year for these
stitchDate_op  <- "2021-12-30"  #last operational hindcast date
# scens   <- c("ssp126", "ssp585")
# GCMs    <- c("miroc", "gfdl", "cesm" )

# Now compile the Pcod indices:
#--------------------------------------
grpby <- c("type","var","basin",
           "year","sim","gcmcmip","GCM","scen","sim_type",
           "bc","GCM_scen","GCM_scen_sim", "CMIP" )

sumat  <- c("jday","mnDate","val_use","mnVal_hind",
            "val_delta","val_biascorrected","val_raw")

# make PCOD_indices.csv using the ACLIM hindcast only as well as 
# PCOD_indices_op.csv, the operational hindcast filled in for 2019-2022
varlist <- c("pH_bottom5m","pH_depthavg","pH_integrated","pH_surface5m")
varlist <- c("temp_surface5m", "temp_bottom5m")
i <- 0
v <- varlist[1]
mIN <- 3:4
for(v in varlist){
  
  i <- i + 1
  cat("compiling indices : ",v,"\n")
  
  # get the variable you want:
  df <- get_var( typeIN    = "monthly", 
                 monthIN   = mIN,
                 plotbasin = c("SEBS"),
                 plotvar   = v,
                 bcIN      = "bias corrected",
                 CMIPIN    = CMIPset, 
                 plothist  = T,  # ignore the hist runs
                 removeyr1 = T)  # "Remove first year of proj ( burn in)")
  
  tmpda <- df$dat%>%
    group_by(across(all_of(grpby)))%>%
    summarize_at(all_of(sumat), mean, na.rm=T)%>%
    mutate(mn_val = val_use, var = paste0("Mar2Apr_",var))%>%ungroup()
  
  tmpd <- stitchTS(dat = tmpda, maxD = stitchDate)
  tmpd <- tmpd%>%mutate(type = "Pcod indices")
  ggplot(tmpd)+
    geom_line(aes(x=year, y=mn_val,color=GCM_scen_sim))+
    facet_grid(.~scen)
  
  # now for operational hindcasts:
  dfop <- get_var_ophind( typeIN       = "monthly", 
                          monthIN      = mIN,
                          stitchDateIN = stitchDate,
                          plotbasin    = c("SEBS"),
                          plotvar      = v,
                          bcIN         = "bias corrected",
                          CMIPIN       = CMIPset, 
                          jday_rangeIN = c(0,365),
                          plothist     = T,  # ignore the hist runs
                          removeyr1    = T,
                          adjIN        = "val_delta",
                          ifmissingyrs = 5,
                          weekIN       = NULL, #"Week"
                          SeasonIN     = NULL, 
                          GCMIN        = NULL, 
                          scenIN       = NULL,
                          facet_rowIN  = "bc", # choices=c("bc","basin","scen")
                          facet_colIN  = "scen") 
#  dfop$dat%>%filter(var==v,year%in%(2022))%>%select(year,mo, basin, var,val_use,val_delta,val_raw)
  tmpdop <- dfop$dat%>%
    group_by(across(all_of(c(grpby,"GCM2","GCM2_scen_sim"))))%>%
    summarize_at(all_of(sumat), mean, na.rm=T)%>%
    mutate(mn_val = val_use, var = paste0("Mar2Apr_",var))%>%ungroup()
  
 # tmpdop%>%filter(var==v,year%in%(2022))%>%select(year, basin, var,val_use,val_delta,val_raw)
  tmpdop <- stitchTS(dat = tmpdop, maxD = stitchDate_op)
  tmpdop <- tmpdop%>%mutate(type = "Pcod indices")
  tmpdop%>%filter(var==v,year%in%(2022))%>%select(year, basin, var,val_use,val_delta,val_raw,GCM_scen,sim)
  
  ggplot(tmpdop)+
    geom_line(aes(x=year, y=mn_val,color=GCM_scen_sim))+
    facet_grid(.~scen)
  
  if(i==1){
    PCOD_vars    <- tmpd
    PCOD_vars_op <- tmpdop
  }else{
    PCOD_vars    <- rbind(PCOD_vars,tmpd)
    PCOD_vars_op <- rbind(PCOD_vars_op,tmpdop)
  }
  
  rm(df)
  rm(dfop)
  rm(tmpd)
  rm(tmpdop)
  
}

varlist <- c("pH_bottom5m","pH_depthavg","pH_integrated","pH_surface5m")
i <- 0
v <- varlist[1]
mIN <- 3:4

for(v in varlist){
  
  cat("compiling indices : ",v,"\n")
  
  # get the variable you want:
  df <- get_var( typeIN    = "monthly", 
                 monthIN   = mIN,
                 plotbasin = c("SEBS"),
                 plotvar   = v,
                 bcIN      = "bias corrected",
                 CMIPIN    = CMIPset, 
                 plothist  = T,  # ignore the hist runs
                 removeyr1 = T)  # "Remove first year of proj ( burn in)")
  
  tmpda <- df$dat%>%
    group_by(across(all_of(grpby)))%>%
    summarize_at(all_of(sumat), mean, na.rm=T)%>%
    mutate(mn_val = val_use, var = paste0("Mar2Apr_",var))%>%ungroup()
  
  tmpd <- stitchTS(dat = tmpda, maxD = stitchDate)
  tmpd <- tmpd%>%mutate(type = "Pcod indices")
  ggplot(tmpd)+
    geom_line(aes(x=year, y=mn_val,color=GCM_scen_sim))+
    facet_grid(.~scen)
  
 
    PCOD_vars    <- rbind(PCOD_vars,tmpd)
  
  
  rm(df)
  rm(tmpd)
  
}



varlist <- c("temp_surface5m", "temp_bottom5m")
i <- 0
v <- varlist[1]
mIN <- 6:9
for(v in varlist){
  cat("compiling indices : ",v,"\n")
  
  # get the variable you want:
  df <- get_var( typeIN    = "monthly", 
                 monthIN   = mIN,
                 plotbasin = c("SEBS"),
                 plotvar   = v,
                 bcIN      = "bias corrected",
                 CMIPIN    = CMIPset, 
                 plothist  = T,  # ignore the hist runs
                 removeyr1 = T)  # "Remove first year of proj ( burn in)")
  
  tmpda <- df$dat%>%
    group_by(across(all_of(grpby)))%>%
    summarize_at(all_of(sumat), mean, na.rm=T)%>%
    mutate(mn_val=val_use, var = paste0("Jun2Aug_",var))%>%ungroup()
  
  tmpd <- stitchTS(dat = tmpda, maxD = stitchDate)
  tmpd <- tmpd%>%mutate(type = "Pcod indices")
  ggplot(tmpd)+
    geom_line(aes(x=year, y=mn_val,color=GCM_scen_sim))+
    facet_grid(.~scen)
  
  # now for operational hindcasts:
  dfop <- get_var_ophind( typeIN       = "monthly", 
                          monthIN      = mIN,
                          stitchDateIN = stitchDate,
                          plotbasin    = c("SEBS"),
                          plotvar      = v,
                          bcIN         = "bias corrected",
                          CMIPIN       = CMIPset, 
                          jday_rangeIN = c(0,365),
                          plothist     = T,  # ignore the hist runs
                          removeyr1    = T,
                          adjIN        = "val_delta",
                          ifmissingyrs = 5,
                          weekIN       = NULL, #"Week"
                          SeasonIN     = NULL, 
                          GCMIN        = NULL, 
                          scenIN       = NULL,
                          facet_rowIN  = "bc", # choices=c("bc","basin","scen")
                          facet_colIN  = "scen") 
  #dfop$dat%>%filter(var==v,year%in%(2022))%>%select(year,mo, basin, var,val_use,val_delta,val_raw)
  tmpdop <- dfop$dat%>%
    group_by(across(all_of(c(grpby,"GCM2","GCM2_scen_sim"))))%>%
    summarize_at(all_of(sumat), mean, na.rm=T)%>%
    mutate(mn_val=val_use, var = paste0("Jun2Aug_",var))%>%ungroup()
#  tmpdop%>%filter(var==v,year%in%(2022))%>%select(year, basin, var,val_use,val_delta,val_raw)
  tmpdop <- stitchTS(dat = tmpdop, maxD = stitchDate_op)
  tmpdop <- tmpdop%>%mutate(type = "Pcod indices")
  tmpdop%>%filter(var==v,year%in%(2022))%>%select(year, basin, var,val_use,val_delta,val_raw,GCM_scen,sim)
  
  ggplot(tmpdop)+
    geom_line(aes(x=year, y=mn_val,color=GCM_scen_sim))+
    facet_grid(.~scen)
  
    PCOD_vars    <- rbind(PCOD_vars,tmpd)
    PCOD_vars_op <- rbind(PCOD_vars_op,tmpdop)
  
  rm(df)
  rm(dfop)
  rm(tmpd)
  rm(tmpdop)
  
}

if(any(unique(PCOD_vars_op$sim)=="ACLIMregion_B10K-K20P19_CORECFS"))
  stop(paste("ACLIMregion_B10K-K20P19_CORECFS in operational hindcast!!!\n ",paste(varlist,"\n")))


PCOD_vars    <- PCOD_vars%>%ungroup()
PCOD_vars_op <- PCOD_vars_op%>%ungroup()


#Annual Indices
# annual values
varlist <- c("temp_surface5m", "temp_bottom5m")

# 
# for(v in varlist){
#   cat("compiling indices : ",v,"\n")
#   # get the variable you want:
#   df <- get_var( typeIN    = "annual", 
#                  plotbasin  = c("SEBS"),
#                  plotvar   = v,
#                  bcIN      = "bias corrected",
#                  CMIPIN    = CMIPset, 
#                  plothist  = T,  # ignore the hist runs
#                  removeyr1 = T)  # "Remove first year of projection ( burn in)")
#   tmpd <- df$dat%>%mutate(season="annual")%>%
#     group_by(across(all_of(grpby)))%>%
#     summarize_at(all_of(sumat), mean, na.rm=T)%>%
#     mutate(mn_val=val_use, var = paste0("annual_",var))
#   
#   tmpd <- stitchTS(dat = tmpd, stitchDate)
#   tmpd <- tmpd%>%mutate(type = "Pcod indices")
#   PCOD_vars <- rbind(PCOD_vars,tmpd)
#   rm(df)
#   rm(tmpd)
#   
#   # now for operational hindcasts:
#   dfop <- get_var_ophind(stitchDateIN = stitchDate, 
#                          typeIN    = "annual", 
#                          plotbasin  = c("SEBS"),
#                          plotvar   = v,
#                          bcIN      = "bias corrected",
#                          CMIPIN    = CMIPset, 
#                          plothist  = T,  # ignore the hist runs
#                          removeyr1 = T)  # "Remove first year of proj ( burn in)")
#   
#   tmpdop <- dfop$dat%>%mutate(season="annual")%>%
#     group_by(across(all_of(c(grpby,"GCM2","GCM2_scen_sim"))))%>%
#     summarize_at(all_of(sumat), mean, na.rm=T)%>%
#     mutate(mn_val=val_use, var = paste0("annual_",var))
# 
#   tmpdop <- stitchTS(dat = tmpdop, stitchDate_op)
#   tmpdop <- tmpdop%>%mutate(type = "Pcod indices")
#   PCOD_vars_op <- rbind(PCOD_vars_op,tmpdop)
#   rm(dfop)
#   rm(tmpdop)    
# }   
# 
# if(any(unique(PCOD_vars_op$sim)=="ACLIMregion_B10K-K20P19_CORECFS"))
#   stop(paste("ACLIMregion_B10K-K20P19_CORECFS in operational hindcast!!!\n ",paste(varlist,"\n")))
# 
# varlist <- c("pH_bottom5m","pH_depthavg","pH_integrated","pH_surface5m")
# 
# for(v in varlist){
#   cat("compiling indices : ",v,"\n")
#   # get the variable you want:
#   df <- get_var( typeIN    = "annual", 
#                  plotbasin  = c("SEBS"),
#                  plotvar   = v,
#                  bcIN      = "bias corrected",
#                  CMIPIN    = CMIPset, 
#                  plothist  = T,  # ignore the hist runs
#                  removeyr1 = T)  # "Remove first year of projection ( burn in)")
#   tmpd <- df$dat%>%mutate(season="annual")%>%
#     group_by(across(all_of(grpby)))%>%
#     summarize_at(all_of(sumat), mean, na.rm=T)%>%
#     mutate(mn_val=val_use, var = paste0("annual_",var))
#   
#   tmpd <- stitchTS(dat = tmpd, stitchDate)
#   tmpd <- tmpd%>%mutate(type = "Pcod indices")
#   PCOD_vars <- rbind(PCOD_vars,tmpd)
#   rm(df)
#   rm(tmpd)
# 
# }   
# 
# if(any(unique(PCOD_vars_op$sim)=="ACLIMregion_B10K-K20P19_CORECFS"))
#   stop(paste("ACLIMregion_B10K-K20P19_CORECFS in operational hindcast!!!\n ",paste(varlist,"\n")))
# 

# fix the caps issue:
PCOD_vars<-PCOD_vars%>%
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

# fix the caps issue:
PCOD_vars_op<-PCOD_vars_op%>%
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
if(!dir.exists("Data/out/PCOD_indices"))
  dir.create("Data/out/PCOD_indices")

save(PCOD_vars, file="Data/out/PCOD_indices/PCOD_vars.Rdata")
write.csv(PCOD_vars, file="Data/out/PCOD_indices/PCOD_vars.csv")
save(PCOD_vars_op, file="Data/out/PCOD_indices/PCOD_vars_op.Rdata")
write.csv(PCOD_vars_op, file="Data/out/PCOD_indices/PCOD_vars_op.csv")

# recast with vars for each column:
PCOD_vars_wide<- PCOD_vars%>%
  group_by(across(all_of(grpby[!grpby%in%
                                 c("units","long_name","lognorm")])))%>%
  summarize_at(all_of(c("val_use")), mean, na.rm=T)%>%
  tidyr::pivot_wider(names_from = "var", values_from = "val_use")

# reorder to put annual indices at the end
cc <- colnames(PCOD_vars_wide)
cc <- cc[-grep("annual",cc)]
PCOD_vars_wide<- PCOD_vars_wide%>%relocate(all_of(cc))

PCOD_vars2<- PCOD_vars_wide%>%
  tidyr::pivot_longer(cols = c(unique(PCOD_vars$var)),
                      names_to = "var",
                      values_to = "val_use")%>%mutate(mn_val=val_use)%>%ungroup()

# recast with vars for each column:
PCOD_vars_wide_op<- PCOD_vars_op%>%
  group_by(across(all_of(grpby[!grpby%in%
                                 c("units","long_name","lognorm")])))%>%
  summarize_at(all_of(c("val_use")), mean, na.rm=T)%>%
  tidyr::pivot_wider(names_from = "var", values_from = "val_use")

# PCOD_vars_wide_op$NE_winds <- 
#   getNE_winds(vNorth=PCOD_vars_wide_op$vNorth_surface5m,
#               uEast=PCOD_vars_wide_op$uEast_surface5m)

# reorder to put annual indices at the end
cc <- colnames(PCOD_vars_wide_op)
cc <- cc[-grep("annual",cc)]
PCOD_vars_wide_op<- PCOD_vars_wide_op%>%
  relocate(all_of(cc))


PCOD_vars2_op<- PCOD_vars_wide_op%>%
  tidyr::pivot_longer(cols = c(unique(PCOD_vars_op$var)),
                      names_to = "var",
                      values_to = "val_use")%>%
  mutate(mn_val=val_use)%>%ungroup()

save(PCOD_vars_wide, file="Data/out/PCOD_indices/PCOD_vars_wide.Rdata")
write.csv(PCOD_vars_wide, file="Data/out/PCOD_indices/PCOD_vars_wide.csv")
save(PCOD_vars_wide_op, file="Data/out/PCOD_indices/PCOD_vars_wide_op.Rdata")
write.csv(PCOD_vars_wide_op, file="Data/out/PCOD_indices/PCOD_vars_wide_op.csv")


tt   <- PCOD_vars_wide_op%>%filter(scen=="rcp45",year ==1976)
unique(tt$sim)

tt2  <- PCOD_vars_op%>%filter(scen=="rcp45",year ==1976,var=="fracbelow1")
unique(tt2$sim)

tt1  <- PCOD_vars_wide%>%filter(scen=="rcp45",year ==1976)
unique(tt1$sim)

tt12 <- PCOD_vars%>%filter(scen=="rcp45",year ==1976,var=="fracbelow1")
unique(tt12$sim)


sclr <- 2
jpeg(filename = file.path("Data/out/PCOD_indices/PCOD_vars.jpg"),
     width=6*sclr, height=9*sclr, units="in", res = 350)
print(plotTS(PCOD_vars )+labs(title="Pcod indices, with ACLIM hind"))
dev.off()



jpeg(filename = file.path("Data/out/PCOD_indices/PCOD_vars_byGCM.jpg"),
     width=6*sclr, height=9*sclr, units="in", res = 350)
print(plotTS(PCOD_vars )+
        labs(title="Pcod indices")+facet_grid(var~GCM,scales='free_y'))
dev.off()


jpeg(filename = file.path("Data/out/PCOD_indices/PCOD_vars_op_byGCM.jpg"),
     width=6*sclr, height=9*sclr, units="in", res = 350)
print(plotTS(PCOD_vars_op )+
        labs(title="Pcod indices, with operational hind")+facet_grid(var~GCM,scales='free_y'))
dev.off()

jpeg(filename = file.path("Data/out/PCOD_indices/PCOD_vars_op.jpg"),
     width=6*sclr, height=9*sclr, units="in", res = 350)
print(plotTS(PCOD_vars_op )+labs(title="Pcod indices, with operational hind"))
dev.off()


plotTS(PCOD_vars_op%>%filter(var=="Mar2Apr_temp_bottom5m"), plotvalIN = "val_raw" )+
  coord_cartesian(ylim=c(7.5,8.1))


pp2 <- plotTS(PCOD_vars2%>%mutate(units="",mnDate=year) )+
  facet_wrap(.~var,scales="free")+ylab("val")+
  labs(title = "ACLIM hindcast +projections")
jpeg(filename = file.path("Data/out/PCOD_indices/PCOD_indices.jpg"),
     width=10,height=8,units="in",res=350)
print(pp2)
dev.off()


pp2 <- plotTS(PCOD_vars2_op%>%mutate(units="",mnDate=year) )+
  facet_wrap(.~var,scales="free")+ylab("val")+
  labs(title = "operational hindcast + projections")
jpeg(filename = file.path("Data/out/PCOD_indices/PCOD_indices_op.jpg"),
     width=10,height=8,units="in",res=350)
print(pp2)
dev.off()

# 
# pp<- ggplot(PCOD_vars_wide)+
#   geom_line(aes(x=year,y=NE_winds,color= GCM_scen,linetype = basin),
#             alpha = 0.2,show.legend = FALSE)+
#   geom_smooth(aes(x=year,y=NE_winds,color= GCM_scen,
#                   fill=GCM_scen,linetype = basin),
#               alpha=0.1,method="loess",formula='y ~ x',span = .5)+
#   theme_minimal() + 
#   labs(x="Year",
#        y="NE_winds (m s^-1)",
#        subtitle = "",
#        title = "NE_winds, ACLIM hindcast",
#        legend = "")+
#   scale_color_discrete()+ facet_grid(scen~bc)
# 
# pp
# 
# jpeg(filename = file.path("Data/out/PCOD_indices/PCOD_indices2.jpg"),
#      width=8,height=7,units="in",res=350)
# print(pp)
# dev.off()

# 
# pp<- ggplot(PCOD_vars_wide_op)+
#   geom_line(aes(x=year,y=NE_winds,color= GCM_scen,linetype = basin),
#             alpha = 0.2,show.legend = FALSE)+
#   geom_smooth(aes(x=year,y=NE_winds,color= GCM_scen,
#                   fill=GCM_scen,linetype = basin),
#               alpha=0.1,method="loess",formula='y ~ x',span = .5)+
#   theme_minimal() + 
#   labs(x="Year",
#        y="NE_winds (m s^-1)",
#        subtitle = "",
#        title = "NE_winds, operational hindcast",
#        legend = "")+
#   scale_color_discrete()+ facet_grid(scen~bc)
# 
# pp
# 
# jpeg(filename = file.path("Data/out/PCOD_indices/PCOD_indices2_op.jpg"),
#      width=8,height=7,units="in",res=350)
# print(pp)
# dev.off()


pp<- ggplot(PCOD_vars_wide_op)+
  geom_hline(yintercept = 0,color="gray")+
  geom_line(aes(x=year,y=Mar2Apr_temp_bottom5m,color= GCM_scen,linetype = basin),
            alpha = 0.2,show.legend = FALSE)+
  geom_smooth(aes(x=year,y=Mar2Apr_temp_bottom5m,color= GCM_scen,
                  fill=GCM_scen,linetype = basin),
              alpha=0.1,method="loess",formula='y ~ x',span = .5)+
  theme_minimal() + 
  labs(x="Year",
       subtitle = "",
       title = "Mar2Apr_temp_bottom5m, operational hindcast",
       legend = "")+
  scale_color_discrete()+ facet_grid(scen~bc)

pp
jpeg(filename = file.path("Data/out/PCOD_indices/PCOD_indices2_op_Mar2Apr_temp_bottom5m.jpg"),
     width=8,height=7,units="in",res=350)
print(pp)
dev.off()

