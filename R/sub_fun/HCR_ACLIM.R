#'HCR_ACLIM.R
#'
#'@description
#' HCR forms developed during the Alaska Climate Integrated Modeling Project (ACLIM) phase 2
#' 2023 sprint. HCRS were evaluated in a series of MSEs for that project to evaluate climate
#' linked / smart harvest control rules for the NPFMC
#' 
#' @param x vector of biomass
#' @param alpha  lower limit of biomass cutoff (e.g., B_5% = 0.05); determines the slope of the HCR
#' @param gamma  alternative slope of the HCR; also determines the slope of the HCR when B>Btarget in HCR 5
#' @param B2B0_lim lower biomass threshold (e.g., B_20% = 0.2); 
#' @param B2B0_target Target biomass/MSY proxy
#' @param Flim input of F harvest mortality rate to apply the HCR to
#' 
#' @export
#' 
#' @example 
#' 
#' B0    <- 3e6  # hypothetical B0 from the stock assessment in 2015
#' B     <- seq(0,1.2,.001)*B0
#' B2B0  <- B/B0
#' Fabc  <- .3 # hypothetical F ABC as determined from the model
#' 
#' # Fadjustment to F_abc, i.e., sloping HCR
#' F_adj <- unlist(lapply(B2B0, HCR, alpha = 0.05, B2B0_lim = 0.2, B2B0_target=0.4))


HCR <-function(x, alpha=0.05, B2B0_lim = 0.2, B2B0_target=0.4,Flim=1){
  B2B40    <- x/B2B0_target
  if(B2B40>1.){
    maxFabc=Flim
  }else{
    if(alpha<B2B40){
      maxFabc=Flim*((B2B40-alpha)/(1.-alpha))
    }else{
      maxFabc=0.0
    }
  }
  if(B2B40<=(B2B0_lim/B2B0_target))
    maxFabc=0.0
  return(maxFabc)
}


HCR2 <-function(x, alpha=0.05, gamma = .2, B2B0_lim = 0.2, B2B0_target=0.4,Flim=1){
  B2B40    <- x/B2B0_target
  
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
  if(B2B40<=(B2B0_lim/B2B0_target))
    maxFabc=0.0
  return(maxFabc)
}