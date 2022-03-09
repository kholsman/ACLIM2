#'
#'
#'make_hind.R
#'
#'

    
    # hindcast first: Update annually
    # -----------------------------
    i <- 0
    sim_listIN <- "B10K-K20_CORECFS"
    for (sim in sim_listIN){
      i <- i + 1
      cat(sim,"....\n")
      
      load(file.path(localfolder,file.path(sim,paste0(reg_txt,sim,".Rdata"))))
      reg_indices <-  make_indices_region( simIN = ACLIMregion,
                                           BiasCorrect = FALSE,
                                           seasonsIN = seasons,
                                           refyrs    = deltayrs)
      
      load(file.path(localfolder,file.path(sim,paste0(srvy_txt,sim,".Rdata"))))
      srvy_indices <-  make_indices_srvyrep( simIN = ACLIMsurveyrep,
                                             BiasCorrect = FALSE,
                                             seasonsIN = seasons,
                                             refyrs = deltayrs)
      rm(ACLIMsurveyrep)
      rm(ACLIMregion)
      reg_indices$type  <- "strata means"
      srvy_indices$type <- "survey replicated"
      hind <- rbind(reg_indices,
                    srvy_indices[,match(names(reg_indices),names(srvy_indices))])
      hind$kind <- "hind"
      
      rm(reg_indices)
      rm(srvy_indices)
    }
    
    hind$cmip     <- "hindcast"
    hind$scenario <- "hindcast"
    hind$gcm  <- "CORECFS"
    hind$ssp  <- "hindcast"
    
    if(!dir.exists("Data/out")) dir.create("Data/out")
    tmpfl <- file.path("Data/out/",paste0("hind_",tmstamp1,".Rdata"))
    if(file.exists(tmpfl)) file.remove(tmpfl)    
    save(hind, file=tmpfl)
    rm(tmpfl)

