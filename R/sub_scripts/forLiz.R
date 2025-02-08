#'
#'
#'
#' forLiz
#' 


#  setwd("D:/GitHub_cloud/ACLIM2")
# loads packages, data, setup, etc.
suppressMessages( suppressWarnings(source("R/make.R")))



# ---------------------------------------------------
# PART 1 make the lookup dataframes ("mnVal_lookup")
# ---------------------------------------------------
    
    # load the strata x weekly bias corrected values ("fut") for each gcm in the cmip6
    cmipfldr <- "K20P19_CMIP6"
    gcmcmipL <- c("B10K-K20P19_CMIP6_miroc",
                  "B10K-K20P19_CMIP6_gfdl",
                  "B10K-K20P19_CMIP6_cesm")
    i<- 0
    for(scen in c("ssp126","ssp585")){
      for (gcmcmip in gcmcmipL){
        i <- i+ 1
        cat(" -- loading ", gcmcmip, " ",scen,"\n")
        # extract gcm and cmip:
        
        mod   <- (strsplit(gcmcmip,"_")[[1]])[1]
        CMIP  <- strsplit(gcmcmip,"_")[[1]][2]
        GCM   <- strsplit(gcmcmip,"_")[[1]][3]
        
        # can be either ssp 126 or 585, the hist is only specific to the gcm (eg. cesm)
        load(file.path("Data/out",cmipfldr,"BC_ACLIMregion", paste0("ACLIMregion_",gcmcmip,"_",scen,"_BC_fut.Rdata")))
        
        # grab the mean strata x weekly values for bias correcting the grid
        sub_BC <- fut%>%
          dplyr::select(sim, var,  season,mo,wk,lognorm, basin, strata, mnVal_hind,mnVal_hist,sf_wk)%>%
          dplyr::distinct(sim, var, season,mo,wk,lognorm, basin, strata, mnVal_hind,mnVal_hist,sf_wk, .keep_all= TRUE)%>%
          mutate(GCM = GCM, CMIP=CMIP, mod = mod,scen =scen)%>%ungroup()
        #dplyr::summarize_at(c("mnVal_hind", "mnVal_hist","sf_wk"), mean, na.rm=T)
        if(i ==1){
          mnVal_lookup <- sub_BC
        }else{
          mnVal_lookup <- rbind(mnVal_lookup,sub_BC)
        }
        rm(list=c("sub_BC","fut"))
      }
    }
    
    # check that there are 3 gcms x 2 scens:, vals are the same for both scens within a gcm:
    mnVal_lookup%>%filter(strata == 70,var=="aice", wk==1)
    
    
    # save the lookup table:
    if(!dir.exists(file.path("Data/out",cmipfldr,"bc_mnVals")))
      dir.create(file.path("Data/out",cmipfldr,"bc_mnVals"))
    
    fl <- file.path("Data/out",cmipfldr,"bc_mnVals")
    nm <- paste(cmipfldr,"_BC_mnVal_lookup.Rdata",sep="_")
    save(mnVal_lookup,file=file.path(fl,nm))
    
    # now for CMIP5
    #----------------------------------------------------------------
    # load the strata x weekly bias corrected values ("fut") for each gcm in the cmip6
    cmipfldr <- "K20P19_CMIP5"
    gcmcmipL <- c("B10K-K20P19_CMIP5_MIROC",
                  "B10K-K20P19_CMIP5_GFDL",
                  "B10K-K20P19_CMIP5_CESM")
    i<- 0
    for(scen in c("rcp45","rcp85")){
      for (gcmcmip in gcmcmipL){
        i <- i+ 1
        cat(" -- loading ", gcmcmip, " ",scen)
        # extract gcm and cmip:
        
        mod   <- (strsplit(gcmcmip,"_")[[1]])[1]
        CMIP  <- strsplit(gcmcmip,"_")[[1]][2]
        GCM   <- strsplit(gcmcmip,"_")[[1]][3]
        
        # can be either ssp 126 or 585, the hist is only specific to the gcm (eg. cesm)
        load(file.path("Data/out",cmipfldr,"BC_ACLIMregion", paste0("ACLIMregion_",gcmcmip,"_",scen,"_BC_fut.Rdata")))
        
        # grab the mean strata x weekly values for bias correcting the grid
        sub_BC <- fut%>%
          dplyr::select(sim, var,  season,mo,wk,lognorm, basin, strata, mnVal_hind,mnVal_hist,sf_wk)%>%
          dplyr::distinct(sim, var, season,mo,wk,lognorm, basin, strata, mnVal_hind,mnVal_hist,sf_wk, .keep_all= TRUE)%>%
          mutate(GCM = GCM, CMIP=CMIP, mod = mod,scen =scen)%>%ungroup()
        #dplyr::summarize_at(c("mnVal_hind", "mnVal_hist","sf_wk"), mean, na.rm=T)
        if(i ==1){
          mnVal_lookup <- sub_BC
        }else{
          mnVal_lookup <- rbind(mnVal_lookup,sub_BC)
        }
        rm(list=c("sub_BC","fut"))
      }
    }
    
    # check that there are 3 gcms:
    mnVal_lookup%>%filter(strata == 70,var=="aice", wk==1)
    
    
    # save the lookup table:
    if(!dir.exists(file.path("Data/out",cmipfldr,"bc_mnVals")))
      dir.create(file.path("Data/out",cmipfldr,"bc_mnVals"))
    
    fl <- file.path("Data/out",cmipfldr,"bc_mnVals")
    nm <- paste(cmipfldr,"_BC_mnVal_lookup.Rdata",sep="_")
    save(mnVal_lookup,file=file.path(fl,nm))


# ---------------------------------------------------
# PART 2 : bias correct with mnVal_lookup
# ---------------------------------------------------
#Now with the lookup tables generated, combine with the cell by cell data and bias correct:
    
    #  setwd("D:/GitHub_cloud/ACLIM2")
    # loads packages, data, setup, etc.
    suppressMessages( suppressWarnings(source("R/make.R")))
    
    tmpDfl <- "D:/GitHub_cloud/ACLIM2/Data/out/K20P19_CMIP6/BC_ACLIMregion"
    load(file.path(tmpDfl,"ACLIMregion_B10K-K20P19_CORECFS_BC_mn_hind.Rdata"))
    
    load(file.path(tmpDfl,"ACLIMregion_B10K-K20P19_CMIP6_gfdl_BC_mn_hist.Rdata"))
    mnVal_lookup <- mn_hist%>%mutate(sim ="B10K-K20P19_CMIP6_gfdl")
    
         load(file.path(tmpDfl,"ACLIMregion_B10K-K20P19_CMIP6_cesm_BC_mn_hist.Rdata"))
         mnVal_lookup <- rbind(mnVal_lookup,mn_hist%>%mutate(sim ="B10K-K20P19_CMIP6_cesm"))
                   load(file.path(tmpDfl,"ACLIMregion_B10K-K20P19_CMIP6_miroc_BC_mn_hist.Rdata"))
                   mnVal_lookup <- rbind(mnVal_lookup,mn_hist%>%mutate(sim ="B10K-K20P19_CMIP6_miroc"))
                   
                   mnVal_lookup <- mnVal_lookup%>%left_join(mn_hind%>%select(-"sim_type"))
    
    # # load the strata x weekly bias corrected values ("fut") for each gcm in the cmip6
    # cmipfldr <- "K20P19_CMIP6"
    # fl <- file.path("Data/out",cmipfldr,"bc_mnVals")
    # nm <- paste(cmipfldr,"_BC_mnVal_lookup.Rdata",sep="_")
    # load(file.path(fl,nm))  # load mnVal_lookup
    # 
    # some dummy data
    liz_dat <- data.frame(var ="aice",
                          mn_val = inv.logit(rnorm(200,0, .4)),
                          strata = factor(70,levels = levels(mnVal_lookup$strata)),
                          cell = 1:200,
                          time = as.Date("1982-04-23"))
    
    
    liz_dat <- liz_dat%>%
      dplyr::mutate(tmptt =strptime(as.Date(time),format="%Y-%m-%d"))%>%
      dplyr::mutate(
        yr     = date_fun(tmptt,type="yr"), # first get week to match lookup
        mo     = date_fun(tmptt,type="mo"),
        jday   = date_fun(tmptt,type="jday"),
        season = date_fun(tmptt,type="season"),
        wk     = date_fun(tmptt,type="wk"))%>%select(-"tmptt")%>%
      left_join(mnVal_lookup)  # now merge with lookup:
    
    # Now bias correct based on which normlist val to use:
    log_adj <- 1e-4
    roundn  <- 5
    if(!any(liz_dat$lognorm%in%c("none","log","logit"))){
      stop("bias_correct_new_strata: problem with lognorm, must be 'none', 'log' or 'logit' for each var")
    }else{
      sdfun<-function(x){
        x[x==0]   <- 1
        x[x==Inf] <- 1
        x  
      }
      
      # normally distrib values:
      # subA <- liz_dat%>%filter(lognorm=="none")%>%
      subA <- liz_dat%>%
        mutate(
          raw_val   = mn_val,
          mnval_adj = mn_val,
          sf_wk  = abs(  sdVal_hind/  sdVal_hist),
          sf_mo  = abs(  sdVal_hind_mo/  sdVal_hist_mo),
          sf_yr  = abs(  sdVal_hind_yr/  sdVal_hist_yr))%>%
          mutate_at(c("sf_wk","sf_mo","sf_yr"),sdfun)%>%
          mutate(
          val_delta =   mnVal_hind + (( mn_val-  mnVal_hist)),
          # val_bcmo  =   mnVal_hind + ( sf_mo*( mn_val- mnVal_hist)),
          # val_bcyr  =   mnVal_hind + ( sf_yr*( mn_val- mnVal_hist)),
          val_bcwk  =   mnVal_hind + ( sf_wk*( mn_val- mnVal_hist)))
      
      # # 0-1 distributed values:
      # subB<- liz_dat%>%filter(lognorm=="logit")%>%
      #   mutate(
      #     raw_val   = mn_val,
      #     mnval_adj = inv.logit(mn_val)-log_adj,
      #     #   sf_wk  = abs(  sdVal_hind/  sdVal_hist),
      #     #   sf_mo  = abs(  sdVal_hind_mo/  sdVal_hist_mo),
      #     #   sf_yr  = abs(  sdVal_hind_yr/  sdVal_hist_yr))%>%
      #     # mutate_at(c("sf_wk","sf_mo","sf_yr"),sdfun)%>%
      #     # mutate(
      #     val_delta =   round(inv.logit(mnVal_hind + (( mn_val-  mnVal_hist)))-log_adj,roundn),
      #     # val_bcmo  =   round(inv.logit(mnVal_hind + ( sf_mo*( mn_val- mnVal_hist)))-log_adj,roundn),
      #     # val_bcyr  =   round(inv.logit(mnVal_hind + ( sf_yr*( mn_val- mnVal_hist)))-log_adj,roundn),
      #     val_bcwk  =   round(inv.logit(mnVal_hind + ( sf_wk*( mn_val- mnVal_hist)))-log_adj,roundn))%>%
      #   mutate_at(c("val_delta","val_bcwk"),function(x){x[x<0]<-0;  x  })
      # #mutate_at(c("val_delta","val_bcwk","val_bcmo","val_bcyr"),function(x){x[x<0]<-0;  x  })
      # 
      # # log norm dist. values
      # subC<- liz_dat%>%filter(lognorm=="log")%>%
      #   mutate(
      #     raw_val   = mn_val,
      #     mnval_adj = exp(mn_val)-log_adj, # fixed what had been log(mn_val) -log_adj
      #     # sf_wk  = abs(  sdVal_hind/  sdVal_hist),
      #     #   sf_mo  = abs(  sdVal_hind_mo/  sdVal_hist_mo),
      #     #   sf_yr  = abs(  sdVal_hind_yr/  sdVal_hist_yr))%>%
      #     # mutate_at(c("sf_wk","sf_mo","sf_yr"),sdfun)%>%
      #     # mutate(
      #     val_delta =   round(exp(mnVal_hind + (( mn_val-  mnVal_hist)))-log_adj,roundn),
      #     # val_bcmo  =   round(exp(mnVal_hind + ( sf_mo*( mn_val- mnVal_hist)))-log_adj,roundn),
      #     # val_bcyr  =   round(exp(mnVal_hind + ( sf_yr*( mn_val- mnVal_hist)))-log_adj,roundn),
      #     val_bcwk  =   round(exp(mnVal_hind + ( sf_wk*( mn_val- mnVal_hist)))-log_adj,roundn))%>%
      #   mutate_at(c("val_delta","val_bcwk"),function(x){x[x<0]<-0;  x  })
      # # mutate_at(c("val_delta","val_bcwk","val_bcmo","val_bcyr"),function(x){x[x<0]<-0;  x  })
      # 
    }
    # futout <- rbind(subA, subB, subC)%>%
    futout <- subA%>%
      rename(
        # val_biascorrectedmo = val_bcmo,
        # val_biascorrectedyr = val_bcyr,
        val_biascorrectedwk = val_bcwk)%>%
      mutate(val_biascorrected = val_biascorrectedwk,
             mn_val=round(mnval_adj,roundn))%>%select(-mnval_adj)
    rm(list=c("subA","subB","subC"))
