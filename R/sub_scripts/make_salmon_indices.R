#'
#'
#' make_salmon_indices.R
#' K. Holsman
#' 2024
#' generate indices for E. Yasumiishi
#' 
#' 

# 
# 1. temperature_surface5m for months 9:10 and strata 70 & 71  
# 2. NW ditrrection for months 5:6 and strata 71  
# 3. temperature_surface5m for months 7:10 and strata 90,61,62  

# load ACLIM packages and functions
rm(list=ls())
suppressMessages(source("R/make.R"))

cat("\n\nsetting things up\n")

# set up paths
outfldr <- "Data/out/salmon_indices"
if(!dir.exists(outfldr)) dir.create(outfldr)

strata_set  <- list(c(70,71),c(71),c(90,61,62))
mo_set      <- list(c(9,10),c(5,6),7:10)
var_set     <- list(c("temp_surface5m"),c("NEwinds"),"temp_surface5m")
names(var_set) <- c("fall_SST_70_71","Winds_71","7through10_SST_90_61_62")

NEWinds     <- c(0,1,0)

# PCOD_vars_wide_op$NE_winds <- 
#   getNE_winds(vNorth=PCOD_vars_wide_op$vNorth_surface5m,
#               uEast=PCOD_vars_wide_op$uEast_surface5m)

#varlist        <- c("pH_bottom5m","pH_depthavg","pH_integrated","pH_surface5m","temp_surface5m", "temp_bottom5m")
CMIPset        <- c("K20P19_CMIP6","K20P19_CMIP5")
stitchDate_op  <- "2021-12-30"  #last operational hindcast date

# preview possible variables
load(file = "Data/out/weekly_vars.Rdata")
load(file = "Data/out/srvy_vars.Rdata")
# save setup for plotting
save(list=ls(),file=file.path(outfldr,"salmon_indices_setup.Rdata"))


# ------------------------------------
# Hindcast First
# ------------------------------------
cat("running hindcast summary\n")

load("Data/out/K20P19_CMIP6/BC_ACLIMregion/ACLIMregion_B10K-K20P19_CORECFS_BC_hind.Rdata")
rm_cols <- c( "lognorm","type", "val_raw","mn_val" ,"sd_val", "n_val", 
              "sdVal_hind_mo", "sdVal_hind_yr")

select_list <- c("sim","year","var_salmon","basin","strata","strata_area_km2","units",
                  "season","mo","wk","jday","mnDate","qry_date","sim_type","mday",
                  "val_use","mnVal_hind","sdVal_hind","nVal_hind","seVal_hind","val_raw","var")

for(i in 1:length(strata_set)){
  
  if(var_set[[i]]=="NEwinds"){
    my_vars2       <- function(IN) select_list[select_list%in%names(IN)]
    valset <- c("val_use","mnVal_hind","sdVal_hind","nVal_hind", "seVal_hind","val_raw")
    
    hindDat_weekly_strata_tmp <- hind%>%
      filter(strata%in%strata_set[[i]],
             mo%in%mo_set[[i]],
             var%in%c("vNorth_surface5m","uEast_surface5m"))%>%
      mutate(val_use = val_raw, units = "meter second-1")%>%
      rowwise()%>%mutate(mday=strptime(mnDate,format = "%Y-%m-%d")$mday)%>%ungroup()%>%
      mutate(var_salmon = names(var_set)[i])
   
    # remove all the extra stuff:
    hindDat_weekly_strata_tmp <- hindDat_weekly_strata_tmp%>%select(my_vars2(hindDat_weekly_strata_tmp))
    
    hindDat_weekly_strata_tmp <-  hindDat_weekly_strata_tmp%>%
      pivot_wider(names_from = var,
                  values_from = all_of(valset))%>%
      ungroup()%>%data.frame()
    
    for(k in 1:length(valset)){
      
      eval(parse(text = paste0(" hindDat_weekly_strata_tmp <- hindDat_weekly_strata_tmp%>%
          rowwise()%>%mutate(",valset[k], "= getNE_winds
          (vNorth = ",valset[k],"_vNorth_surface5m,
            uEast = ",valset[k],"_uEast_surface5m))%>%
            select(-",valset[k],"_vNorth_surface5m,-",
                               valset[k],"_uEast_surface5m)%>%
            ungroup()%>%data.frame()") ))
    }
    hindDat_weekly_strata_tmp <-  hindDat_weekly_strata_tmp%>%mutate(var = "NEwinds")
    
    
  }else{
    my_vars <- function(IN) select_list[select_list%in%names(IN)]
    
    hindDat_weekly_strata_tmp <- hind%>%
      filter(strata%in%strata_set[[i]],
             mo%in%mo_set[[i]],
             var%in%var_set[[i]])%>%
      mutate(val_use = val_raw)%>%
      rowwise()%>%mutate(mday=strptime(mnDate,format = "%Y-%m-%d")$mday)%>%ungroup()%>%
      mutate(var_salmon = names(var_set)[i])
    
    # remove all the extra stuff:
    hindDat_weekly_strata_tmp <- hindDat_weekly_strata_tmp%>%select(my_vars(hindDat_weekly_strata_tmp))
    
    
  }
  
  grp_names <- names(hindDat_weekly_strata_tmp)
  nms3 <- grp_names[!grp_names%in%rm_cols]
  
  hindDat_weekly_strata_tmp <-hindDat_weekly_strata_tmp%>%
    select(!!!syms(nms3))%>%
    relocate(val_use, .before = mnVal_hind)%>%
    relocate(var_salmon, .before = var)%>%
    ungroup()%>%data.frame()
    
  grp_names <- names(hindDat_weekly_strata_tmp)[!names(hindDat_weekly_strata_tmp)%in%c("strata","strata_area_km2","wk","season","basin","mday")]
  nms  <- c("val_use","jday","mnDate",
            "mnVal_hind","sdVal_hind","nVal_hind",
            "seVal_hind")
  
  nms2 <- grp_names[!grp_names%in%nms]
  nms3 <- grp_names[!grp_names%in%rm_cols]
  
  hindDat_monthly_tmp <- hindDat_weekly_strata_tmp%>%
    select(!!!syms(grp_names))%>%group_by(!!!syms(nms2))%>%
    summarize_at(nms,mean,na.rm=T)%>%
    select(!!!syms(nms3))%>%
    relocate(val_use, .before = mnVal_hind)%>%
    relocate(var_salmon, .before = var)%>%
    ungroup()%>%data.frame()
  
  
  grp_names <- names(hindDat_weekly_strata_tmp)[!names(hindDat_weekly_strata_tmp)%in%c("strata","lognorm","type",
                                                                                       "strata_area_km2",
                                                                                       "mo","wk","season","basin","mday")]
  nms  <- c("val_use","jday","mnDate",
            "mnVal_hind","sdVal_hind","nVal_hind",
            "seVal_hind")
  
  nms2 <- grp_names[!grp_names%in%nms]
  nms3 <- grp_names[!grp_names%in%rm_cols]
  
  hindDat_avg_tmp <- hindDat_weekly_strata_tmp%>%
    select(!!!syms(grp_names))%>%group_by(!!!syms(nms2))%>%
    summarize_at(nms,mean,na.rm=T)%>%
    select(!!!syms(nms3))%>%
    relocate(val_use, .before = mnVal_hind)%>%
    relocate(var_salmon, .before = var)%>%
    ungroup()%>%data.frame()
  
  
  if(i==1){
    hindDat_avg     <- hindDat_avg_tmp 
    hindDat_monthly <- hindDat_monthly_tmp 
    hindDat_weekly_strata  <- hindDat_weekly_strata_tmp 
    
  }else{
    hindDat_avg     <- rbind(hindDat_avg,hindDat_avg_tmp)
    hindDat_monthly <- rbind(hindDat_monthly,hindDat_monthly_tmp)
    hindDat_weekly_strata  <- rbind(hindDat_weekly_strata,hindDat_weekly_strata_tmp)
  }
  rm(hindDat_avg_tmp)
  rm(hindDat_monthly_tmp)
  rm(hindDat_weekly_strata_tmp)
  
}


  
    # output the data as Rdata and CSV
    write_csv(hindDat_weekly_strata, file.path(outfldr,"salmon_hindDat_weekly_strata.csv"))
    save(hindDat_weekly_strata, file=file.path(outfldr,"salmon_hindDat_weekly_stratat.Rdata"))
    
    write_csv(hindDat_monthly, file.path(outfldr,"salmon_hindDat_monthly.csv"))
    save(hindDat_monthly, file=file.path(outfldr,"salmon_hindDat_monthly.Rdata"))

    write_csv(hindDat_avg, file.path(outfldr,"salmon_hindDat.csv"))
    save(hindDat_avg, file=file.path(outfldr,"salmon_hindDat.Rdata"))
    
 
  #rm(hindDat_weekly_strata)
  rm(hindDat_monthly)
  rm(hindDat_avg)
  

# ------------------------------------
# Projections Next
# ------------------------------------
select_list <- unique(c(names(hindDat_weekly_strata),"long_name","qry_date","station_id",
                        "sim_type","GCM","RCP","mod", "CMIP", "mnVal_hind","sdVal_hind","val_delta","val_raw"))
  my_vars <- function(IN) select_list[select_list%in%names(IN)]
  
  jj <- 0 

CMIP <- "CMIP6"
ii   <- 1
i    <- 1

for (CMIP in c("CMIP6","CMIP5")){
  
  if(CMIP == "CMIP6"){
    
    fl_base_srv <- "ACLIMsurveyrep_B10K-K20P19_CMIP6_"
    fl_path_srv <- "Data/out/K20P19_CMIP6/BC_ACLIMsurveyrep"
    
    fl_base_reg <- "ACLIMregion_B10K-K20P19_CMIP6_"
    fl_path_reg <- "Data/out/K20P19_CMIP6/BC_ACLIMregion"
    
    
    # CMIP6
    ssps <- c("ssp126","ssp585")
    gcms <- c("cesm","miroc","gfdl")
    set  <- expand.grid(gcms,ssps,stringsAsFactors = F)
    
  }
  
  if(CMIP == "CMIP5"){
    #now get monthly
    fl_base_srv <- "ACLIMsurveyrep_B10K-K20P19_CMIP5_"
    fl_path_srv <- "Data/out/K20P19_CMIP5/BC_ACLIMsurveyrep"
    
    fl_base_reg <- "ACLIMregion_B10K-K20P19_CMIP5_"
    fl_path_reg <- "Data/out/K20P19_CMIP5/BC_ACLIMregion"
    
    # now for CMIP5
    gcms <- c("CESM","MIROC","GFDL")
    ssps <- c("rcp45","rcp85")
    set  <- expand.grid(gcms,ssps,stringsAsFactors = F)
    
  }
  

 for(i in 1:dim(set)[1]){
   fl <- paste0(fl_base_reg,set[i,1],"_",set[i,2],"_BC_fut.Rdata")
   load(file.path(fl_path_reg,fl))
   
  for(ii in 1:length(strata_set)){
    cat(paste("running proj summary for",CMIP,": strata_set",names(var_set)[ii],set[i,1],set[i,2],"\n"))
      
      
      fut$mo   <- as.numeric(substr(fut$mnDate,6,7))
      fut$mday <- as.numeric(substr(fut$mnDate,9,10))
      
      if(var_set[[ii]]=="NEwinds"){
        
        valset <- c("val_use","mnVal_hind","sdVal_hind","val_raw","val_delta")
        # PCOD_vars_wide_op$NE_winds <- 
        #   getNE_winds(vNorth=PCOD_vars_wide_op$vNorth_surface5m,
        #               uEast=PCOD_vars_wide_op$uEast_surface5m)
        
        futDat_weekly_strata_tmp <- fut%>%
                filter(strata%in%strata_set[[ii]],
                       mo%in%mo_set[[ii]],
                       var%in%c("vNorth_surface5m","uEast_surface5m"))%>%
                mutate(val_use = val_delta,units = "meter second-1" )%>%
                mutate(var_salmon = names(var_set)[ii])%>%
                ungroup()%>%data.frame()
       
        # remove all the extra stuff:
        futDat_weekly_strata_tmp <- futDat_weekly_strata_tmp%>%select(my_vars(futDat_weekly_strata_tmp))
        
        futDat_weekly_strata_tmp <-  futDat_weekly_strata_tmp%>%
          pivot_wider(names_from = var,
                    values_from = all_of(valset))%>%
          ungroup()%>%data.frame()
       
        for(k in 1:length(valset)){
         
          eval(parse(text = paste0(" futDat_weekly_strata_tmp <- futDat_weekly_strata_tmp%>%
          rowwise()%>%mutate(",valset[k], "= getNE_winds
          (vNorth = ",valset[k],"_vNorth_surface5m,
            uEast = ",valset[k],"_uEast_surface5m))%>%
            select(-",valset[k],"_vNorth_surface5m,-",
                     valset[k],"_uEast_surface5m)%>%
            ungroup()%>%data.frame()") ))
        }
        futDat_weekly_strata_tmp <-  futDat_weekly_strata_tmp%>%mutate(var = "NEwinds")
    
        
      }else{
        
        futDat_weekly_strata_tmp <- fut%>%
          filter(strata%in%strata_set[[ii]],
                 mo%in%mo_set[[ii]],
                 var%in%var_set[[ii]])%>%
          mutate(val_use = val_delta)%>%
          mutate(var_salmon = names(var_set)[ii])%>%
          ungroup()%>%data.frame() 
        
        # remove all the extra stuff:
        futDat_weekly_strata_tmp <- futDat_weekly_strata_tmp%>%select(my_vars(futDat_weekly_strata_tmp))
        
      }
      
     
      grp_names <- names(futDat_weekly_strata_tmp)[!names(futDat_weekly_strata_tmp)%in%c("strata","strata_area_km2","wk","season","basin","mday")]
      nms  <- c("val_use","jday","mnDate",
                "mnVal_hind","sdVal_hind","val_raw","val_delta")
      
      nms2 <- grp_names[!grp_names%in%nms]
      
      futDat_monthly_tmp <- futDat_weekly_strata_tmp%>%
        select(!!!syms(grp_names))%>%group_by(!!!syms(nms2))%>%
        summarize_at(nms,mean,na.rm=T)%>%
        relocate(val_use, .before = mnVal_hind)%>%
        relocate(var_salmon, .before = var)%>%
        ungroup()%>%data.frame()
      
      
      grp_names <- names(futDat_weekly_strata_tmp)[!names(futDat_weekly_strata_tmp)%in%c("strata","lognorm","type",
                                                                                           "strata_area_km2",
                                                                                           "mo","wk","season","basin","mday")]
      nms  <- c("val_use","jday","mnDate",
                "mnVal_hind","sdVal_hind","val_raw","val_delta")
      
      nms2 <- grp_names[!grp_names%in%nms]
      
      futDat_avg_tmp <- futDat_weekly_strata_tmp%>%
        select(!!!syms(grp_names))%>%group_by(!!!syms(nms2))%>%
        summarize_at(nms,mean,na.rm=T)%>%
        relocate(val_use, .before = mnVal_hind)%>%
        relocate(var_salmon, .before = var)%>%
        ungroup()%>%data.frame()
      
      jj <- jj + 1
      if(jj==1){
        futDat_avg            <- futDat_avg_tmp 
        futDat_monthly        <- futDat_monthly_tmp 
        futDat_weekly_strata  <- futDat_weekly_strata_tmp 
        
      }else{
        futDat_avg            <- rbind(futDat_avg,futDat_avg_tmp)
        futDat_monthly        <- rbind(futDat_monthly,futDat_monthly_tmp)
        futDat_weekly_strata  <- rbind(futDat_weekly_strata,futDat_weekly_strata_tmp)
      }
     
      rm(futDat_avg_tmp)
      rm(futDat_monthly_tmp)
      rm(futDat_weekly_strata_tmp)
    
      
    }  
   rm(fut) 
  }
}
   
  fix_caps <- function (dataset){
    out <- dataset%>%
      mutate(GCM = gsub("MIROC","miroc",GCM))%>%
      mutate(GCM = gsub("GFDL","gfdl",GCM))%>%
      mutate(GCM = gsub("CESM","cesm",GCM))%>%
      mutate(sim = gsub("MIROC","miroc",sim))%>%
      mutate(sim = gsub("GFDL","gfdl",sim))%>%
      mutate(sim = gsub("CESM","cesm",sim))%>%
      mutate(GCM = factor(GCM, levels =c("hind","gfdl","cesm","miroc")))%>%
      mutate(GCM_scen = paste0(GCM,"_",RCP))%>%data.frame()
    return(out)
  }

  cat("saving outputs\n") 

    # fix the caps issue:
    futDat_monthly        <- fix_caps(futDat_monthly)
    futDat_weekly_strata  <- fix_caps(futDat_weekly_strata)
    futDat_avg            <- fix_caps(futDat_avg)
    
      # output the data as Rdata and CSV
      write_csv(futDat_monthly, file.path(outfldr,"futDat_monthly.csv"))
      save(futDat_monthly, file=file.path(outfldr,"futDat_monthly.Rdata"))
      
      # output the data as Rdata and CSV
      write_csv(futDat_weekly_strata, file.path(outfldr,"futDat_weekly_strata.csv"))
      save(futDat_weekly_strata, file=file.path(outfldr,"futDat_weekly_strata.Rdata"))
      
      # output the data as Rdata and CSV
      write_csv(futDat_avg, file.path(outfldr,"futDat_avg.csv"))
      save(futDat_avg, file=file.path(outfldr,"futDat_avg.Rdata"))
      
### ----- PREV


if (1 ==10){
  # loads packages, data, setup, etc.
  suppressMessages( suppressWarnings(source("R/make.R")))
  
  # get the variable you want:
  df <- get_var( typeIN    = "monthly", 
                 monthIN   = 9:10,
                 plotvar   = "temp_bottom5m",
                 bcIN      = c("raw","bias corrected"),
                 CMIPIN    = "K20P19_CMIP6", 
                 plothist  = T,  # ignore the hist runs
                 removeyr1 = T)  # "Remove first year of projection ( burn in)")
  
  df$plot+coord_cartesian(ylim = c(0, 7))
  head(df$dat)
  
  # concat the hind and fut runs by removing years from projection
  stitchDate <- "2020-12-30"
  
  newdat <- stitchTS(dat = df$dat,
                     maxD  = stitchDate)
  
  # newdat has the full set of data
  # select miroc_ssp126
  head(newdat%>%dplyr::filter(GCM_scen==paste0(GCMs[1],"_",scens[1])))
  tail(newdat%>%dplyr::filter(GCM_scen==paste0(GCMs[1],"_",scens[1])))
  
  pp <- plotTS(newdat )
  pp

}