##
## Functions for orientation averaging
##


##' cubature points on a sphere
##'
##' Numerical integration points for angular averaging
##' @title cubature_sphere
##' @param N number of integration points
##' @param cubature cubature method, using either Gauss Legendre cubature (default), Quasi Monte Carlo, regular grid, or "cheap" (3 axes)
##' @param init (qmc method only) logical: restart, or continue from previous call
##' @importFrom randtoolbox halton
##' @importFrom statmod gauss.quad
##' @export
##' @family low_level cubature
##' @author baptiste Auguie
cubs <- function(N = 30,
                 cubature = c('lebedev', 'sphericaldesigns', "gl", 
                                'fibonacci', 'grid', "qmc", "random")){
  
  cubature <- match.arg(cubature)
  
  if(cubature == "lebedev"){
    data(lebedev_table)
    data(lebedev)
    if(N > max(lebedev_table$N)) w <- nrow(lebedev_table) else
    w <- min(which(lebedev_table$N >= N))
    return(lebedev[[w]])
  }
  
  if(cubature == "sphericaldesigns"){
    data(sphericaldesigns_table)
    if(N > max(sphericaldesigns_table$N)) w <- nrow(sphericaldesigns_table) else
      w <- min(which(sphericaldesigns_table$N >= N))
    return(sphericaldesigns[[w]])
  }
  
  
  if(cubature == "gl"){ #  gauss legendre along cos beta, grid alpha
    # may have a few more than N total points
    # N = (P+1)*(P+1)/2 = (P+1)^2/2 -> P = [sqrt(2*N) - 1]
    P <- sqrt(2*N) - 1
    Nalpha <- ceiling(P+1)
    Nbeta <- ceiling((P+1)/2)
    
    alpha <- seq(0, 2*pi *(1 - 1/Nalpha), by = 2*pi/Nalpha)
    GL_cbeta <- statmod::gauss.quad(Nbeta)
    beta  = acos(GL_cbeta$nodes)
    
    # grid of angles
    nodes <- expand.grid(alpha=alpha, beta=beta)
    # corresponding weights for 2D cubature
    weights <- expand.grid(alpha=rep(1/Nalpha, Nalpha),
                           beta=GL_cbeta$weights)
    # combine the weights and divide by 2 
    # (1/4pi for the average, but * 2pi from range of alpha)
    weights <- 1/2 * weights$alpha * weights$beta
    
    return(cbind(as.matrix(nodes), weights))
  }
  
  if(cubature == "qmc"){ # quasi monte-carlo
    
    p <- randtoolbox::halton(N, dim = 2, normal=FALSE, init=TRUE)
    
    alpha <- p[,1]*2*pi
    beta <- acos(2*p[,2] - 1) # cos(beta) in [-1,1]
    nodes <- cbind(alpha=alpha, beta=beta)
    weights <- rep(1/nrow(nodes), nrow(nodes))
    return(cbind(as.matrix(nodes), weights))
  }
  
  if(cubature == "random"){ # monte-carlo with random points
    
    alpha <- runif(N, 0, 2*pi) # uniform [-pi,pi]
    beta <- acos(runif(N, -1, 1)) # cos-uniform [-1,1]
    nodes <- cbind(alpha=alpha, beta=beta)
    weights <- rep(1/nrow(nodes), nrow(nodes))
    return(cbind(as.matrix(nodes), weights))
  }
  
  if(cubature == "grid"){ # grid in acos beta and alpha
    # may have a few more than N total points
    # N = (P+1)*(P+1)/2 = (P+1)^2/2 -> P = [sqrt(2*N) - 1]
    P <- sqrt(2*N) - 1
    Nalpha <- ceiling(P+1)
    Nbeta <- ceiling((P+1)/2) 
    
    alpha <- seq(0, 2*pi *(1 - 1/Nalpha), by = 2*pi/Nalpha)
    beta <- acos(seq(-1, 1, length.out = Nbeta)) 
    # cos-uniform ]-1,1[ exclude poles as otherwise many points there
    nodes <- expand.grid(alpha=alpha, beta=beta[-c(1,Nbeta)])
    weights <- rep(1/(Nalpha*Nbeta), nrow(nodes))
    nodes <- rbind(nodes,
                   c(0,0,0), 
                   c(0, pi, 0)) # add two poles
    weights <- c(weights, 1/(Nbeta),1/(Nbeta))
    
    return(cbind(as.matrix(nodes), weights))
  }
  
  
  if(cubature == "fibonacci"){ # improved spiral
    # R. Marques et al. 1981 
    # Spherical Fibonacci Point Sets for Illumination Integrals
    # tj = arccos(1-(2j+1)/N)
    # pj = 2jpi phi-1
    N0 <- N
    if(N%%2 == 1) N <- N0+1
    jj <- seq(0,N-1)
    
    beta <- acos(1 - (2*jj+1)/N)
    golden <- (1+sqrt(5))/2
    alpha <- (2*pi*jj/golden) %% (2*pi)
    
    nodes <- cbind(alpha=alpha, beta=beta)
    weights <- rep(1/nrow(nodes), nrow(nodes))
    return(cbind(as.matrix(nodes), weights))
  }
  
  
  
  
}
