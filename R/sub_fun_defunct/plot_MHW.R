#'
#' Kirstin Holsman
#' ACLIM2
#' plot_MHW.R
#' 

plot_MHW <- function( datIN, yr_range = c(1968,2026),   subtitleIN,
                      titleIN,
                      alpha2 = .1, simIN = NULL,
                      scenIN = NULL,gcmIN = NULL){
  if(is.null(simIN))
    simIN <- unique(datIN$sim)
  if(is.null(scenIN))
    scenIN <- unique(datIN$scen)
  if(is.null(gcmIN))
    gcmIN <- unique(datIN$GCM)
  minyr <- yr_range[1]
  maxyr <- yr_range[2]
  
  subdat     <- datIN%>%filter(year>minyr,year<maxyr, sim%in%simIN, GCM%in%gcmIN, scen%in%scenIN)%>%unique()
  mhw_cols   <- RColorBrewer::brewer.pal(6,"YlOrRd")[2:6]
  p <- ggplot(subdat)+
    geom_line(aes(x= mnDate,y = mnval),color="gray",alpha=1,linetype = "dashed")+
    geom_line(aes(x= mnDate,y = Category1),linetype = "dashed",color=mhw_cols[1],alpha=alpha2)+
    geom_line(aes(x= mnDate,y = Category2),linetype = "dashed",color=mhw_cols[2],alpha=alpha2)+
    geom_line(aes(x= mnDate,y = Category3),linetype = "dashed",color=mhw_cols[3],alpha=alpha2)+
    geom_line(aes(x= mnDate,y = Category4),linetype = "dashed",color=mhw_cols[4],alpha=alpha2)+
    geom_line(aes(x= mnDate,y = Category5),linetype = "dashed",color=mhw_cols[5],alpha=alpha2)+
    theme_minimal()+
    ggtitle(titleIN,subtitle = subtitleIN)+
    geom_line(aes(x= mnDate,y= val_use, color = GCM), alpha=.8)+
    geom_ribbon(data = subdat, aes(ymin = Category1, ymax = plotdat1, x=mnDate, fill = "Category 1"),color=NA)+
    geom_ribbon(data = subdat, aes(ymin = Category2, ymax = plotdat2, x=mnDate, fill = "Category 2"),color=NA)+
    geom_ribbon(data = subdat, aes(ymin = Category3, ymax = plotdat3, x=mnDate, fill = "Category 3"),color=NA)+
    geom_ribbon(data = subdat, aes(ymin = Category4, ymax = plotdat4, x=mnDate, fill = "Category 4"),color=NA)+
    geom_ribbon(data = subdat, aes(ymin = Category5, ymax = plotdat5, x=mnDate, fill = "Category 5"),color=NA)+
    
    facet_grid(GCM~scen)+scale_color_viridis_d(begin =0,end =.6)+
    ylab(expression(""*degree*C))+
    scale_fill_manual(values = RColorBrewer::brewer.pal(6,"YlOrRd")[2:6], name="MHW")
  p
  return(p)
}


#'
#' Kirstin Holsman
#' ACLIM2
#' plot_MHW.R
#' 

plot_anomly <- function( datIN, yr_range = c(1968,2026),   subtitleIN,
                      titleIN,
                      alpha2 = .1, simIN = NULL,
                      scenIN = NULL,gcmIN = NULL){
  if(is.null(simIN))
    simIN <- unique(datIN$sim)
  if(is.null(scenIN))
    scenIN <- unique(datIN$scen)
  if(is.null(gcmIN))
    gcmIN <- unique(datIN$GCM)
  minyr <- yr_range[1]
  maxyr <- yr_range[2]
  
  subdat     <- datIN%>%filter(year>minyr,year<maxyr, sim%in%simIN, GCM%in%gcmIN, scen%in%scenIN)%>%unique()
  mhw_cols   <- RColorBrewer::brewer.pal(6,"YlOrRd")[2:6]
  cold_cols  <- RColorBrewer::brewer.pal(6,"Blues")[2:6]
  p <- ggplot(subdat)+
    geom_line(aes(x= mnDate,y = mnval),color="gray",alpha=1,linetype = "dashed")+
    geom_line(aes(x= mnDate,y = Category1),linetype = "dashed",color=mhw_cols[1],alpha=alpha2)+
    geom_line(aes(x= mnDate,y = Category2),linetype = "dashed",color=mhw_cols[2],alpha=alpha2)+
    geom_line(aes(x= mnDate,y = Category3),linetype = "dashed",color=mhw_cols[3],alpha=alpha2)+
    geom_line(aes(x= mnDate,y = Category4),linetype = "dashed",color=mhw_cols[4],alpha=alpha2)+
    geom_line(aes(x= mnDate,y = Category5),linetype = "dashed",color=mhw_cols[5],alpha=alpha2)+
    
    geom_line(aes(x= mnDate,y = Category_neg1),linetype = "dashed",color=cold_cols[1],alpha=alpha2)+
    geom_line(aes(x= mnDate,y = Category_neg2),linetype = "dashed",color=cold_cols[2],alpha=alpha2)+
    geom_line(aes(x= mnDate,y = Category_neg3),linetype = "dashed",color=cold_cols[3],alpha=alpha2)+
    geom_line(aes(x= mnDate,y = Category_neg4),linetype = "dashed",color=cold_cols[4],alpha=alpha2)+
    geom_line(aes(x= mnDate,y = Category_neg5),linetype = "dashed",color=cold_cols[5],alpha=alpha2)+
    theme_minimal()+
    ggtitle(titleIN,subtitle = subtitleIN)+
    geom_line(aes(x= mnDate,y= val_use, color = GCM), alpha=.8)+
    geom_ribbon(data = subdat, aes(ymin = Category1, ymax = plotdat1, x=mnDate, fill = "a) Category 1"),color=NA)+
    geom_ribbon(data = subdat, aes(ymin = Category2, ymax = plotdat2, x=mnDate, fill = "b) Category 2"),color=NA)+
    geom_ribbon(data = subdat, aes(ymin = Category3, ymax = plotdat3, x=mnDate, fill = "c) Category 3"),color=NA)+
    geom_ribbon(data = subdat, aes(ymin = Category4, ymax = plotdat4, x=mnDate, fill = "d) Category 4"),color=NA)+
    geom_ribbon(data = subdat, aes(ymin = Category5, ymax = plotdat5, x=mnDate, fill = "e) Category 5"),color=NA)+
    
    geom_ribbon(data = subdat, aes(ymin = Category_neg1, ymax = plotdatNeg1, x=mnDate, fill = "f) Category -1"),color=NA)+
    geom_ribbon(data = subdat, aes(ymin = Category_neg2, ymax = plotdatNeg2, x=mnDate, fill = "g) Category -2"),color=NA)+
    geom_ribbon(data = subdat, aes(ymin = Category_neg3, ymax = plotdatNeg3, x=mnDate, fill = "h) Category -3"),color=NA)+
    geom_ribbon(data = subdat, aes(ymin = Category_neg4, ymax = plotdatNeg4, x=mnDate, fill = "i) Category -4"),color=NA)+
    geom_ribbon(data = subdat, aes(ymin = Category_neg5, ymax = plotdatNeg5, x=mnDate, fill = "j) Category -5"),color=NA)+
    
    facet_grid(GCM~scen)+scale_color_viridis_d(begin =0,end =.6)+
    ylab(expression(""*degree*C))+
    scale_fill_manual(values = c(mhw_cols,cold_cols), name="MHW")
  p
  return(p)
}