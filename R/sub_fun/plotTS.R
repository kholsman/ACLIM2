#'
#'
#'
#'
#'plotTS.R
#'
plotTS<-function(newdat, plotvalIN = "mn_val"){
  eval(parse(text = paste0("newdat<-newdat%>%mutate(plotval = ",plotvalIN,")")))
  
  pp<- ggplot(newdat) +
   geom_line(aes(x=mnDate,y=plotval,color= GCM_scen, linetype = basin),
              alpha = 0.6,show.legend = FALSE) +
    geom_smooth(aes(x = mnDate, 
                    y = plotval,
                    color    = GCM_scen,
                    fill     = GCM_scen,
                    linetype = basin),
                alpha       = 0.1,
                method      = "loess",
                formula     = 'y ~ x',
                span        = .5,
                show.legend = T) +
    theme_minimal() + 
    labs(x = "Date",
         y = newdat$var[1],
         subtitle = plotvalIN,
         legend   = "",
         title    = paste(newdat$var[1],"(",newdat$basin[1],",",newdat$type[1],")"))+
    scale_color_discrete() +
    facet_grid(var~scen,scales='free_y')
  return(pp)
}