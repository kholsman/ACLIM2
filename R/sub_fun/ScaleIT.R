#'
#'
#'ScaleIT.R
#'Scale the data to a reference period (delta)
#'


ScaleIT <- function(
  ref_dat  = hind,
  proj_dat = proj,
  ref_yrs  = 1979:2000
){
  
  mnsdn <- ref_dat%>%filter(year%in%ref_yrs)%>%
    group_by(var,season,basin,type)%>%
    summarize(mn = mean(value, na.rm=T),
              sd = sd(value,na.rm=T),
              n  = length(value))
  mnsdn$ref_yrs <- paste0(ref_yrs[1],":",rev(ref_yrs)[1])
  
  proj_dat<- merge(proj_dat,mnsdn,by=c(
    "var","season","basin","type"), all.x = T)
  
  ref_dat<- merge(ref_dat,mnsdn,by=c(
    "var","season","basin","type"), all.x = T)
  
    
  proj_dat$delta_value <- (proj_dat$value-proj_dat$mn)/sqrt(proj_dat$sd)
  ref_dat$delta_value  <- (ref_dat$value-ref_dat$mn)/sqrt(ref_dat$sd)
 # return(list(ref_dat=ref_dat,proj_dat = proj_dat))
  return(proj_dat)
}