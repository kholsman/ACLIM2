getZip <- function(url,destfile, deletezip=T){
  download.file(url=url, destfile=destfile)
  unzip (destfile, exdir = "./",overwrite = T)
  if(deletezip)
    file.remove(destfile)
}