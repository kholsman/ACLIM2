## convert markdown doc to read me file for github
rmd2md <- function(rmd_fl = "README_Holsman_EBMpaper",md_fl = "README"){
  library(rmarkdown)
  render(paste0(rmd_fl,".Rmd"), md_document(variant = "markdown_github"),params=F)
  file.copy(from=paste0(rmd_fl,".md"),to=paste0(md_fl,".md"),overwrite=T)
}

