
# switches 
hind_yrs    <- 1991:2021   # define the years of your estimation model
fut_yrs     <- 2022:2100   # define the years of your projections

# preview possible variables
load(paste0("Data/out/K20P19_CMIP6/allEBS_means/ACLIM_annual_hind_mn.Rdata"))
varall  <- unique(ACLIM_annual_hind$var)
varall


# get each variable, convert to TS and rbind

plotbasin <- "SEBS"

#CMIPS <- c("K20P19_CMIP6","K20P19_CMIP5")
CMIPS <- c("K20P19_CMIP6")

for(c in 1:length(CMIPS)){
  
  # first for annual mean values:
  varlist <- c("Cop_integrated","NCaO_integrated","NCaS_integrated","EupO_integrated",
               "EupS_integrated","MZL_integrated","PhL_integrated","PhS_integrated")
  typeIN <- "monthly"
  
  load(paste0("Data/out/",CMIPS[c],"/allEBS_means/ACLIM_",typeIN,"_hind_mn.Rdata"))
  load(paste0("Data/out/",CMIPS[c],"/allEBS_means/ACLIM_",typeIN,"_fut_mn.Rdata"))
  eval(parse(text = paste0("dhind <- ACLIM_",typeIN,"_hind")))
  eval(parse(text = paste0("dfut  <- ACLIM_",typeIN,"_fut")))
  
  # rescale the data using mean of the hind
  tmphind    <- dhind%>%
    dplyr::filter(var%in%varlist,basin==plotbasin,year%in%hind_yrs)%>%
    dplyr::select(var,basin,year,mo, jday,mnDate,mn_val,
                  mnVal_hind,sdVal_hind, sim,gcmcmip,CMIP,GCM,scen,sim_type ,units,long_name)%>%
    dplyr::mutate(bc = "bias corrected",
                  GCM_scen = paste0(GCM,"_",scen),
                  mn_val_scaled = (mn_val-mnVal_hind )/sqrt(sdVal_hind))
  
  tmpfut    <- dfut%>%
    dplyr::filter(var%in%varlist,basin==plotbasin,year%in%fut_yrs)%>%
    dplyr::select(var,basin,year,mo, jday,mnDate,val_biascorrected, 
                  mnVal_hind,sdVal_hind, sim,gcmcmip,CMIP,GCM,scen,sim_type ,units,long_name)%>%
    dplyr::rename(mn_val = val_biascorrected)%>%
    dplyr::mutate(bc = "bias corrected",
                  GCM_scen = paste0(GCM,"_",scen),
                  mn_val_scaled = (mn_val-mnVal_hind )/sqrt(sdVal_hind))
  
  
  
  # now for monthly mean values:
  # typeIN  <- "monthly"  # for Andy
  # varlist <- c("Cop_integrated","NCaO_integrated","NCaS_integrated","EupO_integrated",
  #              "EupS_integrated","MZL_integrated","PhL_integrated","PhS_integrated")
  # 
  # monthsIN <- c(7,9)  # for Andy
  # load(paste0("Data/out/",CMIPS[c],"/allEBS_means/ACLIM_",typeIN,"_hind_mn.Rdata"))
  # load(paste0("Data/out/",CMIPS[c],"/allEBS_means/ACLIM_",typeIN,"_fut_mn.Rdata"))
  # eval(parse(text = paste0("dhind <- ACLIM_",typeIN,"_hind")))
  # eval(parse(text = paste0("dfut  <- ACLIM_",typeIN,"_fut")))
  # 
  # 
  # # rescale the data using mean of the hind
  # tmphind2    <- dhind%>%
  #   dplyr::filter(var%in%varlist,basin==plotbasin,year%in%hind_yrs,mo%in%monthsIN)%>%
  #   dplyr::mutate(var = paste0(var,"_",mo))%>%
  #   dplyr::select(var,basin,year,mo,jday,mnDate,mn_val, 
  #                 mnVal_hind,sdVal_hind, sim,gcmcmip,CMIP,GCM,scen,sim_type ,units,long_name)%>%
  #   dplyr::mutate(bc = "bias corrected",
  #                 GCM_scen = paste0(GCM,"_",scen),
  #                 mn_val_scaled = (mn_val-mnVal_hind )/sqrt(sdVal_hind))
  # 
  # tmpfut2    <- dfut%>%
  #   dplyr::filter(var%in%varlist,basin==plotbasin,year%in%fut_yrs,mo%in%monthsIN)%>%
  #   dplyr::mutate(var = paste0(var,"_",mo))%>%
  #   dplyr::select(var,basin,year,mo, jday,mnDate,val_biascorrected, 
  #                 mnVal_hind,sdVal_hind, sim,gcmcmip,CMIP,GCM,scen,sim_type ,units,long_name)%>%
  #   dplyr::rename(mn_val = val_biascorrected)%>%
  #   dplyr::mutate(bc = "bias corrected",
  #                 GCM_scen = paste0(GCM,"_",scen),
  #                 mn_val_scaled = (mn_val-mnVal_hind )/sqrt(sdVal_hind))
  #loop over CMIPS
   if(c ==1){
    hind  <- tmphind #rbind(tmphind,tmphind2)
    fut   <- tmpfut #rbind(tmpfut,tmpfut2)
   }else{
     hind  <- tmphind #rbind(hind,tmphind,tmphind2)
     fut   <- tmpfut #rbind(fut,tmpfut,tmpfut2)
   }
  
}

# An example with largeZoop 
varIN <- "Cop_integrated"
# for the july annual largeZoop index
m26cop_dat   <- rbind(hind%>%dplyr::filter(var==varIN),
               fut%>%dplyr::filter(var==varIN,GCM_scen=="miroc_ssp126"))
dim(m26dat)
head(m26dat)
tail(m26dat)


# plot bias corrected values
ggplot(m26cop_dat)+geom_line(aes(x=mnDate,y=mn_val))
# or plot scaled (z-scored data and bias corrected values)
ggplot(m26cop_dat)+geom_line(aes(x=mnDate,y=mn_val_scaled))


# An example with monthly largeZoop
varIN <- "temp_bottom5m"
# for the july annual largeZoop index
dat   <- rbind(hind%>%dplyr::filter(var==varIN),
               fut%>%dplyr::filter(var==varIN,GCM_scen=="miroc_ssp126"))

# plot bias corrected values
ggplot(dat)+geom_line(aes(x=mnDate,y=mn_val,color=GCM_scen))
# or plot scaled (z-scored data and bias corrected values)
ggplot(dat)+geom_line(aes(x=mnDate,y=mn_val_scaled,color=GCM_scen))

