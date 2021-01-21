#'plot_stations_basemap.R
#'
plot_stations_basemap <- function(sfIN,fillIN = "subregion",colorIN = "subregion",sizeIN=.5,lwdIN=.5, alphaIN=1){
 
    p <-  ggplot() + 
      theme_light()+
      geom_sf(data=st_transform(bering_sf,crs=crs_bering),fill="white",color="black",lwd=lwdIN)+
      theme(legend.position="right")+ theme_minimal() 
      # #guides(fill=guide_legend(title="Temp. degC")) +
      # theme(panel.ontop=T,
      #       panel.grid.major = element_line(colour = "gray"),
      #       panel.grid.minor = element_line(colour = "transparent"),
      #       axis.ticks = element_blank(),
      #       axis.text=element_text(colour = "black",size = rel(1)))+
    
    eval(parse(text = paste0("p <- p +  ggspatial::layer_spatial(data = sfIN,aes(fill=",fillIN,",color=",colorIN,"),alpha=alphaIN,size=sizeIN)" )))
    p <- p +  geom_sf(data=st_transform(bering_sf,crs=crs_bering),fill="white",color="black",lwd=lwdIN)
    p

}
