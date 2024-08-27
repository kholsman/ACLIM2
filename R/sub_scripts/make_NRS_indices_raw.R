#'
#'
#'
#'make_NRS_indices_raw.R
#'
#'This script generates the indices for the NRS and pcod papers
#'for Punt et al. 20220


# Nursery area is approx strata 10& 20
# NW direction in strata 20, and strata 10 >57N, while NE in strata 10< 57N  
# vNorth_surface5m
# uEast_surface5
# coldpool cat --> <16% vs >16% CP area.

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

# Now compile the NRS indices:
#--------------------------------------

grpby <- c("type","var","basin",
           "year","sim","gcmcmip","GCM","scen","sim_type",
           "bc","GCM_scen","GCM_scen_sim", "CMIP" )

sumat  <- c("jday","mnDate","val_use","mnVal_hind",
            "val_delta","val_biascorrected","val_raw")


# make NRS_indices.csv using the ACLIM hindcast only as well as 
#      NRS_indices_op.csv, the operational hindcast filled in for 2019-2022
varlist <- c("vNorth_surface5m","uEast_surface5m")
i <- 0
for(v in varlist){
  i<- i + 1
  cat("compiling indices : ",v,"\n")
  # get the variable you want:
  df <- get_var( typeIN    = "monthly", 
                 monthIN   = 4:6,
                 plotbasin  = c("SEBS"),
                 plotvar   = v,
                 bcIN      = "raw",
                 CMIPIN    = CMIPset, 
                 plothist  = T,  # ignore the hist runs
                 removeyr1 = T)  # "Remove first year of proj ( burn in)")
  tmpd <- df$dat%>%
    group_by(across(all_of(grpby)))%>%
    summarize_at(all_of(sumat), mean, na.rm=T)%>%
    mutate(mn_val=val_use)%>%ungroup()
  tmpd <- stitchTS(dat = tmpd, maxD = stitchDate)
  tmpd <- tmpd%>%mutate(type = "NRS indices")
  ggplot(tmpd)+geom_line(aes(x=year, y=mn_val,color=GCM_scen_sim))+facet_grid(.~scen)
  # now for operational hindcasts:
  dfop <- get_var_ophind( typeIN = "monthly", 
                          monthIN   = 4:6,
                          stitchDateIN = stitchDate,
                          plotbasin  = c("SEBS"),
                          plotvar   = v,
                          bcIN      = "raw",
                          CMIPIN    = CMIPset, 
                          jday_rangeIN = c(0,365),
                          plothist  = T,  # ignore the hist runs
                          removeyr1 = T)  # "Remove first year of proj ( burn in)")
  
  tmpdop <- dfop$dat%>%
    group_by(across(all_of(c(grpby,"GCM2","GCM2_scen_sim"))))%>%
    summarize_at(all_of(sumat), mean, na.rm=T)%>%
    mutate(mn_val=val_use)%>%ungroup()
  tmpdop <- stitchTS(dat = tmpdop, maxD = stitchDate_op)
  tmpdop <- tmpdop%>%mutate(type = "NRS indices")
  ggplot(tmpdop)+geom_line(aes(x=year, y=mn_val,color=GCM_scen_sim))+facet_grid(.~scen)
  if(i==1){
    NRS_vars <- tmpd
    NRS_vars_op <- tmpdop
  }else{
    NRS_vars <- rbind(NRS_vars,tmpd)
    NRS_vars_op <- rbind(NRS_vars_op,tmpdop)
  }
  rm(df)
  rm(dfop)
  rm(tmpd)
  rm(tmpdop)
}

# Ph In Jan- Mar (Winter)
varlist <- "pH_depthavg"
for(v in varlist){
  cat("compiling indices : ",v,"\n")
  # get the variable you want:
  df <- get_var( typeIN    = "seasonal", 
                 SeasonIN =  "Winter",
                 plotbasin  = c("SEBS"),
                 plotvar    = v,
                 bcIN       = "raw",
                 CMIPIN     = CMIPset, 
                 plothist   = T,  # ignore the hist runs
                 removeyr1  = T)  # "Remove first year of proj ( burn in)")
  
  tmpd <- df$dat%>%group_by(across(all_of(grpby)))%>%
    summarize_at(all_of(sumat), mean, na.rm=T)%>%
    mutate(mn_val=val_use)%>%ungroup()
  tmpd <- stitchTS(dat = tmpd, stitchDate)
  tmpd <- tmpd%>%mutate(type = "NRS indices")
  NRS_vars <- rbind(NRS_vars,tmpd)
  rm(df)
  rm(tmpd)
  
  # now for operational hindcasts:
  dfop <- get_var_ophind(stitchDateIN = stitchDate, 
                         typeIN    = "seasonal", 
                         SeasonIN  =  "Winter",
                         plotbasin = c("SEBS"),
                         plotvar   = v,
                         bcIN      = "raw",
                         CMIPIN    = CMIPset,
                         plothist  = T,  # ignore the hist runs
                         removeyr1 = T)  # "Remove first year of proj ( burn in)")
  tmpdop <- dfop$dat%>%
    group_by(across(all_of(c(grpby,"GCM2","GCM2_scen_sim"))))%>%
    summarize_at(all_of(sumat), mean, na.rm=T)%>%
    mutate(mn_val=val_use)%>%ungroup()
  tmpdop <- stitchTS(dat = tmpdop, stitchDate_op)
  tmpdop <- tmpdop%>%mutate(type = "NRS indices")
  NRS_vars_op <- rbind(NRS_vars_op,tmpdop)
  rm(dfop)
  rm(tmpdop)    
}

# summer values  (Jul-Aug)
varlist <- c("fracbelow1","fracbelow2")
for(v in varlist){
  cat("compiling indices : ",v,"\n")
  # get the variable you want:
  df <- get_var( typeIN    = "seasonal", 
                 SeasonIN =  "Summer",
                 plotbasin  = c("SEBS"),
                 plotvar   = v,
                 bcIN      = "raw",
                 CMIPIN    = CMIPset, 
                 plothist  = T,  # ignore the hist runs
                 removeyr1 = T)  # "Remove first year of projection ( burn in)")
  
  myfun2 <- function(x){
    
    if(any(x<0&!is.na(x)))  x[x<0&!is.na(x)]   <- 0
    if(any(x>1&!is.na(x)))  x[x>1&!is.na(x)]   <- 1
    return(x)
  }
  tmpd <- df$dat%>%group_by(across(all_of(grpby)))%>%
    mutate(val_use=myfun2(val_use))%>%
    summarize_at(all_of(sumat), mean, na.rm=T)%>%mutate(mn_val=val_use)%>%ungroup()
  tmpd <- stitchTS(dat = tmpd, stitchDate)
  tmpd<-tmpd%>%mutate(type = "NRS indices")
  NRS_vars <- rbind(NRS_vars,tmpd)
  rm(df)
  rm(tmpd)
  
  
  # now for operational hindcasts:
  dfop <- get_var_ophind(stitchDateIN = stitchDate, 
                         typeIN    = "seasonal", 
                         SeasonIN =  "Summer",
                         plotbasin  = c("SEBS"),
                         plotvar   = v,
                         bcIN      = "raw",
                         CMIPIN    = CMIPset, 
                         plothist  = T,  # ignore the hist runs
                         removeyr1 = T)  # "Remove first year of proj ( burn in)")
  tmpdop <- dfop$dat%>%
    group_by(across(all_of(c(grpby,"GCM2","GCM2_scen_sim"))))%>%
    mutate(val_use=myfun2(val_use))%>%
    summarize_at(all_of(sumat), mean, na.rm=T)%>%
    mutate(mn_val=val_use)%>%ungroup()
  tmpdop <- stitchTS(dat = tmpdop, stitchDate_op)
  tmpdop <- tmpdop%>%mutate(type = "NRS indices")
  NRS_vars_op <- rbind(NRS_vars_op,tmpdop)
  rm(dfop)
  rm(tmpdop)    
}

# spring values  (Mar-Aug)
varlist <- c("temp_surface5m", "temp_bottom5m")
for(v in varlist){
  cat("compiling indices : ",v,"\n")
  # get the variable you want:
  df <- get_var( typeIN    = "monthly", 
                 monthIN   = 3:9,
                 plotbasin  = c("SEBS"),
                 plotvar   = v,
                 bcIN      = "raw",
                 CMIPIN    = CMIPset, 
                 plothist  = T,  # ignore the hist runs
                 removeyr1 = T)  # "Remove first year of projection ( burn in)")
  tmpd <- df$dat%>%group_by(across(all_of(grpby)))%>%
    summarize_at(all_of(sumat), mean, na.rm=T)%>%
    mutate(mn_val=val_use)%>%ungroup()
  tmpd <- stitchTS(dat = tmpd, stitchDate)
  tmpd<-tmpd%>%mutate(type = "NRS indices")
  NRS_vars <- rbind(NRS_vars,tmpd)
  rm(df)
  rm(tmpd)
  
  # now for operational hindcasts:
  dfop <- get_var_ophind(stitchDateIN = stitchDate, 
                         typeIN    = "monthly", 
                         monthIN   = 3:9,
                         plotbasin  = c("SEBS"),
                         plotvar   = v,
                         bcIN      = "raw",
                         CMIPIN    = CMIPset, 
                         plothist  = T,  # ignore the hist runs
                         removeyr1 = T)  # "Remove first year of proj ( burn in)")
  tmpdop <- dfop$dat%>%
    group_by(across(all_of(c(grpby,"GCM2","GCM2_scen_sim"))))%>%
    summarize_at(all_of(sumat), mean, na.rm=T)%>%
    mutate(mn_val=val_use)%>%ungroup()
  tmpdop <- stitchTS(dat = tmpdop, stitchDate_op)
  tmpdop <- tmpdop%>%mutate(type = "NRS indices")
  NRS_vars_op <- rbind(NRS_vars_op,tmpdop)
  rm(dfop)
  rm(tmpdop)    
}

NRS_vars    <- NRS_vars%>%ungroup()
NRS_vars_op <- NRS_vars_op%>%ungroup()


#Annual Indices
# annual values
varlist <- c("temp_surface5m", "temp_bottom5m","fracbelow1","fracbelow2",
             "pH_depthavg","uEast_surface5m","vNorth_surface5m")


for(v in varlist){
  cat("compiling indices : ",v,"\n")
  # get the variable you want:
  df <- get_var( typeIN    = "annual", 
                 plotbasin  = c("SEBS"),
                 plotvar   = v,
                 bcIN      = "raw",
                 CMIPIN    = CMIPset, 
                 plothist  = T,  # ignore the hist runs
                 removeyr1 = T)  # "Remove first year of projection ( burn in)")
  tmpd <- df$dat%>%mutate(season="annual")%>%
    group_by(across(all_of(grpby)))%>%
    summarize_at(all_of(sumat), mean, na.rm=T)%>%
    mutate(mn_val=val_use, var = paste0("annual_",var))
  
  if(v%in%c("fracbelow1","fracbelow2")){
    tmpd <- df$dat%>%mutate(season="annual",val_use=myfun2(val_use))%>%
      group_by(across(all_of(grpby)))%>%
      summarize_at(all_of(sumat), mean, na.rm=T)%>%
      mutate(mn_val=val_use, var = paste0("annual_",var))
  }
  
  tmpd <- stitchTS(dat = tmpd, stitchDate)
  tmpd<-tmpd%>%mutate(type = "NRS indices")
  NRS_vars <- rbind(NRS_vars,tmpd)
  rm(df)
  rm(tmpd)
  
  # now for operational hindcasts:
  dfop <- get_var_ophind(stitchDateIN = stitchDate, 
                         typeIN    = "annual", 
                         plotbasin  = c("SEBS"),
                         plotvar   = v,
                         bcIN      = "raw",
                         CMIPIN    = CMIPset, 
                         plothist  = T,  # ignore the hist runs
                         removeyr1 = T)  # "Remove first year of proj ( burn in)")
  
  tmpdop <- dfop$dat%>%mutate(season="annual")%>%
    group_by(across(all_of(c(grpby,"GCM2","GCM2_scen_sim"))))%>%
    summarize_at(all_of(sumat), mean, na.rm=T)%>%
    mutate(mn_val=val_use, var = paste0("annual_",var))
  if(v%in%c("fracbelow1","fracbelow2")){
    tmpdop <- dfop$dat%>%mutate(season="annual",val_use=myfun2(val_use))%>%
      group_by(across(all_of(c(grpby,"GCM2","GCM2_scen_sim"))))%>%
      summarize_at(all_of(sumat), mean, na.rm=T)%>%
      mutate(mn_val=val_use, var = paste0("annual_",var))
  }
  tmpdop <- stitchTS(dat = tmpdop, stitchDate_op)
  tmpdop <- tmpdop%>%mutate(type = "NRS indices")
  NRS_vars_op <- rbind(NRS_vars_op,tmpdop)
  rm(dfop)
  rm(tmpdop)    
}   

# now for operational hindcasts:
dN <-           get_var(typeIN    = "annual",
                        plotbasin  = c("SEBS"),
                        plotvar   = "vNorth_surface5m",
                        bcIN      = "raw",
                        CMIPIN    = CMIPset,
                        plothist  = T,  # ignore the hist runs
                        removeyr1 = T)  # "Remove first year of proj ( burn in)")
# now for operational hindcasts:
dE <-           get_var(typeIN    = "annual",
                        plotbasin  = c("SEBS"),
                        plotvar   = "uEast_surface5m",
                        bcIN      = "raw",
                        CMIPIN    = CMIPset,
                        plothist  = T,  # ignore the hist runs
                        removeyr1 = T)  # "Remove first year of proj ( burn in)")

dfE <-dE$dat%>%rename(uE = val_use,uE_raw = val_raw)%>%
  mutate(var="NE_winds",units="meter second-1")%>%select(-sd_val)
dfN <-dN$dat%>%rename(vN = val_use,vN_raw = val_raw)%>%
  mutate(var="NE_winds",units="meter second-1")%>%select(-sd_val)
df<-dfN%>%left_join(dfE%>%select(all_of(c(grpby,"uE","uE_raw"))))

df$val_use <-getNE_winds(vNorth=df$vN,uEast=df$uE)
df$val_raw <-getNE_winds(vNorth=df$vN_raw,uEast=df$uE_raw)
tmpd <- df%>%mutate(season="annual")%>%
  group_by(across(all_of(grpby)))%>%
  summarize_at(all_of(sumat), mean, na.rm=T)%>%
  mutate(mn_val=val_use, var = paste0("annual_",var))
head(data.frame(tmpd%>%filter(year>2030,GCM=="miroc",scen=="ssp585")))
tmpd <- stitchTS(dat = tmpd, stitchDate)
tmpd <- tmpd%>%mutate(type = "NRS indices")
NRS_vars<- rbind(NRS_vars,tmpd)
rm(df)
rm(tmpd)    
rm(dN)
rm(dE)

# now for operational hindcasts:
dN <- get_var_ophind(stitchDateIN = stitchDate, 
                     typeIN    = "annual", 
                     plotbasin  = c("SEBS"),
                     plotvar   = "vNorth_surface5m",
                     bcIN      = "raw",
                     CMIPIN    = CMIPset, 
                     plothist  = T,  # ignore the hist runs
                     removeyr1 = T)  # "Remove first year of proj ( burn in)")
# now for operational hindcasts:
dE <- get_var_ophind(stitchDateIN = stitchDate, 
                     typeIN    = "annual", 
                     plotbasin  = c("SEBS"),
                     plotvar   = "uEast_surface5m",
                     bcIN      = "raw",
                     CMIPIN    = CMIPset, 
                     plothist  = T,  # ignore the hist runs
                     removeyr1 = T)  # "Remove first year of proj ( burn in)")

dfopE <-dE$dat%>%rename(uE = val_use,uE_raw = val_raw)%>%
  mutate(var="NE_winds",units="meter second-1")%>%select(-sd_val)
dfopN <-dN$dat%>%rename(vN = val_use,vN_raw = val_raw)%>%
  mutate(var="NE_winds",units="meter second-1")%>%select(-sd_val)
dfop<-dfopN%>%left_join(dfopE%>%select(all_of(c(grpby,"uE","uE_raw"))))

dfop$val_use <-getNE_winds(vNorth=dfop$vN,uEast=dfop$uE)
dfop$val_raw <-getNE_winds(vNorth=dfop$vN_raw,uEast=dfop$uE_raw)
tmpdop <- dfop%>%mutate(season="annual")%>%
  group_by(across(all_of(c(grpby,
                           "GCM2","GCM2_scen_sim"))))%>%
  summarize_at(all_of(sumat), mean, na.rm=T)%>%
  mutate(mn_val=val_use, var = paste0("annual_",var))
head(data.frame(tmpdop%>%filter(year>2030,GCM=="miroc",scen=="ssp585")))
tmpdop <- stitchTS(dat = tmpdop, stitchDate_op)
tmpdop <- tmpdop%>%mutate(type = "NRS indices")
NRS_vars_op <- rbind(NRS_vars_op,tmpdop)
rm(dfop)
rm(tmpdop)
sub<- NRS_vars_op%>%filter(var%in%c("fracbelow1","fracbelow2"))

# save indices
if(!dir.exists("Data/out/NRS_indices"))
  dir.create("Data/out/NRS_indices")


# fix the caps issue:
NRS_vars<-NRS_vars%>%
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
NRS_vars_op<-NRS_vars_op%>%
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



save(NRS_vars, file="Data/out/NRS_indices/NRS_vars_raw.Rdata")
write.csv(NRS_vars, file="Data/out/NRS_indices/NRS_vars_raw.csv")
save(NRS_vars_op, file="Data/out/NRS_indices/NRS_vars_op_raw.Rdata")
write.csv(NRS_vars_op, file="Data/out/NRS_indices/NRS_vars_op_raw.csv")

# recast with vars for each column:
NRS_vars_wide<- NRS_vars%>%
  group_by(across(all_of(grpby[!grpby%in%
                                 c("units","long_name","lognorm")])))%>%
  summarize_at(all_of(c("val_use")), mean, na.rm=T)%>%
  tidyr::pivot_wider(names_from = "var", values_from = "val_use")
NRS_vars_wide$NE_winds <- getNE_winds(vNorth=NRS_vars_wide$vNorth_surface5m,
                                      uEast=NRS_vars_wide$uEast_surface5m)

# reorder to put annual indices at the end
cc <- colnames(NRS_vars_wide)
cc <- cc[-grep("annual",cc)]
NRS_vars_wide<- NRS_vars_wide%>%relocate(all_of(cc))


NRS_vars2<- NRS_vars_wide%>%
  tidyr::pivot_longer(cols = c(unique(NRS_vars$var),"NE_winds"),
                      names_to = "var",
                      values_to = "val_use")%>%mutate(mn_val=val_use)%>%ungroup()

# recast with vars for each column:
NRS_vars_wide_op<- NRS_vars_op%>%
  group_by(across(all_of(grpby[!grpby%in%
                                 c("units","long_name","lognorm")])))%>%
  summarize_at(all_of(c("val_use")), mean, na.rm=T)%>%
  tidyr::pivot_wider(names_from = "var", values_from = "val_use")

NRS_vars_wide_op$NE_winds <- 
  getNE_winds(vNorth=NRS_vars_wide_op$vNorth_surface5m,
              uEast=NRS_vars_wide_op$uEast_surface5m)

# reorder to put annual indices at the end
cc <- colnames(NRS_vars_wide_op)
cc <- cc[-grep("annual",cc)]
NRS_vars_wide_op<- NRS_vars_wide_op%>%
  relocate(all_of(cc))


NRS_vars2_op<- NRS_vars_wide_op%>%
  tidyr::pivot_longer(cols = c(unique(NRS_vars$var),"NE_winds"),
                      names_to = "var",
                      values_to = "val_use")%>%
  mutate(mn_val=val_use)%>%ungroup()

save(NRS_vars_wide, file="Data/out/NRS_indices/NRS_vars_wide_raw.Rdata")
write.csv(NRS_vars_wide, file="Data/out/NRS_indices/NRS_vars_wide_raw.csv")
save(NRS_vars_wide_op, file="Data/out/NRS_indices/NRS_vars_wide_op_raw.Rdata")
write.csv(NRS_vars_wide_op, file="Data/out/NRS_indices/NRS_vars_wide_op_raw.csv")

sclr<-1.2
jpeg(filename = file.path("Data/out/NRS_indices/NRS_vars_raw.jpg"),
     width=6*sclr, height=9*sclr, units="in", res = 350)
print(plotTS(NRS_vars )+labs(title="NRS Indices, with ACLIM hind"))
dev.off()

jpeg(filename = file.path("Data/out/NRS_indices/NRS_vars_byGCM_raw.jpg"),
     width=6*sclr, height=9*sclr, units="in", res = 350)
print(plotTS(NRS_vars )+
        labs(title="NRS Indices")+facet_grid(var~GCM,scales='free_y'))
dev.off()


jpeg(filename = file.path("Data/out/NRS_indices/NRS_vars_op_byGCM_raw.jpg"),
     width=6*sclr, height=9*sclr, units="in", res = 350)
print(plotTS(NRS_vars_op )+
        labs(title="NRS Indices, with operational hind")+facet_grid(var~GCM,scales='free_y'))
dev.off()


jpeg(filename = file.path("Data/out/NRS_indices/NRS_vars_op_raw.jpg"),
     width=6*sclr, height=9*sclr, units="in", res = 350)
print(plotTS(NRS_vars_op )+labs(title="NRS Indices, with operational hind"))
dev.off()

jpeg(filename = file.path("Data/out/NRS_indices/NRS_vars_op_raw_raw.jpg"),
     width=6*sclr, height=9*sclr, units="in", res = 350)
print(plotTS(NRS_vars_op, plotvalIN = "val_raw" )+labs(title="raw NRS Indices, with operational hind"))
dev.off()


plotTS(NRS_vars_op%>%filter(var=="pH_depthavg"), plotvalIN = "val_raw" )+
  coord_cartesian(ylim=c(7.5,8.1))

plotTS(NRS_vars_op%>%filter(var=="pH_depthavg"), plotvalIN = "mn_val" )+
  coord_cartesian(ylim=c(7.5,8.1))

plotTS(NRS_vars%>%filter(var=="pH_depthavg"), plotvalIN = "mn_val" )+
  coord_cartesian(ylim=c(7.5,8.1))


pp2 <- plotTS(NRS_vars2%>%mutate(units="",mnDate=year) )+
  facet_wrap(.~var,scales="free")+ylab("val")+
  labs(title = "ACLIM hindcast +projections")
jpeg(filename = file.path("Data/out/NRS_indices/NRS_indices_raw.jpg"),
     width=10,height=8,units="in",res=350)
print(pp2)
dev.off()


pp2 <- plotTS(NRS_vars2_op%>%mutate(units="",mnDate=year) )+
  facet_wrap(.~var,scales="free")+ylab("val")+
  labs(title = "operational hindcast + projections")
jpeg(filename = file.path("Data/out/NRS_indices/NRS_indices_op_raw.jpg"),
     width=10,height=8,units="in",res=350)
print(pp2)
dev.off()


pp<- ggplot(NRS_vars_wide)+
  geom_line(aes(x=year,y=NE_winds,color= GCM_scen,linetype = basin),
            alpha = 0.2,show.legend = FALSE)+
  geom_smooth(aes(x=year,y=NE_winds,color= GCM_scen,
                  fill=GCM_scen,linetype = basin),
              alpha=0.1,method="loess",formula='y ~ x',span = .5)+
  theme_minimal() + 
  labs(x="Year",
       y="NE_winds (m s^-1)",
       subtitle = "",
       title = "NE_winds, ACLIM hindcast",
       legend = "")+
  scale_color_discrete()+ facet_grid(scen~bc)

pp

jpeg(filename = file.path("Data/out/NRS_indices/NRS_indices2_raw.jpg"),
     width=8,height=7,units="in",res=350)
print(pp)
dev.off()


pp<- ggplot(NRS_vars_wide_op)+
  geom_line(aes(x=year,y=NE_winds,color= GCM_scen,linetype = basin),
            alpha = 0.2,show.legend = FALSE)+
  geom_smooth(aes(x=year,y=NE_winds,color= GCM_scen,
                  fill=GCM_scen,linetype = basin),
              alpha=0.1,method="loess",formula='y ~ x',span = .5)+
  theme_minimal() + 
  labs(x="Year",
       y="NE_winds (m s^-1)",
       subtitle = "",
       title = "NE_winds, operational hindcast",
       legend = "")+
  scale_color_discrete()+ facet_grid(scen~bc)

pp

jpeg(filename = file.path("Data/out/NRS_indices/NRS_indices2_op_raw.jpg"),
     width=8,height=7,units="in",res=350)
print(pp)
dev.off()


pp<- ggplot(NRS_vars_wide_op)+
  geom_hline(yintercept = 0,color="gray")+
  geom_line(aes(x=year,y=fracbelow2,color= GCM_scen,linetype = basin),
            alpha = 0.2,show.legend = FALSE)+
  geom_smooth(aes(x=year,y=fracbelow2,color= GCM_scen,
                  fill=GCM_scen,linetype = basin),
              alpha=0.1,method="loess",formula='y ~ x',span = .5)+
  theme_minimal() + 
  labs(x="Year",
       subtitle = "",
       title = "fracbelow1, operational hindcast",
       legend = "")+
  scale_color_discrete()+ facet_grid(scen~bc)

pp
jpeg(filename = file.path("Data/out/NRS_indices/NRS_indices2_op_coldpool_raw.jpg"),
     width=8,height=7,units="in",res=350)
print(pp)
dev.off()

