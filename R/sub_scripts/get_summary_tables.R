#'
#'
#'get_summary_stats
#'
#'


suppressWarnings(source("R/make.R"))
thisYr <- as.numeric(format(Sys.time(), "%Y"))
today  <- format(Sys.time(), "%b %d, %Y")

# Create lookup table:
# ------------------------

cmip6_lkup <- data.frame(rbind(
  c( "MIROC-ES2L", " r1i1p1f2","miroc"),
  c("GFDL-ESM4", " r1i1p1f1","gfdl"),
  c("CESM2", " r2i1p1f1","cesm")),stringsAsFactors = FALSE)
colnames(cmip6_lkup)<-c("model", "ensemble","GCM")


cmip5_lkup <- data.frame(rbind(
  c( "MIROC5", " r1i1p1","miroc"),
  c("GFDL-ESM2M", " r1i1p1","gfdl"),
  c("CESM1-BGC", " r1i1p1","cesm")),stringsAsFactors = FALSE)
colnames(cmip5_lkup)<-c("model", "ensemble","GCM")



# Now get CMIP6 warming levels from Mathis repo
# ------------------------
# https://github.com/mathause/cmip_warming_levels

GWL_cmip6 <- read.csv("Data/in/cmip_warming_levels-v0.2.0/mathause-cmip_warming_levels-fc9a5d7/warming_levels/cmip6_all_ens/csv/cmip6_warming_levels_all_ens_1850_1900.csv",skip=4)
GWL_cmip5 <- read.csv("Data/in/cmip_warming_levels-v0.2.0/mathause-cmip_warming_levels-fc9a5d7/warming_levels/cmip5_all_ens/csv/cmip5_warming_levels_all_ens_1850_1900.csv",skip=4)
GWL_cmip6%>%filter(model%in%c("CESM2","MIROC-ES2L","GFDL-ESM4"),exp%in%c(" ssp126"," ssp585"))
GWL_cmip5%>%filter(model%in%c("CESM1-BGC","MIROC5","GFDL-ESM4"),exp%in%c(" rcp45"," rcp85"))


cmip5<- GWL_cmip5%>%
  filter(model%in%cmip5_lkup$model,exp%in%c(" rcp45"," rcp85"))%>%
  left_join(cmip5_lkup,by=c("model"="model","ensemble"="ensemble"))%>%
  filter(!is.na(GCM))%>%
  group_by(model,exp,warming_level,GCM)%>%summarize(
    mnSTyr = mean(start_year),
    mnENDyr = mean(end_year))%>%mutate(exp = gsub(" ","",exp))

cmip6 <- GWL_cmip6%>%filter(
  model%in%c("CESM2","MIROC-ES2L","GFDL-ESM4"),
  exp%in%c(" ssp126"," ssp585"))%>%
  left_join(cmip6_lkup,by=c("model"="model","ensemble"="ensemble"))%>%
  filter(!is.na(GCM))%>%
  group_by(model,exp,warming_level,GCM)%>%summarize(
    mnSTyr = mean(start_year),
    mnENDyr = mean(end_year))%>%mutate(exp = gsub(" ","",exp))

# Load the rest of the ROMSNPZ data:
# ------------------------
cat("Rdata_path : ", Rdata_path,"\n") 

hind_yearsIN    <- 1979:thisYr
proj_yearsIN    <- (thisYr+1):2100

yrs             <- hind_yearsIN


# Load weekly data:
# ----------------------------------------------
load("Data/out/K20P19_CMIP5/allEBS_means/ACLIM_weekly_fut_mn.Rdata")
ACLIM_weekly_futCMIP5 <- ACLIM_weekly_fut%>%left_join(weekly_var_def,join_by(var== name)) 
load("Data/out/K20P19_CMIP6/allEBS_means/ACLIM_weekly_fut_mn.Rdata")
load("Data/out/K20P19_CMIP6/allEBS_means/ACLIM_weekly_hind_mn.Rdata")
load("Data/out/K20P19_CMIP6/allEBS_means/ACLIM_weekly_hist_mn.Rdata")
ACLIM_weekly_hist         <- ACLIM_weekly_hist%>%left_join(weekly_var_def,join_by(var== name)) 
ACLIM_weekly_fut          <- ACLIM_weekly_fut%>%left_join(weekly_var_def,join_by(var== name)) 
ACLIM_weekly_futCMIP6     <- ACLIM_weekly_fut
ACLIM_weekly_futCMIP5$GCM <- gsub("MIROC","miroc",ACLIM_weekly_futCMIP5$GCM)
ACLIM_weekly_futCMIP5$GCM <- gsub("CESM","cesm",  ACLIM_weekly_futCMIP5$GCM)
ACLIM_weekly_futCMIP5$GCM <- gsub("GFDL","gfdl",  ACLIM_weekly_futCMIP5$GCM)
ACLIM_weekly_fut          <- rbind(ACLIM_weekly_futCMIP6,ACLIM_weekly_futCMIP5)

# Load surveyrep data:
# ----------------------------------------------
load("Data/out/K20P19_CMIP5/allEBS_means/ACLIM_surveyrep_fut_mn.Rdata")
ACLIM_surveyrep_futCMIP5     <- ACLIM_surveyrep_fut%>%left_join(srvy_var_def,join_by(var== name)) 
load("Data/out/K20P19_CMIP6/allEBS_means/ACLIM_surveyrep_fut_mn.Rdata")
load("Data/out/K20P19_CMIP6/allEBS_means/ACLIM_surveyrep_hind_mn.Rdata")
load("Data/out/K20P19_CMIP6/allEBS_means/ACLIM_surveyrep_hist_mn.Rdata")
ACLIM_surveyrep_hist         <- ACLIM_surveyrep_hist%>%left_join(srvy_var_def,join_by(var== name)) 
ACLIM_surveyrep_hind         <- ACLIM_surveyrep_hind%>%left_join(srvy_var_def,join_by(var== name)) 
ACLIM_surveyrep_fut          <- ACLIM_surveyrep_fut%>%left_join(srvy_var_def,join_by(var== name)) 
ACLIM_surveyrep_futCMIP6     <- ACLIM_surveyrep_fut
ACLIM_surveyrep_futCMIP5$GCM <- gsub("MIROC","miroc",ACLIM_surveyrep_futCMIP5$GCM)
ACLIM_surveyrep_futCMIP5$GCM <- gsub("CESM","cesm",  ACLIM_surveyrep_futCMIP5$GCM)
ACLIM_surveyrep_futCMIP5$GCM <- gsub("GFDL","gfdl",  ACLIM_surveyrep_futCMIP5$GCM)
ACLIM_surveyrep_fut          <- rbind(ACLIM_surveyrep_futCMIP6,ACLIM_surveyrep_futCMIP5)

# Load annual data:
# ----------------------------------------------    
load("Data/out/K20P19_CMIP5/allEBS_means/ACLIM_annual_fut_mn.Rdata")
ACLIM_annual_futCMIP5     <- ACLIM_annual_fut%>%left_join(weekly_var_def,join_by(var== name)) 
load("Data/out/K20P19_CMIP6/allEBS_means/ACLIM_annual_fut_mn.Rdata")
load("Data/out/K20P19_CMIP6/allEBS_means/ACLIM_annual_hind_mn.Rdata")
load("Data/out/K20P19_CMIP6/allEBS_means/ACLIM_annual_hist_mn.Rdata")
ACLIM_annual_hist         <- ACLIM_annual_hist%>%left_join(weekly_var_def,join_by(var== name)) 
ACLIM_annual_hind         <- ACLIM_annual_hind%>%left_join(weekly_var_def,join_by(var== name)) 
ACLIM_annual_fut          <- ACLIM_annual_fut%>%left_join(weekly_var_def,join_by(var== name)) 
ACLIM_annual_futCMIP6     <- ACLIM_annual_fut
ACLIM_annual_futCMIP5$GCM <- gsub("MIROC","miroc",ACLIM_annual_futCMIP5$GCM)
ACLIM_annual_futCMIP5$GCM <- gsub("CESM","cesm",  ACLIM_annual_futCMIP5$GCM)
ACLIM_annual_futCMIP5$GCM <- gsub("GFDL","gfdl",  ACLIM_annual_futCMIP5$GCM)
ACLIM_annual_fut          <- rbind(ACLIM_annual_futCMIP6,ACLIM_annual_futCMIP5)

# Load seasonal data:
# ----------------------------------------------    
load("Data/out/K20P19_CMIP5/allEBS_means/ACLIM_seasonal_fut_mn.Rdata")
ACLIM_seasonal_futCMIP5     <- ACLIM_seasonal_fut%>%left_join(weekly_var_def,join_by(var== name)) 
load("Data/out/K20P19_CMIP6/allEBS_means/ACLIM_seasonal_fut_mn.Rdata")
load("Data/out/K20P19_CMIP6/allEBS_means/ACLIM_seasonal_hind_mn.Rdata")
load("Data/out/K20P19_CMIP6/allEBS_means/ACLIM_seasonal_hist_mn.Rdata")
ACLIM_seasonal_hist         <- ACLIM_seasonal_hist%>%left_join(weekly_var_def,join_by(var== name)) 
ACLIM_seasonal_hind         <- ACLIM_seasonal_hind%>%left_join(weekly_var_def,join_by(var== name)) 
ACLIM_seasonal_fut          <- ACLIM_seasonal_fut%>%left_join(weekly_var_def,join_by(var== name)) 
ACLIM_seasonal_futCMIP6     <- ACLIM_seasonal_fut
ACLIM_seasonal_futCMIP5$GCM <- gsub("MIROC","miroc",ACLIM_seasonal_futCMIP5$GCM)
ACLIM_seasonal_futCMIP5$GCM <- gsub("CESM","cesm",  ACLIM_seasonal_futCMIP5$GCM)
ACLIM_seasonal_futCMIP5$GCM <- gsub("GFDL","gfdl",  ACLIM_seasonal_futCMIP5$GCM)
ACLIM_seasonal_fut          <- rbind(ACLIM_seasonal_futCMIP6,ACLIM_seasonal_futCMIP5)

# Load monthly data:
# ----------------------------------------------
load("Data/out/K20P19_CMIP5/allEBS_means/ACLIM_monthly_fut_mn.Rdata")
ACLIM_monthly_futCMIP5 <- ACLIM_monthly_fut%>%left_join(weekly_var_def,join_by(var== name)) 
load("Data/out/K20P19_CMIP6/allEBS_means/ACLIM_monthly_fut_mn.Rdata")
load("Data/out/K20P19_CMIP6/allEBS_means/ACLIM_monthly_hind_mn.Rdata")
load("Data/out/K20P19_CMIP6/allEBS_means/ACLIM_monthly_hist_mn.Rdata")
ACLIM_monthly_hist         <- ACLIM_monthly_hist%>%left_join(weekly_var_def,join_by(var== name)) 
ACLIM_monthly_hind         <- ACLIM_monthly_hind%>%left_join(weekly_var_def,join_by(var== name)) 
ACLIM_monthly_fut          <- ACLIM_monthly_fut%>%left_join(weekly_var_def,join_by(var== name)) 
ACLIM_monthly_futCMIP6     <- ACLIM_monthly_fut
ACLIM_monthly_futCMIP5$GCM <- gsub("MIROC","miroc",ACLIM_monthly_futCMIP5$GCM)
ACLIM_monthly_futCMIP5$GCM <- gsub("CESM","cesm",  ACLIM_monthly_futCMIP5$GCM)
ACLIM_monthly_futCMIP5$GCM <- gsub("GFDL","gfdl",  ACLIM_monthly_futCMIP5$GCM)
ACLIM_monthly_fut          <- rbind(ACLIM_monthly_futCMIP6,ACLIM_monthly_futCMIP5)


# get just the core columns:
grplist <- c("var","sim",
             "basin","type",
             "sim_type",
             "gcmcmip","CMIP",
             "scen",
             "GCM","mod")

plot_vars      <- c("fracbelow2",
                    "fracbelow0",
                    "temp_bottom5m",
                    "temp_surface5m",
                    "oxygen_bottom5m",
                    "pH_bottom5m",
                    "pH_surface5m",
                    "aice","EupS_integrated","NCaS_integrated")

hind <- ACLIM_weekly_hind%>%filter(var%in%plot_vars)%>%
  select(all_of(c(grplist,"year","season","mn_val","mnVal_hind","mnDate","jday","wk","mo")))

# get weekly climatology
wkly_clim <- hind%>%ungroup()%>%filter(year<2019)%>%
  group_by(!!!syms(c(grplist,"wk")))%>%
  summarise(
    jday_clim = mean(jday, na.rm=T),
    mn_clim = mean(mn_val,na.rm=T),
    sd_clim = sd(mn_val,na.rm=T))%>%
  mutate(mndate_clim = as.Date("1990-01-01")+jday_clim)
ggplot(wkly_clim%>%filter(var=="EupS_integrated"))+
  geom_line(aes(x=mndate_clim,y= mn_clim,color=basin))+
  geom_line(aes(x=mndate_clim,y= mn_clim+sd_clim,color=basin),linetype="dashed")+
  geom_line(aes(x=mndate_clim,y= mn_clim-sd_clim,color=basin),linetype="dashed")


# get monthly climatology
mo_clim <- hind%>%ungroup()%>%filter(year<2019)%>%
  group_by(!!!syms(c(grplist,"mo")))%>%
  summarise(
    jday_clim = mean(jday, na.rm=T),
    mn_clim = mean(mn_val,na.rm=T),
    sd_clim = sd(mn_val,na.rm=T))%>%
  mutate(mndate_clim = as.Date("1990-01-01")+jday_clim)
ggplot(mo_clim%>%filter(var=="EupS_integrated"))+
  geom_line(aes(x=mndate_clim,y= mn_clim,color=basin))+
  geom_line(aes(x=mndate_clim,y= mn_clim+sd_clim,color=basin),linetype="dashed")+
  geom_line(aes(x=mndate_clim,y= mn_clim-sd_clim,color=basin),linetype="dashed")


# get seasonal climatology
season_clim <- hind%>%ungroup()%>%filter(year<2019)%>%
  group_by(!!!syms(c(grplist,"season")))%>%
  summarise(
    jday_clim = mean(jday, na.rm=T),
    mn_clim = mean(mn_val,na.rm=T),
    sd_clim = sd(mn_val,na.rm=T))%>%
  mutate(mndate_clim = as.Date("1990-01-01")+jday_clim)
ggplot(season_clim%>%filter(var=="EupS_integrated"))+
  geom_line(aes(x=mndate_clim,y= mn_clim,color=basin))+
  geom_line(aes(x=mndate_clim,y= mn_clim+sd_clim,color=basin),linetype="dashed")+
  geom_line(aes(x=mndate_clim,y= mn_clim-sd_clim,color=basin),linetype="dashed")

# get annual climatatology
annual_clim <- hind%>%ungroup()%>%filter(year<2019)%>%
  group_by(!!!syms(c(grplist)))%>%
  summarise(
    jday_clim = mean(jday, na.rm=T),
    mn_clim = mean(mn_val,na.rm=T),
    sd_clim = sd(mn_val,na.rm=T))%>%
  mutate(mndate_clim = as.Date("1990-01-01")+jday_clim)


# now determine freq of MHWs in the future
wkly_clim

ACLIM_weekly_hind$warming_level <- 
  ACLIM_weekly_fut$warming_level <- NA
GWLS <- rbind(cmip5,cmip6)
for(i in 1:dim(GWLS)[1]){
  rr <- which(ACLIM_weekly_fut$RCP==GWLS$exp[i]&
                ACLIM_weekly_fut$GCM==GWLS$GCM[i]&
                ACLIM_weekly_fut$year>=GWLS$mnSTyr[i]&
                ACLIM_weekly_fut$year<GWLS$mnENDyr[i]
  )
  if(length(rr>0))
    ACLIM_weekly_fut[rr,]$warming_level<- GWLS[i,]$warming_level
  rm(rr)
}
for(i in 1:dim(GWLS)[1]){
  rr <- which(ACLIM_weekly_hind$GCM==GWLS$GCM[i]&
                ACLIM_weekly_hind$year>=GWLS$mnSTyr[i]&
                ACLIM_weekly_hind$year<GWLS$mnENDyr[i]
  )
  if(length(rr>0))
    ACLIM_weekly_hind[rr,]$warming_level<- GWLS[i,]$warming_level
  rm(rr)
}

ggplot(ACLIM_weekly_hind)+
  geom_point(aes(x=))






hind <- ACLIM_seasonal_hind%>%filter(var%in%plot_vars)%>%
  select(all_of(c(grplist,"year","season","mn_val","mnVal_hind","sdVal_hind","mnDate","jday")))
tt <- hind%>%ungroup()%>%filter(year<2019)%>%
  group_by(!!!syms(c(grplist,"season")))%>%
  summarise(mnVal_hind = mean(mn_val,na.rm=T),
            sdVal_hind = sd(mn_val,na.rm=T))
hind <- hind%>%rename(mnVal_hind_old = mnVal_hind,sdVal_hind_old =sdVal_hind)%>%left_join(tt)
rm(tt)

hind_mo <- ACLIM_monthly_hind%>%filter(var%in%plot_vars)%>%rename(units = units.x)%>%
  select(all_of(c(grplist,"year","season","mo","sdVal_hind","mn_val","mnVal_hind","mnDate","jday")))
tt <- hind_mo%>%ungroup()%>%filter(year<2019)%>%
  group_by(!!!syms(c(grplist,"season","mo")))%>%
  summarise(mnVal_hind = mean(mn_val,na.rm=T),
            sdVal_hind = sd(mn_val,na.rm=T))
hind_mo <- hind_mo%>%rename(mnVal_hind_old = mnVal_hind)%>%left_join(tt)

ggplot(hind%>%filter(var=="aice",basin=="SEBS",season=="Spring"))+
  geom_line(aes(x=year,y=mnVal_hind_old,color="old"))+
  geom_line(aes(x=year,y=mnVal_hind,color="new"))

ggplot(hind_mo%>%filter(var=="aice",basin=="SEBS",mo==12))+
  geom_line(aes(x=year,y=mnVal_hind_old,color="old"))+
  geom_line(aes(x=year,y=mnVal_hind,color="new"))+
  geom_line(aes(x=year,y=mnVal_hind+sdVal_hind))+
  geom_line(aes(x=year,y=mnVal_hind-sdVal_hind))

hind <- ACLIM_seasonal_hind%>%filter(var%in%plot_vars)%>%
  select(all_of(c(grplist,"year","season","sd_val","mn_val","val_raw","mnVal_hind","mnDate","jday")))
tt <- hind%>%ungroup()%>%filter(year<2019)%>%
  group_by(!!!syms(c(grplist,"season")))%>%
  summarise(mnVal_hind = mean(mn_val,na.rm=T),
            sdVal_hind = sd(mn_val,na.rm=T))
hind <- hind%>%rename(mnVal_hind_old = mnVal_hind)%>%left_join(tt)
rm(tt)

hind_mo <- ACLIM_monthly_hind%>%filter(var%in%plot_vars)%>%
  select(all_of(c(grplist,"year","season","mo","sd_val","mn_val","val_raw","mnVal_hind","mnDate","jday")))
  tt <- hind_mo%>%ungroup()%>%filter(year<2019)%>%
    group_by(!!!syms(c(grplist,"season","mo")))%>%
    summarise(mnVal_hind = mean(mn_val,na.rm=T),
           sdVal_hind = sd(mn_val,na.rm=T))
hind_mo <- hind_mo%>%rename(mnVal_hind_old = mnVal_hind)%>%left_join(tt)




