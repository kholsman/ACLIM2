#'
#'
#'
#' makeDat_fut.R
#' 

makeDat_fut <- function( datIN      = fut, 
                         hinddatIN  = hind, 
                         NAVal     = "mean", 
                         value2use = "val_use",
                         value2use_scaled = "val_use_scaled",
                         last_nyrs_avg   = 5, 
                         makeADMB_chunk = T,
                         outfile,
                         nonScaled_covlist = c("temp_bottom5m","temp_surface5m"  ),
                         Scaled_covlist    = covars,
                         nsppIN    = NULL,
                         overlapIN = NULL,
                         overlap_hind= NULL){
  
  if(is.null(NAVal)){
    myfun <- function(x){
      return(x)
  }}
  
  if(NAVal == "mean"){
    myfun <- function(x){
      x2 <- rev(x[1:last_nyrs_avg])
      if(any(is.na(x))) 
        x[is.na(x)] <- mean(x2, na.rm=T) 
      return(x)
  }}
  
  if(NAVal == "last"){
    myfun <- function(x){
      if(any(is.na(x))) 
        x[is.na(x)] <- rev(x[!is.na(x)])[1]
      return(x)
  }}
  if(NAVal == "5Yrmean"){
    myfun <- function(x){
      if(any(is.na(x))) 
        x[is.na(x)] <- mean(rev(x[!is.na(x)])[1:5])
      return(x)
  }}
  
  eval(parse(text = paste0("datIN     <- datIN%>%dplyr::rename(VAL = ",value2use,")") ))
  eval(parse(text = paste0("datIN     <- datIN%>%dplyr::rename(covuse = ",value2use_scaled,")")))
  eval(parse(text = paste0("hinddatIN <- hinddatIN%>%dplyr::rename(VAL = ",value2use,")") ))
  eval(parse(text = paste0("hinddatIN <- hinddatIN%>%dplyr::rename(covuse = ",value2use_scaled,")")))
  
  ncov_fut      <- length(Scaled_covlist)
  ncov_fut_nonS <- length(nonScaled_covlist)
  longnm     <- gsub("\n             "," ",datIN$long_name[match(Scaled_covlist,datIN$var)])
  longnm_nonS<- gsub("\n             "," ",datIN$long_name[match(nonScaled_covlist,datIN$var)])
  fut_yrs    <- sort(unique(datIN$year))
  nfut_yrs   <- length(fut_yrs)
  GCM_sims   <- (unique(datIN$GCM_scen))
  num_runs   <- length(GCM_sims)
  
  cat("#Covars (covariate phase for each covs - do not alter this line)",file=outfile,append=FALSE,sep="\n")
  cat(paste("#",Scaled_covlist),file=outfile,append=TRUE,sep=" ")
  cat("",file=outfile,append=TRUE,sep="\n")
  cat("#Models (do not alter this line) ",file=outfile,append=TRUE,sep="\n")
  cat(paste("# ",c("mnhind",GCM_sims)),file=outfile,append=TRUE,sep=" ")
  cat("",file=outfile,append=TRUE,sep="\n")
  cat("#nEatcovs_fut",file=outfile,append=TRUE,sep="\n")
  cat(1,file=outfile,append=TRUE,sep="\n")
  
  cat("#Eat_covs_fut (1, nEatcovs_fut)",file=outfile,append=TRUE,sep="\n")
  cat(3,file=outfile,append=TRUE,sep="\n")
  
  cat("#num_runs : number of future temperature simulations + mnhind ",file=outfile,append=TRUE,sep="\n")
  cat(num_runs+1,file=outfile,append=TRUE,sep="\n")
 
   cat("#nyrs_fut : number years for the projection data",file=outfile,append=TRUE,sep="\n")
  cat(nfut_yrs,file=outfile,append=TRUE,sep=" ");cat("",file=outfile,append=TRUE,sep="\n")
  
  cat("#fut_yrs : projection years for covariates vector(1,nyrs_fut)",file=outfile,append=TRUE,sep="\n")
  cat(fut_yrs,file=outfile,append=TRUE,sep=" ")
  cat("",file=outfile,append=TRUE,sep="\n")
  
  cat("#ncov_fut : number of covariates ",file=outfile,append=TRUE,sep="\n")
  cat(ncov_fut,file=outfile,append=TRUE,sep=" ");cat("",file=outfile,append=TRUE,sep="\n")
 
  
  cat("###########################################################",file=outfile,append=TRUE,sep="\n")
  cat("#  | mn_Hind",file=outfile,append=TRUE,sep="\n")
  for(m in 1:num_runs)
    eval(parse(text=paste("cat('#  | ",GCM_sims[m],"',file=outfile,append=TRUE,sep='\n')",sep="")))
  cat("###########################################################",file=outfile,append=TRUE,sep="\n")
  for(c in 1:ncov_fut){
    lgnm <- (datIN%>%
               dplyr::filter(var==Scaled_covlist[c])%>%
               select(long_name))[[1]][1]
    lgnm <- gsub("  "," ",gsub("\n"," ",lgnm))
    cat(paste("# ",Scaled_covlist[c],":",lgnm),file=outfile,append=TRUE,sep="\n")
    
    dd <- (hinddatIN%>%
             dplyr::filter(var==Scaled_covlist[c])%>%
             dplyr::select(covuse))[[1]]
    
    cat(rep(mean(dd[1:last_nyrs_avg], na.rm=T),nfut_yrs),file=outfile,append=TRUE,sep=" ")
    rm(dd)
    cat("",file=outfile,append=TRUE,sep="\n")
    for(s in 1:num_runs){
      dd <- (datIN%>%
               dplyr::filter(var==Scaled_covlist[c]&GCM_scen==GCM_sims[s])%>%
               dplyr::mutate(covuse = myfun(covuse))%>%
               dplyr::select(covuse))[[1]]
      cat(dd,
          file=outfile,append=TRUE,sep=" ")
      cat("",file=outfile,append=TRUE,sep="\n")
      rm(dd)
    }
  }
  cat("#nonScaled_covlist ##########################################################",file=outfile,append=TRUE,sep="\n")
  for(c in 1:ncov_fut_nonS){
    cat(paste("# ",nonScaled_covlist[c],":",(datIN%>%
                                               dplyr::filter(var==nonScaled_covlist[c])%>%
                                               select(long_name))[[1]][1]),file=outfile,append=TRUE,sep="\n")
   
    dd <- (hinddatIN%>%
             dplyr::filter(var==nonScaled_covlist[c])%>%
             dplyr::select(VAL))[[1]]
     cat(rep(mean(dd[1:last_nyrs_avg],na.rm=T),nfut_yrs),file=outfile,append=TRUE,sep=" ")
     rm(dd)
    cat("",file=outfile,append=TRUE,sep="\n")
    for(s in 1:num_runs){
      dd <- (datIN%>%
               dplyr::filter(var==nonScaled_covlist[c]&GCM_scen==GCM_sims[s])%>%
               dplyr::mutate(VAL = myfun(VAL))%>%
               dplyr::select(VAL))[[1]]
      cat(dd,
          file=outfile,append=TRUE,sep=" ")
      cat("",file=outfile,append=TRUE,sep="\n")
      rm(dd)
    }
  }
  if(!is.null(overlapIN)){
    for(predd in 1:nsppIN){
      for(preyy in 1:nsppIN){
        if(preyy==1){
          cat(paste("# predator ",predd,"; prey ",preyy),file=outfile,append=TRUE,sep="\n")
          cat(rep(mean(rev(overlap_hind[predd,])[1:last_nyrs_avg]),nfut_yrs),file=outfile,append=TRUE,sep=" ")
          cat("",file=outfile,append=TRUE,sep="\n")
          for(s in 1:num_runs){
            cat(overlapIN[predd,s,],file=outfile,append=TRUE,sep=" ")
            cat("",file=outfile,append=TRUE,sep="\n")
            
          }		
          
          cat("###########################################################",file=outfile,append=TRUE,sep="\n")
        }else{
          cat(paste("# predator ",predd,"; prey ",preyy),file=outfile,append=TRUE,sep="\n")
          cat(rep(1,nfut_yrs),file=outfile,append=TRUE,sep=" ")
          cat("",file=outfile,append=TRUE,sep="\n")
          for(s in 1:num_runs){
            cat(1+0*overlapIN[predd,s,],file=outfile,append=TRUE,sep=" ")
            cat("",file=outfile,append=TRUE,sep="\n")
           
          }
          cat("###########################################################",file=outfile,append=TRUE,sep="\n")
        }
      }
    }
  }
  
  cat("#testfile  ",file=outfile,append=TRUE,sep="\n")
  cat(12345,file=outfile,append=TRUE,sep="\n")
  
  if(makeADMB_chunk){
    flnm <- paste0(substr(outfile,1,nchar(outfile)-4),"_ADMB_chunk.txt")
    if(!file.exists(flnm)) 	file.create(flnm)
    cat("GLOBALS_SECTION",file=flnm,append=FALSE,sep="\n")
    cat(" adstring futfile_name;",file=flnm,append=TRUE,sep="\n")
    cat("",file=flnm,append=TRUE,sep="\n")
    cat("",file=flnm,append=TRUE,sep="\n")
    cat(" LOCAL_CALCS",file=flnm,append=TRUE,sep="\n")
    cat(paste0("  futfile_name      = adstring(","\"",outfile,"\"",");"),file=flnm,append=TRUE,sep="\n")
    cat("  dump_rep = 1;",file=flnm,append=TRUE,sep="\n")
    #cat(paste0("futfile_name        = adstring('",outfile,"');"),append=TRUE,sep="\n")
    cat(" END_CALCS",file=flnm,append=TRUE,sep="\n")
    cat("",file=flnm,append=TRUE,sep="\n")
    cat("",file=flnm,append=TRUE,sep="\n")
    cat("// -------------------------------------------------------------------------",file=flnm,append=TRUE,sep="\n") 
    cat("// -------------------------------------------------------------------------",file=flnm,append=TRUE,sep="\n") 
    cat(paste0("// Read in projection data file e.g., ",outfile),file=flnm,append=TRUE,sep="\n") 
    cat("// -------------------------------------------------------------------------",file=flnm,append=TRUE,sep="\n")  
    cat("// -------------------------------------------------------------------------",file=flnm,append=TRUE,sep="\n")    
    cat("   !!                if(dump_rep) cout << ","\"Projection data read in begins:   \"<<futfile_name<< endl;",file=flnm,append=TRUE,sep="")
    cat("",file=flnm,append=TRUE,sep="\n")
    cat("   !!                ad_comm::change_datafile_name(futfile_name);",file=flnm,append=TRUE,sep="\n")   
    cat("//   init_int          nEatcovs_fut                                    // number of covariates for the food limitation configuration of RS (demand-zoop*Eatcov)",file=flnm,append=TRUE,sep="\n") 
    cat("//   init_ivector      Eat_covs_fut(1,nEatcovs_fut)                    // index of covariates that should be used for the function",file=flnm,append=TRUE,sep="\n") 
    cat("   init_int          num_runs                                             // number of future temperature simulations",file=flnm,append=TRUE,sep="\n") 
    cat("   init_int          nyrs_fut                                          // (1, num_runs) number years for the projection data",file=flnm,append=TRUE,sep="\n") 
    cat("   init_vector       fut_yrs(1,nyrs_fut)                               // fut_years : matrix(num_runs,nyrs_fut) years for the projection data",file=flnm,append=TRUE,sep="\n") 
    cat("   init_int          ncov_fut                                          // number of RS covariates",file=flnm,append=TRUE,sep="\n") 
    cat("   3darray           rs_cov_fut(1,num_runs,1,ncov_fut,1,nyrs_fut)         // covariate values (may be scaled)",file=flnm,append=TRUE,sep="\n") 
    cat(" LOCAL_CALCS",file=flnm,append=TRUE,sep="\n") 
    cat("                     if(ncov_fut!=ncov){cout<<","\"ERROR ncov and ncov_fut do not match!!! \"<<endl;exit(1);}",file=flnm,append=TRUE,sep="")
    cat("",file=flnm,append=TRUE,sep="\n")
    cat("     //                   for (int c=1;c<=nEatcovs_fut;c++){",file=flnm,append=TRUE,sep="\n")   
    cat("      //                       if(Eat_covs_fut(c)!=Eat_covs(c))",file=flnm,append=TRUE,sep="\n") 
    cat("      //                       {",file=flnm,append=TRUE,sep="\n") 
    cat("      //                           cout<<","\"ERROR Eat_covs('<<c<<') and Eat_covs_fut do not match!!!\"<<endl;",file=flnm,append=TRUE,sep="")
    cat("",file=flnm,append=TRUE,sep="\n")
    cat("      //                           exit(1);",file=flnm,append=TRUE,sep="\n") 
    cat("      //                       }",file=flnm,append=TRUE,sep="\n") 
    cat("      //                     }",file=flnm,append=TRUE,sep="\n") 
    cat("                     for (int c=1;c<=ncov_fut;c++)",file=flnm,append=TRUE,sep="\n")  
    cat("                       for (int cm=1;cm<=num_runs;cm++)",file=flnm,append=TRUE,sep="\n") 
    cat("                         for(int yr=1;yr<=nyrs_fut;yr++)",file=flnm,append=TRUE,sep="\n") 
    cat("                           *(ad_comm::global_datafile) >> rs_cov_fut(cm,c,yr);",file=flnm,append=TRUE,sep="\n")        
    cat(" END_CALCS   ",file=flnm,append=TRUE,sep="\n") 
    cat("   init_matrix       BTempC_fut_all(1,num_runs,1,nyrs_fut)              // Bottom temperature for each scenario (actual Temp for bioenergetics)",file=flnm,append=TRUE,sep="\n") 
    cat("   init_matrix       SSTempC_fut_all(1,num_runs,1,nyrs_fut)             // Sea surface temperature (actual temperature)",file=flnm,append=TRUE,sep="\n") 
    cat("   4darray           overlap_fut(1,num_runs,1,nspp,1,nspp,1,nyrs_fut);  // pred prey overlap (scenario,pred,prey, yr); pred overlap with prey species (2-6/0-6 area)",file=flnm,append=TRUE,sep="\n")   
    cat(" LOCAL_CALCS",file=flnm,append=TRUE,sep="\n") 
    cat("                     for (int pred=1;pred<=nspp;pred++) ",file=flnm,append=TRUE,sep="\n") 
    cat("                       for (int prey=1;prey<=nspp;prey++) ",file=flnm,append=TRUE,sep="\n") 
    cat("                        for (int cm=1;cm<=num_runs;cm++)",file=flnm,append=TRUE,sep="\n") 
    cat("                          for(int yr=1;yr<=nyrs_fut;yr++)",file=flnm,append=TRUE,sep="\n") 
    cat("                            *(ad_comm::global_datafile) >> overlap_fut(cm,pred,prey,yr);",file=flnm,append=TRUE,sep="\n")        
    cat(" END_CALCS ",file=flnm,append=TRUE,sep="\n") 
    cat("   init_int         test_num_projection",file=flnm,append=TRUE,sep="\n") 
    cat("   !!               if (test_num_projection != 12345) {cout<<","\"Read file error projection data\"<<endl<<test_num_projection<<endl;exit(1);}",file=flnm,append=TRUE,sep="")
    cat("",file=flnm,append=TRUE,sep="\n")
    
  }
}
