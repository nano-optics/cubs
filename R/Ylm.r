gammalm <- function(l, m){
  sqrt((2*l+1)/(4*pi) * factorial(l-m) / factorial(l+m))
}

##' @importFrom Ryacas yac_expr
##' @importFrom glue glue
##' @export
Plm <- function(l,m, theta){
  ex <- Ryacas::yac_expr(glue::glue("(-1)^{m}*(1-x^2)^({m}/2)*D(x,{m})OrthoP({l}, x)"))
  eval(ex, list(x = cos(theta)))
}

##' @export
Ylm <- function(l,m,phi,theta){
  
  pos <- gammalm(l,abs(m)) * exp(1i*abs(m)*phi) * Plm(l,abs(m), theta)
  if(m<0) return((-1)^m*Conj(pos)) else return(pos)
  
}


