# CESM has the weirdness in Jan and Dec
# (1) NEBS vs EBS bounding
# (2) bias correction or delta
# (3) delta vs akfin

# Findings: AKFIN  = local Level4 indices


source("R/make.R")       # loads packages, data, setup, etc.
# source(here::here("R","sub_fun","get_var_akfin.R"))
# install.packages(c("here", "dplyr", "httr","jsonlite"))


# Load Andy's version of the data - likely 
# Google drive folder data [ mar april 2023] 
# ------------------------------------------

andy_fut <- read.csv(file.path("Data/fromGdrive/ACLIM2_level4_indices_Rpath","cm6_c585_raw.csv"))


suppressMessages(source("R/make.R"))

# preview possible variables
# load(paste0("Data/out/K20P19_CMIP6/allEBS_means/ACLIM_monthly_hind_mn.Rdata"))
load(paste0("Data/out/K20P19_CMIP6/allEBS_means/ACLIM_monthly_operational_hind_mn.Rdata"))
varall  <- unique(ACLIM_monthly_hind$var)
varall

scens   <- c("ssp126","ssp585")
GCMs    <- c("miroc","gfdl",  "cesm" )
# varlist <- c("temp_bottom5m","fracbelow2","uEast_surface5m")
varlist <- c("Cop_integrated","NCaO_integrated","NCaS_integrated","EupO_integrated",
             "EupS_integrated","MZL_integrated","PhL_integrated","PhS_integrated",
             "temp_bottom5m","temp_surface5m")
# varlist <-c("EupO_integrated",
#             "EupS_integrated")
stitchDate     <- "2019-12-30"  # last date of the ACLIM hindcast
stitchDate_op  <- "2021-12-30"  #last operational hindcast date

# get_var_ophind for operational hindcast
out_vars <- NULL  
for(v in varlist){
  df <- get_var(
    typeIN    = "monthly",
    CMIPIN    = c("K20P19_CMIP5", "K20P19_CMIP6"),
    monthIN   = 1:12,
    pathIN    = "data/fromGdrive/ACLIM2_level4_indices_Rpath",
    plotvar   = v,
    bcIN      = "bias corrected",
    plotbasin = "SEBS",
    plothist  = F,  # ignore the hist runs
    removeyr1 = T)  #"Remove first year of projection ( burn in)")
  
  head(df$dat)
  df$plot
  maxDin <- "2019-12-30" # Kirstin said to use this date b/c not all variables go
  # beyond 2019 in the CORECFS hindcast.
  
  tmpd <- stitchTS(dat = df$dat, maxD = maxDin)
 # tmpdop <- stitchTS(dat = dfop$dat, stitchDate_op)
  #out_vars <- rbind(out_vars,tmpd,tmpdop)
  out_vars <- rbind(out_vars,tmpd)
  rm(list = c("tmpd","df"))
  
  
}

# CMIP6
# gfdl_ssp126
# cm6_c585 <- out_vars[which(out_vars$sim=="ACLIMregion_B10K-K20P19_CMIP6_gfdl_ssp126" & 
#                              out_vars$year > 2021),]

library(dplyr)
library(reshape2)

cm6_c585 <- out_vars%>%filter(sim=="ACLIMregion_B10K-K20P19_CMIP6_cesm_ssp585", year >2021)

cm6_c585_raw <- cm6_c585%>%select(year,mo, var, val_use)%>%
  reshape2::dcast(year + mo  ~ var , mean)%>%
  mutate(tstep = 625:1560,
  cop = Cop_integrated + NCaO_integrated + NCaS_integrated,
  eup = EupO_integrated + EupS_integrated)
cm6_c585_raw <- cm6_c585_raw%>%
  dplyr::rename(
   mzl = MZL_integrated,
   phl = PhL_integrated,
   phs = PhS_integrated,
   temp_b5 = temp_bottom5m,
   temp_s5 = temp_surface5m)%>%select(tstep, year, mo,cop,eup,mzl,phl,phs,  temp_b5,  temp_s5)


if(1==10){
  cm6_c585_raw_andy <- cbind(625:1560, # tstep
                        cm6_c585$year[cm6_c585$var=="Cop_integrated"],     # year
                        cm6_c585$mo[cm6_c585$var=="Cop_integrated"],       # mo
                        cm6_c585$val_use[cm6_c585$var=="Cop_integrated"],  # cop_raw
                        cm6_c585$val_use[cm6_c585$var=="NCaO_integrated"], # ncao_raw
                        cm6_c585$val_use[cm6_c585$var=="NCaS_integrated"], # ncas_raw
                        cm6_c585$val_use[cm6_c585$var=="EupO_integrated"], # eupo_raw
                        cm6_c585$val_use[cm6_c585$var=="EupS_integrated"], # eups_raw
                        cm6_c585$val_use[cm6_c585$var=="MZL_integrated"],  # mzl_raw
                        cm6_c585$val_use[cm6_c585$var=="PhL_integrated"],  # phl_raw
                        cm6_c585$val_use[cm6_c585$var=="PhS_integrated"],  # phs_raw
                        cm6_c585$val_use[cm6_c585$var=="temp_bottom5m"],   # temp_b5
                        cm6_c585$val_use[cm6_c585$var=="temp_surface5m"])  # temp_s5
  
  #Also note that I add together the copepod groups and euphausiid groups:
  
  # add together composite groups
  cm6_c585_raw_grps <- cbind(cm6_c585_raw[,c(1:3)], 
                             (cm6_c585_raw[,"cop"]  + cm6_c585_raw[,"ncao"]+cm6_c585_raw[,"ncas"]),
                             (cm6_c585_raw[,"eupo"] + cm6_c585_raw[,"eups"]),
                             cm6_c585_raw[,"mzl"],
                             cm6_c585_raw[,"phl"],
                             cm6_c585_raw[,"phs"],
                             cm6_c585_raw[,"temp_b5"],
                             cm6_c585_raw[,"temp_s5"])
  
  }

# Do the same from the 2023 updated version:
# /Users/KKH/Documents/GitHub_mac/ACLIM2/Data/fromGdrive/2023_updatedBC/K20P19_CMIP6/allEBS_means

out_vars_2023 <- NULL  
for(v in varlist){
  df <- get_var(
    typeIN    = "monthly",
    CMIPIN    = c("K20P19_CMIP5", "K20P19_CMIP6"),
    monthIN   = 1:12,
    pathIN    = "Data/fromGdrive/2023_updatedBC/K20P19_CMIP6/allEBS_means",
    plotvar   = v,
    bcIN      = "bias corrected",
    plotbasin = "SEBS",
    plothist  = F,  # ignore the hist runs
    removeyr1 = T)  #"Remove first year of projection ( burn in)")
  
  head(df$dat)
  df$plot
  maxDin <- "2019-12-30" # Kirstin said to use this date b/c not all variables go
  # beyond 2019 in the CORECFS hindcast.
  
  tmpd <- stitchTS(dat = df$dat, maxD = maxDin)
  # tmpdop <- stitchTS(dat = dfop$dat, stitchDate_op)
  #out_vars <- rbind(out_vars,tmpd,tmpdop)
  out_vars_2023 <- rbind(out_vars_2023,tmpd)
  rm(list = c("tmpd","df"))
  
  
}

# CMIP6

cm6_c585_kir <- out_vars_2023%>%filter(sim=="ACLIMregion_B10K-K20P19_CMIP6_cesm_ssp585", year >2021)

cm6_c585_raw_kir <- cm6_c585_kir%>%select(year,mo, var, val_use)%>%
  reshape2::dcast(year + mo  ~ var , mean)%>%
  mutate(tstep = 625:1560,
         cop = Cop_integrated + NCaO_integrated + NCaS_integrated,
         eup = EupO_integrated + EupS_integrated)
cm6_c585_raw_kir <- cm6_c585_raw_kir%>%
  dplyr::rename(
    mzl = MZL_integrated,
    phl = PhL_integrated,
    phs = PhS_integrated,
    temp_b5 = temp_bottom5m,
    temp_s5 = temp_surface5m)%>%select(tstep, year, mo,cop,eup,mzl,phl,phs,  temp_b5,  temp_s5)


# Load AKFIN version
# ------------------------------------------
eupo_sebs_futa<-
  get_var_akfin (typein = "monthly",
                 basin = "SEBS",
                 dataset = "FUT",
                 cmip="CMIP6",
                 var= "EupS_integrated")

eupo_sebs_futb <-
  get_var_akfin (typein = "monthly",
                 basin = "SEBS",
                 dataset = "FUT",
                 cmip="CMIP6",
                 var= "EupO_integrated")

sellist <- c("BASIN","MO", "YEAR", "UNITS", "SIM","GCMCMIP", "CMIP","GCM","SCEN", "TYPE", "SIM_TYPE", "VAR",
             "MN_VAL",
             "VAL_BIASCORRECTED")

eupo_sebs_fut <- eupo_sebs_futa%>%select(all_of(sellist))%>%
  left_join(eupo_sebs_futb%>%select(all_of(sellist)), 
            by = sellist[!sellist%in%c( "VAR", "MN_VAL","VAL_BIASCORRECTED")],suffix = c(".EupS", ".Eup0"))%>%
  mutate(MN_VAL = MN_VAL.Eup0+ MN_VAL.EupS,
         VAL_BIASCORRECTED = VAL_BIASCORRECTED.EupS + VAL_BIASCORRECTED.Eup0)


  
# Load Google drive current (2024): accessed 6/13/2025
# -------------------------------------------

load("Data/fromGdrive/ACLIM_L4/CMIP6_K20P19_Indices_operational/allEBS_means/ACLIM_monthly_hist_mn.Rdata")
load("Data/fromGdrive/ACLIM_L4/CMIP6_K20P19_Indices_operational/allEBS_means/ACLIM_monthly_hind_mn.Rdata")
load("Data/fromGdrive/ACLIM_L4/CMIP6_K20P19_Indices_operational/allEBS_means/ACLIM_monthly_fut_mn.Rdata")

gdrive_L4_hist <- ACLIM_monthly_hist
gdrive_L4_hind <- ACLIM_monthly_hind
gdrive_L4_fut <- ACLIM_monthly_fut

rm(list = c("ACLIM_monthly_hist","ACLIM_monthly_hind","ACLIM_monthly_fut"))

# Load Local version on Kir's Mac
#--------------------------------------
# K20P19_CMIP6
fldr <- "K20P19_CMIP6"
sim  <- "cesm_ssp585"
flnm   <- paste0("ACLIMregion_B10K-K20P19_CMIP6_",sim,"_BC_fut.Rdata")
nm <- file.path("data","out",fldr,"BC_ACLIMregion",flnm)

load(nm) # fut
kkh_fut2 <- fut 
rm(fut)

load("Data/out/ACLIM_L4/CMIP6_K20P19_Indices_operational/allEBS_means/ACLIM_monthly_hist_mn.Rdata")
load("Data/out/ACLIM_L4/CMIP6_K20P19_Indices_operational/allEBS_means/ACLIM_monthly_hind_mn.Rdata")
load("Data/out/ACLIM_L4/CMIP6_K20P19_Indices_operational/allEBS_means/ACLIM_monthly_fut_mn.Rdata")

kkh_L4_hist <- ACLIM_monthly_hist
kkh_L4_hind <- ACLIM_monthly_hind
kkh_L4_fut  <- ACLIM_monthly_fut

rm(list = c("ACLIM_monthly_hist","ACLIM_monthly_hind","ACLIM_monthly_fut"))


# older version from < 2022

load("/Users/KKH/Documents/GitHub_mac/ACLIM2/Data/in/NotShared/2022_12_6_archived/K20P19_CMIP6/allEBS_means/ACLIM_monthly_fut_mn.Rdata")
old_L4_fut  <- ACLIM_monthly_fut
rm(list = c("ACLIM_monthly_fut"))


# now compare plots

gcmIN   <- "cesm"
sspIN   <- "ssp585"
varIN   <- "EupS_integrated"
basinIN <- "SEBS"
#mn_val val_biascorrected

akfin_fut <- eupo_sebs_fut%>%filter(SCEN==sspIN,VAR == varIN,BASIN == basinIN,GCM == gcmIN)%>%mutate(from = "akfin")%>%
  rename(mo = MO)


kkh_fut    <- kkh_L4_fut%>%filter(scen==sspIN,var == varIN,basin == basinIN,GCM == gcmIN)%>%mutate(from = "kkh_local 2025")
gdrive_fut <- gdrive_L4_fut%>%filter(scen==sspIN,var == varIN,basin == basinIN,GCM == gcmIN)%>%mutate(from = "gdrive 2025")
andy_fut   <- andy_fut%>%mutate(from ="andy")
andy_kir_fut <- cm6_c585_raw%>%mutate(from ="andy via Kir")
andyreplicatedby_kir <-cm6_c585_raw_kir%>%mutate(from ="Kir 2023 replicated")
old_fut    <- old_L4_fut%>%filter(scen==sspIN,var == varIN,basin == basinIN,GCM == gcmIN)%>%mutate(from = "kkh_local 2022")
#kkh_fut2   <- kkh_fut2%>%filter(scen==sspIN,var == varIN,basin == basinIN,GCM == gcmIN)%>%mutate(from = "kkh2_local")

# Akfin L4 = KKH local L4
ptest <- ggplot()+
  geom_point(data = kkh_fut, aes( x = year,  y  = val_biascorrected,  color = from,  shape = from))+
  geom_point(data = akfin_fut, aes(x = YEAR, y  = VAL_BIASCORRECTED, color = from, shape = from))+
  geom_point(data = gdrive_fut, aes( x = year,  y  = val_biascorrected,  color = from,  shape = from))+
  geom_point(data = old_fut, aes( x = year,  y  = val_biascorrected,  color = from,  shape = from))+
  facet_wrap(.~mo, nrow = 4, scales = "free_y")+ theme_minimal()

ptest2 <- ptest+
  geom_point(data = andy_fut, aes( x = year,  y  = eup,  color = from,  shape = from))+
  #geom_point(data = andy_kir_fut, aes( x = year,  y  = eup,  color = from,  shape = from))+
  geom_point(data = andyreplicatedby_kir, aes( x = year,  y  = eup,  color = from,  shape = from))
  
ptest2

# Andys != level 4
# look and see if he is working with raw instead of biascorrected:
ggplot()+
  geom_point(data = kkh_fut, aes( x = year,  y  = val_biascorrected,  color = from,  shape = from))+
  # geom_point(data = akfin_fut, aes(x = YEAR, y  = VAL_BIASCORRECTED, color = from, shape = from))+
  # geom_point(data = gdrive_fut, aes( x = year,  y  = val_biascorrected,  color = from,  shape = from))+
  geom_point(data = gdrive_fut, aes( x = year,  y  = mn_val,  color = "mn_val",  shape = "mn_val"))+
  geom_line(data = gdrive_fut, aes( x = year,  y  = sdVal_hind,  color = "sdVal_hind"),linetype= "dashed")+
  geom_line(data = gdrive_fut, aes( x = year,  y  = mnVal_hind,  color = "mnVal_hind"))+
  geom_line(data = gdrive_fut, aes( x = year,  y  = sdVal_hist,  color = "sdVal_hist"),linetype= "dashed")+
  geom_line(data = gdrive_fut, aes( x = year,  y  = mnVal_hist,  color = "mnVal_hist"))+
  geom_point(data = gdrive_fut, aes( x = year,  y  = val_biascorrected,  color = from,  shape = from))+
  geom_point(data = andy_fut, aes( x = year,  y  = eup,  color = from,  shape = from))+
  facet_wrap(.~mo, nrow = 4, scales = "free_y")+ theme_minimal()



