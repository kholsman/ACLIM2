#' misc functions for ACLIM2
#' 

LNmean <-function(x,log_adj=1e-4,na.rm=F){
  df <- data.frame(y =x, x = 0)
  if(na.rm) df <-na.omit(df)
  model <-  glm(y+log_adj ~ x,data=df,family = gaussian(link = "log"))
  mn <- as.numeric(fitted(model)[1])-log_adj
  
  return(mn)
}
LNsd <-function(x,log_adj=1e-4,na.rm=F){
  df <- data.frame(y =x, x = 0)
  model <-  glm(y+log_adj ~ x,data=df,family = gaussian(link = "log"))
  mn <- as.numeric(fitted(model)[1])-log_adj
  if(na.rm) df <-na.omit(df)
  sd <- exp(sqrt(diag(vcov(model)))[1])-log_adj
  return(sd)
}


#' get_mlt
get_mlt <- function(unit_txt){
if(length(grep("seconds", unit_txt)>0))  out <- data.frame(mlt = 1,ntxt = nchar("seconds since "))
if(length(grep("minutes", unit_txt)>0))  out <- data.frame(mlt = 60,ntxt = nchar("minutes since "))
if(length(grep("hours", unit_txt)>0))    out <- data.frame(mlt = 60*60,ntxt = nchar("hours since "))
if(length(grep("days", unit_txt)>0))     out <- data.frame(mlt = 24*60*60,ntxt = nchar("days since "))
return(out)
}


get_mn_forecast<-function(valIN   = "TempC",
                          strataOut   = F,
                          strataIN    = region_area_name, 
                          basinIN     = c("NEBS","SEBS"),
                          dataIN = subdat ) {
  
  if(!strataOut){
    eval(parse(text = paste0("tmp <- dataIN%>%
        filter(basin%in%basinIN,!is.na(",valIN,"))%>%
        group_by(var,time,jday,mo,yr,species,basin)%>%
        mutate(valArea = ",valIN,"*grid_cell_area)%>%
        summarize(
          tot_val = sum(valArea), 
          sumArea = sum(grid_cell_area))%>%
        mutate(mn_val=tot_val/sumArea) ") ))
    
  }else{
    
    eval(parse(text = paste0("tmp <- dataIN%>%
        filter(strata%in%strataIN,!is.na(",valIN,"))%>%
        group_by(var,time,jday,mo,yr,species,strata,strata_area_km2)%>%
        mutate(valArea = ",valIN,"*grid_cell_area)%>%
        summarize(
          tot_val = sum(valArea), 
          sumArea = sum(grid_cell_area))%>%
        mutate(mn_val=tot_val/sumArea) ") ))

  }

  tmp$plotvar <- valIN
  
  return(tmp)
  
}

get_mn_forecast_old<-function(valIN = "TempC",
                            strataOut = F,
                            strataIN = NEBS_strata, 
                            dataIN = subdat ) {
  eval(parse(text = paste0("tmp <- dataIN%>%
        filter(strata%in%strataIN)%>%
        group_by(var,time,jday,mo,yr,species,strata,strata_area_km2)%>%
        summarize(mn_val = mean(",valIN,",na.rm=T)) ") ))
  tmp$strata <- factor(tmp$strata, levels = region_area_name)
  
  eval(parse(text = paste0("tmp2 <- dataIN%>%
        group_by(var,time,jday,mo,yr,species,basin)%>%
        summarize(mn_val = mean(",valIN,",na.rm=T)) ") ))
  
  tmp$plotvar <- tmp2$plotvar <- valIN
  if(strataOut){
    return(tmp)
  }else{
    return(tmp2)
  }
}

