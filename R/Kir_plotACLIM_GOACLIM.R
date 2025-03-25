#Kir's plots

# First for GOACLIM 
# ----------------------------------
  
  setwd("/Users/KKH/Documents/GitHub_mac/ROMS_to_Index-main")
  
  nep_vars <- read.csv("Data/NEP_variable_names.csv")

  # Load data integrated across depth and strata
  nep_hind <- read.csv("Data/NEP_10k_revised_indices/nep_avg_hind_300.csv")
  nep_hind$simulation = "hindcast"
  
  nep_hist <- read.csv("Data/NEP_10k_revised_indices/nep_avg_wb_hist_300.csv")
  nep_hist$simulation = "historical"
  
  nep_ssp126 <- read.csv("Data/NEP_10k_revised_indices/nep_avg_wb_ssp126_300.csv")
  nep_ssp126$simulation = "ssp126"
  
  nep_ssp245 <- read.csv("Data/NEP_10k_revised_indices/nep_avg_wb_ssp245_300.csv")
  nep_ssp245$simulation = "ssp245"
  
  nep_585 <- read.csv("Data/NEP_10k_revised_indices/nep_avg_wb_ssp585_300.csv")
  nep_585$simulation = "ssp585"
  
  # Combine in list
  roms_avg_data <- do.call(rbind, list(nep_hind, nep_hist,
                                       nep_ssp126,
                                       nep_ssp245,
                                       nep_585))
  
  # Add time and date information
  roms_avg_data <- roms_avg_data %>%
    mutate(
      date = lubridate::as_date(date),
      month = lubridate::month(date),
      year = lubridate::year(date))
  
  # Run bias correction for all variables 
  # - rbinds bias-corrected projection to historical run
  # - SSP126
  ssp126_avg_biascorrected <- delta_correction(
    hindcast = roms_avg_data %>% filter(simulation == "hindcast"),
    historical = roms_avg_data %>% filter(simulation == "historical"),
    projection = roms_avg_data %>% filter(simulation == "ssp126"),
    ref_yrs = 1990:2014, # Overlap years for historical and hindcast ROMS
    lognormal = FALSE,
    #use_sd = TRUE,
    use_sd = F,
    include_hindcast = F)
  
  # - SSP245
  ssp245_avg_biascorrected <- delta_correction(
    hindcast = roms_avg_data %>% filter(simulation == "hindcast"),
    historical = roms_avg_data %>% filter(simulation == "historical"),
    projection = roms_avg_data %>% filter(simulation == "ssp245"),
    ref_yrs = 1990:2014, # Overlap years for historical and hindcast ROMS
    lognormal = FALSE,
    #use_sd = TRUE,
    use_sd = F,
    include_hindcast = F)
  
  # - SSP585
  ssp585_avg_biascorrected <- delta_correction(
    hindcast = roms_avg_data %>% filter(simulation == "hindcast"),
    historical = roms_avg_data %>% filter(simulation == "historical"),
    projection = roms_avg_data %>% filter(simulation == "ssp585"),
    ref_yrs = 1990:2014, # Overlap years for historical and hindcast ROMS
    lognormal = FALSE,
    #use_sd = TRUE,
    use_sd = F,
    include_hindcast = F)

  
  # Extract small copepod for desired area

  # Convert to t C per NMFS area. You may use alternative calculations here
  # - Units of Cop in the *sum* files are mg C m^-2 of water column
  # - Area is in m^2
  # - There are 1e-9 tonnes in a mg
  # - Final units will be t C per NMFS area 
  
  goa_BT <- rbind(ssp126_avg_biascorrected%>%mutate(simulation = "ssp126"),
                  ssp245_avg_biascorrected%>%mutate(simulation = "ssp245"),
                  ssp585_avg_biascorrected%>%mutate(simulation = "ssp585") )%>%
    filter(varname == "temp", depthclass == "Bottom",  NMFS_AREA == "All") %>%
    # Take mean fall 
    #group_by(year, month,simulation) %>%
    #summarise(BT = mean(temp)) %>% # Sum biomass across 610 and 620
    mutate(season = case_when(
      month %in% c(3,4,5) ~ "spring",
      month %in% c(11,12,1,2) ~ "winter",
      month %in% c(6,7,8) ~ "summer",
      month %in% c(9,10) ~ "fall",
    ))  %>%
    group_by(year, season,simulation) %>%
    summarise(BT = mean(value, na.rm=T),
              BT_sd = sd(value, na.rm=T)) %>%
    mutate(GCM="GFDL",
           BT_low = BT-BT_sd,
           BT_high = BT+BT_sd)%>%mutate(Basin = "GOA")
  
  # Plot it
  ggplot(goa_BT) + 
    geom_ribbon(aes(ymin =BT_low, ymax = BT_high, x=year, fill = season),alpha=.3) +
    geom_line(aes(x=year, y=BT, colour = season)) +
    ylab("Bottom temp (deg C)") + xlab("Year")+
    facet_grid(season~simulation)+
    scale_color_viridis_d()+
      scale_fill_viridis_d()
  
  
  # Now ACLIM
  
  setwd("/Users/KKH/Documents/GitHub_mac/ACLIM2")
  # loads packages, data, setup, etc.
  suppressWarnings(source("R/make.R"))
  
  get_var_akfin <- function(typein="annual",
                            var="temp_bottom5m",
                            basin="SEBS",
                            cmip="CMIP6",
                            dataset="HIND") {
    if(typein %in% c("annual","monthly", "weekly","surveyrep", "seasonal")) {
      
      url <- paste0("https://apex.psmfc.org/akfin/data_marts/clim/aclim_l4_",typein)
      query<-list(dataset=dataset, var=var, basin=basin, cmip=cmip)
      
      jsonlite::fromJSON(httr::content(
        httr::GET(url=url, query=query),
        as="text", encoding="UTF-8")) |>
        dplyr::bind_rows()
    }
    
    else {
      return("typein must be one of annual, monthly, weekly, surveyrep, or seasonal. Otherwise more error messages coming later")
    }
  }
  
  
  lvls <- c("GOA","SEBS","NEBS")
  
  EBS_hista <- rbind(
    get_var_akfin(typein="seasonal",basin="NEBS", 
                  dataset = "HIST", var="temp_bottom5m", cmip="CMIP6"),
    get_var_akfin(typein="seasonal",basin="SEBS", 
                  dataset = "HIST", var="temp_bottom5m", cmip="CMIP6"),
    get_var_akfin(typein="seasonal",basin="NEBS", 
                  dataset = "HIST", var="temp_bottom5m", cmip="CMIP5"),
    get_var_akfin(typein="seasonal",basin="SEBS", 
                  dataset = "HIST", var="temp_bottom5m", cmip="CMIP5"))
  
  EBS_hist <- EBS_hista %>%
    select(year = YEAR, season = SEASON,
           simulation =SCEN, BT = MN_VAL, GCM,Basin = BASIN )%>%
    mutate(season = case_when(
      season == "Fall" ~ "fall",
      season == "Spring" ~ "spring",
      season == "Summer" ~ "summer",
      season == "Winter" ~ "winter"
    ),
    GCM = case_when(
      GCM == "cesm" ~ "CESM",
      GCM == "gfdl" ~ "GFDL",
      GCM == "miroc" ~ "MIROC",
      GCM == "CESM" ~ "CESM",
      GCM == "GFDL" ~ "GFDL",
      GCM == "MIROC" ~ "MIROC"
    ))%>%mutate(Basin = factor(Basin, levels = lvls))%>%
    filter(simulation!="rcp85")
  
  
  EBS_hinda <- rbind(
    get_var_akfin(typein="seasonal",basin="NEBS", 
                  dataset = "HIND", var="temp_bottom5m", cmip="CMIP6"),
    get_var_akfin(typein="seasonal",basin="SEBS", 
                  dataset = "HIND", var="temp_bottom5m", cmip="CMIP6"),
    get_var_akfin(typein="seasonal",basin="NEBS", 
                  dataset = "HIND", var="temp_bottom5m", cmip="CMIP5"),
    get_var_akfin(typein="seasonal",basin="SEBS", 
                  dataset = "HIND", var="temp_bottom5m", cmip="CMIP5"))
  
  EBS_hind <- EBS_hinda %>%
    select(year = YEAR, season = SEASON,
           simulation =SCEN, BT = MN_VAL, GCM,Basin = BASIN )%>%
    mutate(season = case_when(
      season == "Fall" ~ "fall",
      season == "Spring" ~ "spring",
      season == "Summer" ~ "summer",
      season == "Winter" ~ "winter"
    ))%>%mutate(Basin = factor(Basin, levels = lvls))
  
  
  
  # fut
  EBS_futa <- rbind(
    get_var_akfin(typein="seasonal",basin="NEBS", 
                  dataset = "FUT", var="temp_bottom5m", cmip="CMIP6"),
    get_var_akfin(typein="seasonal",basin="SEBS", 
                  dataset = "FUT", var="temp_bottom5m", cmip="CMIP6"),
    get_var_akfin(typein="seasonal",basin="NEBS", 
                  dataset = "FUT", var="temp_bottom5m", cmip="CMIP5"),
   get_var_akfin(typein="seasonal",basin="SEBS", 
                  dataset = "FUT", var="temp_bottom5m", cmip="CMIP5"))
  
  EBS_fut <- EBS_futa %>%select(year = YEAR, 
                               season = SEASON,
                               simulation =SCEN, BT = MN_VAL, 
           BT_bc = VAL_BIASCORRECTED,GCM,Basin = BASIN )%>%
    mutate(season = case_when(
      season == "Fall" ~ "fall",
      season == "Spring" ~ "spring",
      season == "Summer" ~ "summer",
      season == "Winter" ~ "winter"
    ),
    GCM = case_when(
      GCM == "cesm" ~ "CESM",
      GCM == "gfdl" ~ "GFDL",
      GCM == "miroc" ~ "MIROC",
      GCM == "CESM" ~ "CESM",
      GCM == "GFDL" ~ "GFDL",
      GCM == "MIROC" ~ "MIROC"
    ))%>%mutate(Basin = factor(Basin, levels = lvls))
  
  # Plot it
  ggplot(EBS_fut%>%filter(Basin=="SEBS")%>%select(-BT)%>%mutate(BT=BT_bc)) +  
    geom_line(data=EBS_hind%>%filter(Basin=="SEBS")%>%select(-simulation),
              aes(x=year, y=BT), color="blue") +
    geom_line(aes(x=year, y=BT, colour = GCM)) +
    ylab("Bottom temp (deg C)") + xlab("Year")+
    facet_grid(simulation~season)+
    scale_color_viridis_d()+
    scale_fill_viridis_d()
  
  
  # Plot it
  ggplot( ) +  
    geom_line( data = EBS_hind %>%
                filter( Basin == "SEBS" ,
                        season == "summer" ) %>%
                select( -simulation ),
              aes( x = year, y = BT ), color = "blue" ) +
    geom_line( data = EBS_fut %>%
                 filter( Basin == "SEBS" , 
                         season == "summer" ) %>%
                 select(-BT) %>% mutate( BT = BT_bc ),
               aes( x = year, y = BT, colour = GCM ) )  +
    geom_line( data = goa_BT %>%mutate(Basin = "GOA") %>%
                 filter(season == "summer" ) ,
               aes( x = year, y = BT, colour = GCM ) )  +
    ylab("Bottom temp (deg C)") + xlab("Year")+
    facet_grid( simulation ~ Basin )+
    scale_color_viridis_d( option = "mako" , begin = .1, end = .8 ) +
    scale_fill_viridis_d( option = "mako", begin = .1, end = .8 ) +
    theme_minimal()
  
  
  # Plot it
  plot_by_basin <- ggplot( ) +  
    geom_line( data = EBS_hind %>%
                 filter( 
                         season == "summer" ) %>%
                 select( -GCM ),
               aes( x = year, y = BT ), color = "blue" ) +
    geom_line( data = EBS_fut %>%
                 filter(  
                         season == "summer" ) %>%
                 select(-BT) %>% mutate( BT = BT_bc ),
               aes( x = year, y = BT, colour = simulation ) )  +
    geom_line( data = goa_BT %>%mutate(Basin = "GOA") %>%
                 filter(season == "summer" ) ,
               aes( x = year, y = BT, colour = simulation ) )  +
    ylab("Bottom temp (deg C)") + xlab("Year")+
    facet_grid( GCM ~ Basin )+
    scale_color_viridis_d( option = "mako" , begin = .1, end = .8 ) +
    scale_fill_viridis_d( option = "mako", begin = .1, end = .8 ) +
    theme_minimal()
  
  plot_by_basin
  
  # Plot it
  plot_by_gcm <- ggplot( ) +  
    geom_line( data = EBS_hind %>%
                 filter( 
                   season == "summer" ) %>%
                 select( -simulation,-GCM ),
               aes( x = year, y = BT , colour = Basin) ) +
    geom_line( data = EBS_fut %>%
                 filter(  
                   season == "summer" ) %>%
                 select(-BT) %>% mutate( BT = BT_bc ),
               aes( x = year, y = BT, colour = Basin ) )  +
    geom_line( data = goa_BT %>%mutate(Basin = "GOA") %>%
                 filter(season == "summer" ) ,
               aes( x = year, y = BT, colour = Basin ) )  +
    ylab("Bottom temp (deg C)") + xlab("Year")+
    facet_grid( simulation ~ GCM )+
    scale_color_viridis_d( option = "mako" , begin = .1, end = .8 ) +
    scale_fill_viridis_d( option = "mako", begin = .1, end = .8 ) +
    theme_minimal()
  

 
  plot_by_ssp <- function( gcmset = c("GFDL","MIROC","CESM","hind") ){
    ggplot( ) +  
    geom_line( data = EBS_hind %>%
                 filter( GCM%in%gcmset,
                   season == "summer" ) %>%
                 select(-simulation ),
               aes( x = year, y = BT , colour = GCM) ) +
    geom_line( data = EBS_fut %>%
                 filter(   GCM%in%gcmset,
                   season == "summer" ) %>%
                 select(-BT) %>% mutate( BT = BT_bc ),
               aes( x = year, y = BT, colour = GCM ) )  +
    geom_line( data = goa_BT %>%mutate(Basin = "GOA") %>%
                 filter( GCM%in%gcmset,
                   season == "summer" ) ,
               aes( x = year, y = BT, colour = GCM ) )  +
    ylab("Bottom temp (deg C)") + xlab("Year")+
    facet_grid( Basin ~ simulation )+
    scale_color_viridis_d( option = "mako" , begin = .1, end = .8 ) +
    scale_fill_viridis_d( option = "mako", begin = .1, end = .8 ) +
    theme_minimal()
  }
  
  ggplot( ) +  
    geom_line( data = EBS_hind %>%
                 filter(  Basin == "NEBS",
                   season == "summer" ) %>%
                 select( -simulation,-GCM ),
               aes( x = year, y = BT , colour = "hind") ) +
    geom_line( data = EBS_hist %>%
                 filter(  Basin == "NEBS",GCM =="MIROC",simulation == "ssp126",
                          season == "summer" ),
               aes( x = year, y = BT, colour = "hist" ) )  +
    geom_line( data = EBS_fut %>%
                 filter(  Basin == "NEBS",GCM =="MIROC",simulation == "ssp126",
                   season == "summer" ) %>%
                 select(-BT) %>% mutate( BT = BT_bc ),
               aes( x = year, y = BT, colour = "Bias_corrected" ) )  +
    geom_line( data = EBS_fut %>%
                 filter(   Basin == "NEBS",GCM =="MIROC",simulation == "ssp126",
                   season == "summer" ),
               aes( x = year, y = BT, colour = "Raw" ) ) +
    ylab("Bottom temp (deg C)") + xlab("Year")+
    facet_grid( simulation ~ GCM )+
    scale_color_viridis_d( option = "mako" , begin = .1, end = .8 ) +
    scale_fill_viridis_d( option = "mako", begin = .1, end = .8 ) +
    theme_minimal()
  
  
  alpha_hind <- 1
  alpha_hist <- 1
  alpha_bc   <- 1
  alpha_raw  <- 1
  
  tmp_plot <-function(
    alpha_hind = 1,
    alpha_hist = 1,
    alpha_bc   = 1,
    alpha_raw  = 1
    ){
    ggplot( ) +  
    geom_line( data = EBS_hind %>%
                 filter(  Basin == "SEBS",
                          season == "summer" ) %>%
                 select( -simulation,-GCM ),
               aes( x = year, y = BT , colour = "hind"), alpha = alpha_hind ) +
    geom_line( data = EBS_hist %>%
                 filter(  Basin == "SEBS",GCM =="MIROC",simulation == "ssp126",
                          season == "summer" ),
               aes( x = year, y = BT, colour = "hist" ) , alpha = alpha_hist)  +
    geom_line( data = EBS_fut %>%
                 filter(  Basin == "SEBS",GCM =="MIROC",simulation == "ssp126",
                          season == "summer" ) %>%
                 select(-BT) %>% mutate( BT = BT_bc ),
               aes( x = year, y = BT, colour = "Bias_corrected" ), alpha = alpha_bc  )  +
    geom_line( data = EBS_fut %>%
                 filter(   Basin == "SEBS",GCM =="MIROC",simulation == "ssp126",
                           season == "summer" ),
               aes( x = year, y = BT, colour = "Raw" ) , alpha = alpha_raw) +
    ylab("Bottom temp (deg C)") + xlab("Year")+
    facet_grid( simulation ~ GCM )+
    scale_color_viridis_d( option = "mako" , begin = .1, end = .8 ) +
    scale_fill_viridis_d( option = "mako", begin = .1, end = .8 ) +
    theme_minimal()
  }
  
  outfldr <- file.path("Figs","2025_jointmeeting")
  if(!dir.exists(outfldr))
    dir.create(outfldr)
  
  sclr <- 1.1
  jpeg(filename = file.path(outfldr,"compare_bc_a.jpg"),
       width=7*sclr,height=4*sclr,units="in",res=350)
  print(tmp_plot(alpha_hind = 0,alpha_bc = 0))
  dev.off()
  
  jpeg(filename = file.path(outfldr,"compare_bc_b.jpg"),
       width=7*sclr,height=4*sclr,units="in",res=350)
  print(tmp_plot(alpha_hind = 1,alpha_bc = 0))
  dev.off()
  
  jpeg(filename = file.path(outfldr,"compare_bc_c.jpg"),
       width=7*sclr,height=4*sclr,units="in",res=350)
  print(tmp_plot(alpha_hist = 0,alpha_bc = 0))
  dev.off()
  
  jpeg(filename = file.path(outfldr,"compare_bc_d.jpg"),
       width=7*sclr,height=4*sclr,units="in",res=350)
  print(tmp_plot(alpha_hind = 1,alpha_bc = 1))
  dev.off()
  
  jpeg(filename = file.path(outfldr,"compare_bc_e.jpg"),
       width=7*sclr,height=4*sclr,units="in",res=350)
  print(tmp_plot(alpha_hist = 0,alpha_raw = 0))
  dev.off()
  
  
  jpeg(filename = file.path(outfldr,"plot_by_basin.jpg"),
       width=8*sclr,height=4.5*sclr,units="in",res=350)
  print(plot_by_basin)
  dev.off()
  
  jpeg(filename = file.path(outfldr,"plot_by_gcm.jpg"),
       width=8*sclr,height=4.5*sclr,units="in",res=350)
  print(plot_by_gcm)
  dev.off()
  plot_by_gcm
  
  
  jpeg(filename = file.path(outfldr,"plot_by_ssp_all.jpg"),
       width=8*sclr,height=4.5*sclr,units="in",res=350)
  print(plot_by_ssp())
  dev.off()
  jpeg(filename = file.path(outfldr,"plot_by_ssp_gfdl_miroc.jpg"),
       width=8*sclr,height=4.5*sclr,units="in",res=350)
  print(plot_by_ssp(gcmset = c("GFDL","MIROC","hind")))
  dev.off()
  jpeg(filename = file.path(outfldr,"plot_by_ssp_gfdl.jpg"),
       width=8*sclr,height=4.5*sclr,units="in",res=350)
  print(plot_by_ssp(gcmset = c("GFDL","hind")))
  dev.off()


