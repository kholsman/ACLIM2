#'
#'
#'
#'getNE.R
#'
#'return vector in the NE direction


getNE <- function(vNorth,uEast){
  theta  <- atan2(y=vNorth,x=uEast)
  radius <- sqrt(uEast^2+vNorth^2)
  theta2 <- theta-pi/4
  Length <- radius*cos(theta2)
  return(Length)
}

vN<- uE<--10:10

plot(uE, getNE(vNorth=vN,uEast=uE))