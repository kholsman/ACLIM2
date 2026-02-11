---
title: "Quick setup steps for ACLIM2"
output:
  word_document:
    fig_caption: yes
    fig_width: 4
    keep_md: yes
  html_document:
    df_print: kable
    fig_caption: yes
    theme: flatly
  header-includes:
  - \usepackage{inputenc}
  - \usepackage{unicode-math}
  - \pagenumbering{gobble}
  pdf_document:
    fig_caption: yes
    fig_height: 4
    fig_width: 5
    highlight: tango
    keep_tex: yes
    latex_engine: xelatex
---




<!-- ```{r, echo=FALSE, fig.align='center'} -->
<!-- include_graphics("Figs/ACLIM_logo.jpg") -->
<!-- ``` -->

 
[**ACLIM Repo: github.com/kholsman/ACLIM2**](https://github.com/kholsman/ACLIM2 "ACLIM2 Repo")  
  Repo maintained by:  
  Kirstin Holsman  
  Alaska Fisheries Science Center  
  NOAA Fisheries, Seattle WA  
  **[kirstin.holsman@noaa.gov](kirstin.holsman@noaa.gov)**  
  *Last updated: Mar 05, 2021*


Here is a quick ACLIM2 code setup. This is also available in the ACLIM

## Use R to download and set up the ACLIM2 code repo


```r
    # Specify the download directory
    main_nm       <- "ACLIM2"
    download_path <- path.expand("~/desktop")
    dest_fldr     <- file.path(download_path,main_nm)
    
    url           <- "https://github.com/kholsman/ACLIM2/archive/main.zip"
    dest_file     <- file.path(download_path,paste0(main_nm,".zip"))
    download.file(url=url, destfile=dest_file)
    
    # unzip the .zip file
    setwd(download_path)
    unzip (dest_file, exdir = "./",overwrite = T)
    
    #rename the unzipped folder from ACLIM2-main to ACLIM2
    file.rename(paste0(main_nm,"-main"), main_nm)
    setwd(main_nm)
```


Now grab a coffee and set this up to download the map files and set up the ACLIM file structure.


```r
    # --------------------------------------
    # SETUP WORKSPACE
    tmstp  <- format(Sys.time(), "%Y_%m_%d")
    main   <- getwd()  #"~/GitHub_new/ACLIM2
    source("R/make.R")
    # --------------------------------------
```

 

![.](Figs/ACLIM_logo.jpg){ width=20%}
