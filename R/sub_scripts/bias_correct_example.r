# test the bias correct
#'
#'
#'
#'I belive the issue with the data is in the weekly bias corrections - 
#'the methods are to calculate weekly values pooled over areas, then monthly, seasonal, and annual mean values
#'from the weekly values 
#'We then bias correct the weekly using weekly mean hind and hist, the monthly
#'using monthly mean hind and hist, etc.
#'
#'The seasonal means seem to work fine but in the weekly data some weird peaks arise - presumablly because 
#'the mean or hist in that time period is close to 0 - so the solution might be
#'to use monthly or seasonal means to bias correct the weekly data instead of weekly
#'ditto for location
#'
library(ggplot2)
mu_hind <- 1.4
sd_hind <- .5
mu_hist <- 2.9
sd_hist <- .9

df       <- data.frame(x=1:12,hind=rnorm(12,mu_hind,sd_hind),
                       hist=rnorm(12,mu_hist,sd_hist))
fut      <- data.frame(x=13:43,
                       fut=mu_hist+-.07*0:30+rnorm(30,0,.4))
log_adj  <- 1e-4

mnVal_hind <- mean(df$hind)
sdVal_hind <- sd(df$hind)
sdVal_hist <- sd(df$hist)
mnVal_hist <- mean(df$hist)

ggplot(df)+
  geom_line(aes(x=x,y=hind),color="blue",size=.8)+
  geom_line(aes(x=x,y=hist),color="red",size=.8)+  
  geom_line(data=fut,aes(x=x,y=fut),color="red",linetype="dashed",size=.8)+  
  theme_minimal()ggplot(df)+
  geom_line(aes(x=x,y=hind),color="blue",size=.8)+
  geom_line(aes(x=x,y=hist),color="red",size=.8)+  
  geom_line(data=fut,aes(x=x,y=fut),color="red",linetype="dashed",size=.8)+  
  theme_minimal()




#fut$bc_fut <- mnVal_hind + ((sdVal_hind/sdVal_hist)*(fut$fut-mnVal_hist))

ggplot(df)+
  geom_line(aes(x=x,y=hind),color="blue",size=.8)+
  geom_line(aes(x=x,y=hist),color="red",size=.8)+  
  geom_line(data=fut,aes(x=x,y=fut),color="red",linetype="dashed",size=.8)+  
  geom_line(data=fut,aes(x=x,y=bc_fut),color="blue",linetype="dashed",size=.8)+  
  geom_hline(yintercept = mnVal_hind,color="blue")+
  geom_hline(yintercept = mnVal_hist,color="red")+
  
  theme_minimal()





df$LNhind <- log(df$hind + log_adj)
df$LNhist <- log(df$hist + log_adj)
fut$LNfut <- log(fut$fut + log_adj)

mnLNVal_hind <- mean(df$LNhind)
sdLNVal_hind <- sd(df$LNhind)
sdLNVal_hist <- sd(df$LNhist)
mnLNVal_hist <- mean(df$LNhist)

# mnLNVal_hind <- LNmean(df$LNhind)
# sdLNVal_hind <- LNsd(df$LNhind)
# sdLNVal_hist <- LNsd(df$LNhist)
# mnLNVal_hist <- LNmean(df$LNhist)


fut$bc_fut_ln <- exp(mnLNVal_hind + ((sdLNVal_hind/sdLNVal_hist)*(fut$LNfut-mnLNVal_hist)))-log_adj

ggplot(df)+
  geom_line(aes(x=x,y=hind),color="blue",size=.8)+
  geom_line(aes(x=x,y=hist),color="red",size=.8)+  
  geom_line(data=fut,aes(x=x,y=fut),color="red",linetype="dashed",size=.8)+  
  geom_line(data=fut,aes(x=x,y=bc_fut),color="blue",linetype="dashed",size=.8)+  
  geom_line(data=fut,aes(x=x,y=bc_fut_ln),color="blue",linetype="solid",size=.8)+  
  theme_minimal()



