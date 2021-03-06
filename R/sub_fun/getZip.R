getZip <- function(urlIN,destfileIN,deletezip=T){
  
  # download the file
  download.file(url=urlIN, destfile=destfileIN)
  tmp_wd <- getwd()
  # get root directory
  tt     <- strsplit(destfileIN,"/")
  ex_dir <- substr(destfileIN,1,nchar(destfileIN)-4)
  tt     <- tt[[1]][length(tt[[1]])]
  
  # create directory
  if(!dir.exists(ex_dir)) dir.create(ex_dir)
  setwd(ex_dir)
  
  # unzip it
  unzip(zipfile=file.path(tmp_wd,destfileIN),exdir = file.path(tmp_wd,ex_dir),overwrite = T)
  
  setwd(tmp_wd)
  # cleanup
  if(deletezip)  file.remove(destfileIN)
  
  
}