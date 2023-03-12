#'
#'
#'
#'makeACLIM2_BC_Indices_new()
#'
#'Author: Kirstin Holsman
#'kirstin.holsman@noaa.gov
#'
#'This script will created the ACLIM indices and 
#'    correct the CMIP6 projections using the 
#'    hindcast and historical simulations
#'
#'

# 1  -- Create indices from Hindcast and save
# 2  -- loop across GCMs and create historical run indices & save
# 3  -- create projection indices
# 4  -- bias correct the projections
# 5  -- save results

makeACLIM2_BC_Indices_new <- function(

  # switches
  overwrite = FALSE,
  bystrata  = TRUE, #if false do survey rep, if true do strata estimates
  sv        = NULL,
  sfIN      = "val_delta",
  updateHist = TRUE,
  updateHind = TRUE,
  updateProj = TRUE,
  smoothIT  = TRUE,
  usehist   = TRUE,
  gcinfoIN  = FALSE,
  ref_yrsIN = 1980:2013,
  # setup 
  BC_target = "mn_val",
  CMIP_fdlr = "K20P19_CMIP6",
  scenIN    =  c("ssp126","ssp585"),
  hind_sim  = "B10K-K20_CORECFS",
  regnm     = "ACLIMregion",
  srvynm    = "ACLIMsurveyrep",
  # data
  histLIST,
  Rdata_pathIN = Rdata_path,
  normlist_IN = normlist,
  gcmcmipLIST = c("B10K-K20P19_CMIP6_miroc","B10K-K20P19_CMIP6_gfdl","B10K-K20P19_CMIP6_cesm"),
  sim_listIN){
  
  
  reg_txtIN  = paste0("Level3/",regnm,"_")
  srvy_txtIN = paste0("Level3/",srvynm,"_")
  gcinfo(gcinfoIN)
 
  if(bystrata) {
    
    if(is.null(sv))
      sv <- unique(normlist_IN$var)
    subtxt <- regnm
  }else{
   
    if(is.null(sv))
      sv <-  unique(normlist_IN$var)
    subtxt <- srvynm
  }
  
  
  if(!dir.exists(file.path("Data/out",CMIP_fdlr)))
    dir.create(file.path("Data/out",CMIP_fdlr))
  
  # if(replace){
  # if(dir.exists(file.path("Data/out",CMIP_fdlr,paste0("BC_",subtxt)))){
  #   dir.remove(file.path("Data/out",CMIP_fdlr,paste0("BC_",subtxt)))
  # }}
  if(!dir.exists(file.path("Data/out",CMIP_fdlr,paste0("BC_",subtxt))))
   dir.create(file.path("Data/out",CMIP_fdlr,paste0("BC_",subtxt)))
  fl <- file.path("Data/out",CMIP_fdlr,paste0("BC_",subtxt))
  

  # Load data
  if(updateHind){
    nm <- paste(subtxt,hind_sim,"BC_hind.Rdata",sep="_")
    if(overwrite){
      if(file.exists(file.path(fl,nm))) 
        file.remove(file.path(fl,nm))}
    nm <- paste(subtxt,hind_sim,"BC_mn_hind.Rdata",sep="_")
    if(overwrite){
      if(file.exists(file.path(fl,nm)))
      file.remove(file.path(fl,nm))}
    
   # source("R/sub_scripts/sub_makeACLIM2_BC_indices/sub_get_hind.R")
    sub_get_hind(sim = hind_sim,
                 reg_txtIN = reg_txtIN,
                 srvy_txtIN = srvy_txtIN,
                 subtxt = subtxt,
                 fl = fl,
                 bystrata  = bystrata, #if false do survey rep, if true do strata estimates
                 sv        = sv,
                 sfIN      = sfIN,
                 smoothIT  = smoothIT,
                 usehist   = usehist,
                 gcinfoIN  = gcinfoIN,
                 ref_yrsIN = ref_yrsIN,
                 BC_target = BC_target,
                 CMIP_fdlr = CMIP_fdlr,
                 scenIN    =  scenIN,
                 regnm     = regnm,
                 srvynm    = srvynm,
                 histLIST =histLIST,
                 Rdata_pathIN = Rdata_pathIN,
                 normlist_IN = normlist_IN,
                 gcmcmipLIST = gcmcmipLIST,
                 sim_listIN = sim_listIN)
    cat(" Make hind...Complete \n")
   # rm(hind)
  }
  
  if(updateHist){
    nm <- "BC_hist.Rdata"
    nm <- paste(subtxt,"BC_hist.Rdata",sep="_")
    if(overwrite)
      if(file.exists(file.path(fl,nm)))
      file.remove(file.path(fl,nm))
    #nm <- "BC_mn_hist.Rdata"
    nm <-  paste(subtxt,"BC_mn_hist.Rdata",sep="_")
    if(overwrite)
      if(file.exists(file.path(fl,nm)))
         file.remove(file.path(fl,nm))
    
   #source("R/sub_scripts/sub_makeACLIM2_BC_indices/sub_get_hist.R")
    sub_get_hist(reg_txtIN = reg_txtIN,
                 srvy_txtIN = srvy_txtIN,
                 subtxt = subtxt,
                 fl = fl,
                 bystrata  = bystrata, #if false do survey rep, if true do strata estimates
                 sv        = sv,
                 sfIN      = sfIN,
                 smoothIT  = smoothIT,
                 usehist   = usehist,
                 gcinfoIN  = gcinfoIN,
                 ref_yrsIN = ref_yrsIN,
                 BC_target = BC_target,
                 CMIP_fdlr = CMIP_fdlr,
                 scenIN    =  scenIN,
                 regnm     = regnm,
                 srvynm    = srvynm,
                 histLIST =histLIST,
                 Rdata_pathIN = Rdata_pathIN,
                 normlist_IN = normlist_IN,
                 gcmcmipLIST = gcmcmipLIST,
                 sim_listIN = sim_listIN)
    cat(" Make hist...Complete \n")
    #rm(hist)
  }
  
  if(updateProj){
    cat("Load hind & hist \n")
    #nm <- "BC_mn_hist.Rdata"
    nm <- paste(subtxt,"BC_mn_hist.Rdata",sep="_")
    load(file=file.path(fl,nm))
    
    #nm <- "BC_mn_hind.Rdata"
    nm <- paste(subtxt,hind_sim,"BC_mn_hind.Rdata",sep="_")
    load(file=file.path(fl,nm))
    
    cat("Remove any previous fut files \n")
    dirlist <- dir(fl)
    grp     <- grep("BC_fut",dirlist)
    if(overwrite){
        if(length(grp)>0){
          # remove proj files
          for(dd in dirlist[grp])
            file.remove(file.path(fl,dd))
        }
      }
 
    #source("R/sub_scripts/sub_makeACLIM2_BC_indices/sub_get_proj.R")
    sub_get_proj(  reg_txtIN = reg_txtIN,
                   fut_startY= 2015,
                   mn_hist   = mn_hist,
                   mn_hind   = mn_hind,
                   srvy_txtIN= srvy_txtIN,
                   subtxt    = subtxt,
                   fl        = fl,
                   bystrata  = bystrata, #if false do survey rep, if true do strata estimates
                   sv        = sv,
                   sfIN      = sfIN,
                   smoothIT  = smoothIT,
                   usehist   = usehist,
                   gcinfoIN  = gcinfoIN,
                   ref_yrsIN = ref_yrsIN,
                   BC_target = BC_target,
                   CMIP_fdlr = CMIP_fdlr,
                   scenIN    =  scenIN,
                   regnm     = regnm,
                   srvynm    = srvynm,
                   histLIST  = histLIST,
                   Rdata_pathIN = Rdata_pathIN,
                   normlist_IN  = normlist_IN,
                   gcmcmipLIST  = gcmcmipLIST,
                   sim_listIN   = sim_listIN)
    cat(" Make proj...Complete \n")
  }
}


