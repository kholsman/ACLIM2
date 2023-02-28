#'
#'
#'
#'unlink_val.R
#'
# now convert vals back for hindIN and histIN

unlinkfun <- function(x,type=logit,log_adj = 1e-4,roundn=5){
  if(type=="none")
    x <- x
  if(type=="logit"){
    
    myfun2 <- function(x){
      
      if(any(x<0&!is.na(x)))  x[x<0&!is.na(x)]   <- 0
      if(any(x>1&!is.na(x)))  x[x>1&!is.na(x)]   <- 1
      return(x)
    }
    x <- myfun2(x)
  }
  
  if(type=="log"){
    myfun3 <- function(x){
      if(any(x<0&!is.na(x)))  x[x<0&!is.na(x)]   <- 0
      return(x)
    }
    x <- myfun3(x)
  }
  return(round(x,roundn))
}

unlink_val <- function(indat,
                           log_adj =1e-4,
                           bc_keep = NULL,
                           roundn = 5,
                           listIN = c("mn_val","mnVal_hind","mnVal_hist"),
                           rmlistIN = c("sdVal_hind", "seVal_hind", "sdVal_hind_mo", "sdVal_hind_yr",
                                        "sdVal_hist", "seVal_hist", "sdVal_hist_mo", "sdVal_hist_yr",
                                        "nVal_hist","nVal_hind")){
  
  if(!any(indat$lognorm%in%c("none","log","logit"))){
    stop("bias_correct_new_strata: problem with lognorm, must be 'none', 'log' or 'logit' for each var")
  }else{
    subA<-subB<-subC<-NULL
    if(any(indat$lognorm=="none"))
      subA <- indat%>%filter(lognorm=="none")
    if(any(indat$lognorm=="logit")){
      myfun2 <- function(x){
        
        if(any(x<0&!is.na(x)))  x[x<0&!is.na(x)]   <- 0
        if(any(x>1&!is.na(x)))  x[x>1&!is.na(x)]   <- 1
        return(x)
      }
      subB <- indat%>%filter(lognorm=="logit")%>%
        mutate_at(all_of(listIN),function(x) myfun2(x) )
      
    }
    
    if(any(indat$lognorm=="log")){
      myfun3 <- function(x){
        if(any(x<0&!is.na(x)))  x[x<0&!is.na(x)]   <- 0
        return(x)
      }
      
      subC <- indat%>%filter(lognorm=="log")%>%
        mutate_at(all_of(listIN),function(x) myfun3(x) )
    }
    
  }
  
  out <- rbind(subA, subB, subC)%>%
    mutate(mn_val=round(mn_val,roundn))%>%select(-all_of(rmlistIN))
  
  return(out)
}


unlinkfun_old <- function(x,type=logit,log_adj = 1e-4,roundn=5){
  if(type=="none")
    x <- x
  if(type=="logit"){
    
    myfun2 <- function(x){
      
      if(any(x>0&!is.na(x)))  x[x>0&!is.na(x)]   <- inv.logit(x[x>0&!is.na(x)])+log_adj
      if(any(x<0&!is.na(x))) x[x<0&!is.na(x)]    <- inv.logit(x[x<0&!is.na(x)])-log_adj
      if(any(x==0&!is.na(x))) x[x==0&!is.na(x)]  <- inv.logit(x[x==0&!is.na(x)])
      return(x)
    }
    x <- myfun2(x)
  }
  
  if(type=="log")
    x<- exp(x)-log_adj 
  return(round(x,roundn))
}



unlink_val_old <- function(indat,
                       log_adj =1e-4,
                       roundn = 5,
                       listIN = c("mn_val","mnVal_hind","mnVal_hist"),
                       rmlistIN = c("sdVal_hind", "seVal_hind", "sdVal_hind_mo", "sdVal_hind_yr",
                                    "sdVal_hist", "seVal_hist", "sdVal_hist_mo", "sdVal_hist_yr",
                                    "nVal_hist","nVal_hind")){
  
  
  if(!any(indat$lognorm%in%c("none","log","logit"))){
    stop("bias_correct_new_strata: problem with lognorm, must be 'none', 'log' or 'logit' for each var")
  }else{
    subA<-subB<-subC<-NULL
   if(any(indat$lognorm=="none"))
    subA <- indat%>%filter(lognorm=="none")
   if(any(indat$lognorm=="logit")){
     
       myfun2 <- function(x){
         
         # x <- round(inv.logit(x),6)-log_adj
         # # if(any(na.omit(x)==log_adj)) x[x==log_adj&!is.na(x)]<- 0
         # # if(any(na.omit(x)==(1-log_adj))) x[x==(1-log_adj)&!is.na(x)]<- 1
         # x
         
           # x <- logit(x)
           # if(any(x==-Inf&!is.na(x))) x[x==-Inf&!is.na(x)] <- logit(log_adj)
           # if(any(x==Inf&!is.na(x))) x[x==Inf&!is.na(x)] <- logit(1-log_adj)
           # return(x)
           if(any(x>0&!is.na(x)))  x[x>0&!is.na(x)]   <- inv.logit(x[x>0&!is.na(x)])+log_adj
           if(any(x<0&!is.na(x)))  x[x<0&!is.na(x)]    <- inv.logit(x[x<0&!is.na(x)])-log_adj
           if(any(x==0&!is.na(x))) x[x==0&!is.na(x)]  <- inv.logit(x[x==0&!is.na(x)])
           return(x)
         }
     subB <- indat%>%filter(lognorm=="logit")%>%
       mutate_at(all_of(listIN),function(x) myfun2(x) )
     
   }
    
   if(any(indat$lognorm=="log"))
    subC <- indat%>%filter(lognorm=="log")%>%
      mutate_at(all_of(listIN),function(x) exp(x)-log_adj )
    
  }
  
  out <- rbind(subA, subB, subC)%>%
    mutate(mn_val=round(mn_val,roundn))%>%select(-all_of(rmlistIN))
  
  return(out)
}


unlinkfun_old <- function(x,type=logit,log_adj = 1e-4,roundn=5){
  if(type=="none")
    x <- x
  if(type=="logit"){
    
    myfun2 <- function(x){
      
      if(any(x>0&!is.na(x)))  x[x>0&!is.na(x)]   <- inv.logit(x[x>0&!is.na(x)])+log_adj
      if(any(x<0&!is.na(x))) x[x<0&!is.na(x)]    <- inv.logit(x[x<0&!is.na(x)])-log_adj
      if(any(x==0&!is.na(x))) x[x==0&!is.na(x)]  <- inv.logit(x[x==0&!is.na(x)])
      return(x)
    }
    x <- myfun2(x)
  }
  
  if(type=="log")
    x<- exp(x)-log_adj 
  return(round(x,roundn))
}


