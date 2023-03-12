#'
#'
#'
#'APPENDIX_A.R
#'
#'

# --------------------------------------
# SETUP WORKSPACE
# rm(list=ls())
# setwd("D:/GitHub_cloud/ACLIM2")
# setwd("/Volumes/LaCie/GitHub_cloud/ACLIM2")
# loads packages, data, setup, etc.

tmstp       <- "2022_10_17"
update_biascorrection <- FALSE
suppressMessages(source("R/make.R"))
tmstp       <- "2022_10_17"
Rdata_path  <- paste0("../../romsnpz/",tmstp,"_Rdata")
main        <- getwd()  #"~/GitHub_new/ACLIM2"
tmstamp1    <- format(Sys.time(), "%Y%m%d")

update_hind  <- TRUE   # set to true to update hind
update_hist  <- TRUE   # set to true to update hist
update_proj  <- TRUE   # set to true to update fut

# the reference years for bias correcting in R/setup.R
ref_years 
# the year to z-score scale / delta in R/setup.R
deltayrs 
data_path

#load(file.path(Rdata_path,"../weekly_vars_C.Rdata"))
load(file.path(Rdata_path,"weekly_vars.Rdata"))
#load(file.path(Rdata_path,"../srvy_vars_C.Rdata"))
load(file.path(Rdata_path,"srvy_vars.Rdata"))
load(file.path(Rdata_path,"l3srvy_varlist.Rdata"))
load(file.path(Rdata_path,"l3wk_varlist.Rdata"))
load(file.path(Rdata_path,"l3srvy_varlist_H16.Rdata"))
load(file.path(Rdata_path,"l3wk_varlist_H16.Rdata"))

load(file.path(Rdata_path,"l2_vars.Rdata"))


vl1   <- l3srvy_varlist #srvy_vars[!srvy_vars%in%rm_var_list]
vl2   <- l3wk_varlist# weekly_vars[!weekly_vars%in%rm_wk_list]

# add in largeZoop (gets generated in make_indices_region_new.R)
vl <- c(unique(c(vl1,vl2)),"largeZoop_integrated")

# Identify which variables would be normally 
# distributed (i.e., can have negative values)
normvl <- c( vl[grep("pH",vl)],
             vl[grep("temp",vl)],
             #vl[grep("Ben",vl)],
             vl[grep("Hsbl",vl)],
             vl[grep("shflux",vl)],
             vl[grep("ssflux",vl)],
             vl[grep("vNorth",vl)],
             vl[grep("uEast",vl)])

normlist <- data.frame(var = vl, lognorm = "none",stringsAsFactors = F)
normlist$lognorm[!normlist$var%in%normvl]   <- "log"
normlist$lognorm[normlist$var%in%
                   c( vl[grep("aice",vl)],
                      vl[grep("fracbelow0",vl)],
                      vl[grep("fracbelow1",vl)],
                      vl[grep("fracbelow2",vl)])]  <- "logit"


sv_bc    <- c("largeZoop_integrated","fracbelow2",
              "temp_bottom5m","temp_surface5m","pH_depthavg")
sv_bc <- NULL  # bias correct all indices

weekly_vars <- c(weekly_vars,"largeZoop_integrated")
srvy_vars <- c(srvy_vars,"largeZoop_integrated")
save(normlist,file      = file.path(Rdata_path,"normlist.Rdata"))
write.csv(normlist,file = file.path(Rdata_path,"normlist.csv"))
save(weekly_vars,file   = "Data/out/weekly_vars.Rdata")
save(srvy_vars,file     = "Data/out/srvy_vars.Rdata")
write.csv(normlist,file = file.path("Data/out/","normlist.csv"))


# generate indices and bias corrected projections 
# this takes about 30 mins each
# -------------------------------------------
# CMIP6 K20P19
# -------------------------------------------


    gcmcmipL <- c("B10K-K20P19_CMIP6_miroc",
                  "B10K-K20P19_CMIP6_gfdl",
                  "B10K-K20P19_CMIP6_cesm") 

    gcmcmipL2 <- c("B10K-K20P19_CMIP5_MIROC",
               "B10K-K20P19_CMIP5_GFDL",
               "B10K-K20P19_CMIP5_CESM")
    gc()
    tmp_hind <- suppressMessages(makeACLIM2_BC_Indices_new(
      bystrata  = TRUE,
      BC_target = "mn_val",
      ref_yrsIN = 1980:2013,
      sv         = sv_bc,
      updateHist = TRUE, # update_hist,
      updateHind = TRUE, # update_hind,
      updateProj = TRUE,
      smoothIT  = TRUE,
      sfIN      = "val_delta",
      CMIP_fdlr ="K20P19_CMIP6",
      scenIN    = c("ssp126","ssp585"),
      hind_sim  =  "B10K-K20P19_CORECFS",
      histLIST  = paste0(gcmcmipL,"_historical"),
      gcmcmipLIST  = gcmcmipL,
      usehist      = TRUE,
      Rdata_pathIN = file.path(Rdata_path,"roms_for_public"),
      regnm        = "ACLIMregion",
      srvynm       = "ACLIMsurveyrep",
      normlist_IN  = normlist,
      sim_listIN   = sim_list[-grep("historical",sim_list)],
      gcinfoIN     = FALSE))
    
    
    
    rplc_bcplot <-TRUE
    source("R/sub_scripts/plot_BC_stratawk.R")
    
    
    # make bc indices for survey rep stations
    tmp2_hind<- suppressMessages(makeACLIM2_BC_Indices_new(
      bystrata  = FALSE,
      BC_target = "mn_val",
      sv        = sv_bc,
      sfIN      = "val_delta",
      smoothIT  = TRUE,
      updateHist = TRUE, # update_hist,
      updateHind = TRUE, # update_hind,
      updateProj = TRUE,
      CMIP_fdlr ="K20P19_CMIP6",
      scenIN    = c("ssp126","ssp585"),
      hind_sim  =  "B10K-K20P19_CORECFS",
      histLIST  = paste0(gcmcmipL,"_historical"),
      gcmcmipLIST = gcmcmipL,
      usehist     = TRUE,
      Rdata_pathIN = file.path(Rdata_path,"roms_for_public"),
      regnm       = "ACLIMregion",
      srvynm      = "ACLIMsurveyrep",
      normlist_IN = normlist,
      sim_listIN  = sim_list[-grep("historical",sim_list)],
      gcinfoIN    = FALSE))
    
  
# -------------------------------------------
# CMIP5 K20P19
# -------------------------------------------
    
    gcmcmipL2 <- c("B10K-K20P19_CMIP5_MIROC",
                   "B10K-K20P19_CMIP5_GFDL",
                   "B10K-K20P19_CMIP5_CESM")
    # make bc indices for strata specific values:
    tmphind <- suppressMessages(makeACLIM2_BC_Indices_new(
      bystrata  = TRUE,
      BC_target = "mn_val",
      ref_yrsIN = 1980:2020,
      sv        = sv_bc,
      updateHist = TRUE, # update_hist,
      updateHind = TRUE, # update_hind,
      updateProj = FALSE,
      smoothIT  = TRUE,
      CMIP_fdlr ="K20P19_CMIP5",
      scenIN    = c("rcp45","rcp85"),
      hind_sim  =  "B10K-K20P19_CORECFS",
      histLIST  = gcmcmipL2,
      gcmcmipLIST  = gcmcmipL2,
      usehist      = FALSE,
      Rdata_pathIN = file.path(Rdata_path,"roms_for_public"),
      regnm        = "ACLIMregion",
      srvynm       = "ACLIMsurveyrep",
      normlist_IN  = normlist,
      sim_listIN   = sim_list[-grep("historical",sim_list)],
      gcinfoIN     = FALSE))
    tmp <- suppressMessages(makeACLIM2_BC_Indices_new(
      bystrata  = TRUE,
      BC_target = "mn_val",
      ref_yrsIN = 1980:2020,
      sv        = sv_bc,
      updateHist = FALSE, # update_hist,
      updateHind = FALSE, # update_hind,
      updateProj = TRUE,
      smoothIT  = TRUE,
      CMIP_fdlr ="K20P19_CMIP5",
      scenIN    = c("rcp45","rcp85"),
      hind_sim  =  "B10K-K20P19_CORECFS",
      histLIST  = gcmcmipL2,
      gcmcmipLIST  = gcmcmipL2,
      usehist      = FALSE,
      Rdata_pathIN = file.path(Rdata_path,"roms_for_public"),
      regnm        = "ACLIMregion",
      srvynm       = "ACLIMsurveyrep",
      normlist_IN  = normlist,
      sim_listIN   = sim_list[-grep("historical",sim_list)],
      gcinfoIN     = FALSE))   
    
    # rplc_bcplot <-TRUE
    # source("R/sub_scripts/plot_BC_stratawk.R")
    # 
    
    # make bc indices for survey rep stations
    tmp2<- suppressMessages(makeACLIM2_BC_Indices_new(
      bystrata  = FALSE,
      BC_target = "mn_val",
      sv = sv_bc, 
      smoothIT  = TRUE,
      CMIP_fdlr ="K20P19_CMIP5",
      scenIN    = c("rcp45","rcp85"),
      hind_sim  =  "B10K-K20P19_CORECFS",
      histLIST  = gcmcmipL2,
      gcmcmipLIST  = gcmcmipL2,
      usehist     = FALSE,
      Rdata_pathIN = file.path(Rdata_path,"roms_for_public"),
      regnm       = "ACLIMregion",
      srvynm      = "ACLIMsurveyrep",
      normlist_IN = normlist,
      sim_listIN  = sim_list[-grep("historical",sim_list)],
      gcinfoIN    = FALSE))
    
    
    #make ACLIM level 4 indices (annual, mont    
    gc()
    suppressMessages(makeACLIM2_L4_Indices_strata(
      CMIP_fdlr   = "Data/out/K20P19_CMIP6",
      CMIP        = "CMIP6",
      scenIN      = c("ssp126","ssp585"),
      hind_sim    = "B10K-K20P19_CORECFS",
      gcmcmipLIST = gcmcmipL,
      ref_yrsIN   = 1980:2013,
      subfldrIN     = "BC_ACLIMregion",
      sim_listIN  = sim_list, 
      varlistIN   = sv_bc,
      prefix      = "ACLIMregion"))
    
    gc()
    suppressMessages(makeACLIM2_L4_Indices_survey(
      CMIP_fdlr   = "Data/out/K20P19_CMIP6",
      CMIP        = "CMIP6",
      scenIN      = c("ssp126","ssp585"),
      hind_sim    = "B10K-K20P19_CORECFS",
      gcmcmipLIST = gcmcmipL,
      subfldrIN     = "BC_ACLIMsurveyrep",
      sim_listIN  = sim_list, 
      varlistIN   = sv_bc,
      prefix      = "ACLIMsurveyrep"))
    
    source("R/sub_scripts/plot_NEBSnSEBS.R")
    
    
    suppressMessages(makeACLIM2_L4_Indices_strata(
      CMIP_fdlr   = "Data/out/K20P19_CMIP5",
      CMIP        = "CMIP5",
      scenIN    = c("rcp45","rcp85"),
      hind_sim    = "B10K-K20P19_CORECFS",
      gcmcmipLIST = gcmcmipL2,
      subfldrIN     = "BC_ACLIMregion",
      sim_listIN  = sim_list, 
      varlistIN   = sv_bc,
      prefix      = "ACLIMregion"))
    gc()
    
    suppressMessages(makeACLIM2_L4_Indices_survey(
      CMIP_fdlr   = "Data/out/K20P19_CMIP5",
      CMIP        = "CMIP5",
      scenIN    = c("rcp45","rcp85"),
      hind_sim    = "B10K-K20P19_CORECFS",
      gcmcmipLIST = gcmcmipL2,
      subfldrIN     = "BC_ACLIMsurveyrep",
      sim_listIN  = sim_list, 
      varlistIN   = sv_bc,
      prefix      = "ACLIMsurveyrep"))

# APPENDIX B: Create & bias correct ACLIM2 indices to IEA the operational hindcast


# --------------------------------------
# SETUP WORKSPACE
# rm(list=ls())
# setwd("D:/GitHub_cloud/ACLIM2")
# loads packages, data, setup, etc.
# generate indices and bias corrected projections 
# this takes about 30 mins each
# -------------------------------------------
# Operational hincast CMIP6 K20P19
# -------------------------------------------
    sv_bc <- NULL
    gcmcmipL <- c("B10K-K20P19_CMIP6_miroc",
                  "B10K-K20P19_CMIP6_gfdl",
                  "B10K-K20P19_CMIP6_cesm") 
    tmp_hind <- suppressMessages(makeACLIM2_BC_Indices_new(
      bystrata  = TRUE,
      overwrite = FALSE,
      BC_target = "mn_val",
      ref_yrsIN = 1980:2013,
      sv         = sv_bc,
      updateHist = FALSE, # update_hist,
      updateHind = TRUE, # update_hind,
      updateProj = FALSE,
      smoothIT  = TRUE,
      sfIN      = "val_delta",
      CMIP_fdlr ="K20P19_CMIP6",
      scenIN    = c("ssp126","ssp585"),
      hind_sim  = "OperationalHindcast",
      histLIST  = paste0(gcmcmipL,"_historical"),
      gcmcmipLIST  = gcmcmipL,
      usehist      = TRUE,
      Rdata_pathIN = file.path(Rdata_path,"roms_for_public"),
      regnm        = "ACLIMregion",
      srvynm       = "ACLIMsurveyrep",
      normlist_IN  = normlist,
      sim_listIN   = sim_list[-grep("historical",sim_list)],
      gcinfoIN     = FALSE))
    
    
    tmp_hind2 <- suppressMessages(makeACLIM2_BC_Indices_new(
      bystrata  = FALSE,
      overwrite = FALSE,
      BC_target = "mn_val",
      ref_yrsIN = 1980:2013,
      sv         = sv_bc,
      updateHist = FALSE, # update_hist,
      updateHind = TRUE, # update_hind,
      updateProj = FALSE,
      smoothIT  = TRUE,
      sfIN      = "val_delta",
      CMIP_fdlr ="K20P19_CMIP6",
      scenIN    = c("ssp126","ssp585"),
      hind_sim  = "OperationalHindcast",
      histLIST  = paste0(gcmcmipL,"_historical"),
      gcmcmipLIST  = gcmcmipL,
      usehist      = TRUE,
      Rdata_pathIN = file.path(Rdata_path,"roms_for_public"),
      regnm        = "ACLIMregion",
      srvynm       = "ACLIMsurveyrep",
      normlist_IN  = normlist,
      sim_listIN   = sim_list[-grep("historical",sim_list)],
      gcinfoIN     = FALSE))
    
    #make ACLIM level 4 indices (annual, monthly, seasonal, weekly)
    
    suppressMessages(makeACLIM2_L4_Indices_strata(
      CMIP_fdlr   = "Data/out/K20P19_CMIP6",
      ophind      = TRUE,
      CMIP        = "CMIP6",
      scenIN      = c("ssp126","ssp585"),
      hind_sim    = "OperationalHindcast",
      gcmcmipLIST = gcmcmipL,
      subfldrIN     = "BC_ACLIMregion",
      sim_listIN  = sim_list, 
      varlistIN   = sv_bc,
      #varlistIN   = c("aice","largeZoop_integrated"),
      prefix      = "ACLIMregion"))
    gc()
    
    suppressMessages(makeACLIM2_L4_Indices_survey(
      CMIP_fdlr   = "Data/out/K20P19_CMIP6",
      ophind      = TRUE,
      CMIP        = "CMIP6",
      scenIN      = c("ssp126","ssp585"),
      hind_sim    = "OperationalHindcast",
      gcmcmipLIST = gcmcmipL,
      subfldrIN     = "BC_ACLIMsurveyrep",
      sim_listIN  = sim_list, 
      varlistIN   = sv_bc,
      prefix      = "ACLIMsurveyrep"))

if(1==10){
  
  #Skip this for now
  
  # -------------------------------------------  
  # CMIP5 H16
  # -------------------------------------------
  gcmcmipL2 <- c("B10K-H16_CMIP5_MIROC",
                 "B10K-H16_CMIP5_GFDL",
                 "B10K-H16_CMIP5_CESM") 
  
  tmp <- suppressMessages(makeACLIM2_BC_Indices_new(
    bystrata  = TRUE,
    BC_target = "mn_val",
    sv        = NULL,
    ref_yrsIN = 1980:2020,
    smoothIT  = TRUE,
    CMIP_fdlr ="B10K_H16",
    scenIN    = c("rcp45","rcp85"),
    hind_sim  =  "B10K-H16_CORECFS",
    histLIST  = gcmcmipL2,
    gcmcmipLIST  = gcmcmipL2,
    usehist      = FALSE,
    Rdata_pathIN = file.path(Rdata_path,"roms_for_public"),
    regnm        = "ACLIMregion",
    srvynm       = "ACLIMsurveyrep",
    normlist_IN  = normlist,
    sim_listIN   = sim_list[-grep("historical",sim_list)],
    gcinfoIN     = FALSE))
  
  # make bc indices for survey rep stations
  tmp2<- suppressMessages(makeACLIM2_BC_Indices_new(
    bystrata  = FALSE,
    BC_target = "mn_val",
    sv = sv_bc, 
    smoothIT  = TRUE,
    CMIP_fdlr ="B10K_H16",
    scenIN    = c("rcp45","rcp85"),
    hind_sim  =  "B10K-H16_CORECFS",
    histLIST  = gcmcmipL2,
    gcmcmipLIST  = gcmcmipL2,
    usehist     = FALSE,
    Rdata_pathIN = file.path(Rdata_path,"roms_for_public"),
    regnm       = "ACLIMregion",
    srvynm      = "ACLIMsurveyrep",
    normlist_IN = normlist,
    sim_listIN  = sim_list[-grep("historical",sim_list)],
    gcinfoIN    = FALSE))
  #make ACLIM level 4 indices (annual, monthly, seasonal, weekly)
  
  suppressMessages(makeACLIM2_L4_Indices_strata(
    CMIP_fdlr   = "Data/out/K20P19_CMIP5",
    CMIP        = "CMIP5",
    scenIN    = c("rcp45","rcp85"),
    hind_sim    = "B10K-H16_CORECFS",
    gcmcmipLIST = gcmcmipL2,
    subfldr     = "BC_ACLIMregion",
    sim_listIN  = sim_list, 
    varlistIN   = normlist$var,
    prefix      = "ACLIMregion"))
  gc()
  
  suppressMessages(makeACLIM2_L4_Indices_survey(
    CMIP_fdlr   = "Data/out/K20P19_CMIP5",
    CMIP        = "CMIP5",
    scenIN    = c("rcp45","rcp85"),
    hind_sim    = "B10K-H16_CORECFS",
    gcmcmipLIST = gcmcmipL2,
    subfldr     = "BC_ACLIMsurveyrep",
    sim_listIN  = sim_list, 
    varlistIN   = normlist$var,
    prefix      = "ACLIMsurveyrep"))
}

