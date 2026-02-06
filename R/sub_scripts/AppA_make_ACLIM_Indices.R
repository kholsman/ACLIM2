#'
#'
#'
#'APPENDIX_A.R
#'
#'

  # ========================================
  # switches & settings
  # ========================================
   
    source("R/make.R") |> suppressMessages()
  
    tmstp    <- "2026_02_05"
    library(here)
    #here("Data/in")|>dir()
    Rdata_path  <- here("Data/in/2026_02_05_Rdata")
    nc_data_path <- here("Data/in/2026_02_05_ncdata")
    if(!file.exists(Rdata_path)) dir.create(Rdata_path)
    if(!file.exists(nc_data_path)) dir.create(nc_data_path)
    
    main        <- here()  
    tmstamp1    <- format(Sys.time(), "%Y%m%d")

    update_biascorrection <- TRUE # set to true to update the bias correction
    update_CMIP6 <- TRUE    # will re-download the nc files from the thredds server
    update_CMIP5 <- TRUE   # will re-download the nc files from the thredds server
    update_l2 <- TRUE      # will re-download the level 2 files form the thredds server - slow!
    
  # ========================================
  # load data
  # ========================================
    
    ref_years # the reference years for bias correcting in R/setup.R
    deltayrs # the year to z-score scale / delta in R/setup.R
    data_path
    proj_cmip6_list <- simlist[grep("CMIP6",sim_list)]
    proj_cmip5_list <- simlist[grep("CMIP5",sim_list)]
    hind_cmip6_list <- c("B10K-K20P19_CORECFS","B10K-K20_CORECFS")  #updated with OA from Darren #"B10K-K20_CORECFS"
    hind_cmip5_list <- "B10K-H16_CORECFS"
    
    if(update_l2){
      
      # first get the updated grid for L2 files:
      anc <- aclim_thredds(section = "ancillary")
      anc
    
      for(i in seq(anc$filename)){
        thredds_download_nc(url = anc$download_url[i],
                            dest = file.path(nc_data_path,anc$filename[i]),
                            cache_dir = "~/.aclim_cache",
                            overwrite = TRUE)
      }
      
      # now get L2 files
      sims <- aclim_thredds(section = "files")
      head(sims)
      
      # what are the sub folders?
      aclim_thredds(run = sims[2])
      
      L2_time_periods <- aclim_thredds(run =sims[2], level = 2)
      L2_time_periods
      
      L2_files <- aclim_thredds(run =sims[2], level = 2, time_period = L2_time_periods[1] )
      L2_files$variable
      
      # example - get avg bottom temp
      ll <- which(L2_files$variable =="average_temp_bottom5m")
      
      tmpURL <- L2_files$download_url[ll]
      
      tmpdest <- make_fldr(list_obj = L2_files[ll,])
      
      thredds_download_nc(url = L2_files$download_url[ll],
                          dest = tmpdest,
                          cache_dir = "~/.aclim_cache",
                          overwrite = TRUE)
      
      # get all bottom temps:
      L2_files$variable
      l2varset <- "average_temp_bottom5m"
      if(update_l2){
        for(v in seq_along(l2varset)){
          for(s in seq_along(sims)){
            message(paste("getting L2 data for ",sims[s],"..."))
            L2_time_periods <- aclim_thredds(run =sims[s], 
                                             level = 2)
            L2_time_periods
            
            
            for(t in seq_along(L2_time_periods)){
              
              L2_files <- aclim_thredds(run =sims[s], 
                                        level = 2, 
                                        time_period = L2_time_periods[t] )
              
               ll <- which(L2_files$variable ==varset[v])
                
                tmpURL <- L2_files$download_url[ll]
                
                tmpdest <- make_fldr(list_obj = L2_files[ll,])
                
                thredds_download_nc(url = L2_files$download_url[ll],
                                    dest = tmpdest,
                                    cache_dir = "~/.aclim_cache",
                                    overwrite = TRUE)
              }
          }
        }
       
     
       
      }
      
    }
    
    if(update_l3){  
      
      # now get the L2 and L3 data:
      sims <- aclim_thredds(section = "files")
      head(sims)

      # what are the sub folders?
      aclim_thredds(run = sims[2])

      files_L3 <- aclim_thredds(run =sims[2], level = 3)
      files_L3
      
      # ---- Get the CMIP5 set ----
      if(update_CMIP5){
        message("Updating CMIP5 set, may take a while...")
        
        tmp_set <- sims[grep("H16",sims)]
        for(s in seq_along(tmp_set) ) 
        {
          files_L3 <- aclim_thredds(run =tmp_set[s], level = 3)
          # ignore the _C files bc they are holdovers from bridging activities
          #files_L3use <-files_L3[-grep("_C_",files_L3$filename),]
          files_L3use <- files_L3
          for(f in seq(files_L3use$filename)){
            
            # make the folder:
            tmpURl  <- files_L3use$download_url[f]
            tmpdest <-  make_fldr(list_obj = files_L3use[f,])
            # download the file:
            thredds_download_nc(url = tmpURl,
                                dest = tmpdest,
                                cache_dir = "~/.aclim_cache",
                                overwrite = TRUE)
            
          }
          
        }
      }
      
      # ---- Get the CMIP6 set ----
      if(update_CMIP6){
        message("Updating CMIP6 set, may take a while...")
        tmp_set <- sims[grep("K20P19_",sims)]
        for(s in seq_along(tmp_set) ) 
        {
          
          files_L3 <- aclim_thredds(run =tmp_set[s], level = 3)
          # ignore the _C files bc they are holdovers from bridging activities
          #files_L3use <-files_L3[-grep("_C_",files_L3$filename),]
          files_L3use<-files_L3
          for(f in seq_along(files_L3use$filename)){
            
            # make the folder:
            tmpURl  <- files_L3use$download_url[f]
            tmpdest <-  make_fldr(list_obj = files_L3use[f,])
            # download the file:
            thredds_download_nc(url = tmpURl,
                                dest = tmpdest,
                                cache_dir = "~/.aclim_cache",
                                overwrite = TRUE)
            
          }
          
        }
      }
      
      # ---- test on your ancillary ----
      start_extra <- "https://data.pmel.noaa.gov/aclim/thredds/catalog/ancillary/catalog.html"
      lst_extra <- thredds_nc_list(start_extra)
      lst_extra
      download.file(lst_extra$download_url,destfile = file.path(Rdata_path,lst_extra$filename[1]), overwrite = T)
      
      thredds_download_nc(url = lst_extra$download_url,
                          dest = file.path(Rdata_path,lst_extra$filename[1]),
                          cache_dir = "~/.aclim_cache",
                          overwrite = TRUE)
      
      start_sims  <-"https://data.pmel.noaa.gov/aclim/thredds/catalog/files.html"
      
      lst_extra <- thredds_nc_list(start_extra)
      lst_sims  <- thredds_nc_list(start_sims) # takes a few mins
      
      nrow(lst_sims)
      nrow(lst_extra)
      
      # Write lists
      writeLines(lst_sims$filename,    "sims_filenames.txt")
      writeLines(lst_sims$download_url,"sims_download_urls.txt")
      
      # download the nc file and save locally
      tmpURL <- paste0(paste0(ACLIM_data_url,"fileServer/",m,"/Level3/"),d,"_",m,".nc")
      tmpURl <- lst_extra$download_url[2]
      download.file(tmpURL,destfile = file.path(Rdata_path,lst_extra$filename[1]), overwrite = T)
      
      tmpURL <- "https://data.pmel.noaa.gov/aclim/thredds/fileServer/ancillary/Bering10K_extended_grid.nc"
      
      download.file(tmpURL,destfile = file.path(Rdata_path,lst_extra$filename[1]), overwrite = overwriteIN)
      
      thredds_download_nc(url = tmpURL,
                          dest = file.path(Rdata_path,lst_extra$filename[1]),
                          cache_dir = "~/.aclim_cache",
                          overwrite = TRUE)
      
      
      rd_path <- local_path <- Rdata_path
      tmp <- get_l3(web_nc= TRUE,
                    download_nc = TRUE,
                    rd_path    = Rdata_path,
                    local_path = Rdata_path,
                    varlist    = c(
                          "temp_bottom5m",    # bottom temperature,
                          "NCaS_integrated",  # Large Cop
                          "Cop_integrated",   # Small Cop
                          "EupS_integrated"),  # Shelf  euphausiids
                     sim_list   = hind_cmip6_list[1] 
                    )
      https://data.pmel.noaa.gov/aclim/thredds/catalog/files/B10K-K20P19_CORECFS/Level3/catalog.html?dataset=files/B10K-K20P19_CORECFS/Level3/ACLIMregion_B10K-K20P19_CORECFS.nc
      https://data.pmel.noaa.gov/aclim/thredds/fileServer/B10K-K20P19_CORECFS/Level3/ACLIMregion_B10K-K20P19_CORECFS.nc
  
          # get weekly data
      
      
      # get survey replicated data
      
    }
    
    load(file.path(Rdata_path,"weekly_vars.Rdata"))
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
    
    # -------------------------------------------
    # make ACLIM level 4 indices (annual, monthly, weekly, etc)
    # -------------------------------------------
      
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

