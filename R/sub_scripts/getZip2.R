# getZip2.R

# download the file
download.file(url=url, destfile=destfile)
tmp_wd <- getwd()
# get root directory
tt     <- strsplit(destfile,"/")
ex_dir <- substr(destfile,1,nchar(destfile)-4)
tt     <- tt[[1]][length(tt[[1]])]

# create directory
if(!dir.exists(ex_dir)) dir.create(ex_dir)
setwd(ex_dir)

# unzip it
unzip(zipfile=file.path(tmp_wd,destfile),exdir = file.path(tmp_wd,ex_dir),overwrite = T)

setwd(tmp_wd)
# cleanup
if(deletezip)  file.remove(destfile)
