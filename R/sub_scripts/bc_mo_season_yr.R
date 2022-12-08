#' 
#' 
#' 
#' bc_mo_season_yr.R
#' 
#' 
#' 
#' 

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
