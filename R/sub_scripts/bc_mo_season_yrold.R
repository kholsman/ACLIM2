#' 
#' 
#' 
#' bc_mo_season_yr.R
#' 
#' 
#'   # get monthly means:
cat("    -- make reg_indices_monthly_proj ... \n")
reg_indices_monthly_proj  <- tmp%>%
  dplyr::group_by(var,year,season,mo,units, long_name,basin,sim)%>%
  dplyr::summarize(mn_val  = mean(mn_val, na.rm = T),
                   sd_val  = sd(mn_val, na.rm = T),
                   mnDate  = mean(mnDate, na.rm = T))%>%
  dplyr::mutate(type = "monthly means",
                jday = mnDate,
                mnDate = as.Date(paste0(year,"-01-01"))+mnDate)

# get seasonal means:
cat("    -- make reg_indices_seasonal_proj ... \n")
reg_indices_seasonal_proj   <- tmp%>%
  dplyr::group_by(var,year,season,units, long_name,basin,sim)%>%
  dplyr::summarize(mn_val  = mean(mn_val, na.rm = T),
                   sd_val  = sd(mn_val, na.rm = T),
                   mnDate  = mean(mnDate, na.rm = T))%>%
  dplyr::mutate(type =  "seaonal means",
                jday = mnDate,
                mnDate = as.Date(paste0(year,"-01-01"))+mnDate)

# get annual means:
cat("    -- make reg_indices_annual_proj ... \n")
reg_indices_annual_proj   <- tmp%>%
  dplyr::group_by(var,year,units, long_name,basin,sim)%>%
  dplyr::summarize(
    mn_val  = mean(mn_val, na.rm = T),
    sd_val  = sd(mn_val, na.rm = T), 
    mnDate  = mean(mnDate, na.rm = T))%>%
  dplyr::mutate(type = "annual means",
                jday = mnDate,
                mnDate = as.Date(paste0(year,"-01-01"))+mnDate)

rm(list=c("tmp","proj_wk","proj_srvy"))
gc()
# Now bias correct the data:
cat("    -- bias correct seasonal_adj ... \n")
seasonal_adj <- suppressWarnings(bias_correct( 
  target     = BC_target,
  hindIN = reg_indices_seasonal_hind,
  histIN = reg_indices_seasonal_hist,
  futIN  = reg_indices_seasonal_proj,
  ref_yrs    = ref_years,
  group_byIN = c("var","basin","season"),
  normlistIN =  normlist_IN,
  log_adj    = 1e-4))
# rm(list=c("reg_indices_seasonal_hind","reg_indices_seasonal_hist","reg_indices_seasonal_proj"))
# gc()

cat("    -- bias correct monthly_adj ... \n")
monthly_adj <- suppressWarnings(bias_correct( 
  target     = BC_target,
  hindIN = reg_indices_monthly_hind,
  histIN = reg_indices_monthly_hist,
  futIN  = reg_indices_monthly_proj,
  ref_yrs    = ref_years,
  group_byIN = c("var","basin","season","mo"),
  normlistIN =  normlist_IN,
  log_adj    = 1e-4))


if(1==10){
  aa<- monthly_adj$fut%>%filter(basin=="SEBS",var=="temp_bottom5m")
  
  ggplot()+geom_line(data=aa, aes(x=jday, y=val_biascorrected,color=factor(year)))+
    theme_minimal()
}

# rm(list=c("reg_indices_monthly_hind","reg_indices_monthly_hist","reg_indices_monthly_proj"))
# gc()
cat("    -- bias correct annual_adj ... \n")
annual_adj <- suppressWarnings(bias_correct( 
  target     = BC_target,
  hindIN = reg_indices_annual_hind,
  histIN = reg_indices_annual_hist,
  futIN  = reg_indices_annual_proj,
  ref_yrs    = ref_years,
  group_byIN = c("var","basin"),
  normlistIN =  normlist_IN,
  log_adj    = 1e-4))

# rm(list=c("reg_indices_annual_hind","reg_indices_annual_hist","reg_indices_annual_proj"))
# gc()
# 
