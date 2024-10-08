#'
#'
#'make_CEATTLE_dat_files.R
#'
#'first run "R/sub_scripts/make_ceattle_indices.R"
#' 

# "Data/out/CEATTLE_indices/ceattle_vars_wide_op.Rdata"

  # Load setup
  #--------------------------------------
  suppressMessages(source("R/make.R"))
  
  # load the datafile:
  load(file="Data/out/CEATTLE_indices/ceattle_vars_op.Rdata")
  load(file="Data/out/CEATTLE_indices/ceattle_vars_wide_op.Rdata")
  
  # switches 
  varall  <- varlist <- unique(ceattle_vars_op$var)
  shortlist <- c("Summer_temp_bottom5m","Winter_temp_bottom5m",
                 "Winter_pH_depthavg","Summer_oxygen_bottom5m",
                 "Summer_temp_surface5m",
                 "Spring_Cop_integrated",
                 "Fall_largeZoop_integrated")
  thisYr  <- as.numeric(format(Sys.time(), "%Y"))
  today   <- format(Sys.time(), "%b %d, %Y")
  lastyr_hind <- thisYr #as.numeric(thisYr)  #2021
  hind_yrs    <- 1979:(lastyr_hind)   # define the years of your estimation model (noting that recruitment covars are for cohort year)
  fut_yrs     <- (lastyr_hind+1):2099   # define the years of your projections
  stitchDate     <- "2019-12-30"  # last date of the ACLIM hindcast
  stitchDate_op  <- "2022-05-16"  #last operational hindcast date
  log_adj      <- 1e-4
  zscore_years <- 1980:2010  # years to recenter z score on
  plotbasin    <- "SEBS"  
  
  # Define the name for the .dat file
  fn      <- paste0("ACLIM2_CMIP6_short_delta_bc",thisYr,".dat")
  fn_long <- paste0("ACLIM2_CMIP6_delta_bc",thisYr,".dat")
  
  archive_old <- T  # Archive the older version of the .dat file?
  normlist    <- read.csv(file=file.path(Rdata_path,"../normlist.csv"))
  
  CMIPS <- c("K20P19_CMIP6","K20P19_CMIP5")
  
  # create outpath folder
  outpath     <- "Data/out/ADMB_datfiles"
  if(!dir.exists(outpath)) dir.create(outpath)
  
  # define hind and fut data files
  fndat_hind  <- file.path(outpath,paste("KKHhind_",fn,sep=""))
  fndat_fut   <- file.path(outpath,paste("KKHfut_",fn,sep=""))

  fndat_hind_long  <- file.path(outpath,paste("KKHhind_",fn_long,sep=""))
  fndat_fut_long   <- file.path(outpath,paste("KKHfut_",fn_long,sep=""))
  
  fndat_hind2 <- file.path(outpath,paste("hind_",fn,sep=""))
  fndat_fut2  <- file.path(outpath,paste("fut_",fn,sep=""))

  # create and archive .dat files
  outfile    <- fndat_fut
  if(file.exists(outfile)&archive_old){	
    # archive older version
    archivefl <- paste0(substr(outfile,start=1,stop=nchar(outfile)-4),
                        format(Sys.time(), "%Y%m%d_%H%M%S"),".dat")
    file.rename(outfile, archivefl)
    #file.remove(outfile)
  }
  
  file.create(outfile)
  outfile  <- fndat_hind
  if(file.exists(outfile)&archive_old){	
    # archive older version
    archivefl <- paste0(substr(outfile,start=1,stop=nchar(outfile)-4),
                        format(Sys.time(), "%Y%m%d_%H%M%S"),".dat")
    file.rename(outfile, archivefl)
    #file.remove(outfile)
  }
  file.create(outfile)

  # ----------------------------------------------
  # CREATE INDICES
  # ----------------------------------------------
  # 2 -- rescale (Z-score) data and get variables
  
  # preview possible variables
  varall
  
  grpby2 <- c("type","var","basin",
            "year","sim","sim_type",
            "bc")

  #define hind and fut:
  hind <- ceattle_vars_op%>%filter(year%in%hind_yrs,sim_type=="hind")%>%
    ungroup()

  mnhind <- hind%>%
    group_by(season,var,basin)%>%
    summarize(mnhind = mean(val_use,na.rm=T),
              sdhind = sd(val_use, na.rm=T))%>%ungroup()
  hind <- hind%>%left_join(mnhind)%>%
    mutate(val_use_scaled = (val_use-mnhind)/sdhind,
           zscoreyrs = paste0(  zscore_years[1],":", rev(zscore_years)[1]))%>%
    select(all_of(c(grpby2,"val_use","val_use_scaled")))%>%distinct()%>%
    ungroup()
  
  hind <- hind%>%full_join(expand.grid(year= hind_yrs, var = unique(hind$var))) %>%ungroup()

  fut  <- ceattle_vars_op%>%
    filter(year%in%fut_yrs)%>%ungroup()

  #temporary fix: Add Large Zoop for CESM RCP85
  tmp_fut <- fut%>%filter(GCM_scen=="cesm_rcp85")
  grplist <- c("NCaS_integrated","EupS_integrated")
  
  if(length(grep("largeZoop_integrated",unique(tmp_fut$var_raw)) )==0){
    tmp_futA <- tmp_fut[grep(grplist[1],tmp_fut$var),]
    tmp_futB <- tmp_fut[grep(grplist[2],tmp_fut$var),]
    tmp_futA$var2 <- grplist[1] 
    tmp_futB$var2 <- grplist[2] 
    sumat<-c("val_use","mnVal_hind","val_delta","val_biascorrected",
             "val_raw","mn_val")
    tmp_var_zoop    <- rbind(tmp_futA,tmp_futB)%>%
      dplyr::filter(var2%in%c("NCaS_integrated","EupS_integrated"))%>%
      dplyr::group_by(
        var,
        season,
        type,
        basin,
        year,
        sim,
        gcmcmip,
        GCM,
        scen,
        sim_type,
        bc,
        GCM_scen,
        GCM_scen_sim, 
        CMIP,
        GCM2,
        GCM2_scen_sim,
        jday,mnDate,var_raw,lognorm,var2)%>%
      summarise_at(all_of(sumat),mean,na.rm=T)%>%
      mutate(var_raw="largeZoop_integrated",
             var = paste0(season,"_largeZoop_integrated"))%>%select(-var2)%>%
      summarise_at(all_of(sumat),sum,na.rm=T)%>%relocate(names(fut))%>%
      distinct()
    
    fut <- rbind(fut%>%ungroup(), tmp_var_zoop%>%ungroup())
    
  }
  fut  <- fut%>%left_join(mnhind)%>%
    mutate(val_use_scaled = (val_use-mnhind)/sdhind,
           zscoreyrs = paste0(  zscore_years[1],":", rev(zscore_years)[1]))%>%ungroup()

  data.frame(fut%>%filter(var=="Winter_largeZoop_integrated",GCM_scen=="cesm_rcp85"))
  data.frame(fut%>%ungroup()%>%group_by(GCM_scen)%>%summarise(count = length(var)))

  fut <- fut%>%full_join(expand.grid(year= fut_yrs,
                                     var = unique(fut$var),
                                     GCM_scen = unique(fut$GCM_scen)))
  data.frame(fut%>%ungroup()%>%group_by(GCM_scen)%>%summarise(count = length(var)))
  data.frame(fut%>%filter(var=="Winter_largeZoop_integrated",GCM_scen=="cesm_rcp85"))

  # now identify which covars are highly correlated
  
  d_wide   <- ceattle_vars_op%>%
    filter(year<=lastyr_hind)%>%
    left_join(mnhind)%>%
    mutate(val_use_scaled = (val_use-mnhind)/sdhind)%>%ungroup()%>%
    group_by(across(all_of(grpby2)))%>%
    summarize_at(all_of(c("val_use_scaled")), mean, na.rm=T)%>%
    tidyr::pivot_wider(names_from = "var", values_from = "val_use_scaled")

  # calculate correlations and display in column format
  
  # define columns with meta data:
  col_meta   <- which(colnames(d_wide)%in%grpby2)
  d_wide_dat <-d_wide[,-col_meta]
  num_col  <- ncol(d_wide[,-col_meta])
  out_indx <- which(upper.tri(diag(num_col))) 
  cor_cols <- d_wide_dat%>%
    do(melt(cor(.,
                method="spearman", 
                use="pairwise.complete.obs"),
            value.name="cor")[out_indx,])

  corr     <- cor(na.omit(d_wide_dat))
  
  long_dat <- reshape2::melt(corr,variable.name = "variable") %>% 
    as.data.frame() 

  # plot co variation between variables
  corplot <- long_dat %>%arrange(value)%>%
    ggplot(aes(x=Var1, y=Var2, fill=value)) + 
    geom_raster() + 
    scale_fill_viridis_c()+
    theme_minimal()+
    theme(axis.text.x = element_text(angle = 90))
  
  jpeg(filename = file.path("Data/out/CEATTLE_indices/CEATTLE_indicescorplot.jpg"),
       width=8,height=7,units="in",res=350)
  print(corplot)
  dev.off()

  # # remove those where cov is high (temp by season and cold pool by season)
  # subset <- long_dat$>$filter(abs(value)<0.6)
  
  # 3 -- write data to hind .dat file
  # ------------------------------------


  # CEATTLE uses a spp overlap index - you can skip this
  
  overlapdat <- data.frame(
    atf_OL=c(0.9391937,0.8167094,0.808367,0.5926875,0.7804481,0.5559549,
             0.4006931,0.5881404,0.7856776,0.511565,0.6352048,0.5583476,
             0.5792738,0.5417657,0.8212887,0.6287613,0.4536608,0.6587292,
             0.4884194,0.8289379,0.4399257,0.5950167,0.6388434,0.6111834,
             0.8742649,0.7868746,0.8024257,0.6227457,0.4956742,0.4347917,
             0.4791108,0.4369006,0.5613625,0.4353015),
    south_OL=c(0.9980249,0.9390368,0.9959974,0.6130846,0.951234,0.5851891,
               0.4934879,0.641471,0.9809618,0.5596813,0.7196964,0.6754698,
               0.5774808,0.6041351,0.9406521,0.7949525,0.5306435,0.7977694,
               0.5345031,0.9879945,0.5079171,0.7148121,0.8997132,0.7340859,
               0.9962068,0.9627235,0.998043,0.8111,0.6087638,0.513057,0.5492621,
               0.4971361,0.665453,0.5969653)
  )
  

  includeOverlap <- F
  overlap        <- matrix(1,3,length(sort(unique(hind$year))))
  overlap_fut    <- array(1,c(3,length(unique(fut$GCM_scen))+1,length(sort(unique(fut$year)))))
  if(includeOverlap){
    overlap[3,] <- overlapIN
    overlap[3,][overlap[3,]>1]<-1 #covs$BT2to6/covs$BT0to6
  }

  # replace NA values with the mean 
  hind_short <- hind%>%mutate(long_name=var)%>%
    filter(var%in%shortlist)

  cat("making short hind and future dat files\n")

  
  # Kir's .dat file
  makeDat_hind(datIN   = hind_short, 
               outfile = fndat_hind,
               value2use = "val_use",
               value2use_scaled = "val_use_scaled",
               NAVal     = "mean",  
               nsppIN    = 3,
               overlapIN = overlap, 
               nonScaled_covlist = c("Summer_temp_bottom5m","Summer_temp_surface5m"),
               Scaled_covlist    = unique(hind_short$var))
  
  makeDat_fut( datIN             = fut%>%mutate(long_name=var)%>%
                 filter(var%in%shortlist), 
               hinddatIN         = hind%>%mutate(long_name=var)%>%
                 filter(var%in%shortlist),
               outfile           = fndat_fut,
               value2use         = "val_use",
               value2use_scaled  = "val_use_scaled",
               NAVal             = "mean", 
               nsppIN            = 3,
               last_nyrs_avg     = 10, 
               overlapIN         = overlap_fut,  #(nspp,nsim+1,nyrs_fut) 
               overlap_hind      = overlap,
               nonScaled_covlist = c("Summer_temp_bottom5m","Summer_temp_surface5m"),
               Scaled_covlist    = unique(hind_short$var))
  
  # Kir's .dat file
  cat("making long hind and future dat files\n")
  
  makeDat_hind(datIN   = hind%>%mutate(long_name=var), 
               outfile = fndat_hind_long,
               value2use = "val_use",
               value2use_scaled = "val_use_scaled",
               NAVal     = "mean",  
               nsppIN    = 3,
               overlapIN = overlap, 
               nonScaled_covlist = c("Summer_temp_bottom5m","Summer_temp_surface5m"),
               Scaled_covlist    = unique(hind$var))
  
  makeDat_fut( datIN             = fut%>%mutate(long_name=var), 
               hinddatIN         = hind%>%mutate(long_name=var),
               outfile           = fndat_fut_long,
               value2use         = "val_use",
               value2use_scaled  = "val_use_scaled",
               NAVal             = "mean", 
               nsppIN            = 3,
               last_nyrs_avg     = 10, 
               overlapIN         = overlap_fut,  #(nspp,nsim+1,nyrs_fut) 
               overlap_hind      = overlap,
               nonScaled_covlist = c("Summer_temp_bottom5m","Summer_temp_surface5m"),
               Scaled_covlist    = unique(hind$var))
  
  message(paste0("dat files successfully created (e.g., ",fndat_fut_long,")"))
