#'
#'
#'
#'get_MHW.R
#'
#'K. Holsman
#'ACLIM2 code
#'
#'Generates MHW from ROMSNPZ Level 3 weekly data
#'2024
#'

get_MHW <- function(datIN = df_NEBS_BT$dat,
                    ref_yearsIN = ref_years, 
                    hindsim = "ACLIMregion_B10K-K20P19_CORECFS"){
  
  dfnew <- datIN
  
  decades  <- seq(1960,2110,10)
  quarters <- seq(1900,2150,25)
  time_df  <- data.frame(
    year = c(1970:2100),
    decade = NA,
    quarter = NA)
  
  for(tt in 1:length(decades)){
    rr <- which(time_df$year<decades[tt+1]&time_df$year>=decades[tt]) 
    time_df$decade[rr] <- decades[tt]
  }
  for(tt in 1:length(quarters)){
    rr <- which(time_df$year<quarters[tt+1]&time_df$year>=quarters[tt]) 
    time_df$quarter[rr] <- quarters[tt]
  }
  climatology <- dfnew%>%
    filter(year%in%ref_yearsIN, sim==hindsim)%>%
    select(year,season,mo, wk, basin, var,val_use)%>%
    unique()%>%group_by(wk, basin, var)%>%
    summarise(mnval = mean(val_use,na.rm=T),
              sdval  = sd(val_use,na.rm=T))%>%
    mutate(Category1 = mnval+sdval,
           Category2 = mnval+2*sdval,
           Category3 = mnval+3*sdval,
           Category4 = mnval+4*sdval,
           Category5 = mnval+5*sdval)%>%
    mutate(Category_neg1 = mnval-sdval,
           Category_neg2 = mnval-2*sdval,
           Category_neg3 = mnval-3*sdval,
           Category_neg4 = mnval-4*sdval,
           Category_neg5 = mnval-5*sdval)
  
  dfnew<- dfnew%>%left_join(time_df)%>%
    # now join with climatology
    left_join(climatology)%>%
    # now find the plotdata
    rowwise()%>%mutate(
      plotdat1 = max(Category1,val_use),
      plotdat2 = max(Category2,val_use),
      plotdat3 = max(Category3,val_use),
      plotdat4 = max(Category4,val_use),
      plotdat5 = max(Category5,val_use), 
      
      plotdatNeg1 = min(Category_neg1,val_use),
      plotdatNeg2 = min(Category_neg2,val_use),
      plotdatNeg3 = min(Category_neg3,val_use),
      plotdatNeg4 = min(Category_neg4,val_use),
      plotdatNeg5 = min(Category_neg5,val_use))%>%
    mutate(cat5 = ifelse(val_use>=Category5,val_use,0),
           cat4 = ifelse(val_use>=Category4&val_use<Category5,val_use,0),
           cat3 = ifelse(val_use>=Category3&val_use<Category4,val_use,0),
           cat2 = ifelse(val_use>=Category2&val_use<Category3,val_use,0),
           cat1 = ifelse(val_use>=Category1&val_use<Category2,val_use,0),
           catNeg5 = ifelse(val_use<=Category_neg5,val_use,0),
           catNeg4 = ifelse(val_use<=Category_neg4&val_use>Category_neg5,val_use,0),
           catNeg3 = ifelse(val_use<=Category_neg3&val_use>Category_neg4,val_use,0),
           catNeg2 = ifelse(val_use<=Category_neg2&val_use>Category_neg3,val_use,0),
           catNeg1 = ifelse(val_use<=Category_neg1&val_use>Category_neg2,val_use,0)
           )%>%
    ungroup()%>%data.frame()
  
  MHW_decade = dfnew%>%group_by(decade, sim, scen, GCM,basin,var)%>%
    summarize(tot = length(cat1), 
              sumcat1 = length(which(cat1>0)),Category1 = round(sumcat1/tot,4),
              sumcat2 = length(which(cat2>0)),Category2 = round(sumcat2/tot,4),
              sumcat3 = length(which(cat3>0)),Category3 = round(sumcat3/tot,4),
              sumcat4 = length(which(cat4>0)),Category4 = round(sumcat4/tot,4),
              sumcat5 = length(which(cat5>0)),Category5 = round(sumcat5/tot,4),
              
              sumcatNeg1 = length(which(catNeg1>0)),CategoryNeg1 = round(sumcatNeg1/tot,4),
              sumcatNeg2 = length(which(catNeg2>0)),CategoryNeg2 = round(sumcatNeg2/tot,4),
              sumcatNeg3 = length(which(catNeg3>0)),CategoryNeg3 = round(sumcatNeg3/tot,4),
              sumcatNeg4 = length(which(catNeg4>0)),CategoryNeg4 = round(sumcatNeg4/tot,4),
              sumcatNeg5 = length(which(catNeg5>0)),CategoryNeg5 = round(sumcatNeg5/tot,4)
    )%>%data.frame()
  
  MHW_quarter= dfnew%>%group_by(quarter, sim, scen, GCM,basin,var)%>%
    summarize(tot = length(cat1), 
              sumcat1 = length(which(cat1>0)),Category1 = round(sumcat1/tot,4),
              sumcat2 = length(which(cat2>0)),Category2 = round(sumcat2/tot,4),
              sumcat3 = length(which(cat3>0)),Category3 = round(sumcat3/tot,4),
              sumcat4 = length(which(cat4>0)),Category4 = round(sumcat4/tot,4),
              sumcat5 = length(which(cat5>0)),Category5 = round(sumcat5/tot,4),
              
              sumcatNeg1 = length(which(catNeg1>0)),CategoryNeg1 = round(sumcatNeg1/tot,4),
              sumcatNeg2 = length(which(catNeg2>0)),CategoryNeg2 = round(sumcatNeg2/tot,4),
              sumcatNeg3 = length(which(catNeg3>0)),CategoryNeg3 = round(sumcatNeg3/tot,4),
              sumcatNeg4 = length(which(catNeg4>0)),CategoryNeg4 = round(sumcatNeg4/tot,4),
              sumcatNeg5 = length(which(catNeg5>0)),CategoryNeg5 = round(sumcatNeg5/tot,4)
    )%>%data.frame()
  
  return(list(MHW = dfnew, MHW_decade = MHW_decade, MHW_quarter = MHW_quarter))
}

