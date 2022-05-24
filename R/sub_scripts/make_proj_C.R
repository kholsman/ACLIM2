#'
#'
#'
#'make_proj_C.R
#'
#'



# Bias corrected proj: don't need to update CMIP6 again
# -----------------------------

# set up hindcast
sim       <-  "B10K-K20P19_CORECFS"
load(file.path(localfolder,file.path(sim,paste0(reg_txt,sim,".Rdata"))))
hnd       <- ACLIMregion; rm(ACLIMregion)
load(file.path(localfolder,file.path(sim,paste0(srvy_txt,sim,".Rdata"))))
hnd_srvy  <- ACLIMsurveyrep; rm(ACLIMsurveyrep)

i <- 0
for( gcmcmip  in c("CMIP6_miroc","CMIP6_gfdl","CMIP6_cesm")){
  
  # set up historical:
  sim   <- paste0("B10K-K20P19_",gcmcmip,"_historical")
  load(file.path(localfolder,file.path(sim,paste0(reg_txt,sim,".Rdata"))))
  hist  <- ACLIMregion; rm(ACLIMregion)
  load(file.path(localfolder,file.path(sim,paste0(srvy_txt,sim,".Rdata"))))
  hist_srvy  <- ACLIMsurveyrep; rm(ACLIMsurveyrep)
  
  sim_listIN <- sim_list[grep(gcmcmip,sim_list)]
  sim_listIN <- sim_listIN[-grep("historical",sim_listIN)]
  
  for (sim in sim_listIN){
    i<-i+1
    cat(sim,"....\n")
    
    # open a "region" or strata specific  file
    load(file.path(localfolder,file.path(sim,paste0(reg_txt,sim,".Rdata"))))
    fut     <- ACLIMregion; rm(ACLIMregion)
    SIM_adj <- bias_correct( 
      hindIN = hnd,
      histIN = hist,
      futIN  = fut,
      ref_yrs    = 1980:2013,
      normlistIN =  normlist,
      plotIT = TRUE,
      plotwk = 2,
      plotvarIN  = "temp_bottom5m",
      log_adj    = 1e-4)
    
    reg_indices <-  make_indices_region( simIN = SIM_adj$fut,
                                         BiasCorrect = TRUE,
                                         seasonsIN = seasons,
                                         refyrs    = deltayrs)
    # open a "region" or strata specific  file
    load(file.path(localfolder,file.path(sim,paste0(srvy_txt,sim,".Rdata")))) 
    fut_srvy    <- ACLIMsurveyrep; rm(ACLIMsurveyrep)
    SIM_adjsrvy <- bias_correct_srvy( 
      hindIN = hnd_srvy,
      histIN = hist_srvy,
      futIN  = fut_srvy,
      ref_yrs    = 1980:2013,
      normlistIN =  normlist,
      plotIT = TRUE,
      plotwk = 45,
      plotvarIN  = "temp_bottom5m",
      log_adj    = 1e-4)
    
    srvy_indices <-  make_indices_srvyrep(simIN = SIM_adjsrvy$fut,
                                          BiasCorrect = TRUE,
                                          seasonsIN = seasons, 
                                          refyrs = deltayrs)
    reg_indices$type  <- "strata means"
    srvy_indices$type <- "survey replicated"
    tmpproj <- rbind(reg_indices,
                     srvy_indices[,match(names(reg_indices),names(srvy_indices))])
    if(i ==1)
      proj <- tmpproj
    if(i!=1)
      proj <- rbind(proj,tmpproj)
    
    rm(reg_indices)
    rm(srvy_indices)
  }
}

proj      <- add_gcmssp(proj)
if(!dir.exists("Data/out")) dir.create("Data/out")
tmpfl <- file.path("Data/out/",paste0("proj_CMIP6_BiasCorr_C_",tmstamp1,".Rdata"))
if(file.exists(tmpfl)) file.remove(tmpfl)    
save(proj, file=tmpfl)
rm(tmpfl)


for( gcmcmip  in c("CMIP5_CESM","CMIP5_GFDL","CMIP5_MIROC")){
  sim_listIN <- sim_list[grep(gcmcmip,sim_list)]
  for (sim in sim_listIN){
    i<-i+1
    cat(sim,"....\n")
    
    # open a "region" or strata specific  file
    load(file.path(localfolder,file.path(sim,paste0(reg_txt,sim,".Rdata"))))
    fut     <- ACLIMregion; rm(ACLIMregion)
    SIM_adj <- bias_correct( 
      hindIN = hnd,
      histIN = hnd,
      futIN  = fut,
      ref_yrs    = 2006:2020,
      normlistIN =  normlist,
      plotIT = TRUE,
      plotwk = 2,
      plotvarIN  = "temp_bottom5m",
      log_adj    = 1e-4)
    
    reg_indices <-  make_indices_region( simIN = SIM_adj$fut,
                                         BiasCorrect = TRUE,
                                         seasonsIN = seasons,
                                         refyrs    = deltayrs)
    
    # open a "region" or strata specific  file
    load(file.path(localfolder,file.path(sim,paste0(srvy_txt,sim,".Rdata")))) 
    fut_srvy     <- ACLIMsurveyrep; rm(ACLIMsurveyrep)
    SIM_adjsrvy <- bias_correct_srvy( 
      hindIN = hnd_srvy,
      histIN = hnd_srvy,
      futIN  = fut_srvy,
      ref_yrs    = 2006:2020,
      normlistIN =  normlist,
      plotIT = TRUE,
      plotwk = 45,
      plotvarIN  = "temp_bottom5m",
      log_adj    = 1e-4)
    
    srvy_indices <-  make_indices_srvyrep(simIN = SIM_adjsrvy$fut,
                                          BiasCorrect = TRUE,
                                          seasonsIN = seasons, 
                                          refyrs = deltayrs)
    reg_indices$type  <- "strata means"
    srvy_indices$type <- "survey replicated"
    tmpproj <- rbind(reg_indices,
                     srvy_indices[,match(names(reg_indices),names(srvy_indices))])
    
    proj <- rbind(proj,tmpproj)
    
    rm(reg_indices)
    rm(srvy_indices)
  }
}
proj      <- add_gcmssp(proj)
if(!dir.exists("Data/out")) dir.create("Data/out")
tmpfl <- file.path("Data/out/",paste0("proj_CMIP5n6_BiasCorr_C_",tmstamp1,".Rdata"))
if(file.exists(tmpfl)) file.remove(tmpfl)    
save(proj, file=tmpfl)
rm(tmpfl)

# Non-Bias corrected proj (CMIP5 and CMIP66) don't need to update again
# -----------------------------
# set up hindcast
sim       <-  "B10K-K20P19_CORECFS"
load(file.path(localfolder,file.path(sim,paste0(reg_txt,sim,".Rdata"))))
hnd  <- ACLIMregion; rm(ACLIMregion)
load(file.path(localfolder,file.path(sim,paste0(srvy_txt,sim,".Rdata"))))
hnd_srvy  <- ACLIMsurveyrep; rm(ACLIMsurveyrep)

i <- 0
sim_listIN <- sim_list[-grep("CORECFS",sim_list)]

for (sim in sim_listIN){
  i<-i+1
  cat(sim,"....\n")
  
  # open a "region" or strata specific  file
  load(file.path(localfolder,file.path(sim,paste0(reg_txt,sim,".Rdata"))))
  reg_indices <-  make_indices_region( simIN = ACLIMregion,
                                       BiasCorrect = FALSE,
                                       seasonsIN = seasons,
                                       refyrs    = deltayrs)
  
  # open a "region" or strata specific  file
  load(file.path(localfolder,file.path(sim,paste0(srvy_txt,sim,".Rdata")))) 
  srvy_indices <-  make_indices_srvyrep(sim = ACLIMsurveyrep,
                                        BiasCorrect = FALSE,
                                        seasonsIN = seasons, 
                                        refyrs = deltayrs)
  reg_indices$type  <- "strata means"
  srvy_indices$type <- "survey replicated"
  tmpproj <- rbind(reg_indices,
                   srvy_indices[,match(names(reg_indices),names(srvy_indices))])
  if(i ==1)
    proj <- tmpproj
  if(i!=1)
    proj <- rbind(proj,tmpproj)
  
  rm(reg_indices)
  rm(srvy_indices)
}

proj      <- add_gcmssp(proj)
if(!dir.exists("Data/out")) dir.create("Data/out")
tmpfl <- file.path("Data/out/",paste0("proj_CMIP6_raw_C_",tmstamp1,".Rdata"))
if(file.exists(tmpfl)) file.remove(tmpfl)    
save(proj, file=tmpfl)
rm(tmpfl)



