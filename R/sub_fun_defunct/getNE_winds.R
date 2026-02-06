#'
#'
#'
#'getNE_winds.R
#'
#'return vector in the NE direction


getNE_winds <- function(vNorth,uEast){

    theta  <- atan2(y=vNorth,x=uEast)
    radius <- sqrt(uEast^2+vNorth^2)
    theta2 <- theta-pi/4
    Length <- radius*cos(theta2)
    return(Length)
}

# vN<- uE<--10:10
# vN[3]<-uE[5]<-NaN
#plot(uE, getNE_winds(vNorth=vN,uEast=uE))