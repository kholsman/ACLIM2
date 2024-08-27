#'
#'
#'get_bc_mean.R
#'
#'This function bias corrects
#'projections using reference 
#'time periods and time series
#'Revised version reflects methodology from 
#'the 2022 bias correction workshop
#'
#'ACLIM2 updated
#'
# 
if(1==10){
  bcdatIN    = weekly_adj
  selectBy   = c("var","units","long_name","sim","type","sim_type",
                 "basin","mnDate","jday","mn_val")
  fullList   = c("year","season","mo","wk","mnDate","jday")
  poolby     = c("year") 
  mutby_h    = c("val_raw","mn_val")
  
  normlistIN =  normlist
  log_adj    = 1e-4
}
get_bc_mean <- function(
  bcdatIN    = weekly_adj,
  plotIT     = FALSE,
  varIN      = c("aice","temp_bottom5m","EupS_integrated"),
  byStrata   = FALSE, # bias correct across years and regions
  selectBy   = c("var","units","long_name","sim","type","sim_type",
                 "basin","mnDate","jday","mn_val"),
  fullList   = c("year","season","mo","wk","mnDate","jday"),
  poolby     = c("year") ,
  mutby_h    = c("val_raw","mn_val"),
  mutby_f    = c("val_raw","mn_val","val_delta","val_biascorrected" ,"val_biascorrectedmo",
                "val_biascorrectedyr", 
                "scaling_factorwk" ,"scaling_factormo","scaling_factoryr",
                "mnVal_hind"  ,"sdVal_hind","sdVal_hind_mo","sdVal_hind_yr",
                "mnVal_hist","sdVal_hist","sdVal_hist_mo","sdVal_hist_yr"),
  validyr    = 2015:2021,
  normlistIN =  normlist,
  log_adj    = 1e-4

){
  wk <- FALSE
  if(any(poolby=="wk")) wk<-TRUE
  
  hindIN  <- bcdatIN$hind%>%
    select(all_of(c(selectBy,"val_raw","year","season", "mo", "wk" )))%>%
    left_join(normlistIN ,by=c("var"="var"))%>%ungroup()
  histIN  <- bcdatIN$hist%>%
    select(all_of(c(selectBy,"val_raw","year","season", "mo", "wk" )))%>%
    left_join(normlistIN ,by=c("var"="var"))%>%ungroup()
  futIN   <- bcdatIN$fut%>%ungroup()
  selectBy <- c(selectBy,"lognorm")
 
  
  MN <- function(x,na.rm=T,adj = log_adj,logIT=T){
    if(logIT){ 
      logx <- suppressWarnings(log(x + adj))
      out <- exp(mean(logx, na.rm=na.rm))-adj
      }else{
      out <- mean(x, na.rm=na.rm)
    }
    return(out)
  }
  SD <- function(x,na.rm=T,adj = log_adj,logIT=T){
    if(logIT){ 
      logx <- suppressWarnings(log(x + adj))
      out  <- exp(sd(logx, na.rm=na.rm))-log_adj
    }else{
      out  <- sd(x, na.rm=na.rm)
    }
    return(out)
  }
  
  #_________________________
  # hist
  #_________________________
  
    mutby  <- mutby_h
    rmList <- fullList[-which(fullList%in%poolby)]
    rr     <- which(selectBy%in%c(fullList[-which(fullList%in%poolby)],
                                      "val_raw","mn_val"))
    selectlist <- c(selectBy[-rr],poolby,mutby)
    if(!wk){
    sub  <- histIN
    suba <- sub[sub$lognorm,]
    subb <- sub[!sub$lognorm,]
    
    meta <-  sub%>%ungroup()%>%
      select(all_of(c(selectBy[-rr],poolby,"mnDate","jday")))%>%
      group_by(across(all_of(c(selectBy[-rr],poolby))))%>%
      summarize_at(all_of(c("mnDate","jday")), 
                        list(~mean(.,na.rm=TRUE)))
    a <- suba%>%ungroup()%>%
      select(all_of(selectlist))%>%
      ungroup()%>%
      group_by(across(all_of(c(selectBy[-rr],poolby))))%>%
      summarize_at(all_of(mutby), 
                list( ~MN(.,logIT=TRUE), 
                     ~SD(.,logIT=TRUE)))
    
    b <- subb%>%ungroup()%>%
      select(all_of(selectlist))%>%
      ungroup()%>%
      group_by(across(all_of(c(selectBy[-rr],poolby))))%>%
      summarize_at(all_of(mutby), 
                list( ~MN(.,logIT=FALSE), 
                      ~SD(.,logIT=FALSE)))
    
    out<- rbind(a,b)
    hist<- out%>%left_join(meta)%>%
      mutate(mn_val = mn_val_MN,
             val_raw = val_raw_MN)%>%
      relocate(all_of(c(selectBy,poolby)))
    rm(list=c("a","b","out","sub","suba","subb","mutby"))
    }else{
      
      hist <- histIN%>%ungroup()%>%
        select(all_of(c(selectBy[-rr],poolby,"mnDate","jday",mutby)))%>%
        relocate(all_of(c(selectBy,poolby)))
    }
    
  
  #_________________________
  # hind
  #_________________________
    mutby  <- mutby_h
    rmList <- fullList[-which(fullList%in%poolby)]
    rr     <- which(selectBy%in%c(fullList[-which(fullList%in%poolby)],
                                  "val_raw","mn_val"))
    selectlist <- c(selectBy[-rr],poolby,mutby)
    if(!wk){
    sub  <- hindIN
    suba <- sub[sub$lognorm,]
    subb <- sub[!sub$lognorm,]
    
    meta <-  sub%>%ungroup()%>%
      select(all_of(c(selectBy[-rr],poolby,"mnDate","jday")))%>%
      group_by(across(all_of(c(selectBy[-rr],poolby))))%>%
      summarize_at(all_of(c("mnDate","jday")), 
                   list(~mean(.,na.rm=TRUE)))
    a <- suba%>%ungroup()%>%
      select(all_of(selectlist))%>%
      ungroup()%>%
      group_by(across(all_of(c(selectBy[-rr],poolby))))%>%
      summarize_at(all_of(mutby), 
                   list( ~MN(.,logIT=TRUE), 
                         ~SD(.,logIT=TRUE)))
    
    b <- subb%>%ungroup()%>%
      select(all_of(selectlist))%>%
      ungroup()%>%
      group_by(across(all_of(c(selectBy[-rr],poolby))))%>%
      summarize_at(all_of(mutby), 
                   list( ~MN(.,logIT=FALSE), 
                         ~SD(.,logIT=FALSE)))
    
    out<- rbind(a,b)
    hind<- out%>%left_join(meta)%>%
      mutate(mn_val = mn_val_MN,
             val_raw = val_raw_MN)%>%
      relocate(all_of(c(selectBy,poolby)))
    rm(list=c("a","b","out","sub","suba","subb","mutby"))
    }else{
      
      hind <- hindIN%>%ungroup()%>%
        select(all_of(c(selectBy[-rr],poolby,"mnDate","jday",mutby)))%>%
        relocate(all_of(c(selectBy,poolby)))
    }
    
    
  
  #_________________________
  # Future
  #_________________________
   
    mutby  <- mutby_f
    rmList <- fullList[-which(fullList%in%poolby)]
    rr     <- which(selectBy%in%c(fullList[-which(fullList%in%poolby)],
                                  "val_raw","mn_val"))
    selectlist <- c(selectBy[-rr],poolby,mutby)
    
    if(!wk){
      sub  <- futIN
      suba <- sub[sub$lognorm,]
      subb <- sub[!sub$lognorm,]
      
      meta <-  sub%>%ungroup()%>%
        select(all_of(c(selectBy[-rr],poolby,"mnDate","jday")))%>%
        group_by(across(all_of(c(selectBy[-rr],poolby))))%>%
        summarize_at(all_of(c("mnDate","jday")), 
                     list(~mean(.,na.rm=TRUE)))
      a <- suba%>%ungroup()%>%
        select(all_of(selectlist))%>%
        ungroup()%>%
        group_by(across(all_of(c(selectBy[-rr],poolby))))%>%
        summarize_at(all_of(mutby), 
                     list( ~MN(.,logIT=TRUE), 
                           ~SD(.,logIT=TRUE)))
      
      b <- subb%>%ungroup()%>%
        select(all_of(selectlist))%>%
        ungroup()%>%
        group_by(across(all_of(c(selectBy[-rr],poolby))))%>%
        summarize_at(all_of(mutby), 
                     list( ~MN(.,logIT=FALSE), 
                           ~SD(.,logIT=FALSE)))
      
      out <- rbind(a,b)
      fut <- out%>%left_join(meta)%>%
        mutate(mn_val = mn_val_MN,
               val_biascorrected = val_biascorrected_MN,
               val_raw = val_raw_MN)%>%
        relocate(all_of(c(selectBy,poolby,"val_biascorrected")))
      rm(list=c("a","b","out","sub","suba","subb","mutby"))
      
    }else{
      
      fut <- futIN%>%ungroup()%>%
        select(all_of(c(selectBy[-rr],poolby,"mnDate","jday",mutby)))%>%
        relocate(all_of(c(selectBy,poolby,"val_biascorrected")))
    }
  

  if(plotIT){
  fsub<- fut%>%filter(var%in%varIN,year%in%validyr)%>%
    select(all_of(c("var","sim_type","basin",poolby,"mnDate",
                    "mn_val","mn_val_SD",
                    "val_biascorrected","val_biascorrected_SD")))
  hsub<- hind%>%filter(var%in%varIN,year%in%validyr)%>%
    select(all_of(c("var","sim_type","basin",poolby,"mnDate",
                    "mn_val","mn_val_SD",
                    "val_biascorrected","val_biascorrected_SD")))
  psub <-rbind(hsub,fsub)%>%ungroup()%>%
    select(all_of(c("var","sim_type","basin",poolby,"mnDate",
                    "mn_val","mn_val_SD",
                    "val_biascorrected","val_biascorrected_SD")))
  
  p <- ggplot(psub)+
    geom_point(data=hsub,aes(x=mnDate,y=mn_val,color=year),size=2)+
    # geom_point(data=hsub,aes(x=mnDate,y=mn_val+mn_val_SD,color=year),shape="-",size=5)+
    # geom_point(data=hsub,aes(x=mnDate,y=mn_val-mn_val_SD,color=year),shape="-",size=5)+
    # 
    geom_line(data=fsub,aes(x=mnDate,y=mn_val ),color="gray",size=.8)+
    geom_line(data=fsub,aes(x=mnDate,y=val_biascorrected ),size=1)+
    facet_grid(var~basin,scales="free_y")+theme_minimal()+ggtitle(paste0("out of sample: ",varIN))
  }
  
  
  # psub <- reshape2::melt(psub, id.vars=c("var","sim_type","basin",poolby))
  # ggplot(psub)+
  #   geom_line(aes(x=year,y=value,color=variable,linetype=sim_type),size=1)+facet_grid(basin~.)
 
  
  return( list(fut = fut, hind = hind,hist = hist,p=p))
}