#'
#'
#'
#'
#'profile_attach.R
#'
#'This code generaes species profiles from attach for use in CEATTLE
#'


library(catchfunction)
library(progress)
library(ggplot2)
library(dplyr)

attach_sp <- c("Arrowtooth", "Atka", "Flathead", "Greenland", "Kamchatka", 
"Northern", "Octopus", "OtherFlat", "OtherRock", "PCod", "Plaice", "POP", 
"Pollock", "Rock", "Rougheye", "Sablefish", "Sculpin", "Shark", "Shortraker", 
"Skate", "Squid", "Yellowfin")

abc_sim <- c(0.01,seq(0,10,2)[-1]*1e6)
simdat  <- expand.grid(scenario=1:3, PollockABC=abc_sim,PCodABC=abc_sim/10,ArrowtoothABC=abc_sim/10)
simdat$id <- 1:dim(simdat)[1]
pb <- progress_bar$new(
  format = "  profiling [:bar] :percent eta: :eta",
  total = dim(simdat)[1], clear = FALSE, width= 60)


for(i in 1:(dim(simdat)[1])){
  
  tmp <- catch_function(
    scenario   = simdat$scenario[i],
    Pollock    = simdat$PollockABC[i],
    PCod       = simdat$PCodABC[i],
    Arrowtooth = simdat$ArrowtoothABC[i])
  tmp$id <- i
  if(i==1){
    out <- tmp
  }else{
    out <- rbind(out,tmp)
  }
  pb$tick()
  Sys.sleep(1 / dim(simdat)[1])
    
}
rm(pb)
abcsub <- abc_sim[seq(1,length(abc_sim),round(length(abc_sim)/5))]

dat <- (simdat%>%left_join(out))
#save(dat,file= "Data/NotShared/profile_attach2022.Rdata")

ggplot(na.omit(dat)) + 
  geom_point(aes(x=PollockABC,y =Pollock, color=(PCodABC)))+
  facet_grid(factor(ArrowtoothABC)~scenario)+theme_minimal()


ggplot(dat%>%filter(ArrowtoothABC%in%(abcsub/10),PCodABC%in%(abcsub/10))) + 
  geom_line(aes(x=PollockABC,y =Pollock, color=factor(PCodABC)),size=1)+
  facet_grid(factor(ArrowtoothABC)~scenario)+theme_minimal()

ggplot(dat%>%filter(ArrowtoothABC%in%(abcsub/10),PCodABC%in%(abcsub/10))) + 
  geom_line(aes(x=PCodABC,y =Pollock, color=factor(PollockABC)),size=1)+
  facet_grid(factor(ArrowtoothABC)~scenario)+theme_minimal()

ggplot(dat%>%filter(ArrowtoothABC%in%(abcsub/10),PCodABC%in%(abcsub/10))) + 
  geom_line(aes(x=ArrowtoothABC,y =Pollock, color=factor(PollockABC)),size=1)+
  facet_grid(factor(PCodABC)~scenario)+theme_minimal()

# 
# ggplot(dat%>%filter(ArrowtoothABC%in%abcsub/10,PollockABC%in%abcsub)) + 
#   geom_line(aes(x=PCodABC,y =PCod, color=factor(PollockABC)),size=1)+
#   facet_grid(factor(ArrowtoothABC)~scenario)+theme_minimal()
# 
# ggplot(dat%>%filter(PCodABC%in%abcsub/10,PollockABC%in%abcsub)) + 
#   geom_line(aes(x=ArrowtoothABC,y =Arrowtooth, color=factor(PollockABC)),size=1)+
#   facet_grid(factor(PCodABC)~scenario)+theme_minimal()



