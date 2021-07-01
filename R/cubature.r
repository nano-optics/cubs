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
    
    if(N > max(gl_table)) N <- max(gl_table) else
      N <- gl_table[min(which(gl_table >= N))]
    
    # N=2Nb^2
    Nb <- as.integer(sqrt(N/2))
    Na <- 2*Nb
    
    alpha <- seq(0, 2*pi *(1 - 1/Na), by = 2*pi/Na)
    GL_cbeta <- statmod::gauss.quad(Nb)
    beta = acos(GL_cbeta$nodes)
    
    # grid of angles
    nodes <- expand.grid(alpha=alpha, beta=beta)
    # corresponding weights for 2D cubature
    weights <- expand.grid(alpha=rep(1/Na, Na),
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
    # mid-point rule
    
    if(N > max(grid_table)) N <- max(grid_table) else
      N <- grid_table[min(which(grid_table >= N))]
    Nb <- as.integer(sqrt(N/2)) # 2Nb^2 = N
    Na <- 2*Nb
    
    alpha <- seq(0, 2*pi *(1 - 1/Na), by = 2*pi/Na)
    beta <- acos(seq(-1+1/Nb, 1-1/Nb, by = 2/Nb)) # Nb mid-points, no poles
    nodes <- expand.grid(alpha=alpha, beta=beta)
    weights <- rep(1/nrow(nodes), nrow(nodes))
    # # N=2Nb^2+2
    # Nb <- as.integer(sqrt((N-2)/2))
    # Na <- 2*Nb
    # 
    # alpha <- seq(0, 2*pi *(1 - 1/Na), by = 2*pi/Na)
    # beta <- acos(seq(-1+2/Nb, 1-2/Nb, length.out = Nb)) 
    
    # Nb <- as.integer(sqrt(N/2) + 1)
    # Na <- 2*Nb
    # alpha <- seq(0, 2*pi *(1 - 1/Na), by = 2*pi/Na)
    # beta <- acos(seq(-1, 1, length.out = Nb)) 
    # cos-uniform ]-1,1[ exclude poles as otherwise many points there
    # nodes <- expand.grid(alpha=alpha, beta=beta[-c(1,Nb)])
    # nodes <- expand.grid(alpha=alpha, beta=beta[-c(1,Nb)])
    # weights <- rep(1/nrow(nodes), nrow(nodes))
    # nodes <- rbind(nodes,
    #                c(0,0,0), 
    #                c(0, pi, 0)) # add two poles
    # weights <- c(weights, 1/Nb,1/Nb)
    
    return(cbind(as.matrix(nodes), weights))
  }
  
  
  if(cubature == "fibonacci"){ # improved spiral
    # R. Marques et al. 1981 
    # Spherical Fibonacci Point Sets for Illumination Integrals
    # tj = arccos(1-(2j+1)/N)
    # pj = 2jpi phi-1
    
    if(N > max(fibonacci_table)) N <- max(fibonacci_table) else
      N <- fibonacci_table[min(which(fibonacci_table >= N))]
    
    jj <- seq(0,N-1)
    
    beta <- acos(1 - (2*jj+1)/N)
    golden <- (1+sqrt(5))/2
    alpha <- (2*pi*jj/golden) %% (2*pi)
    
    nodes <- cbind(alpha=alpha, beta=beta)
    weights <- rep(1/nrow(nodes), nrow(nodes))
    return(cbind(as.matrix(nodes), weights))
  }
  
  
  
  
}
