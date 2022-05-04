#'
#'
#'
#'save_indices.R
#'

save_indices <- function(
  flIN,
  subfl = "watercolumn_mean",
  post_txt = "_mn",
  CMIP_fdlr = "TEST",
  outlist = c("ACLIM_annual_hind",
             "ACLIM_seasonal_hind",
             "ACLIM_monthly_hind",
             "ACLIM_weekly_hind",
             "ACLIM_surveyrep_hind",
             
             "ACLIM_annual_hist",
             "ACLIM_seasonal_hist",
             "ACLIM_monthly_hist",
             "ACLIM_weekly_hist",
             "ACLIM_surveyrep_hist",
             
             "ACLIM_annual_fut",
             "ACLIM_seasonal_fut",
             "ACLIM_monthly_fut",
             "ACLIM_weekly_fut",
             "ACLIM_surveyrep_fut")  ){

  cat("-- Files will be saved in",paste0("Data/out/",CMIP_fdlr,"/",subfl)," ....\n")
    # make root folders"
    if(!dir.exists("Data/out")) dir.create("Data/out")
    if(!dir.exists( paste0("Data/out") )) dir.create(paste0("Data/out"))
    fl_out <- paste0("Data/out")
    
    if(!dir.exists(file.path(fl_out,CMIP_fdlr))){
      dir.create(file.path(fl_out,CMIP_fdlr))
    }else{
      dir.remove(file.path(fl_out,CMIP_fdlr))
      dir.create(file.path(fl_out,CMIP_fdlr))
    }
  
    if(!dir.exists(file.path(fl_out,CMIP_fdlr,subfl))) 
      dir.create(file.path(fl_out,CMIP_fdlr,subfl))
    
      for(outfl in outlist){
        
        eval(parse(text = paste0(outfl,"<-flIN$",outfl)))
        tmpfl <- file.path(fl_out,CMIP_fdlr,subfl,paste0(outfl,post_txt,".Rdata"))
        
        if(file.exists(tmpfl)) file.remove(tmpfl)    
        eval(parse(text = paste0("save(",outfl,", file='",tmpfl,"')")))
        
        rm(tmpfl)
        eval(parse(text = paste0("rm(",outfl,")")))
      }
    cat("-- Indices saved \n")
}

