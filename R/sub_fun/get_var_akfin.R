# get_var_akfin

#'
#' @param typein # The time scale of the indicator, one of annual, monthly, weekly, surveyrep, or seasonal
#' @param var Modeled variable for download, e.d. "temp_bottom5m"
#' @param basin "SEBS", "NEBS" etc. 
#' @param cmip "CMIP6" (recommended) or "CMIP5"
#' @param dataset FUT, HIST, or HIND
#' @examples
#' # example code
#' tempbottom5_sebs_hind_cmip6_annual <- get_var_akfin()
#' tempbottom5_NBS_hind_cmip6_annual <- get_var_akfin(basin="NEBS")
#' tempbottom5_NBS_fut_cmip6_annual <- get_var_akfin(basin="NEBS", dataset = "FUT")
#' tempsurface5_NBS_fut_cmip6_annual <- get_var_akfin(basin="NEBS", dataset = "FUT", var="temp_surface5m")
#' tempsurface5_NBS_fut_cmip5_annual <- get_var_akfin(basin="NEBS", dataset = "FUT", var="temp_surface5m", cmip="CMIP5")
#' tempbottom5_NBS_hind_cmip6_monthly <- get_var_akfin(typein="monthly",basin="NEBS", dataset = "HIND", var="temp_bottom5m", cmip="CMIP6")
#' tempbottom5_NBS_hind_cmip6_seasonal <- get_var_akfin(typein="seasonal",basin="NEBS", dataset = "HIND", var="temp_bottom5m", cmip="CMIP6")
#' tempbottom5_NBS_hind_cmip6_surveyrep <- get_var_akfin(typein="surveyrep",basin="NEBS", dataset = "HIND", var="temp_bottom5m", cmip="CMIP6")# had to format api differently
#' tempbottom5_NBS_hind_cmip6_weekly <- get_var_akfin(typein="weekly",basin="NEBS", dataset = "HIND", var="temp_bottom5m", cmip="CMIP6")
#' @export

# library(magrittr)
# library(dplyr)
# library(httr)
# library(jsonlite)

get_var_akfin <- function(typein="annual",
                          var="temp_bottom5m",
                          basin="SEBS",
                          cmip="CMIP6",
                          dataset="HIND") {
  if(typein %in% c("annual","monthly", "weekly","surveyrep", "seasonal")) {
    
  url <- paste0("https://apex.psmfc.org/akfin/data_marts/clim/aclim_l4_",typein)
  query<-list(dataset=dataset, var=var, basin=basin, cmip=cmip)
  
  jsonlite::fromJSON(httr::content(
    httr::GET(url=url, query=query),
    as="text", encoding="UTF-8")) |>
    dplyr::bind_rows()
  }
    
  else {
    return("typein must be one of annual, monthly, weekly, surveyrep, or seasonal. Otherwise more error messages coming later")
  }
}