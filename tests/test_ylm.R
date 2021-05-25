
library(cubs)
library(ggplot2)
library(dplyr)
library(tidyr)
library(purrr)
library(glue)

rotate_x <- function(phi, theta, alpha){
  
  Rx = rbind(c(cos(alpha/2),-1i*sin(alpha/2)),
             c(-1i*sin(alpha/2),cos(alpha/2)))
  
  Q <- rbind(cos(theta/2), exp(1i*phi)*sin(theta/2))
  
  RQ <- Rx %*% Q
  
  thetap <- apply(RQ, 2, function(z) 2*atan2(Mod(z[2]),Mod(z[1])))
  phip <- apply(RQ, 2, function(z) Arg(z[2]) - Arg(z[1]))
  
  data.frame(phi = phip, theta = thetap)
}


library(cubature)

I0 <- 0
I1 <- 216*pi/35
I2 <- 6.6961822200736179523
I3 <- 4*pi/9

# num <- hcubature(function(x) matrix(sin(x[2,]) * f0(x[1,],x[2,])), 
#                  c(0,0), c(2*pi, pi), vectorInterface = TRUE)
# num$integral


test_cubature <- function(cub, l, m, alpha=-27.1*pi/180, ...){
  
  cub2 <- rotate_x(cub[,1]-pi, cub[,2], alpha=alpha)
  
  vals1 <- Re(cubs::Ylm(l, m, cub[,1], cub[,2]))
  vals2 <- Re(cubs::Ylm(l, m, cub2[,1], cub2[,2]))
  
  d <- data.frame(N = nrow(cub),
                  sum1 = sum(vals1 * cub[,3]),
                  sum2 = sum(vals2 * cub[,3]))
  
  mutate(d,
         err1 = sum1 - I0/(4*pi),
         err2 = sum2 - I0/(4*pi))
}

data("lebedev")
data("sphericaldesigns")


l1 <- map_df(lebedev[1:20], function(.c) tibble(name = 'lebedev', N = nrow(.c), cub = list(.c)))

l2 <- map_df(sphericaldesigns[1:30], function(.c) tibble(name = 'sphericaldesigns', N = nrow(.c), cub = list(.c)))
str(l2)

wrap_cub <- function(N,cubature) {
  .c <- cubs(N,cubature)
  tibble(name=cubature,N=nrow(.c),cub=list(.c))
} 

l3 <- pmap_df(cross_df(list(N = c(seq(10,100,by=5),seq(500,2e3,by=500)),  
                       cubature = c('gl','fibonacci','qmc','random','grid'))), wrap_cub)
dim(l3)
l3 <- l3 %>% distinct()
dim(l3)
str(l3)

lc <- rbind(l1,l2,l3)

str(lc)


pars <- rowwise(data.frame(l=c(10,15,20))) %>% 
  mutate(m = list(seq(0, l))) %>% 
  unnest(cols = c(m))


# test_cubature(lc$cub[[1]], 1,1)
# map_df(lc$cub, ~test_cubature(.,1,1))
test <- rowwise(pars) %>% mutate(res = list(map2_df(lc$cub,lc$name, ~cbind(test_cubature(.x,l,m),quad=.y))))

resm <- test %>% unnest(cols=c(res)) %>% pivot_longer(cols=c(err1,err2))
str(resm)

resm$value[abs(resm$value)<1e-16] <- 1e-16

p <- ggplot(subset(resm, N > 1 & N < 5e4 & l>0 &name=='err1' & !(quad %in% c('lebedev2','gausslegendre2','sphericaldesigns2','random2'))),
            aes(N, abs(value),colour=factor(m))) +
  facet_grid(quad~l,scales = 'free_y')+
  geom_line() +
  scale_x_log10() +
  scale_y_log10(lim=10^c(-16,-1)) +
  theme() +
  scale_colour_brewer(palette = 'Set1')+
  labs(x=expression(N[nodes]),y='abs(error)',colour='')+
  theme()

p
