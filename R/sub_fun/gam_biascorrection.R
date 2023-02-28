#'
#'
#'
#'gam_biascorrection.R
#'
#' INCOMPLETE

gam_biascorrection <- function(indat,
                               kin = 0.8,
                       log_adj =1e-4,
                       bc_keep = FALSE,
                       roundn = 5,
                       listIN = c("mn_val","mnVal_hind","mnVal_hist"),
                       rmlistIN = c("sdVal_hind", "seVal_hind", "sdVal_hind_mo", "sdVal_hind_yr",
                                    "sdVal_hist", "seVal_hist", "sdVal_hist_mo", "sdVal_hist_yr",
                                    "nVal_hist","nVal_hind")){
  require(mgcv)
  
  
  if(bc_keep) indat <- indat%>%mutate(val_bcwk_IN=val_bcwk)
  if(!any(indat$lognorm%in%c("none","log","logit"))){
    stop("bias_correct_new_strata: problem with lognorm, must be 'none', 'log' or 'logit' for each var")
  }else{
    subA<-subB<-subC<-NULL
    if(any(indat$lognorm=="none"))
      subA <- indat%>%filter(lognorm=="none")
    if(any(indat$lognorm=="logit")){
      myfun2 <- function(x){
        
        if(any(x>0&!is.na(x)))  x[x<0&!is.na(x)]   <- 0
        if(any(x<0&!is.na(x)))  x[x>1&!is.na(x)]   <- 1
        return(x)
      }
      subB <- indat%>%filter(lognorm=="logit")%>%
        mutate_at(all_of(listIN),function(x) myfun2(x) )
      
    }
    
    if(any(indat$lognorm=="log")){
      function ( x =sub$wk, y = sub$mnVal_x, kin = .8,pos=FALSE){
        df <- na.omit(data.frame(x,y))
        nobs <- length(unique(df$x))
        if(dim(df)[1]>2){
          if(pos){
            Gam   <- mgcv::gam( log(y+1e-4) ~ 1 + s(x, k=round(365*kin),bs= "cc"),data=df)
            out   <- exp(as.numeric(predict(Gam, newdata=data.frame(x=x), se.fit=FALSE ))-1e-4)
          }else{
            Gam   <- mgcv::gam( y ~ 1 + s(x, k=round(nobs*kin),bs= "cc"),data=df)
            out <- as.numeric(predict(Gam, newdata=data.frame(x=x), se.fit=FALSE ))
          }
        }else{
          out<- y
        }
        
        return(out)
      }
      
      
      #mg  <- gam(data=dd, mn_val~ 1 +basin+strata+ s(mnVal_hind,jday,k=round(365*kin)), bs ="cc")
      dd<- dd%>%mutate(delta= mn_val - mnVal_hind)
      mg  <- gam(data=dd, mn_val ~ 1 +basin+strata+s(mnVal_hind,k=10)+s(wk,k=round(52*kin), bs ="cc",link="log"))
    
      dd$mn_val2 <- as.numeric(predict(mg, newdata=dd, se.fit=FALSE ))
      ggplot(dd) +
        geom_line(aes(x=mnDate, y = mn_val, color = "mn_val"))+
        geom_line(aes(x=mnDate, y = mn_val2, color= "mn_val2"))+
        facet_grid(basin~.)
      subA$mn_val2 <-as.numeric(predict(mg, newdata=subA, se.fit=FALSE ))
      ggplot(subA%>%filter(strata%in%c(50,71))) +
        geom_line(aes(x=mnDate, y = mn_val, color = "raw_fut"))+
        geom_line(aes(x=mnDate, y = mn_val2, color= "bc_fut"))+
        geom_line(aes(x=mnDate, y = mnVal_hind, color= "mnVal_hind"))+
        geom_line(aes(x=mnDate, y = mnVal_hist, color= "mnVal_hist"))+
        coord_cartesian(xlim =c(as.Date("2080-12-29"),as.Date("2085-12-29")))+
        facet_grid(basin~strata)
      
      out <- as.numeric(predict(Gam, newdata=data.frame(x=x), se.fit=FALSE ))
      subC <- indat%>%filter(lognorm=="log")%>%
        mutate_at(all_of(listIN),function(x) myfun3(x) )
    }
    
  }
  
  out <- rbind(subA, subB, subC)%>%
    mutate(mn_val=round(mn_val,roundn))%>%select(-all_of(rmlistIN))
  
  return(out)
}