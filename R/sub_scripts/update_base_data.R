#' update_base_data.R
#' 

#_______________________________________
# Open nc files and extract global objects
#_______________________________________
# get the grid:
nc      <- nc_open(file.path(data_path,"Bering10K_extended_grid.nc"))
stations_regions       <- ncvar_get(nc, varid = "stations_regions")
surveystrata_original  <- ncvar_get(nc, varid = "surveystrata_original")
surveystrata_updated   <- ncvar_get(nc, varid = "surveystrata_updated")
surveystrata_comboeast <-  ncvar_get(nc, varid = "surveystrata_comboeast")
area_feast             <- ncvar_get(nc, varid = "area_feast")
bsierp_marine_regions  <- ncvar_get(nc, varid = "bsierp_marine_regions")
shelf_mismatch        <- ncvar_get(nc, varid = "shelf_mismatch")
nc_close(nc)

region_area <- region_area_name  <- unique(na.omit(as.vector(surveystrata_comboeast)))
region_area <- region_area*NA
for(i in 1:length(region_area_name))
  region_area[i]     <- sum(area_feast[surveystrata_comboeast==region_area_name[i]],na.rm=T)

strata_grid <- surveystrata_comboeast
basin_grid  <- strata_grid*0
basin_grid  <- factor(basin_grid,levels=c("SEBS","NEBS","Other"))

basin_grid[which(strata_grid%in%NEBS_strata)]   <- factor("NEBS",levels=c("SEBS","NEBS","Other"))
basin_grid[which(strata_grid%in%SEBS_strata)]   <- factor("SEBS",levels=c("SEBS","NEBS","Other"))
basin_grid[!which(strata_grid%in%c(NEBS_strata,SEBS_strata))]   <- factor("Other",levels=c("SEBS","NEBS","Other"))

i       <- 2
ncfl    <- file.path(aclim[i],paste0(reg_txt,aclim[i],".nc"))
nc      <- nc_open(file.path(data_path,ncfl))

# get the area for each region:
region_area_old      <- ncvar_get(nc, varid = "region_area")
region_area_name_old <- nc$var[["region_area"]]$dim[[1]]$vals

strata_areas <- merge(data.frame(area = region_area,    strata = region_area_name),
      data.frame(area_old = region_area_old,strata = region_area_name_old),by=c("strata"),all.x=T,all.y=T)

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

save(list=c("region_area","region_area_name",
            "stations_regions"       ,
            "surveystrata_original"  ,
            "surveystrata_updated"   ,
            "surveystrata_comboeast" ,
            "area_feast"             ,
            "bsierp_marine_regions"  ,
            "shelf_mismatch"         ,
            "strata_areas"           ,
            "basin_grid"             ,
            "strata_grid"            ,
            
            "weekly_vars","weekly_nvar","weekly_var_def","srvy_var_def","weekly_strata","weekly_t",
            "all_info1","all_info2",
       "srvy_vars","srvy_nvar","srvy_station_num","srvy_nstations","srvy_yrs","station_info"),file="Data/shared/base_data.Rdata")

