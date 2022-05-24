#'
#'
#'make_hind_C.R
#'ACLIM2 folder
#'
#'updated Apr 28 2022


# hindcast first: Update annually
# -----------------------------
i <- 0
sim_listIN <- "B10K-K20P19_CORECFS"
for (sim in sim_listIN){
  i <- i + 1
  cat(sim,"....\n")
  
  load(file.path(Rdata_path,file.path(sim,paste0(reg_txt,sim,".Rdata"))))
  reg_indices <-  make_indices_region( simIN = ACLIMregion,
                                       timeblockIN = c("yr","season"),
                                       seasonsIN = seasons,
                                       refyrs    = deltayrs)
  
  load(file.path(Rdata_path,file.path(sim,paste0(srvy_txt,sim,".Rdata"))))
  srvy_indices <-  make_indices_srvyrep( simIN = ACLIMsurveyrep,
                                         BiasCorrect = FALSE,
                                         seasonsIN = seasons,
                                         refyrs = deltayrs)
  rm(ACLIMsurveyrep)
  rm(ACLIMregion)
  reg_indices$type  <- "strata means"
  srvy_indices$type <- "survey replicated"
  hind_C <- rbind(reg_indices,
                srvy_indices[,match(names(reg_indices),names(srvy_indices))])
  hind_C$kind <- "hind"
  
  rm(reg_indices)
  rm(srvy_indices)
}

hind_C$cmip     <- "hindcast"
hind_C$scenario <- "hindcast"
hind_C$gcm  <- "CORECFS"
hind_C$ssp  <- "hindcast"

if(!dir.exists("Data/out")) dir.create("Data/out")
tmpfl <- file.path("Data/out/",paste0("hind_C_",tmstamp1,".Rdata"))
if(file.exists(tmpfl)) file.remove(tmpfl)    
save(hind_C, file=tmpfl)
rm(tmpfl)

