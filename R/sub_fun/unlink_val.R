#'
#'
#'
#'unlink_val.R
#'
# now convert vals back for hindIN and histIN
unlink_val <- function(indat,
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
     
       myfun <- function(x){
         
         x <- round(inv.logit(x),6)
         if(any(na.omit(x)==log_adj)) x[x==log_adj&!is.na(x)]<- 0
         if(any(na.omit(x)==(1-log_adj))) x[x==(1-log_adj)&!is.na(x)]<- 1
         x
       }
      
       
     subB <- indat%>%filter(lognorm=="logit")%>%
       mutate_at(all_of(listIN),function(x) myfun(x) )
     
   }
    
   if(any(indat$lognorm=="log"))
    subC <- indat%>%filter(lognorm=="log")%>%
      mutate_at(all_of(listIN),function(x) exp(x)-log_adj )
    
  }
  
  out <- rbind(subA, subB, subC)%>%
    mutate(mn_val=round(mn_val,roundn))%>%select(-all_of(rmlistIN))
  
  return(out)
}
