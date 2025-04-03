#'
#' Load ACLIM HCRs.R
#' 
#' K. Holsman 2025
#' 
#' 
#' 
#' 
# --- functions:
# Define helper functions
inv.logit <- function(x){ 
  exp(x)/(1+exp(x))
}

logit <- function(p){ 
  log(p/(1-p))
}


# HCR function from ACLIM (mimicking the one from your source file)
source("HCR_ACLIM.R")
# Function to plot HCR curves
plot_HCR_shiny <- function(dataIN,
                     showbase = T,
                     B2B0_ref = NULL,
                     wrapit = F,
                     plotTitle = "Harvest Control Rule" ,
                     ylim = c(0,1.3) , 
                     xlim = c(0,0.6) ,
                     ncolIN = 1 ){
  
  #dataIN2 <- left_join(dataIN,col_lineIN)
  baseData <- data.frame(B2B0=B2B0, 
                         F_adj = unlist(lapply(B2B0, 
                                               ACLIM_HCR, 
                                               type=1,
                                               alpha = 0.05, 
                                               B2B0_lim = 0.2, 
                                               B2B0_target=0.4)),
                         alpha = 0.05, B2B0_lim = 0.2, B2B0_target=0.4)
  
  
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



# ------

B0    <- 3e6  # hypothetical B0 from the stock assessment in 2015
B     <- seq(0,1.2,.001)*B0
B2B0  <- B/B0

HCR_levels <-  c("HCR1a: Status Quo",
                 "HCR1b: Status Quo + SSL", 
                 "HCR2a: decline",
                 "HCR2b: lagged recovery",
                 "HCR3a: B50", 
                 "HCR3b: B50 + SSL", 
                 "HCR4a: no MHW",
                 "HCR4b: small MHW",
                 "HCR4c: large MHW",
                 "HCR5a: no sensitivity",
                 "HCR5b: low sensitivity",
                 # "HCR5c: medium sensitivity",
                 "HCR5c: high sensitivity",
                 "HCR6a: no MHW, no sensitivity",
                 "HCR6b: small MHW, low sensitivity",
                 "HCR6c: large MHW, high sensitivity",
                 "HCR7a: max productivity (SQ)",
                 "HCR7b: SR cov effects",
                 "HCR7c: SR cov effects uneven omega",
                 "HCR8a: max productivity (SQ)",
                 "HCR8b: theta set to 0.75")


HCRscen_levels <- paste0("HCR",1:8)
subtxt_levels <- c("a","b","c","d")
colset        <- viridis(length(HCRscen_levels), 
                         option = "mako", direction = -1,  begin = .15, end = .9)
lineset       <- c("solid","dashed","dotted","solid")
linesize      <- c(1,1,1,.7)

col_line <- data.frame(HCR = factor(HCR_levels,levels=HCR_levels),
                       HCRscen = factor(substr(HCR_levels,1,4),levels=HCRscen_levels),
                       subtxt  =  factor(substr(HCR_levels,5,5),levels=subtxt_levels))

col_line$col  <- colset[as.numeric(col_line$HCRscen)]
col_line$line <- lineset[as.numeric(col_line$subtxt)]
col_line$size <- linesize[as.numeric(col_line$subtxt)]

col_in  <- col_line$HCR; names(col_in)<-col_line$col  
line_in <- col_line$HCR; names(line_in)<-col_line$line  

# --- HCR 0 (base SQ)
baseData <- data.frame(B2B0=B2B0, F_adj = unlist(lapply(B2B0, 
                                                        ACLIM_HCR, type=1,
                                                        alpha = 0.05, 
                                                        B2B0_lim = 0.2, 
                                                        B2B0_target=0.4)),
                       alpha = 0.05, B2B0_lim = 0.2, B2B0_target=0.4)
typeIN <- 1
# --- HCR 1 (base SQ)
plotdat1 <- rbind(data.frame(B2B0=B2B0,
                             F_adj = unlist(lapply(B2B0, ACLIM_HCR, type=typeIN,
                                                  alpha = 0.05, B2B0_lim = 0.0, B2B0_target=0.4)), 
                             alpha = 0.05, B2B0_lim = 0.0, B2B0_target=0.4, 
                             HCR = "HCR1a: Status Quo" , HCRscen="HCR1", subtxt = "a"),
                  data.frame(B2B0=B2B0, 
                             F_adj = unlist(lapply(B2B0, ACLIM_HCR, type=typeIN,
                                                   alpha = 0.05, B2B0_lim = 0.2, B2B0_target=0.4)),
                             alpha = 0.05, B2B0_lim = 0.2, B2B0_target=0.4, 
                             HCR = "HCR1b: Status Quo + SSL", HCRscen="HCR1", subtxt = "b"))%>%
  mutate(HCR = factor(HCR,levels=HCR_levels),
         HCRscen = factor(HCRscen,levels=HCRscen_levels),
         subtxt = factor(subtxt,levels=subtxt_levels))#%>%left_join(col_line)

# i <- 1
# p_HCR1 <- plot_HCR(dataIN = plotdat1, baseDataIN = NULL)

# --- HCR 2 
typeIN <- 2
plotdat2 <- rbind(data.frame(B2B0=B2B0,
                             F_adj =unlist(lapply(B2B0, ACLIM_HCR, type=typeIN,
                                                  alpha = 0.05, B2B0_lim = 0.25, B2B0_target=0.4)), 
                             alpha = 0.05, B2B0_lim = 0.25, B2B0_target=0.4, 
                             HCR = "HCR2a: decline" , HCRscen="HCR2", subtxt = "a"),
                  data.frame(B2B0=B2B0, 
                             F_adj = unlist(lapply(B2B0, ACLIM_HCR, type=typeIN,
                                                   alpha = 0.3, B2B0_lim = 0.25, B2B0_target=0.4)),
                             alpha = 0.3, B2B0_lim = 0.25, B2B0_target=0.4, 
                             HCR = "HCR2b: lagged recovery", HCRscen="HCR2", subtxt = "b"))%>%
  mutate(HCR = factor(HCR,levels=HCR_levels),
         HCRscen = factor(HCRscen,levels=HCRscen_levels),
         subtxt = factor(subtxt,levels=subtxt_levels))


# --- HCR 3
typeIN <- 3
plotdat3 <- rbind(data.frame(B2B0=B2B0,
                             F_adj =unlist(lapply(B2B0, ACLIM_HCR, type=typeIN,
                                                  alpha = 0.05, B2B0_lim = 0.0, B2B0_target=0.5)), 
                             alpha = 0.05, B2B0_lim = 0.0, B2B0_target=0.5, 
                             HCR = "HCR3a: B50" , HCRscen="HCR3", subtxt = "a"),
                  data.frame(B2B0=B2B0, 
                             F_adj = unlist(lapply(B2B0, ACLIM_HCR, type=typeIN,
                                                   alpha = 0.05, B2B0_lim = 0.2, B2B0_target=0.5)),
                             alpha = 0.05, B2B0_lim = 0.2, B2B0_target=0.5,
                             HCR = "HCR3b: B50 + SSL", HCRscen="HCR3", subtxt = "b"))%>%
  mutate(HCR = factor(HCR,levels=HCR_levels),
         HCRscen = factor(HCRscen,levels=HCRscen_levels),
         subtxt = factor(subtxt,levels=subtxt_levels))

# --- HCR 4
typeIN <- 4
plotdat4 <- rbind(data.frame(B2B0=B2B0,
                             F_adj =unlist(lapply(
                               B2B0, ACLIM_HCR, type=typeIN,
                               alpha = 0.05, B2B0_lim = 0.2, B2B0_target=0.4)), 
                             alpha = 0.05, B2B0_lim = 0.2, B2B0_target=0.4, 
                             HCR = "HCR4a: no MHW" , HCRscen="HCR4", subtxt = "a"),
                  data.frame(B2B0=B2B0,
                             F_adj = unlist(lapply(B2B0, ACLIM_HCR, type=typeIN,
                                                   alpha = 0.23, B2B0_lim = 0.2, B2B0_target=0.4)),
                             alpha = 0.23, B2B0_lim = 0.2, B2B0_target=0.4, 
                             HCR = "HCR4b: small MHW", HCRscen="HCR4", subtxt = "b"),
                  data.frame(B2B0=B2B0,
                             F_adj = unlist(lapply(B2B0, ACLIM_HCR, type=typeIN,
                                                   alpha = 0.41, B2B0_lim = 0.2, B2B0_target=0.4)),
                             alpha = 0.41, B2B0_lim = 0.2, B2B0_target=0.4, 
                             HCR = "HCR4c: large MHW", HCRscen="HCR4", subtxt = "c"))%>%
  mutate(HCR = factor(HCR,levels=HCR_levels),
         HCRscen = factor(HCRscen,levels=HCRscen_levels),
         subtxt = factor(subtxt,levels=subtxt_levels))

# --- HCR 5
typeIN <- 5
plotdat5 <- rbind(data.frame(B2B0=B2B0,
                             F_adj = unlist(lapply(B2B0, ACLIM_HCR, type=typeIN,
                                                   invlogit_gamma=inv.logit(0), 
                                                   alpha = 0.05, B2B0_lim = 0.2, B2B0_target=0.4)),
                             alpha = 0.05, B2B0_lim = 0.2, B2B0_target=0.4, 
                             HCR = "HCR5a: no sensitivity" , HCRscen="HCR5", subtxt = "a"),
                  data.frame(B2B0=B2B0, 
                             F_adj = unlist(lapply(B2B0, ACLIM_HCR, type=typeIN,
                                                   invlogit_gamma=inv.logit(.1), 
                                                   alpha = 0.05, B2B0_lim = 0.2, B2B0_target=0.4)),
                             alpha = 0.05, B2B0_lim = 0.2, B2B0_target=0.4, 
                             HCR = "HCR5b: low sensitivity", HCRscen="HCR5", subtxt = "b"),
                  data.frame(B2B0=B2B0, 
                             F_adj = unlist(lapply(B2B0, ACLIM_HCR, type=typeIN,
                                                   invlogit_gamma=inv.logit(.7), 
                                                   alpha = 0.05, B2B0_lim = 0.2, B2B0_target=0.4)),
                             alpha = 0.05, B2B0_lim = 0.2, B2B0_target=0.4, 
                             HCR = "HCR5c: high sensitivity", HCRscen="HCR5", subtxt = "c"))%>%
  mutate(HCR = factor(HCR,levels=HCR_levels),
         HCRscen = factor(HCRscen,levels=HCRscen_levels),
         subtxt = factor(subtxt,levels=subtxt_levels))

# --- HCR 6
typeIN <- 6
plotdat6 <- rbind(data.frame(B2B0=B2B0,
                             F_adj = unlist(lapply(B2B0, ACLIM_HCR, type=typeIN,
                                                   invlogit_gamma= inv.logit(0), 
                                                   alpha = 0.05, B2B0_lim = 0.2, B2B0_target=0.4)),
                             alpha = 0.05, B2B0_lim = 0.2, B2B0_target=0.4, 
                             HCR = "HCR6a: no MHW, no sensitivity" , HCRscen="HCR6", subtxt = "a"),
                  data.frame(B2B0=B2B0, 
                             F_adj = unlist(lapply(B2B0, ACLIM_HCR, type=typeIN,
                                                   invlogit_gamma= inv.logit(.1),  
                                                   alpha = 0.2, B2B0_lim = 0.2, B2B0_target=0.4)),
                             alpha = 0.2, B2B0_lim = 0.2, B2B0_target=0.4, 
                             HCR = "HCR6b: small MHW, low sensitivity", HCRscen="HCR6", subtxt = "b"),
                  
                  data.frame(B2B0=B2B0, 
                             F_adj = unlist(lapply(B2B0, ACLIM_HCR, type=typeIN,
                                                   invlogit_gamma=.7, 
                                                   alpha = 0.4, B2B0_lim = 0.2, B2B0_target=0.4)),
                             alpha = 0.4, B2B0_lim = 0.2, B2B0_target=0.4, 
                             HCR = "HCR6c: large MHW, high sensitivity", HCRscen="HCR6", subtxt = "c"))%>%
  mutate(HCR = factor(HCR,levels=HCR_levels),
         HCRscen = factor(HCRscen,levels=HCRscen_levels),
         subtxt = factor(subtxt,levels=subtxt_levels))

# --- HCR 7
typeIN <- 7
plotdat7 <- rbind(data.frame(B2B0=B2B0,
                             F_adj = unlist(lapply(B2B0, ACLIM_HCR, type=typeIN,
                                                   
                                                   log_omega1 = log(0), 
                                                   log_omega2 = log(0), 
                                                   log_omega3 = log(0), 
                                                   cov =.7,
                                                   alpha = 0.05, B2B0_lim = 0.2, B2B0_target=0.4)),
                             alpha = 0.05, B2B0_lim = 0.2, B2B0_target=0.4, 
                             HCR = "HCR7a: max productivity (SQ)" , HCRscen="HCR7", subtxt = "a"),
                  data.frame(B2B0=B2B0,
                             F_adj = unlist(lapply(B2B0, ACLIM_HCR, type=typeIN,
                                                   
                                                   log_omega1  = log(.5), 
                                                   log_omega2  = log(.5), 
                                                   log_omega3  = log(.5), 
                                                   cov =.7,
                                                   alpha = 0.05, B2B0_lim = 0.2, B2B0_target=0.4)),
                             alpha = 0.05, B2B0_lim = 0.2, B2B0_target=0.4, 
                             HCR = "HCR7b: SR cov effects", HCRscen="HCR7", subtxt = "b"),
                  data.frame(B2B0=B2B0,
                             F_adj = unlist(lapply(B2B0, ACLIM_HCR, type=typeIN,
                                                   invlogit_gamma= 0,
                                                   log_omega1  = log(.7),
                                                   log_omega2  = log(.5), 
                                                   log_omega3  = log(.3), 
                                                   cov =.7,
                                                   alpha = 0.05, B2B0_lim = 0.2, B2B0_target=0.4)),
                             alpha = 0.05, B2B0_lim = 0.2, B2B0_target=0.4, 
                             HCR = "HCR7c: SR cov effects uneven omega", HCRscen="HCR7", subtxt = "c"))%>%
  mutate(HCR = factor(HCR,levels=HCR_levels),
         HCRscen = factor(HCRscen,levels=HCRscen_levels),
         subtxt = factor(subtxt,levels=subtxt_levels))



# --- HCR 8
typeIN <- 8
plotdat8 <- rbind(data.frame(B2B0=B2B0,
                             F_adj = unlist(lapply(B2B0, ACLIM_HCR, type=typeIN,
                                                   log_theta = 0,
                                                   alpha = 0.05, B2B0_lim = 0.2, B2B0_target=0.4)),
                             alpha = 0.05, B2B0_lim = 0.2, B2B0_target=0.4, 
                             HCR = "HCR8a: max productivity (SQ)" , HCRscen="HCR8", subtxt = "a"),
                  data.frame(B2B0=B2B0,
                             F_adj = unlist(lapply(B2B0, ACLIM_HCR, type=typeIN,
                                                   log_theta = log(.75),
                                                   alpha = 0.05, B2B0_lim = 0.2, B2B0_target=0.4)),
                             alpha = 0.05, B2B0_lim = 0.2, B2B0_target=0.4, 
                             HCR = "HCR8b: theta set to 0.75" , HCRscen="HCR8", subtxt = "b"))%>%
  mutate(HCR = factor(HCR,levels=HCR_levels),
         HCRscen = factor(HCRscen,levels=HCRscen_levels),
         subtxt = factor(subtxt,levels=subtxt_levels))
# txt8 <- "In this scenario, rather than adjust the FMP target from $B_{40%}$, the effective $B_y$ and $B_{y+1}$ is adjusted downward:
# "
# includeMarkdown(rmarkdown::render(txt8))
plotdat_all <- rbind(plotdat1,plotdat2,plotdat3,plotdat4,plotdat5,
                    plotdat6,plotdat7, plotdat8)%>%left_join( col_line, by = c("HCR", "HCRscen", "subtxt"))
if(!dir.exists("data")) dir.create("data")
save(plotdat_all, file = file.path("data","plotdat_all.rds"))
save(HCR_levels, file = file.path("data","HCR_levels.rds"))
save(col_line, file = file.path("data","col_line.rds"))
save(HCRscen_levels, file = file.path("data","HCRscen_levels.rds"))




