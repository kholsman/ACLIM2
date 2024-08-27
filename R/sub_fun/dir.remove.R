dir.remove<-function(x){
  eval(parse(text=paste0("system('rm -r ",x,"')")))
}