

is_valid_GL <- function(N){#2n^2
  sqrt(N/2) %% 1 == 0
}

is_valid_grid <- function(N){ 
  # sqrt((N-2)/2) %% 1 == 0 #2n^2+2
  # (sqrt(N/2) + 1) %% 1 == 0
  sqrt(N/2) %% 1 == 0
}

is_valid_fibonacci <- function(N){ #n even
  N %% 2 == 0
}

all_int <- 3:5000
gl_table <- all_int[is_valid_GL(all_int)]
qmc_table <- all_int
grid_table <- all_int[is_valid_grid(all_int)]
random_table <- all_int
fibonacci_table <- all_int[is_valid_fibonacci(all_int)]
