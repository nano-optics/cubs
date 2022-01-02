
##' cubature points on a sphere
##'
##' Tests if a number of points is valid
##' @title is_valid_GL
##' @param N number of integration points
##' @rdname valid
##' @export
##' @family low_level
##' @author baptiste Auguie
is_valid_GL <- function(N){#2n^2
  sqrt(N/2) %% 1 == 0
}

##' @rdname valid
##' @export
is_valid_grid <- function(N){ 
  # sqrt((N-2)/2) %% 1 == 0 #2n^2+2
  # (sqrt(N/2) + 1) %% 1 == 0
  sqrt(N/2) %% 1 == 0
}

##' @rdname valid
##' @export
is_valid_fibonacci <- function(N){ #n even
  N %% 2 == 0
}

