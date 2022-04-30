# ----------------------------------------
# load_data.R
# subset of Holsman et al. 2020 Nature Comm.
# kirstin.holsman@noaa.gov
# updated 2020
# ----------------------------------------

  seasons <- data.frame(mo = 1:12, 
                        season =factor("",
                                       levels=c("Winter","Spring","Summer","Fall")))
  seasons$season[1:3]   <- "Winter"
  seasons$season[4:6]   <- "Spring"
  seasons$season[7:9]   <- "Summer"
  seasons$season[10:12] <- "Fall"

  #cat("loading data, this may take a few mins...")
  NEBS_strata <- c(71,70,81,82,90)
  SEBS_strata <- c(10,20,31,32,50,
                   20,41,42,43,61,62)
  

  if(update_base_data) 
    source("R/sub_scripts/update_base_data.R")
  
  # load strata Area for area weighted mean temp:
  load(file.path("Data/in/lookup_tables","STRATA_AREA.Rdata"))
  STRATA_AREAall <-STRATA_AREA
  STRATA_AREA   <- STRATA_AREA%>%filter(REGION=="BS")
  STRATA_AREA$subREG <- "Other"
  STRATA_AREA$subREG[STRATA_AREA$STRATUM%in%NEBS_strata] <- "NEBS"
  STRATA_AREA$subREG[STRATA_AREA$STRATUM%in%SEBS_strata] <- "SEBS"
  STRATA_AREA_compare  <- cast(STRATA_AREA%>%dplyr::select(REGION,STRATUM,YEAR, AREA),
                               REGION+STRATUM~YEAR)
  # use 2010 area designations:
  STRATA_AREA <- STRATA_AREA%>%
    dplyr::filter(YEAR ==2010)%>%
    dplyr::select(REGION,STRATUM, subREG,AREA)
  
  
  load(file.path(shareddata_path,"base_data.Rdata"))
  load(file.path(shareddata_path,"grid_list.Rdata"))
  
  if(load_gis) 
    source("R/sub_scripts/load_maps.R")
  

  #mod_lkup <- readxl::read_xlsx(file.path(in_dir,"aclim_qry_ControlFile.xlsx"),sheet="models")
  #var_lkup <- readxl::read_xlsx(file.path(in_dir,"aclim_qry_ControlFile.xlsx"),sheet="variables")
  
  #_______________________________________
  # Load ROMSNPZ covariates:
  #_______________________________________
  # 
  # load(file.path(in_dir,"covariates.Rdata"))
  # 
  # Scenarios     <-  unique(covariates$Scenario)
  # A1B_n         <-  grep("A1B",Scenarios)
  # bio_n         <-  grep("bio",Scenarios)
  # rcp45_n       <-  grep("rcp45",Scenarios)
  # rcp85_n       <-  grep("rcp85",Scenarios)
  # rcp85NoBio_n  <-  setdiff(rcp85_n,bio_n)
  # plotList      <-  Scenario_set  <- c(1,rcp45_n,rcp85NoBio_n)
  # esnm          <-  list(c(rcp45_n,rcp85NoBio_n))
  # esmlist       <-  list(rcp45_n,rcp85NoBio_n)
  # 
  #_______________________________________
  # Load simulations:
  #_______________________________________
  # 
  # if( update.outputs ){
  #   cat(paste0("\nLoading Intermediate data ('",in_dir,"')...\n"))
  #   for(fn in infn){
  #     if(!any(dir(in_dir)%in%fn))
  #       stop(paste0(fn," file not found in: \t \t",in_dir,
  #                   "\n\nplease go to: https://figshare.com/s/6dea7722df39e07d79f0","",
  #                   "\n\nand download file into: \t \t",in_dir,"/",fn))
  #     load(file.path(in_dir,fn))
  #     cat(paste("\nloaded",fn))
  #   }
  #   cat(paste0("\nIntermediate data loaded  ('",in_dir,"')...\n"))
  #   
  #   if(!file.exists(out_dir))
  #     dir.create(out_dir)
  #   compile.natcommruns(out=out_dir,savelist= outfn)
  #   update.outputs  <-  FALSE
  # }
  #   cat(paste0("\nLoading final data ('",out_dir,"')...\n"))
  #   for(fn in outfn){
  #     if(!any(dir(out_dir)%in%paste0(fn,".Rdata")))
  #       stop(paste0(fn," file not found in: \t \t",out_dir,
  #                   "\n\nplease go to: https://figshare.com/s/6dea7722df39e07d79f0","",
  #                   "\n\nand download file into: \t \t",in_dir," and re-run the R/make.R script"))
  #     load(file.path(out_dir,paste0(fn,".Rdata")))
  #     cat(paste("\nloaded:",fn))
  #   }
  #   cat(paste0("\n\nfinal data loaded('",out_dir,"')...\n"))
  #   
  # 
  #   
  #   simnames  <- Scenarios
  #   Years     <- sort(unique(msm_noCap$future_year)+start_yr-1)
  #   nYrsTot   <- length(Years )

# subset of downscaled projections used for the paper = Scenario_set
# bio runs are a sensitivity set of runs to evaluate nutrient forcing
# of boundary conditions, not used here bc they are highly similar to 
# non-bio runs (See Kearney et al. 2020 and Hermann et al. 2019 for more info
# A1B not used bc they were AR4 runs and only went to 2040
# print(as.character(Scenarios[Scenario_set]))
# ACLIM Projection simulations
# "###########################################################"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
# [1]  "#  | mn_Hind"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   
# [2]  "#  | MIROC_A1B"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
# [3]  "#  | ECHOG_A1B"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
# [4]  "#  | CCCMA_A1B"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
# [5]  "#  | GFDL_rcp45"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
# [6]  "#  | GFDL_rcp85"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
# [7]  "#  | GFDL_rcp85_bio"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
# [8]  "#  | MIROC_rcp45"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               
# [9]  "#  | MIROC_rcp85"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               
# [10] "#  | CESM_rcp45"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
# [11] "#  | CESM_rcp85"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
# [12] "#  | CESM_rcp85_bio"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
#  "###########################################################"  

#cat("Load Data Complete")





