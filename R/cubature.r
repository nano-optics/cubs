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
                                'fibonacci', "qmc", 'grid')){
  
  cubature <- match.arg(cubature)
  
  if(cubature == "lebedev"){
    if(N > max(lebedev_table$N)) w <- nrow(lebedev_table) else
    w <- which(lebedev_table$N >= 36)[1]
    return(lebedev[[w]])
  }
  
  if(cubature == "sphericaldesigns"){
    if(N > max(sphericaldesigns_table$N)) w <- nrow(sphericaldesigns_table) else
      w <- which(sphericaldesigns_table$N >= 36)[1]
    return(sphericaldesigns[[w]])
  }
  
  
  if(cubature == "gl"){ #  gauss legendre along cos beta, grid alpha
    # might have slightly more than N total points
    # N = (P+1)*(P+1)/2 = (P+1)^2/2 -> P = [sqrt(2*N) - 1]
    P <- sqrt(2*N) - 1
    # now check +/-1 on each one and pick best combo
    # opts <- expand.grid(N1 = round(P) + seq(-1,1), N2=2*round(P) + seq(-1,1))
    # prod <- opts$N1 * opts$N2
    # best <- which.min(abs(N - prod))
    # Nbeta <- opts$N1[best]
    # Nalpha <- opts$N2[best]
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
    # might have slightly more than N total points
    # N = 2P^2 -> P = [sqrt(N/2)]
    # now check +/-1 on each one and pick best combo
    P <- sqrt(N/2)
    opts <- expand.grid(N1 = round(P) + seq(-1,1), 
                        N2=2*round(P) + seq(-1,1))
    prod <- opts$N1 * opts$N2
    best <- which.min(abs(N - prod)) 
    Nbeta <- opts$N1[best]
    Nalpha <- opts$N2[best]
    
    alpha <- seq(0, 2*pi *(1 - 1/Nalpha), by = 2*pi/Nalpha)
    beta <- acos(seq(-1+1/(2*Nbeta+1), 1-1/(2*Nbeta+1), 
                     length.out = Nbeta)) 
    # cos-uniform ]-1,1[ exclude poles as otherwise many points there
    # nodes <- rbind(expand.grid(alpha=alpha, beta=beta, gamma=0),
    #                c(0,0,0), c(0, pi, 0)) # add two poles
    nodes <- expand.grid(alpha=alpha, beta=beta)
    weights <- rep(1/nrow(nodes), nrow(nodes))
    
    return(cbind(as.matrix(nodes), weights))
  }

  
  if(cubature == "fibonacci"){ # spiral
    
    N0 <- N
    if(N%%2 == 1) N0 <- N+1
    P <- (N0-1)/2
    ii <- seq(-P,P,by=1)
    # asin(2*ii/N0) latitude = asin(x) -> colatitude = pi/2 - asin(x)
    beta <- pi/2 - asin(2*ii/N0)
    golden <- (1+sqrt(5))/2
    alpha <- (2*pi*ii/golden) %% (2*pi)
    
    nodes <- cbind(alpha=alpha, beta=beta)
    weights <- rep(1/nrow(nodes), nrow(nodes))
    return(cbind(as.matrix(nodes), weights))
  }
  
  
  if(cubature == "fibonacci2"){ # spiral
    
    N0 <- N
    if(N%%2 == 1) N0 <- N+1
    
    ii <- seq(0,N0,by=1)
    
    beta <- acos(1 - (2*ii+1)/N0)
    golden <- (1+sqrt(5))/2
    alpha <- (2*pi*ii/golden) %% (2*pi)
    
    nodes <- rbind(alpha=alpha, beta=beta)
    weights <- rep(1/ncol(nodes), ncol(nodes))
    return(cbind(as.matrix(nodes), weights))
  }
  
  
  
  
}
