# Download the ACLIM2 repo & data

## Clone the ACLIM2 repo

To run this tutorial first clone the ACLIM2 repository to your local
drive:

### Option 1: Use R

This set of commands, run within R, downloads the ACLIM2 repository and
unpacks it, with the ACLIM2 directory structrue being located in the
specified `download_path`. This also performs the folder renaming
mentioned in Option 2.

``` r
    # Specify the download directory
    main_nm       <- "ACLIM2"

    # Note: Edit download_path for preference
    download_path <-  path.expand("~")
    dest_fldr     <- file.path(download_path,main_nm)
    
    url           <- "https://github.com/kholsman/ACLIM2/archive/main.zip"
    dest_file     <- file.path(download_path,paste0(main_nm,".zip"))
    download.file(url=url, destfile=dest_file)
    
    # unzip the .zip file (manually unzip if this doesn't work)
    setwd(download_path)
    unzip (dest_file, exdir = download_path,overwrite = T)
    
    #rename the unzipped folder from ACLIM2-main to ACLIM2
    file.rename(paste0(main_nm,"-main"), main_nm)
    setwd(main_nm)
```

### Option 2: Download the zipped repo

Download the full zip archive directly from the [**ACLIM2
Repo**](https://github.com/kholsman/ACLIM2) using this link:
[**https://github.com/kholsman/ACLIM2/archive/main.zip**](https://github.com/kholsman/ACLIM2/archive/main.zip),
and unzip its contents while preserving directory structure.

**Important!**\* If downloading from zip, please **rename the root
folder** from `ACLIM2-main` (in the zipfile) to `ACLIM2` (name used in
cloned copies) after unzipping, for consistency in the following
examples.

Your final folder structure should look like this:

<img src="Figs/ACLIM_dir.png" style="width:100.0%" />

### Option 3: Use git commandline

If you have git installed and can work with it, this is the preferred
method as it preserves all directory structure and can aid in future
updating. Use this from a **terminal command line, not in R**, to clone
the full ACLIM2 directory and sub-directories:

``` bash
    git clone https://github.com/kholsman/ACLIM2.git
```

------------------------------------------------------------------------

## Get the data

Go to the google drive and download the zipped file with the R data
‘2022_03_07_Rdata.zip’:

[00_ACLIM_shared \> 02_Data \> Newest_Data(use this) \>
2022_03_07_Rdata.zip](https://drive.google.com/drive/folders/11BQEfNEl9vvrN-V0LgS67XS4aLE9pNzz)

Move the Zipped folder to your local folder ‘ACLIM2/Data/in’ and unzip.
The final folder structure should look like:

<img src="Figs/DATA_dir.png" style="width:50.0%" />

## Set up the Workspace

Open R() and used ‘setwd()’ to navigate to the root ACLIM2 folder (.e.g,
\~/mydocuments/ACLIM2)

``` r
    # set the workspace to your local ACLIM2 folder
    # e.g., "/Users/kholsman/Documents/GitHub/ACLIM2"
    # setwd( path.expand("~/Documents/GitHub/ACLIM2") )
   
    # --------------------------------------
    # SETUP WORKSPACE
    tmstp  <- format(Sys.time(), "%Y_%m_%d")
    main   <- getwd()  #"~/GitHub_new/ACLIM2"
    
    # loads packages, data, setup, etc.
    suppressWarnings(source("R/make.R"))
```

    ## ------------------------------
    ## ALIM2/R/setup.R settings 
    ## ------------------------------
    ## main:                : /Users/kholsman/Documents/GitHub/ACLIM2/R/shiny_aclim/ACLIM2_indices 
    ## data_path            : /Users/kholsman/Documents/GitHub/ACLIM2/R/shiny_aclim/ACLIM2_indices/Data/in/2022_03_07/roms_for_public 
    ## Rdata_path           : /Users/kholsman/Documents/GitHub/ACLIM2/R/shiny_aclim/ACLIM2_indices/Data/in/2022_03_07_Rdata/roms_for_public 
    ## redownload_level3_mox: FALSE 
    ## update.figs          : FALSE 
    ## load_gis             : FALSE 
    ## update.outputs       : TRUE 
    ## update.figs          : FALSE 
    ## dpiIN                : 150 
    ## update.figs          : FALSE 
    ## ------------------------------
    ## ------------------------------
    ## 
    ## The following datasets are public, please cite as Hermann et al. 2019 (v.H16) and Kearney et al. 2020 (v.K20) :
    ## B10K-H16_CMIP5_CESM_BIO_rcp85 
    ## B10K-H16_CMIP5_CESM_rcp45 
    ## B10K-H16_CMIP5_CESM_rcp85 
    ## B10K-H16_CMIP5_GFDL_BIO_rcp85 
    ## B10K-H16_CMIP5_GFDL_rcp45 
    ## B10K-H16_CMIP5_GFDL_rcp85 
    ## B10K-H16_CMIP5_MIROC_rcp45 
    ## B10K-H16_CMIP5_MIROC_rcp85 
    ## B10K-H16_CORECFS 
    ## B10K-K20_CORECFS 
    ## 
    ## The following datasets are still under embargo, please do not share outside of ACLIM:
    ## B10K-K20P19_CMIP6_cesm_historical 
    ## B10K-K20P19_CMIP6_cesm_ssp126 
    ## B10K-K20P19_CMIP6_cesm_ssp585 
    ## B10K-K20P19_CMIP6_gfdl_historical 
    ## B10K-K20P19_CMIP6_gfdl_ssp126 
    ## B10K-K20P19_CMIP6_gfdl_ssp585 
    ## B10K-K20P19_CMIP6_miroc_historical 
    ## B10K-K20P19_CMIP6_miroc_ssp126 
    ## B10K-K20P19_CMIP6_miroc_ssp585

------------------------------------------------------------------------

# Read this before you start

## Overview

The [**ACLIM2 github repository**](https://github.com/kholsman/ACLIM2)
contains R code and Rdata files for working with netcdf-format data
generated from the [**downscaled ROMSNPZ
modeling**](https://beringnpz.github.io/roms-bering-sea) of the ROMSNPZ
Bering Sea Ocean Modeling team; Drs. Hermann, Cheng, Kearney,
Pilcher,Ortiz, and Aydin. The code and R resources described in this
tutorial are maintained by [Kirstin
Holsman](mailto:kirstin.holsman@noaa.gov) as part of NOAA’s [**ACLIM
project**](https://www.fisheries.noaa.gov/alaska/ecosystems/alaska-climate-integrated-modeling-project)
for the Bering Sea. *See [Hollowed et
al. 2020](https://www.frontiersin.org/articles/10.3389/fmars.2019.00775/full)
for more information about the ACLIM project.*

------------------------------------------------------------------------

This document provides an overview of accessing, plotting, and creating
bias corrected indices for ACLIM2 based on CMIP6 (embargoed for ACLIM2
users until 2023) and CMIP5 (publicly available) simulations. This guide
assumes analyses will take place in R() and that users have access to
the data folder within the ACLIM2 shared drive. For more information
also see the full tutorial (“GettingStarted_Bering10K_ROMSNPZ” available
at the bottom of [**this repo
page**](https://github.com/kholsman/ACLIM2).

**Important!** A few key things to know before getting started are
detailed below. Please review this information before getting started.

## KEY ROMSNPZ versions

**Important!** ACLIM1 CMIP5 and ACLIM2 CMIP5 and CMIP6 datasets use
different base models.

There are two versions of the ROMSNPZ model:

1.  ACLIM1 an older 10-depth layer model used for CMIP5 (“H-16”)
2.  ACLIM2 a new 30-depth layer model used for CMIP6 (“K20” or “K20P19”)

The models are not directly comparable, therefore the projections should
be bias corrected and recentered to baselines of hindcasts of each model
(forced by “observed” climate conditions). i.e. CMIP5 and CMIP6 have
corresponding hindcasts:

1.  Hindcast for CMIP5 “H19” –\> H16_CORECFS
2.  Hindcast for CMIP5 “K20P19” –\> H16_CORECFS
3.  Hindcast for CMIP6 “K20P19” –\> K20_CORECFS

In addition for CMIP6 “historical” runs are available for bias
correcting. We will use those below.

For a list of the available simulations for ACLIM enter the following in
R():

``` r2
# list of the climate scenarios
data.frame(sim_list)
```

## KEY Data outputs

**Important!** There are 2 types of post-processed data available for
use in ACLIM.

The ROMSNPZ team has developed a process to provide standardized
post-processed outputs from the large (and non-intuitive) ROMSNPZ grid.
These have been characterized as:

1.  Level 1 (original ROMSNPZ U,V, grid, not rotated or corrected)  
2.  Level 2 (lat long bi-weekly high res versions, shouldn’t be needed
    and are difficult to work with)  
3.  **Level 3 indices (depth corrected and area weighted means for each
    model variable; i.e., what we will mostly use) **
    1.  “ACLIMsurveyrep\_”: groundifsh survey replicated (replicated in
        space and time)
    2.  “ACLIMregion\_”: weekly strata based averages

To get more information about each of these level 3 datasets enter this
in R:

``` r
    # Metadata for Weekly ("ACLIMregion_...") indices
    head(all_info1)
```

    ##                            name                    Type B10KVersion  CMIP
    ## 1 B10K-H16_CMIP5_CESM_BIO_rcp85 Weekly regional indices         H16 CMIP5
    ## 2     B10K-H16_CMIP5_CESM_rcp45 Weekly regional indices         H16 CMIP5
    ## 3     B10K-H16_CMIP5_CESM_rcp85 Weekly regional indices         H16 CMIP5
    ## 4 B10K-H16_CMIP5_GFDL_BIO_rcp85 Weekly regional indices         H16 CMIP5
    ## 5     B10K-H16_CMIP5_GFDL_rcp45 Weekly regional indices         H16 CMIP5
    ## 6     B10K-H16_CMIP5_GFDL_rcp85 Weekly regional indices         H16 CMIP5
    ##    GCM   BIO Carbon_scenario               Start                 End nvars
    ## 1 CESM  TRUE           rcp85 2006-01-22 12:00:00 2099-12-27 12:00:00    59
    ## 2 CESM FALSE           rcp45 2006-01-22 12:00:00 2081-02-16 12:00:00    59
    ## 3 CESM FALSE           rcp85 2006-01-22 12:00:00 2099-12-27 12:00:00    59
    ## 4 GFDL  TRUE           rcp85 2006-01-22 12:00:00 2099-12-27 12:00:00    59
    ## 5 GFDL FALSE           rcp45 2006-01-22 12:00:00 2099-12-27 12:00:00    59
    ## 6 GFDL FALSE           rcp85 2006-01-22 12:00:00 2099-12-27 12:00:00    59

``` r
    # Metadata for Weekly ("ACLIMsurveyrep_...") indices
    head(all_info2)
```

    ##                            name              Type B10KVersion  CMIP  GCM
    ## 1 B10K-H16_CMIP5_CESM_BIO_rcp85 Survey replicated         H16 CMIP5 CESM
    ## 2     B10K-H16_CMIP5_CESM_rcp45 Survey replicated         H16 CMIP5 CESM
    ## 3     B10K-H16_CMIP5_CESM_rcp85 Survey replicated         H16 CMIP5 CESM
    ## 4 B10K-H16_CMIP5_GFDL_BIO_rcp85 Survey replicated         H16 CMIP5 GFDL
    ## 5     B10K-H16_CMIP5_GFDL_rcp45 Survey replicated         H16 CMIP5 GFDL
    ## 6     B10K-H16_CMIP5_GFDL_rcp85 Survey replicated         H16 CMIP5 GFDL
    ##     BIO Carbon_scenario Start  End nvars
    ## 1  TRUE           rcp85  1970 2100    60
    ## 2 FALSE           rcp45  1970 2100    60
    ## 3 FALSE           rcp85  1970 2100    60
    ## 4  TRUE           rcp85  1970 2100    60
    ## 5 FALSE           rcp45  1970 2100    60
    ## 6 FALSE           rcp85  1970 2100    60

# Create Indices & bias correct projections

The next step creates indices based on the level 3 data for each hind
cast, historical run, and CMIP6 projection. The script below then bias
corrects each index using the historical run and recenters the
projection on the corresponding hindcast (such that projections are *Δ*
from historical mean values for the reference period
`deltayrs     <- 1970:2000` ).

## Water column averaged values

The average water column values for each variable from the ROMSNPZ model
strata x weekly Level2 outputs (‘ACLIMregion’) was calculated and used
to calculate the strata-area weighted mean value for the NEBS and SEBS
weekly, monthly, seasonally, and annually. Similarly, for survey
replicated (‘ACLIMsurveyrep’) Level2 outputs the average water column
value for each variable at each station was calculated used to calculate
the strata-area weighted mean value for the NEBS and SEBS annually.
These indices were calculate for hindcast, historical, and projection
scenarios, and used to bias correct the projections. More information on
the methods for each can be found in the tabs below and the code
immediately following this section will re-generate the bias corrected
indices. All of the bias corrected outputs can be found in the
“Data/out/CMIP6” folder.

<figure>
<img src="Figs/biascorrected_temp2.png" style="width:75.0%" alt="Raw (top row) and bias corrected (bottom row)bottom temperature indices based on survey replicated Level3 outputs for the SEBS" /><figcaption aria-hidden="true"><em>Raw (top row) and bias corrected (bottom row)bottom temperature indices based on survey replicated Level3 outputs for the SEBS</em></figcaption>
</figure>

*Important!* Note that for projections the ‘mn_val’ represents raw mean
values, while ‘val_bias-corrected’ is the bias corrected mn_val (should
be used instead of the raw values). In all cases, for variables that are
log-normally distributed (cannot be \< 0), the ln(mn_val) were used to
bias correct and were then back transformed to non-log space after
correction:

For normally distributed variables (*Y*):
$${Y}^{fut'}\_{t,k} =\\bar{Y}^{hind}\_{k,\\bar{T}} +\\left( \\frac{\\sigma^{hind}\_{k,\\bar{T}}}{\\sigma^{hist}\_{k,\\bar{T}}}\*({Y}^{fut}\_{t,k}-\\bar{Y}^{hist}\_{k,\\bar{T}})  \\right )$$

where *Ȳ*<sub>*y*, *k*</sub><sup>*f**u**t*′</sup> is the bias corrected
varable *k* value for time-step *t* (e.g., year, month, or season),
*Ȳ*<sub>*k*, *T̄*</sub><sup>*h**i**n**d*</sup> is the mean value of the
variable *k* during the reference period *T̄* = \[1980, 2013\] from the
hindcast model, *σ*<sub>*k*, *T̄*</sub><sup>*h**i**n**d*</sup> is the
standard deviation of the hindcast during the reference period *T̄*,
*σ*<sub>*k*, *T̄*</sub><sup>*h**i**s**t*</sup> is the standard deviation
of the historical run during tje reference period,
*Y*<sub>*t*, *k*</sub><sup>*f**u**t*</sup> is the value of the variable
from the projection at time-step *t* and
*Ȳ*<sub>*k*, *T̄*</sub><sup>*h**i**s**t*</sup> is the average value from
the historical run during reference period *T̄*.

For log-normally distributed variables(*Y*):
$${Y}^{fut'}\_{y,k} =e^{\\ln\\bar{Y}^{hind}\_{k,\\bar{T}} +\\left( \\frac{\\hat{\\sigma}^{hind}\_{k,\\bar{T}}}{\\hat{\\sigma}^{hist}\_{k,\\bar{T}}}\*(\\ln{Y}^{fut}\_{t,k}-\\ln\\bar{Y}^{hist}\_{k,\\bar{T}})  \\right )}$$
, where *σ̂*<sub>*k*, *T̄*</sub><sup>*h**i**s**t*</sup> and
*σ̂*<sub>*k*, *T̄*</sub><sup>*h**i**n**d*</sup> are the standard deviation
of the ln *Ȳ*<sub>*k*, *t*</sub><sup>*h**i**s**t*</sup> and
ln *Ȳ*<sub>*k*, *t*</sub><sup>*h**i**n**d*</sup> during the reference
period *T̂* (respectively).

### Weekly indices

Uses the strata x weekly data (‘ACLIMregion’) to generate
strata-specific averages in order to generate the strata area-weighted
averages for each week *w* each year *y*.

$$\\bar{Y}\_{w,y,k}= \\frac{\\sum^{n_s}\_{l}(\\frac{1}{n_i}\\sum^{n_t}\_{t}Y\_{k,w,y,s,t})\*A_s} {\\sum^{n_s}\_{s}{A_s}}$$
, where *Y*<sub>*k*, *w*, *y*, *s*, *t*</sub> is the value of the
variable *k* in strata *s* at time *t* in year *y*, *A*<sub>*s*</sub> is
the area of strata *s*, *n*<sub>*i*</sub> is the number of stations in
strata *s*, and *n*<sub>*s*</sub> is the number of strata *s* in each
basin (NEBS or SEBS).

*Ȳ*<sub>*w*, *y*, *k*</sub> was calculated for the hindcast, historical
run, and projection time-series. For projections
*Ȳ*<sub>*w*, *y*, *k*</sub> was bias corrected using the corresponding
historical and hindcast values such that:

$$\\bar{Y}^{fut'}\_{w,y,k} =\\bar{Y}^{hind}\_{w,k} +\\left( \\frac{\\sigma^{hind}\_{w,k}}{\\sigma^{hist}\_{w,k}}\*(\\bar{Y}^{fut}\_{w,y,k}-\\bar{Y}^{hist}\_{w,k})  \\right )$$
, where *Ȳ*<sub>*w*, *k*</sub><sup>*h**i**s**t*</sup> and
*Ȳ*<sub>*w*, *k*</sub><sup>*h**i**n**d*</sup> are the average historical
weekly values across years in the period (1980 to 2012 ; adjustable in
`R/setup.R`).

### Monthly indices

Uses the strata x weekly data (‘ACLIMregion’) to generate
strata-specific averages in order to generate the strata area-weighted
averages for each month *m* each year *y*.

$$\\bar{Y}\_{m,y,k}= \\frac{1}{n_w}\\sum^{n_w}\_{w}\\bar{Y}\_{w,y,k}$$
, where *Ȳ*<sub>*w*, *y*, *k*</sub> are the weekly average indices for
variable *k* in year *y* from the previous step ,*n*<sub>*w*</sub> is
the number of weeks in each month *m*.

*Ȳ*<sub>*m*, *y*, *k*</sub> was calculated for the hindcast, historical
run, and projection time-series. For projections
*Ȳ*<sub>*m*, *y*, *k*</sub> was bias corrected using the corresponding
historical and hindcast values such that:

$$\\bar{Y}^{fut'}\_{m,y,k} =\\bar{Y}^{hind}\_{m,k} +\\left( \\frac{\\sigma^{hind}\_{m,k}}{\\sigma^{hist}\_{m,k}}\*(\\bar{Y}^{fut}\_{m,y,k}-\\bar{Y}^{hist}\_{m,k})  \\right )$$
, where *Ȳ*<sub>*m*, *k*</sub><sup>*h**i**s**t*</sup> and
*Ȳ*<sub>*m*, *k*</sub><sup>*h**i**n**d*</sup> are the average historical
monthly values across years in the period (1980 to 2012 ; adjustable in
`R/setup.R`).

### Seasonal indices

Uses the strata x weekly data (‘ACLIMregion’) to generate
strata-specific averages in order to generate the strata area-weighted
averages for each season *l* each year *y*.

$$\\bar{Y}\_{l,y,k}= \\frac{1}{n_w}\\sum^{n_w}\_{w}\\bar{Y}\_{w,y,k}$$
, where *Ȳ*<sub>*w*, *y*, *k*</sub> are the weekly average indices for
variable *k* in year *y* from the previous step ,*n*<sub>*w*</sub> is
the number of weeks in each season *l*.

*Ȳ*<sub>*l*, *y*, *k*</sub> was calculated for the hindcast, historical
run, and projection time-series. For projections
*Ȳ*<sub>*l*, *y*, *k*</sub> was bias corrected using the corresponding
historical and hindcast values such that:

$$\\bar{Y}^{fut'}\_{l,y,k} =\\bar{Y}^{hind}\_{l,k} +\\left( \\frac{\\sigma^{hind}\_{l,k}}{\\sigma^{hist}\_{l,k}}\*(\\bar{Y}^{fut}\_{l,y,k}-\\bar{Y}^{hist}\_{l,k})  \\right )$$
, where *Ȳ*<sub>*l*, *k*</sub><sup>*h**i**s**t*</sup> and
*Ȳ*<sub>*l*, *k*</sub><sup>*h**i**n**d*</sup> are the average historical
seasonal values across years in the reference period (1980 to 2012 ;
adjustable in `R/setup.R`).

### Annual indices

Uses the strata x weekly data (‘ACLIMregion’) to generate
strata-specific averages in order to generate the strata area-weighted
averages for each season *l* each year *y*.

$$\\bar{Y}\_{y,k}= \\frac{1}{n_w}\\sum^{n_w}\_{w}\\bar{Y}\_{w,y,k}$$
, where *Ȳ*<sub>*w*, *y*, *k*</sub> are the weekly average indices for
variable *k* in year *y* from the previous step ,*n*<sub>*w*</sub> is
the number of weeks in each year *y*.

*Ȳ*<sub>*y*, *k*</sub> was calculated for the hindcast, historical run,
and projection time-series. For projections *Ȳ*<sub>*y*, *k*</sub> was
bias corrected using the corresponding historical and hindcast values
such that:

$$\\bar{Y}^{fut'}\_{y,k} =\\bar{Y}^{hind}\_{k} +\\left( \\frac{\\sigma^{hind}\_{k}}{\\sigma^{hist}\_{k}}\*(\\bar{Y}^{fut}\_{y,k}-\\bar{Y}^{hist}\_{k})  \\right )$$
, where *Ȳ*<sub>*k*</sub><sup>*h**i**n**d*</sup> and
*Ȳ*<sub>*k*</sub><sup>*h**i**s**t*</sup> are the average historical
values across years in the reference period (1980 to 2012 ; adjustable
in `R/setup.R`).

### Annual survey rep. indices

Uses the station specific survey replicated (in time and space) data
(‘ACLIMsurveyrep’) to generate strata-specific averages in order to
generate the strata area-weighted averages for each year *y*.

$$\\bar{Y}\_{y,k}= \\frac{\\sum^{n_s}\_{l}(\\frac{1}{n_i}\\sum^{n_i}\_{i}Y\_{k,y,s,i})\*A_s} {\\sum^{n_s}\_{s}{A_s}}$$
, where *Y*<sub>*k*, *y*, *s*, *i*</sub> is the value of the variable
*k* at station *i* in strata *s* in year *y*, *A*<sub>*s*</sub> is the
area of strata *s*, *n*<sub>*i*</sub> is the number of stations in
strata *s*, and *n*<sub>*s*</sub> is the number of strata *s* in each
basin (NEBS or SEBS).

*Ȳ*<sub>*y*, *k*</sub> was calculated for the hindcast, historical run,
and projection time-series. For projections *Ȳ*<sub>*y*, *k*</sub> was
bias corrected using the corresponding historical and hindcast values
such that:

$$\\bar{Y}^{fut'}\_{y,k} =\\bar{Y}^{hind}\_{k} +\\left( \\frac{\\sigma^{hind}\_{k}}{\\sigma^{hist}\_{k}}\*(\\bar{Y}^{fut}\_{y,k}-\\bar{Y}^{hist}\_{k})  \\right )$$
, where *Ȳ*<sub>*k*</sub><sup>*h**i**n**d*</sup> and
*Ȳ*<sub>*k*</sub><sup>*h**i**s**t*</sup> are the average historical
values across years in the reference period (1980 to 2012 ; adjustable
in `R/setup.R`).

Appendix A includes the code used to generate the ACLIM2 indices and
bias correct them. That code can be run to re-make the indices if you
like but takes approx 30 mins a CMIP to run.

# Explore ACLIM2 Indices

The following code will open an interactive shiny() app for exploring
the indices. You can also view this online at
(kkh2022.shinyapps.io/ACLIM2_indices)\[<https://kkh2022.shinyapps.io/ACLIM2_indices/>\].

``` r
shiny::runApp("/Users/kholsman/Documents/GitHub/ACLIM2/R/shiny_aclim/ACLIM2_indices/app.R")
```

<figure>
<img src="Figs/biascorrected_temp2.png" style="width:100.0%" alt="“Raw (top row) and bias corrected (bottom row)bottom temperature indices based on survey replicated Level3 outputs for the SEBS”" /><figcaption aria-hidden="true">“Raw (top row) and bias corrected (bottom row)bottom temperature indices based on survey replicated Level3 outputs for the SEBS”</figcaption>
</figure>

## Annual indices

````` r
    # --------------------------------------
    # SETUP WORKSPACE
    main   <- getwd()  #"~/GitHub_new/ACLIM2"
    
    # loads packages, data, setup, etc.
    suppressMessages(source("R/make.R"))
    
    
    # load the Indices:
    fldr <- "Data/out/K20P19_CMIP6/allEBS_means"
    dirlist <-grep ("annual", dir(fldr))
    for(d in dirlist)
      load(file.path(fldr,d))
    hnd <- ACLIM_annual_fut_mn
    
````

## Monthly indices

## Seasonal indices

## weekly indices

# Output to .dat file (ADMB/ TMB users)

# Special cases {.tabset}

## monthly indices (Andy)
`````

## NRS indices (André)

## Salmon index (Ellen)

## NFS index (Jeremy )

# APPENDIX A: Create indices and bias correct CMIP6 projections

The following code shows how the ACLIM2 indices and bias correction was
done. You do not need to re-run this (it is included so you can if you
want to). To explore the indices skep to the next section.

``` r
    # --------------------------------------
    # SETUP WORKSPACE
    # setwd("Documents/GitHub/ACLIM2")
    tmstp  <- format(Sys.time(), "%Y_%m_%d")
    main   <- getwd()  #"~/GitHub_new/ACLIM2"
    
    # loads packages, data, setup, etc.
    suppressMessages(source("R/make.R"))
    
    tmstamp1  <- format(Sys.time(), "%Y%m%d")
    # tmstamp1  <- "20220428"
    
    update_hind  <- TRUE   # set to true to update hind and hindS; needed annually
    update_proj  <- TRUE   # set to true to update fut; not needed
    update_hist  <- TRUE   # set to true to update fut; not needed
     
    # the reference years for bias correcting in R/setup.R
    ref_years 
    
    # the year to z-score scale / delta in R/setup.R
    deltayrs 
    
    # remove these variables:
    vl1 <- srvy_vars[!srvy_vars%in%c("station_id","latitude",
                                    "longitude","stratum","doy",
                                  "Iron_bottom5m","Iron_integrated",
                                  "Iron_surface5m","prod_Eup_integrated",
                                  "prod_NCa_integrated")]
    vl2 <- weekly_vars[!weekly_vars%in%c("station_id","latitude",
                                    "longitude","stratum","doy",
                                  "Iron_bottom5m","Iron_integrated",
                                  "Iron_surface5m","prod_Eup_integrated",
                                  "prod_NCa_integrated")]
    vl<-unique(c(vl1,vl2))
    # add in largeZoop (gets generated in make_indices_region_new.R)
    vl <- c(vl,"largeZoop_integrated")

    # Identify which variables would be normally 
    # distributed (i.e., can have negative values)
     normvl <- c("shflux","ssflux","temp_bottom5m",
      "temp_integrated","temp_surface5m",
      "uEast_bottom5m","uEast_surface5m",
      "vNorth_bottom5m","vNorth_surface5m")

    normlist <- data.frame(var = vl, lognorm = TRUE)
    normlist$lognorm[normlist$var%in%normvl] <- FALSE

    
    # generate indices and bias corrected projections 
    # This takes approx 30 mins each
    
    gcmcmipL <- c("B10K-K20P19_CMIP6_miroc",
                  "B10K-K20P19_CMIP6_gfdl",
                  "B10K-K20P19_CMIP6_cesm") 
    CMIP6_Indices <- suppressMessages(
                        makeACLIM2_Indices(
                        BC_target = "mn_val",
                        hind_sim  =  "B10K-K20_CORECFS",
                        histLIST  = paste0(gcmcmipL,"_historical"),
                        gcmcmipLIST = gcmcmipL,
                        sim_listIN = sim_list[-grep("historical",sim_list)]))
    
     if("CMIP6_Indices"%in%ls()){                 
      save_indices(flIN = CMIP6_Indices, 
                   subfl = "allEBS_means",
                   post_txt = "_mn",
                   CMIP_fdlr ="K20P19_CMIP6")
      fl <- "Data/out/CMIP6_Indices_List.Rdata"
      
      if(file.exists(fl)) file.remove(fl)
      save(CMIP6_Indices, file = fl)
      rm(CMIP6_Indices)
      gc()
     }
    # CMIP5 K20P19
    gcmcmipL2 <- c("B10K-K20P19_CMIP5_MIROC","B10K-K20P19_CMIP5_GFDL","B10K-K20P19_CMIP5_CESM") 
    CMIP5_K20_Indices <- suppressMessages(
                        makeACLIM2_Indices(
                        BC_target = "mn_val",
                        hind_sim  =  "B10K-K20_CORECFS",
                        histLIST  = paste0(gcmcmipL,"_historical"),
                        gcmcmipLIST = gcmcmipL2,
                        sim_listIN = sim_list[-grep("historical",sim_list)]))
    
    if("CMIP5_K20_Indices"%in%ls()){
        save_indices(flIN = CMIP5_K20_Indices, 
                     subfl = "allEBS_means",
                     post_txt = "_mn",
                     CMIP_fdlr ="K20P19_CMIP5")
        
        fl <- "Data/out/CMIP5_K20_Indices_List.Rdata"
        if(file.exists(fl)) file.remove(fl)
        save(CMIP5_K20_Indices, file = fl)
        rm(CMIP5_K20_Indices)
        gc()
    }
    # CMIP5 H16
    gcmcmipL2 <- c("B10K-H16_CMIP5_MIROC","B10K-H16_CMIP5_GFDL","B10K-H16_CMIP5_CESM") 
    CMIP5_H16_Indices <- suppressMessages(
                        makeACLIM2_Indices(
                        BC_target = "mn_val",
                        hind_sim  =  "B10K-H16_CORECFS",
                        histLIST  = rep("B10K-H16_CORECFS",3),
                        gcmcmipLIST = gcmcmipL2,
                        sim_listIN = sim_list[-grep("historical",sim_list)]))
    if("CMIP5_H16_Indices"%in%ls()){
      save_indices(flIN = CMIP5_H16_Indices, 
                   subfl = "allEBS_means",
                   post_txt = "_mn",
                   CMIP_fdlr ="H16_CMIP5")
     
      fl <- "Data/out/CMIP5_H16_Indices_List.Rdata"
      if(file.exists(fl)) file.remove(fl)
      save(CMIP5_H16_Indices, file = fl)
      rm(CMIP5_H16_Indices)
      gc()
    }
    if(1==10){
      save(CMIP6_Indices, file = "Data/out/CMIP6_Indices_List.Rdata")
      save(CMIP5_K20_Indices, file = "Data/out/CMIP5_K20_Indices_List.Rdata")
      save(CMIP5_H16_Indices, file = "Data/out/CMIP5_H16_Indices_List.Rdata")
    }
```

<figure>
<img src="Figs/Hind_Sept_large_Zoop.jpg" style="width:75.0%" alt="September large zooplankton integrated concentration" /><figcaption aria-hidden="true">September large zooplankton integrated concentration</figcaption>
</figure>

# misc

$$B0^k\_{input}= \\bar{B0}^k\_{(2004:2014)}\\left(\\frac{B0^{a}\_{2015}}{\\bar{B0}^a\_{(2004:2014)}}\\right) $$
Where B0kinput is the unfished biomass used for setting inputs of (e.g.,
B0ktarget = 0.4B0kinput) and is determined by re-scaling the spawning
stock biomass from the status quo assessment in 2015 (B0a2015) to the
average model spawning stock biomass for your model between 2004-2014
(i.e., B0k) using the average unfished biomass from the stock assessment
model during the same period (B0a).
