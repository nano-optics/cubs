
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


random_table <- 3:5000
gl_table <- random_table[is_valid_GL(random_table)]
qmc_table <- random_table
grid_table <- random_table[is_valid_grid(random_table)]
fibonacci_table <- random_table[is_valid_fibonacci(random_table)]

# this saves internally, but it is actually useful at user level..
# however.. when using cubs::cubs() unattached, these should be available (loaded internally) as sysdata.rda

# usethis::use_data(lebedev_table,
#                   sphericaldesigns_table,
#                   gl_table, grid_table,
#                   qmc_table, random_table,
#                   fibonacci_table,
#                   internal = TRUE, overwrite = TRUE)
