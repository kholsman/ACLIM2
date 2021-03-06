getZip <- function(url,destfile,deletezip=F){
  download.file(url=url, destfile=destfile)
  tmp_wd <- getwd()
  
  tt     <- strsplit(destfile,"/")
  ex_dir <- substr(destfile,1,nchar(destfile)-4)
  tt     <- tt[[1]][length(tt[[1]])]
  
  
  if(!dir.exists(ex_dir)) dir.create(ex_dir)
  #setwd(substr(tt,1,nchar(tt)-4))
  unzip(destfile,exdir = ex_dir,overwrite = T)
  
  if(deletezip)
    file.remove(destfile)
  setwd(tmp_wd)
  
}