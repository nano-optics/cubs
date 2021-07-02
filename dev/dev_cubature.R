library(cubs)
library(purrr)
library(ggplot2)

library(cubs)
library(ggplot2)
library(dplyr)
library(tidyr)
library(purrr)
library(glue)

# 


cs <- list(qmc = c(qmc_table),
           fibonacci = fibonacci_table,
           gl = gl_table,
           random = random_table,
           grid = c(grid_table),
           lebedev = lebedev_table$N,
           sphericaldesigns = sphericaldesigns_table$N)

allcubs <- purrr::map2_df(names(cs), cs, function(.x,.y) data.frame(cubature = .x, N=.y, stringsAsFactors = FALSE))

# cubs(N = 30, cubature = 'lebedev')

rotate_x <- function(phi, theta, alpha){
  
  Rx = rbind(c(cos(alpha/2),-1i*sin(alpha/2)),
             c(-1i*sin(alpha/2),cos(alpha/2)))
  
  Q <- rbind(cos(theta/2), exp(1i*phi)*sin(theta/2))
  
  RQ <- Rx %*% Q
  
  thetap <- apply(RQ, 2, function(z) 2*atan2(Mod(z[2]),Mod(z[1])))
  phip <- apply(RQ, 2, function(z) Arg(z[2]) - Arg(z[1]))
  
  data.frame(phi = phip, theta = thetap)
}



I0 <- 0
I1 <- 216*pi/35
I2 <- 6.6961822200736179523
I3 <- 4*pi/9

# fun <- function(x,y) Re(cubs::Ylm(l, m, cub[,1], cub[,2]))



# test_cubature <- function(N, cubature, fun, alpha=-27.1*pi/180, ...){
#   
#   cub <- cubs(N, cubature)
#   cub2 <- rotate_x(cub[,1]-pi, cub[,2], alpha=alpha)
#   
#   vals1 <- Re(cubs::Ylm(l, m, cub[,1], cub[,2]))
#   vals2 <- Re(cubs::Ylm(l, m, cub2[,1], cub2[,2]))
#   
#   d <- data.frame(N = nrow(cub),
#                   sum1 = sum(vals1 * cub[,3]),
#                   sum2 = sum(vals2 * cub[,3]))
#   
#   mutate(d,
#          err1 = sum1 - I0/(4*pi),
#          err2 = sum2 - I0/(4*pi))
# }


l <- 8
m <- 7
# P87 <- Ryacas::yac_expr(glue::glue("(-1)^{m}*(1-x^2)^({m}/2)*D(x,{m})OrthoP({l}, x)"))

f0 <- function(phi,theta){
  l <- 8; m <- 7
  # Re(exp(10i*phi)*sin(theta)^10*(164021*cos(theta)^10 - 189255*cos(theta)^8 + 71610*cos(theta)^6 - 10230*cos(theta)^4 + 465*cos(theta)^2 - 3))
  # yl8m5 <- Re( exp(5i*phi)* sin(theta)^5 * cos(theta)* (5 * cos(theta)^2 - 1))
  # yl8m5
  # Re(gammalm(l,abs(m)) * exp(1i*abs(m)*phi) * eval(P87, list(x = cos(theta))))  
  Re(exp(10i*phi)*sin(theta)^10*(164021*cos(theta)^10 - 189255*cos(theta)^8 + 71610*cos(theta)^6 - 10230*cos(theta)^4 + 465*cos(theta)^2 - 3))
  
 Re( exp(12i*phi)* sin(theta)^12)
}

# I0 <- 4*pi
test_cubature <- function(N, cubature){
  quad <- cubs(N, cubature)
  quad2 <- rotate_x(quad[,1]-pi, quad[,2], alpha=-27.1*pi/180)
  
  vals0 <- f0(quad[,1], quad[,2])
  vals0r <- f0(quad2[,1], quad2[,2])
  vals1 <- f1(quad[,1], quad[,2])
  vals2 <- f2(quad[,1], quad[,2])
  # vals3 <- f3(quad[,1], quad[,2])
  
  d <- data.frame(N = nrow(quad),
                  cubature = cubature,
                  sum0 = sum(vals0 * quad[,3]),
                  sum0r = sum(vals0r * quad[,3]),
                  sum1 = sum(vals1 * quad[,3]),
                  sum2 = sum(vals2 * quad[,3]), stringsAsFactors = FALSE)
  
  mutate(d,
         err0r = sum0r - I0/(4*pi),
         err0 = sum0 - I0/(4*pi),
         err1 = sum1 - I1/(4*pi),
         err2 = sum2 - I2/(4*pi))
}


# test_cubature(3, 'grid', 4, 2)

test_cubature(5, 'qmc')

test <- pmap_df(allcubs %>% filter(N<500), test_cubature)
str(test)

m <- pivot_longer(test,c('err0r','err0','err1','err2'))
str(m)

m$value[abs(m$value)<1e-16] <- 1e-16

ggplot(m %>% filter(cubature != 'grid2'), aes(N, abs(value), colour=cubature)) +
  facet_wrap(~name, scales='free_x') +
  geom_line() +  
  # scale_x_log10() +
  scale_y_log10(lim=10^c(-16,0)) +
  theme() +
  scale_colour_brewer(palette = 'Set1')+
  labs(x=expression(N[nodes]),y='abs(error)',colour='')+
  theme()

