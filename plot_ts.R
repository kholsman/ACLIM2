#'-------------------------------------
#' plot_ts.R
#'-------------------------------------
#' PLot ACLIM covariates using GGplot
#'
#' @param dat is a data.frame with t=date and dat=data to plot
#' @param plotSet is the columns of dat that you want to plot (col=1 is the date, 2:ncol are options)
#' @param lwdd vector of the line widths; length of the projection simulation set + 1 for hindcast (dim of dat)
#' @param ltyy vector of the line types; length of the projection simulation set + 1 for hindcast (dim of dat)
#' @param ylab y axis label
#' @param xlab x axis label
#' @param title title for the graph
#' @param coll vector colors for each line; length of the projection simulation set + 1 for hindcast (dim of dat)
#' @param esnmCol colors for each ensemble polygon
#' @param esnmSet is a list with the set for each ensemble groups
#' @param alpha vector of transparencies of the ensemble mean; corresponds to number quantiles
#' @param add0line Add a horizontal line at 0?
#' @keywords Temperature, plot, data, ACLIM
#' @export 
#' @examples
#' 
GGplot_aclimTS<-function(
  dataIN,
  plotSet=list(c(2,rcp45_n),c(2,rcp85NoBio_n)),
  h=3,
  w=4.75,
  sublab=TRUE,
  sublab_adj=0.95,
  lgnpos= "bottom",  #c(.95,1.12),
  fn="BT",
  lwdd=rep(2,13),
  coll=c(colors()[491],col2(6)[c(1,3,5)],col3(6)[c(2,3,6)]),
  ltyy=rep("solid",7),
  ylabb=expression(paste("Bottom temperature",'( '^{o},"C)")),
  xlabb="Year", 
  xlimmIN = NULL,
  titleIN="",
  captionIN="",
  subtitleIN="",
  projLine=2017,
  threshold = 2.5,
  tline=5,
  talpha=.5,
  smooth_yr=20,
  add0line=FALSE,
  plot_marginIN= c(1, 1, 1, 1),
  plot_title_marginIN = 0,
  subtitle_marginIN = 0,
  subtitle_faceIN = "bold",
  caption_marginIN = 0){
  
  dev.new(height=h,width=w)
  make_plotdat<-function(datIN=dat){
    
    mlt<-reshape::melt(datIN[,1+plotSet[[1]]])
    mlt$Year<-datIN[,1]
    mlt$rcp=" RCP 4.5 "
    mlt$num<-factor(mlt$variable,levels=simnames[c(plotSet[[1]],plotSet[[2]][-1])])
    mlt$col<-coll[mlt$num]
    mlt$lty<-ltyy[mlt$num]
    mlt2<-reshape::melt(datIN[,1+plotSet[[2]]])
    mlt2$Year<-datIN[,1]
    mlt2$rcp=" RCP 8.5 "
    mlt2$num<-factor(mlt2$variable,levels=simnames[c(plotSet[[1]],plotSet[[2]][-1])])
    mlt2$col<-coll[mlt2$num]
    mlt2$lty<-ltyy[mlt2$num]
    # mlt2$col<-collIN[length(plotSet[[1]])+2:length(plotSet[[2]])]
    # mlt2$lty<-ltyyIN[length(plotSet[[1]])+2:length(plotSet[[2]])]
    dt<-rbind(mlt,mlt2)
    dt$rcp<-factor(dt$rcp,levels=c(" RCP 4.5 "," RCP 8.5 "))
    
    return(dt)
  }
  dt      <-   make_plotdat(dat)
  m_dat   <-   dat
  dat[,2] <-   NA*dat[,2]
  for(i in 3:dim(dat)[2])
    m_dat[,i]  <-  as.numeric(ma2(x=(dat[,i]),n=smooth_yr))
  m_dat2  <-  dat
  for(i in 2:dim(dat)[2])
    m_dat2[,i]  <-  as.numeric(ma2(x=(dat[,i]),n=smooth_yr))
  
  
  m_dt    <-  make_plotdat(m_dat)
  m_dt2   <-  make_plotdat(m_dat2)
  
  dt$zeroline     <- 0;    dt$projLine    <- projLine
  m_dt$zeroline   <- 0;    m_dt$projLine  <- projLine
  m_dt2$zeroline  <- 0;    m_dt2$projLine <- projLine
  
  p <-     ggplot(data=dt, aes(x = Year, y = value),colour=variable)
  p <- p + facet_grid(~rcp) 
  if(add0line)   p <- p + geom_hline(data=dt, aes(yintercept = zeroline),col="lightgray")
  p <- p + geom_vline(data=dt, aes(xintercept=projLine),col="gray",size=1,linetype="dashed") 
  if(!is.null(threshold)) p <- p + geom_hline (data=dt, aes(yintercept=threshold),col="gray",size=tline, alpha =talpha) 
  p <- p + geom_line(aes(x = Year, y = value,group=variable,colour=variable,linetype=variable),alpha=.6,inherit.aes=TRUE,size=.4)
  # add moving average:
  p <- p + geom_line(data=m_dt,aes(x = Year, y = value,group=variable,colour=variable,linetype=variable),alpha=1,inherit.aes=FALSE,size=.75)
  p <- p + geom_line(data=m_dt2,aes(x = Year, y = value,group=variable,colour=variable,linetype=variable),alpha=1,inherit.aes=FALSE,size=.75)
  
  p <- p + scale_color_manual(values=c(coll))
  p <- p + scale_linetype_manual(values=ltyy)
  p
  
  p<- p + theme_light() +
    labs(x=NULL, y=NULL,
         title=titleIN,
         subtitle=subtitleIN,
         caption=captionIN) +
    theme(plot.subtitle=element_text(margin=margin(b=20))) +
    theme(legend.title=element_blank()) +
    theme(legend.position=lgnpos) +
    theme(legend.key.width = unit(.5, "cm")) +
    theme(legend.text=element_text(size=5)) +
    theme(legend.key.size=unit(.01, "cm")) +
    labs(x= xlabb,y=ylabb)+
    #labs(tag=letters(1:6)) +
    theme(plot.margin=margin(t = 10, r = 10, b = 10, l =10)) 
  
  p<- p+ theme_kir_EBM(sub_title_size=12,
                       sub_title_just="l",
                       plot_margin = margin(plot_marginIN),
                       plot_title_margin = plot_title_marginIN,
                       subtitle_margin = subtitle_marginIN,
                       caption_margin = caption_marginIN,
                       axis_title_just = "cm") +
    labs(x=xlabb, y= ylabb)+
    theme(plot.subtitle=element_text(face=subtitle_faceIN)) +
    theme(legend.title=element_blank()) 
  p <- p + theme(legend.position=lgnpos)
  
  if(!is.null(sublab)){
    ann_text<-dt
    ann_text[-(1:2),]<-NA
    ann_text[1:2,]$value<-max(dt$value,na.rm=T)
    ann_text[1:2,]$Year<-min(dt$Year,na.rm=T)
    ann_text[1:2,]$rcp<-factor(levels(dt$rcp),levels=levels(dt$rcp))
    ann_text$lab2<-NA
    ann_text[1:2,]$lab2<-letters[1:2]
    ann_text<- na.omit(ann_text)
    
    p <-  p + geom_text(data = ann_text,aes(x = Year, y =value *sublab_adj,label = lab2,fontface=2))
  }
  p
}
