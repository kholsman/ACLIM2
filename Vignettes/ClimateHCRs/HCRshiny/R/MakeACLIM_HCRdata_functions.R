#'
#' Load ACLIM HCRs.R
#' 
#' K. Holsman 2025
#' 
#' 
#' 
#' 

# ------

library(shiny)
library(ggplot2)
library(dplyr)
library(viridis)
#library(bslib)
library(plotly)
library(reshape)

# --- functions:
# Define helper functions
inv.logit <- function(x){ 
  exp(x)/(1+exp(x))
}

logit <- function(p){ 
  log(p/(1-p))
}


# Function to plot HCR curves
plot_HCR_shiny <- function(dataIN,
                           baseDataIN = baseData,
                           showbase = T,
                           B2B0_ref = NULL,
                           wrapit = F,
                           plotTitle = "Harvest Control Rule" ,
                           ylim = c(0,1.3) , 
                           xlim = c(0,0.6) ,
                           ncolIN = 1 ){
  
  #dataIN2 <- left_join(dataIN,col_lineIN)
  baseData <- baseDataIN
  dataIN2  <- dataIN
  # col2     <- dataIN2%>%select(HCR,col,line, size)%>%distinct()
  B2B0_target <- dataIN$B2B0_target[1]
  
  plotout <- 
    ggplot(dataIN2)+
    geom_vline(aes(xintercept=B2B0_target),linetype="dashed",size=1.1, color="gray")
  
  if(showbase)
    plotout <- plotout +
    geom_line(data=baseData,aes(x=B2B0,y=F_adj),color="gray",linetype = "solid", size= .7)
  
  plotout <- plotout +
    geom_line(aes(x=B2B0,y=F_adj,color=HCR,linetype = HCR, size= HCR))
  
  if(!is.null(B2B0_ref)){
    
    plotout <- plotout +
      geom_point(data =plotdat%>%filter(B2B0 == B2B0_ref), 
                 aes(x=B2B0,y=F_adj,color=HCR,size=2))
  }
  
  plotout <- plotout +
    #facet_wrap(HCRscen~.,ncol=ncolIN)+
    coord_cartesian(ylim = c(ylim[1],ylim[2]),
                    xlim = c(xlim[1],xlim[2]))+   
    theme_minimal()+    
    scale_color_manual(values = setNames(dataIN$col, dataIN$HCR)) +
    scale_linetype_manual(values = setNames(dataIN$line, dataIN$HCR)) +
    scale_size_manual(values = setNames(dataIN$size, dataIN$HCR)) +
    #labs(x = expression(B/B[0]), y = expression(F/F[ABC]), title = plotTitle) +
    labs(x = "B/B0", y = "F_adj", title = plotTitle) +
    theme(legend.position = "bottom",
          legend.title = element_blank(),
          plot.title = element_text(hjust = 0.5))
  
  
  
  if(wrapit)
    plotout <- plotout + facet_wrap(HCRscen~.,ncol=ncolIN)+
    theme(legend.position = "bottom",
          legend.title = element_blank(),
          plot.title = element_text(hjust = 0.5))
  
  
  return(plotout)
}


# HCR function from ACLIM (mimicking the one from your source file)
source("R/HCR_ACLIM.R")
# read in HCRpar 
HCRpar     <- readxl::read_xlsx(file.path("data","HCR_par_shiny.xlsx"),col_names=T)%>%data.frame()


B0    <- 3e6  # hypothetical B0 from the stock assessment in 2015
B     <- seq(0,1.2,.001)*B0
B2B0  <- B/B0
Fabc  <- .3 # hypothetical F ABC as determined from the model

HCRset         <- HCRpar$HCR_sub%>%unique()
HCR_levels     <- HCRpar$HCR_sub |> unique()
HCRscen_levels <- paste0("HCR",HCRpar$HCR |> unique())
subtxt_levels  <- HCRpar$sub |> unique()
colset         <- viridis(length(HCRscen_levels), 
                          option = "mako", direction = -1,  begin = .15, end = .9)
lineset       <- c("solid","dashed","dotted","solid")
linesize      <- c(1,1,1,.7)
# test the data inputs to make sure they are correct:
B0    <- 3e6  # hypothetical B0 from the stock assessment in 2015
B     <- seq(0,1.2,.001)*B0
B2B0  <- B/B0
sp_tab <- data.frame(Species = c("Species1","Species2","Species3"),
                     sp = c("pollock","P. cod","atf"),sp_num = c(1:3))

# col_line <- data.frame(HCR = factor(HCR_levels,levels=HCR_levels),
#                        HCRscen = factor(substr(HCR_levels,1,4),levels=HCRscen_levels),
#                        subtxt  =  factor(substr(HCR_levels,5,5),levels=subtxt_levels))

HCRnm_nm   <- lapply(strsplit(HCR_levels,split=":"),"[[",1)%>%unlist()
HCRnum     <- lapply(strsplit(HCRnm_nm,split="HCR"),"[[",2)%>%unlist()
HCR_subtxt <- substr(HCRnum,1,nchar(HCRnum)-1)

col_line <- data.frame(HCR = factor(HCR_levels,levels=HCR_levels),
                       HCRscen = factor(paste0("HCR",substr(HCRnum,1,nchar(HCRnum)-1)),levels=HCRscen_levels),
                       subtxt  = factor( substr(HCRnum,nchar(HCRnum),nchar(HCRnum)),levels=subtxt_levels))


col_line$col  <- colset[as.numeric(col_line$HCRscen)]
col_line$line <- lineset[as.numeric(col_line$subtxt)]
col_line$size <- linesize[as.numeric(col_line$subtxt)]

col_in  <- col_line$HCR; names(col_in)<-col_line$col  
line_in <- col_line$HCR; names(line_in)<-col_line$line  
txt2num<-function(x){
  if(is.character(x))
    return(eval(parse(text=x)))
  else
    return(x)
}

baseData <- data.frame(B2B0=B2B0, F_adj = unlist(lapply(B2B0, ACLIM_HCR, type=1,
                                                        alpha = 0.05, B2B0_lim = 0.2, B2B0_target=0.4)),
                       alpha = 0.05, B2B0_lim = 0.2, B2B0_target=0.4)
cov_val <- 2.4
for(hh in 1:length(HCRset)){
  
  sub    <- HCRpar%>%filter(HCR_sub==HCRset[hh])
  HCRtmp <- sub$HCR[1]
  HCRsub <- sub$sub[1]
  sub    <- reshape::melt(sub[,1:4], id.vars = "Parm", 
                 variable_name = "Species")%>%left_join(sp_tab,by = join_by(Species))
  
  sub <- sub%>%
    rowwise()%>%
    mutate(value2 = txt2num(value))%>%
    select(-value)%>%dplyr::rename(value = value2)
  sub <- reshape2::dcast(sub%>%select(Parm,Species,value), Species~Parm,  )%>%
    dplyr::rename(
    alpha=alpha_ABC,B2B0_lim = minBlimMult,cov=hcr_cov, B2B0_target =Btarget)
  sub$type <- HCRtmp
  sub$cov <- cov_val
  # if(hh==9)
  #   sub$cov <- -3
  
  
  
  for(i in 1: dim(sub)[1]){
    plotdat1 <- suppressWarnings(
      data.frame(B2B0 = B2B0,
                 F_adj = unlist( lapply (B2B0, ACLIM_HCR,
                                         type = HCRtmp,
                                         alpha =  sub$alpha[i],
                                         log_gamma = sub$log_gamma[i],
                                         omega1 = sub$omega1[i],
                                         omega2 = sub$omega2[i],
                                         omega3 = sub$omega3[i],
                                         log_theta = sub$log_theta[i],
                                         B2B0_lim = sub$B2B0_lim[i],
                                         B2B0_target = sub$B2B0_target[i],
                                         cov = sub$cov[i],
                                         Flim = 1)),
                 sub[i,],
                 HCR = HCRset[hh],
                 HCRscen = paste0("HCR",HCRtmp),
                 subtxt = HCRsub))
    
    if(i==1){
      plotdat_all <- plotdat1
    }else{
      plotdat_all <- rbind(plotdat_all,plotdat1)
    }
    rm(plotdat1)
  }
  if(hh == 1){
    plotdat_out <- plotdat_all
  }else{
    plotdat_out <- rbind(plotdat_out,plotdat_all)
  }
  rm(plotdat_all)
}

plotdat_out <- plotdat_out%>%filter(Species == "Species1")

plotdat_all <- plotdat_out%>%left_join( col_line, by = c("HCR", "HCRscen", "subtxt"))

if(1 ==10){
  if(!dir.exists("data")) dir.create("data")
  save(plotdat_all, file = file.path("data","plotdat_all.rds"))
  save(HCR_levels, file = file.path("data","HCR_levels.rds"))
  save(col_line, file = file.path("data","col_line.rds"))
  save(HCRscen_levels, file = file.path("data","HCRscen_levels.rds"))

}


