getZip <- function(urlIN,destfileIN,deletezip=T){
  
  # download the file
  download.file(url=urlIN, destfile=destfileIN)
  tmp_wd <- getwd()
  # get root directory
  tt     <- strsplit(destfileIN,"/")
  ex_dir <- substr(destfileIN,1,nchar(destfileIN)-4)
  ex_dir <- paste0(tt[[1]][-length(tt[[1]])],collapse="/")
  tt     <- tt[[1]][length(tt[[1]])]
  
  # create directory
  if(!dir.exists(ex_dir)) dir.create(ex_dir)
  #setwd(ex_dir)
  
  # unzip it
  unzip(zipfile=destfileIN,exdir = ex_dir,overwrite = T)
  
  #setwd(tmp_wd)
  # cleanup
  if(deletezip)  file.remove(destfileIN)
  
  
}