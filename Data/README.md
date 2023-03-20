# Main data folder for ACLIM2 indices


## Get the data
* Go to the google drive and download the zipped file with the R ACLIM2 indices `ACLIM2_indices.zip`:
* [00_ACLIM_shared > 02_Data > Newest_Data(use this) > unzip_and_put_in_dat_out_folder_CMIP6](https://drive.google.com/drive/u/1/folders/1clPtrPCQMPcwqr8UE78_Sd2IGwyBuDcD)
[00_ACLIM_shared > 02_Data > Newest_Data(use this) > unzip_and_put_in_dat_out_folder_CMIP5](https://drive.google.com/drive/u/1/folders/1t_JqDBQU-Fyy5nvIYRAmVcqzWi4mq7mk)

* Unzip `K29P19_CMIP5.zip` or `K29P19_CMIP6.zip` files move the `K29P19_CMIP5` or `K29P19_CMIP6` folders to your local folder `ACLIM2/Data/out`. The result should be the following folder structure on your local computer:  
* `ACLIM2/Data/out/K29P19_CMIP6/allEBSmeans`: main folder with annual, monthly, seasonal, and survey replicated level 4 ACLIM indices
* `ACLIM2/Data/out/K29P19_CMIP6/BC_ACLIMregion`: Weekly x Strata based indices, including delta and bias corrected values (these are "rolled up" to become strata AREA weighted mean vals in the allEBSmeans folder).
* `ACLIM2/Data/out/K29P19_CMIP6/BC_ACLIMsurveyrep`: Survey replicated indices at each station, including delta and bias corrected values (these are "rolled up" to become average across station mean vals in the allEBSmeans folder).

* `ACLIM2/Data/out/K29P19_CMIP6/allEBSmeans`: as above but for CMIP5
* `ACLIM2/Data/out/K29P19_CMIP6/allEBSmeans`: as above but for CMIP5
* `ACLIM2/Data/out/K29P19_CMIP6/allEBSmeans`: as above but for CMIP5

### CMIP6


### CMIP5


## Individual models

Temperature anomalies for individual models can be found in separate folders for [cmip6](temperatures/cmip6/csv/) and [cmip5](temperatures/cmip5/csv/)

### Example
The data is available in csv files:
``` csv
model, ens, exp, postprocess, table, grid, varn, period, mean
CAMS-CSM1-0, r1i1p1f1, ssp119, global_mean, Amon, gn, tas, 2021-2040, 1.07
CNRM-ESM2-1, r1i1p1f2, ssp119, global_mean, Amon, gr, tas, 2021-2040, 1.32
CanESM5, r1i1p1f1, ssp119, global_mean, Amon, gn, tas, 2021-2040, 2.16
...
```

### Files

There are two files with [cmip6](temperatures/cmip6/csv/) data. One with one ensemble member per model and one with all ensemble members. For [cmip5](temperatures/cmip5/csv/) two additional files are provided. The reference period is 1850 to 1900, however, many cmip5 models only start after 1850 and are therefore excluded. These models are also included in the `*_no_bounds_check.yml` files.

## Data
 * Weekly strata temperature, productivity, and other data for `historical` and `projections` for each General Circulation Model (`GCM`)
   * `RCP4.5` and `RCP8.5` (CMIP5)
   * `SSP1-2.6` and `SSP5-8.5` (CMIP6)


## Acknowledgment

We thank the Alaska Climate Integrated Modeling project for downloading, curating, and sharing the dynamically down-scaled CMIP5 and CMIP6 data via the National Oceanic and Atmospheric Administration Alaska Fisheries Science Center and the University of Washington, Seattle, USA.

## License

CMIP TEMPERATURES is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License.

A copy of the license is availabe at [LICENSE](LICENSE). If not, see [CC BY-SA 4.0](http://creativecommons.org/licenses/by-sa/4.0/).

### CMIP5 Data License Statement

The underlying raw data are published under the license of CMIP5. Terms of use for CMIP5 are applied for the derived data presented here. They are provided at https://pcmdi.llnl.gov/mips/cmip5/terms-of-use.html. Data from some modelling centres are licensed for use in non-commercial research and for educational purposes, other for unrestricted use. Please refer to the [terms of use for the CMIP5 modeling groups](https://pcmdi.llnl.gov/mips/cmip5/docs/CMIP5_modeling_groups.pdf) for details.
The data should be cited by its DOI and according to the [citation recommendation of CMIP5](https://pcmdi.llnl.gov/mips/cmip5/citation.html).

### CMIP6 Data License Statement

The raw CMIP6 data are licensed under Creative Commons [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0), following the [CMIP6 Terms of Use](https://pcmdi.llnl.gov/CMIP6/TermsOfUse). Note that some models publish the data under a non-commercial license ([CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/)). The license for each particular model dataset can be obtained at the [ESGF CoG portal](https://esgf-node.llnl.gov/search/cmip6) as part of the data citation information.


### CMIP5

We acknowledge the World Climate Research Programme's Working Group on Coupled Modelling, which is responsible for CMIP, and we thank the climate modeling groups (listed in [cmip5_models.md](cmip5_models.md)) for producing and making available their model output. For CMIP the U.S. Department of Energy's Program for Climate Model Diagnosis and Intercomparison provides coordinating support and led development of software infrastructure in partnership with the Global Organization for Earth System Science Portals.”

### CMIP6

We acknowledge the World Climate Research Programme, which, through its Working Group on Coupled Modelling, coordinated and promoted CMIP6. We thank the climate modeling groups for producing and making available their model output, the Earth System Grid Federation (ESGF) for archiving the data and providing access, and the multiple funding agencies who support CMIP6 and ESGF.
