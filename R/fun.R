## unexported test functions

## @export
f1 <- function(phi, theta){
  
  x <- cos(phi)*sin(theta)
  y <- sin(phi)*sin(theta)
  z <- cos(theta)
  
  1+x+y^2 +x^2*y+x^4 +y^5 +x^2*y^2*z^2
}

## @export
f2 <- function(phi, theta){
  
  x <- cos(phi)*sin(theta)
  y <- sin(phi)*sin(theta)
  z <- cos(theta)
  
 0.75*exp(-(9*x - 2)^2/4 - (9*y - 2)^2/4 - (9*z - 2)^2/4) +
    0.75*exp(-(9*x + 1)^2/49 - (9*y + 1)/10 - (9*z + 1)/10) +
    0.5*exp(-(9*x - 7)^2/4 - (9*y - 3)^2/4 - (9*z - 5)^2/4) -
    0.2*exp(-(9*x - 4)^2 - (9*y - 7)^2 - (9*z - 5)^2)
  
}

## @export
f3 <- function(phi,theta){
  
  1/(4*pi) + Re( exp(12i*phi)* sin(theta)^12)
}


