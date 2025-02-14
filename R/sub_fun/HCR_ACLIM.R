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
#' @param gamma default is 0; decay rate value is between 0 and 1
#' @param omega1 covariate linked penalty on Flim for HCR 7
#' @param omega2 covariate linked penalty on B2B0_lim and B2B0_target for HCR 7
#' @param B2B0_lim lower biomass threshold (e.g., B_20% = 0.2); 
#' @param B2B0_target Target biomass/MSY proxy
#' @param Flim input of F harvest mortality rate to apply the HCR to
#' 
#' @export
#' 
    ACLIM_HCR <-function(B2B0,
                         type    = 1,
                         alpha   = 0.05, 
                         gamma   = 0, 
                         omega1  = 0,  
                         omega2  = 0, 
                         B2B0_lim = 0.2, 
                         B2B0_target = 0.4,
                         Flim   = 1,
                         cov    = NULL){
      
      if(!type%in%c(1:7)){
        stop("type must be an integer between 1 and 7")
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
        
        
        # omega 1 and 2 are environmental effective parameters from retro analyses
        # paul's HCR, cov is vector of scaled covariate effects on ref points
        B2B0_target <- B2B0_target*exp(-omega2*cov)
        B2B0_lim    <- B2B0_lim*exp(-omega2*cov)
        B2B40       <- B2B0/B2B0_target
        if(B2B40>1.){
          maxFabc = Flim*exp(-omega1*cov)
        }else{
          if(alpha<B2B40){
            maxFabc = Flim*((B2B40-alpha)/(1.-alpha))*exp(-omega1*cov)
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
