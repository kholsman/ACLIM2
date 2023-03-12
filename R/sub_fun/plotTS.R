#'
#'
#'
#'
#'plotTS.R
#'
plotTS<-function(newdat){
  pp<- ggplot(newdat) +
   geom_line(aes(x=mnDate,y=mn_val,color= GCM_scen, linetype = basin),
              alpha = 0.6,show.legend = FALSE) +
    geom_smooth(aes(x = mnDate, 
                    y = mn_val,
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
         subtitle = "",
         legend   = "",
         title    = paste(newdat$var[1],"(",newdat$basin[1],",",newdat$type[1],")"))+
    scale_color_discrete() +
    facet_grid(var~scen,scales='free_y')
  return(pp)
}