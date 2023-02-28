#'
#'
#'plot_NEBSnSEBS.R
#'
  fldrout <- "Figs/prod_plots"
  if(dir.exists(fldrout))
    dir.remove(fldrout)
  dir.create(fldrout)

  load("Data/out/K20P19_CMIP6/allEBS_means/ACLIM_weekly_hind_mn.Rdata")
  
  load("Data/out/K20P19_CMIP6/allEBS_means/ACLIM_weekly_fut_mn.Rdata")
  varz <- unique(ACLIM_weekly_hind$var)
  vardef <- rbind(weekly_var_def,data.frame(name = "largeZoop_integrated", units = "(mg C m^-3)*m", 
                                            longname = "On-shelf euph. + large cop., integrated over depth" ))
  vardef <- rbind(vardef,
                  data.frame(name = varz[which(!varz%in%vardef$name)],units = "",longname=""))
  
  vardef <- vardef%>%filter(name%in%unique(ACLIM_weekly_hind$var))
  
  i <-grep("temp_bottom5m",vardef$name)
  w<-9; h<-6; dpi <-350
  w2<-6; h2<-4 
  sclr <- 1
  for(i in 1:length(vardef$name)){
    
    lgn <- vardef[i,]$longname
    vv  <- vardef[i,]$name
    unt <- vardef[i,]$units
    cat(vv,"\n")
    
    tmp <- suppressMessages(plotNEBS_productivity(datIN=ACLIM_weekly_hind,
                                                  varlistIN=vardef[i,]))
    tmp2 <- suppressMessages(plotNEBS_productivity_fut(datIN=ACLIM_weekly_hind,alphaIN = .4,
                                                       datIN_fut=ACLIM_weekly_fut,
                                                       varlistIN=vardef[i,]))
    
    jpeg(file.path(fldrout,paste0(vv,".jpg")),width = w, height=h, res=dpi, units="in")
    print(tmp$p2)
    dev.off()
    
    jpeg(file.path(fldrout,paste0(vv,"_fut.jpg")),width = w*sclr, height=h*sclr, res=dpi, units="in")
    print(tmp2$p2)
    dev.off()
    
    jpeg(file.path(fldrout,paste0(vv,"_hind.jpg")),width = w2*sclr, height=h2*sclr, res=dpi, units="in")
    print(tmp2$p1)
    dev.off()
    
    rm(tmp2)
    rm(tmp)

    tmp3 <- suppressMessages(plotNEBS_productivity_futBC(datIN=ACLIM_weekly_hind,alphaIN = .4,
                                                       datIN_fut=ACLIM_weekly_fut,
                                                       varlistIN=vardef[i,]))
    
    jpeg(file.path(fldrout,paste0(vv,"_futBC.jpg")),width = w*sclr, height=h*sclr, res=dpi, units="in")
    print(tmp3$p2)
    dev.off()
    rm(tmp2)
  }
  
