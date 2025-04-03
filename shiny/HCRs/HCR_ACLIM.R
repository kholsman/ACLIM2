#'HCR_ACLIM.R
#'
#'@description
#' HCR forms developed during the Alaska Climate Integrated Modeling Project (ACLIM) phase 2
#' 2023 sprint. HCRS were evaluated in a series of MSEs for that project to evaluate climate
#' linked / smart harvest control rules for the NPFMC
#' 
#' @param B2B0 vector of biomass
#' @param type integer 1-7; default is 1
#' 1) ABC+HCR 1: Status quo
#' 2) ABC+HCR 2: Lagged recovery to estimate emergency relief financing needs
#' 3) ABC+HCR 3: Long-term resilience (stronger reserve) Ftarget
#' 4) ABC+HCR 4: CE informed sloping rate, e.g., MHW category alpha
#' 5) ABC+HCR 5: climate sensitivity reserve (buffer shocks)
#' 6) ABC+HCR 6: MHW slope + climate sensitivity reserve (buffer shocks)
#' 7) ABC+HCR 7: Recruit per spawner biomass variability adjusted HCR based on analyses by Spencer et al. in prep
#' @param alpha default is 0.05, this is the slope of the HCR
#' @param invlogit_gamma  log of the gamma parameter default is inv.logit(10); gamma decay rate value is between 0 and 1
#' @param log_omega1 omega1 is >0 covariate linked penalty on Flim for HCR 7
#' @param log_omega2 covariate linked penalty on B2B0_target for HCR 7
#' @param log_omega3 covariate linked penalty on B2B0_lim for HCR 7
#' @param B2B0_lim lower biomass threshold (e.g., B_20% = 0.2); 
#' @param B2B0_target Target biomass/MSY proxy
#' @param Flim input of F harvest mortality rate to apply the HCR to
#' @param log_theta is a scaler on SSB, should be >0
#' 
#' @export
#' 
    ACLIM_HCR <-function(B2B0,
                         type,
                         alpha, 
                         invlogit_gamma   = inv.logit(0), 
                         log_omega1  = log(0),  
                         log_omega2  = log(0),  
                         log_omega3  = log(0), 
                         log_theta = 1,
                         B2B0_lim, 
                         B2B0_target,
                         Flim   = 1,
                         cov    = NULL){
      
      if(!type%in%c(1:8)){
        stop("Error with HCR_ACLIM function: type must be an integer between 1 and 8")
      }
      
      if(type%in%c(1,2,3,4)){
               B2B40    <- B2B0/B2B0_target
               if(B2B40>1.){
                 maxFabc = Flim
               }else{
                 if(alpha<B2B40){
                   maxFabc = Flim*((B2B40-alpha)/(1.-alpha))
                 }else{
                   maxFabc=0.0
                 }
               }
      }
      
      if(type%in%c(5,6)){
        B2B40    <- B2B0/B2B0_target
        # gamma is the environmental sensitivity parameter from vulnerability analyses
        gamma <- logit(invlogit_gamma) # gamma is between 0 and 1
        if(B2B40>1.){
          if(gamma<B2B40){
            maxFabc=Flim*(exp(-gamma*(B2B40-1)))
          }
        }else{
          if(alpha<B2B40){
            maxFabc=Flim*((B2B40-alpha)/(1.-alpha))
          }else{
            maxFabc=0.0
          }
        }
      }
  
      if(type==7){
        
        omega1 <- exp(log_omega1)
        omega2 <- -1*exp(log_omega2)
        omega3 <- -1* exp(log_omega3)
        
        # omega 1 and 2 are environmental effective parameters from retro analyses
        # paul's HCR, cov is vector of scaled covariate effects on ref points
        B2B0_target <- B2B0_target*exp(-omega2*cov)
        B2B0_lim    <- B2B0_lim*exp(-omega3*cov)
        B2B40       <- B2B0/B2B0_target
        if(B2B40>1.){
          maxFabc = Flim
        }else{
          if(alpha<B2B40){
            maxFabc = Flim*((B2B40-alpha)/(1.-alpha))
          }else{
            maxFabc=0.0
          }
        }
        maxFabc = maxFabc*exp(-omega1*cov)
      }
       
      if(type%in%c(8)){
        B2B40    <- (exp(log_theta)*B2B0)/B2B0_target
        if(B2B40>1.){
          maxFabc = Flim
        }else{
          if(alpha<B2B40){
            maxFabc = Flim*((B2B40-alpha)/(1.-alpha))
          }else{
            maxFabc=0.0
          }
        }
      }
      
      if(B2B40<=(B2B0_lim/B2B0_target))
        maxFabc=0.0
      
      
      return(maxFabc)
      
      
}


    
    # HCR <-function(x, alpha=0.05, B2B0_lim = 0.2, B2B0_target=0.4,Flim=1){
    #   # Type 1
    #   if(type == 1){
    #     B2B40    <- x/B2B0_target
    #     if(B2B40>1.){
    #       maxFabc=Flim
    #     }else{
    #       if(alpha<B2B40){
    #         maxFabc=Flim*((B2B40-alpha)/(1.-alpha))
    #       }else{
    #         maxFabc=0.0
    #       }
    #     }
    #     if(B2B40<=(B2B0_lim/B2B0_target))
    #       maxFabc=0.0
    #     return(maxFabc)
    #   }
    #   if(type == 2){
    #     B2B40    <- x/B2B0_target
    #     
    #     # gamma is the environmental sensitivity parameter from vulnerability analyses
    #     if(B2B40>1.){
    #       if(gamma<B2B40){
    #         maxFabc=Flim*(exp(-gamma*(B2B40-1)))
    #       }
    #     }else{
    #       if(alpha<B2B40){
    #         maxFabc=Flim*((B2B40-alpha)/(1.-alpha))
    #       }else{
    #         maxFabc=0.0
    #       }
    #     }
    #     if(B2B40<=(B2B0_lim/B2B0_target))
    #       maxFabc=0.0
    #     return(maxFabc)
    #   }
    #   
    #   if(type == 3){
    #     
    #   }
    #   
    # }
    # 
    # 
    # HCR2 <-function(x, alpha=0.05, gamma = .2, B2B0_lim = 0.2, B2B0_target=0.4,Flim=1){
    #   B2B40    <- x/B2B0_target
    #   
    #   # gamma is the environmental sensitivity parameter from vulnerability analyses
    #   if(B2B40>1.){
    #     if(gamma<B2B40){
    #       maxFabc=Flim*(exp(-gamma*(B2B40-1)))
    #     }
    #   }else{
    #     if(alpha<B2B40){
    #       maxFabc=Flim*((B2B40-alpha)/(1.-alpha))
    #     }else{
    #       maxFabc=0.0
    #     }
    #   }
    #   if(B2B40<=(B2B0_lim/B2B0_target))
    #     maxFabc=0.0
    #   return(maxFabc)
    # }
