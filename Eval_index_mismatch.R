# CESM has the weirdness in Jan and Dec
# (1) NEBS vs EBS bounding
# (2) bias correction or delta
# (3) delta vs akfin

source("R/make.R")       # loads packages, data, setup, etc.
# source(here::here("R","sub_fun","get_var_akfin.R"))
# install.packages(c("here", "dplyr", "httr","jsonlite"))


# Load Andy's version of the data - likely 
# Google drive folder data [ mar april 2023] 
# ------------------------------------------



# Load AKFIN version
# ------------------------------------------
eupo_sebs_fut <-
  get_var_akfin (typein = "monthly",
                 basin = "SEBS",
                 dataset = "FUT",
                 var= "Cop_integrated",
                 cmip = "СМІР6")



# Load Google drive current (2024): accessed 6/13/2025
# -------------------------------------------

load("Data/fromGdrive/ACLIM_L4/CMIP6_K20P19_Indices_operational/allEBS_means/ACLIM_seasonal_hist_mn.Rdata")
load("Data/fromGdrive/ACLIM_L4/CMIP6_K20P19_Indices_operational/allEBS_means/ACLIM_seasonal_hind_mn.Rdata")
load("Data/fromGdrive/ACLIM_L4/CMIP6_K20P19_Indices_operational/allEBS_means/ACLIM_seasonal_fut_mn.Rdata")

gdrive_L4_hist <- ACLIM_seasonal_hist
gdrive_L4_hind <- ACLIM_seasonal_hind
gdrive_L4_fut <- ACLIM_seasonal_fut

rm(list = c("ACLIM_seasonal_hist","ACLIM_seasonal_hind","ACLIM_seasonal_fut"))

# Load Local version on Kir's Mac
#--------------------------------------
# K20P19_CMIP6
fldr <- "K20P19_CMIP6"
sim  <- "cesm_ssp585"
flnm   <- paste0("ACLIMregion_B10K-K20P19_CMIP6_",sim,"_BC_fut.Rdata")
nm <- file.path("data","out",fldr,"BC_ACLIMregion",flnm)

load(nm) # fut
kkh <- fut 
rm(fut)

load("Data/out/ACLIM_L4/CMIP6_K20P19_Indices_operational/allEBS_means/ACLIM_seasonal_hist_mn.Rdata")
load("Data/out/ACLIM_L4/CMIP6_K20P19_Indices_operational/allEBS_means/ACLIM_seasonal_hind_mn.Rdata")
load("Data/out/ACLIM_L4/CMIP6_K20P19_Indices_operational/allEBS_means/ACLIM_seasonal_fut_mn.Rdata")

kkh_L4_hist <- ACLIM_seasonal_hist
kkh_L4_hind <- ACLIM_seasonal_hind
kkh_L4_fut  <- ACLIM_seasonal_fut

rm(list = c("ACLIM_seasonal_hist","ACLIM_seasonal_hind","ACLIM_seasonal_fut"))

# now compare plots

gcmIN   <- "CESM"
sspIN   <- "SSP585"
varIN   <- "Eups_integrated"
basinIN <- "SEBS"
#mn_val val_biascorrected


kkh_eupo_sebs_fut <- kkh_L4_fut%>%filter(GCM==gcmIN,scen==sspIN,var == varIN,basin == basinIN)


eupo_sebs_fut


