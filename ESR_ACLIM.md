---
title: "ACLIM2 ESR indices"
author: K. Holsman
always_allow_html: true
output:
  word_document:
    fig_caption: yes
    fig_width: 4
    keep_md: yes
  header-includes:
  - \usepackage{knputenc}
  - \usepackage{unicode-math}
  - \pagenumbering{gobble}
  - \documentclass{article}
  - \usepackage{amsmath}
  pdf_document:
    toc: TRUE
    toc_depth: 3
    fig_caption: yes
    fig_height: 4
    fig_width: 5
    highlight: tango
    keep_tex: yes
    latex_engine: xelatex
  html_document:
    df_print: paged
    toc: true
    toc_depth: 3
    number_sections: true
    toc_float:
      collapsed: false
      smooth_scroll: true
#runtime: shiny
---


```
## Warning: package 'shiny' was built under R version 4.1.3
```

```
## Warning: package 'ggnewscale' was built under R version 4.1.3
```




## High resolution climate change projections for the Eastern Bering Sea
Albert Hermann, Wei Cheng, Kelly Kearney, Darren Pilcher, Kerim Aydin, Ivonne Ortiz, Kirstin K. Holsman*

*ESR contribution POC: Kirstin Holsman (kirstin.holsman@noaa.gov)

Alaska Fisheries Science Center, NOAA, 7600 Sand Point Way N.E., Bld. 4, Seattle, Washington 98115

**Last Updated: October 2022** 

## Summary statement:

Projections of a high resolution oceanographic model for the Bering Sea projects wide spread warming across the region under high emission scenarios (SSP585) with bottom temperatures exceeding historical ranges by mid-century onward. Low emission scenarios also project less warming over the next century but modeled temperatures do not exceed historical ranges (1980-2013) under the latter part of the century. *[ADD Caveat - ? Model results are not observations and should be considered in the context of ongoing ocean observations].*
Under both low and high emission scenarios the model projects continued declines in ocean pH in bottom waters of the both the North and Southern Bering Sea, especially during winter months but declines are markedly larger and reach thresholds associated with decreased survival of crab larvae (7.8 Long et al. 20XX) by mid-century, and critical thresholds of high larval mortality by end of century (7.5 Long et al. 20xx). 

## Status and trends:  
Summer bottom temperatures in both the SEBS and NEBS are projected to increase, with higher rates of warming associated with higher greenhouse gas emission scenarios (SSP585). There is general agreement in all three models with respect to trends in warming and across the three GCMS. For the SEBS, estimates of end of century warming [2080-2100] range from 0.7 to 4.2 deg C and 2.8 to 6.1 deg C for SSP126 and SSP585, respectively. For the NEBS, estimates of end of century warming of bottom temperatures [(2080-2100)-(1980-2000)] range from +0.5 to +5.4 deg C and +2.6 to +7.8 deg C for SSP126 and SSP585, respectively. In high emission scenarios, bottom temperatures for the SEBS and NEBS are projected to consistently to exceed the upper range of historical temperatures predicted from the hindcast between 2050 and 2060. Model projected patterns for SST are similar to those of bottom temperature and with high agreement for all three models under SSP585. Under higher emission scenarios (SSP585), of century SST range from 13.5 to 16.2 deg. C for the SEBS (historically mean of 9.7 deg C) and range from 12.3 to 15.7 deg. C for the NEBS (historically 8.3 deg. C). 

[add pH details]

## Factors influencing observed trends
[ Kirstin to add statements from IPCC Ar6 WGI]
* uptake of CO2 by oceans
* uptake of atmospheric heat by oceans 

Global increases in warming driven of approximately 1.1 deg. C over postindustrial timeperiod is associated with significant warming of the world's oceans and ....[ use details from IPCC AR6]

## Implications: 


## Description of index: 

We report trends in modeled bottom temperature and modeled bottom pH from the Bering10K K20P19 Regional Oceanographic model projected under ACLIM2 CMIP6 simulations. The IEA operational hindcast and the ACLIM2 projections presented here are based on the K20P19 30-layer variant of the Bering10K model that merges the biological module source code and parameter updates from the K20 version (Kearney et al. 2020) with the carbonate chemistry updates from the P19 (Pilcher et al. 2019) version. See the [Bering 10K dataset documentation](https://zenodo.org/record/4586950/files/Bering10K_dataset_documentation.pdf) for more information and technical details. The two climate scenarios and three global General Circulation Models (GCMs) were selected from the Coupled Model Intercomparison Project phase 6 (CMIP6) and used to force the boundary conditions of the regional model. See Hermann et al. 2021, Cheng et al. 2021, Kearney et al. 2020, and Pilcher et al. 2019 for details about model parameterization and Hollowed et al. 2020 for details about the Alaska Climate Integrated Modeling project and climate and GCM selection. 

In support of the [Alaska Climate Integrated Modeling (ACLIM) project](www.fisheries.noaa.gov/alaska/ecosystems/alaska-climate-integrated-modeling-project), a number of different biophysical index timeseries were calculated based on the Bering10K simulations and provide the primary means of linking the physical and lower trophic level dynamics simulated by the Bering10K long-term forecast simulations to the ACLIM suite of upper trophic level and socioeconomic models; see Hollowed et al. [2020]() for further details.The timeseries reported here are derived from the area-weighted strata averages for Summer (months 7:9) and Winter for the Northern Bering Sea (strata 70, 81, 82, 90) and Southern Bering sea. The timerseries were bias corrected to the IEA operational hindcast using historical runs for each GCM. More detail on this approach is available by request.

The climate simulations presented here are dynamically downscaled from a selection of the historical and shared socioeconomic pathway simulations from the sixth phase of the [Climate Model Intercomparison Project (CMIP6)](https://www.wcrp-climate.org/wgcm-cmip/wgcm-cmip6). Names reflect the parent model simulation (miroc
= MIROC ES2L, cesm = CESM2, gfdl = GFDL ESM4) and emissions scenario via Shared Socioeconomic Pathways (SSPs) (ssp126 = SSP1-2.6, ssp585 = SSP5-8.5, historical = Historical). SSP126 represents a lower atmospheric carbon emissions scenario; SSP585 represents the high baseline emissions scenario. More information on the SSPs and their use in climate projections is available at O'Neil et al. [2017](
https://link.springer.com/article/10.1007/s10584-013-0905-2).


## Literature Cited
Hermann et al., 2021 A.J. Hermann, K. Kearney, W. Cheng, D. Pilcher, K. Aydin, K.K. Holsman, et al.
Coupled modes of projected regional change in the Bering Sea from a dynamically downscaling model under CMIP6 forcing Deep-Sea Res. II (2021), 10.1016/j.dsr2.2021.104974 194 104974

Cheng et al., 2021 W. Cheng, A.J. Hermann, A.B. Hollowed, K.K. Holsman, K.A. Kearney, D.J. Pilcher, et al.
Eastern Bering Sea shelf environmental and lower trophic level responses to climate forcing: results of dynamical downscaling from CMIP6 Deep-Sea Res. II, 193 (2021), Article 104975, 10.1016/j.dsr2.2021.104975

K. Kearney, A. Hermann, W. Cheng, I. Ortiz, and K. Aydin. A coupled pelagicbenthic-sympagic biogeochemical
model for the Bering Sea: documentation and validation of the BESTNPZ model (v2019.08.23) within a highresolution regional ocean model. Geoscientific Model Development, 13 (2):597–650, 2020. DOI: 10.5194/gmd13-597-2020. URL https://www.geosci-model-dev.net/13/597/2020/10 https://github.com/beringnpz/roms-bering-sea

Pilcher, D. J.,  D. M. Naiman, J. N. Cross, A. J. Hermann, S. A. Siedlecki, G. A. Gibson, and J. T. Mathis. Modeled Effect of Coastal Biogeochemical Processes, Climate Variability, and Ocean Acidification on Aragonite Saturation State in the Bering Sea. Frontiers in Marine Science, 5(January):1–18, 2019. DOI: 10.3389/fmars.2018.00508
12 https://github.com/beringnpz/ roms-bering-sea

Hollowed, K. K. Holsman, A. C. Haynie, A. J. Hermann, A. E. Punt, K. Y. Aydin, J. N. Ianelli, S. Kasperski,
W. Cheng, A. Faig, K. Kearney, J. C. P. Reum, P. D. Spencer, I. Spies, W. J. Stockhausen, C. S. Szuwalski, G. Whitehouse, and T. K. Wilderbuer. Integrated modeling to evaluate climate change impacts on coupled social-ecological systems in Alaska. Frontiers in Marine Science, 6(January):1–18, 2020. DOI: 10.3389/fmars.2019.00775


Projections of the high resolution Bering10K 30 layer model for the Eastern Bering Sea. For more information see Hermman et al. 2021, Kearney et al. 2020 and Pilcher et al. 2019. For more information about climate scenarios selection see the Alaska Climate Integrate Modeling project (ACLIM) website at www.fisheries.noaa.gov/alaska/ecosystems/alaska-climate-integrated-modeling-project and the Alaska NOAA Integrated Ecosystem Assessment program www.integratedecosystemassessment.noaa.gov


## Figures: 

![Bias corrected summer bottom temperature and winter pH for the SEBS under low (SSP126) and high (SSP585) emission scenarios).](ESR_EBS/Figs/annualTS_SSTBT.png){ width=100% }

![Bias corrected summer bottom temperature and winter pH for the SEBS under low (SSP126) and high (SSP585) emission scenarios).](ESR_EBS/Figs/annualTS.png){ width=100% }



![Bottom water temperature (degC) pojected under two climate scenarios ( high carbon mitigation (ssp126); low carbon mitigation, (SSP585) from three General Circulation Models (GCMs) dynamically downscaled to a high resolution regional model (Bering10K 30 layer ROMSNPZ model).  2022).](ESR_EBS/Figs/nonBC_weeklyProj_BT.png){ width=100% }

![Bottom water temperature (degC) pojected under two climate scenarios ( high carbon mitigation (ssp126); low carbon mitigation, (SSP585) from three General Circulation Models (GCMs) dynamically downscaled to a high resolution regional model (Bering10K 30 layer ROMSNPZ model).](ESR_EBS/Figs/nonBC_weeklyProj_BT_N.png){ width=100% }

![Bottom water pH pojected under two climate scenarios ( high carbon mitigation (ssp126); low carbon mitigation, (SSP585) from three General Circulation Models (GCMs) dynamically downscaled to a high resolution regional model (Bering10K 30 layer ROMSNPZ model).](ESR_EBS/Figs/nonBC_weeklyProj_pH.png){ width=100% }

![Bottom water pH pojected under two climate scenarios ( high carbon mitigation (ssp126); low carbon mitigation, (SSP585) from three General Circulation Models (GCMs) dynamically downscaled to a high resolution regional model (Bering10K 30 layer ROMSNPZ model).](ESR_EBS/Figs/nonBC_weeklyProj_pH_N.png){ width=100% }



