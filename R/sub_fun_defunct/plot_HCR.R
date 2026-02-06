#'
#'
#'plot_HCR.R
#'
#'

plot_HCR <- function(dataIN,baseDataIN = baseData, ylim = c(0,1.3) , col_lineIN = col_line,ncolIN = 1,xlim = NULL ){
  
  dataIN2 <- left_join(dataIN,col_lineIN)
  col2    <- dataIN2%>%select(HCR,col,line, size)%>%distinct()

  plotout <- 
    ggplot(dataIN2)+
    geom_vline(aes(xintercept=B2B0_target),linetype="dashed",size=1.1, color="gray")
  
  if(!is.null(baseDataIN))
    plotout <- plotout +
    geom_line(data=baseDataIN,aes(x=B2B0,y=F_adj),color="gray",
              linetype = "solid", size= .7)
  
  plotout <- plotout +
    geom_line(aes(x=B2B0,y=F_adj,color=HCR,linetype = HCR, size= HCR))+
    facet_wrap(HCRscen~.,ncol=ncolIN)+
    coord_cartesian(ylim = c(ylim[1],ylim[2]))+
    
    theme_minimal()+    
    scale_color_manual(values = col2$col)+
    scale_size_manual(values = col2$size)+   
    scale_linetype_manual(values = col2$line)
  
  if(!is.null(xlim))
    plotout <- plotout + coord_cartesian(xlim = c(xlim[1],xlim[2]))
 
    
  return(plotout)
}

