#' update_base_data.R
#' 

#_______________________________________
# Open nc files and extract global objects
#_______________________________________

i       <- 2
ncfl    <- file.path(aclim[i],paste0(reg_txt,aclim[i],".nc"))
nc      <- nc_open(file.path(data_path,ncfl))

# get the area for each region:
region_area   <- ncvar_get(nc, varid = "region_area")

# get the full list of variables (i.e., ACLIM indices):
weekly_vars    <- names(nc$var)
weekly_nvar    <- length(weekly_vars)
weekly_var_def <- data.frame(name = weekly_vars, units ="", longname = "",stringsAsFactors = FALSE)

i <- 0 
for(k in weekly_vars){
  i <- i + 1
  weekly_var_def$units[i]    <- nc$var[[k]]$units
  weekly_var_def$longname[i] <- nc$var[[k]]$longname
}

# get the variable index number:
k             <- grep("temp_bottom5m", weekly_vars)

# get the full list of survey strata names:
weekly_strata <- (nc$var[[k]]$dim[[1]]$vals)

# get the timestep for each value:
weekly_t <- list()
tmp_list <- c("B10K-H16_CORECFS",
              "B10K-K20_CORECFS" ,
              "B10K-H16_CMIP5_CESM_rcp45" ,
              "B10K-K20P19_CMIP6_miroc_ssp585")
i <- 0
for(mod in tmp_list){
  i <- i + 1
  ncfl    <- file.path(mod,paste0(reg_txt,mod,".nc"))
  nc      <- nc_open(file.path(data_path,ncfl))
  
  tmp_t   <- as.POSIXct(nc$var[[k]]$dim[[2]]$vals, 
                        origin = substr(nc$var[[k]]$dim[[2]]$units,15,36),
                        tz = "GMT")
  weekly_t[[i]] <- tmp_t
}
names(weekly_t) <- c("H16 Hindcast","K20 Hindcast","CMIP5","CMIP6")

nc_close(nc)

#______________________________
# srvy_replicated

i           <- 2
ncfl        <- file.path(aclim[i],paste0(srvy_txt,aclim[i],".nc"))
nc          <- nc_open(file.path(data_path,ncfl))

# get the full list of variables (i.e., ACLIM indices):
srvy_vars   <- names(nc$var)
srvy_nvar   <- length(srvy_vars)

srvy_var_def <- data.frame(name = srvy_vars, units ="", longname = "",stringsAsFactors = FALSE)
i <- 0 
for(k in srvy_vars){
  i <- i + 1
  srvy_var_def$units[i]    <- nc$var[[k]]$units
  srvy_var_def$longname[i] <- nc$var[[k]]$longname
}

srvy_station_num   <- (nc$var[[k]]$dim[[1]]$vals)
srvy_nstations     <- length(srvy_station_num)
srvy_yrs           <- (nc$var[[k]]$dim[[2]]$vals)

station_info <- data.frame(
  srvy_station_num = srvy_station_num,
  station_id = ncvar_get(nc, varid = "station_id"),
  latitude   = ncvar_get(nc, varid = "latitude"),
  longitude  = ncvar_get(nc, varid = "longitude"),
  stratum    = ncvar_get(nc, varid = "stratum"),
  doy        = ncvar_get(nc, varid = "doy"))

station_info$subregion <- factor(NA,levels=c("SEBS","NEBS"))
station_info$subregion[station_info$stratum%in%SEBS_strata]<-"SEBS"
station_info$subregion[station_info$stratum%in%NEBS_strata]<-"NEBS"
station_info$stratum <- factor(station_info$stratum, levels=sort(unique(station_info$stratum)))
nc_close(nc)

all_info1 <- info(model_list=aclim,type=1)
all_info2 <- info(model_list=aclim,type=2)

save(list=c("region_area","weekly_vars","weekly_nvar","weekly_var_def","srvy_var_def","weekly_strata","weekly_t",
            "all_info1","all_info2",
       "srvy_vars","srvy_nvar","srvy_station_num","srvy_nstations","srvy_yrs","station_info"),file="Data/in/base_data.Rdata")

