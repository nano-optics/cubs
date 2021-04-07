
library(cubs)
library(ggplot2)
library(dplyr)
library(tidyr)

g <- expand.grid(phi=seq(0,2*pi,length=360), theta=seq(0,pi,length=180))

g$f1 <- f1(g$phi,g$theta)
g$f2 <- f2(g$phi,g$theta)
g$f3 <- f3(g$phi,g$theta)


gm <- g %>% pivot_longer(c('f1','f2','f3')) %>% 
  group_by(name) %>% 
  mutate(normalised = scales::rescale(value))

str(gm)


ggplot(gm, aes(phi, theta, fill=normalised)) +
  facet_wrap(~name,ncol=1)+
  geom_raster() +
  coord_equal()+
  theme_minimal()+
  scale_x_continuous(expand=c(0,0)) +
  scale_y_continuous(expand=c(0,0)) 

library(cubature)

I1 <- 216*pi/35
I2 <- 6.6961822200736179523
I3 <- 4*pi/9

num <- hcubature(function(x) sin(x[2]) * f1(x[1],x[2]) , c(0,0), c(2*pi, pi))
num$integral
I1

num <- hcubature(function(x) sin(x[2]) * f2(x[1],x[2]) , c(0,0), c(2*pi, pi))
num$integral
I2

num <- hcubature(function(x) sin(x[2]) * f3(x[1],x[2]) , c(0,0), c(2*pi, pi))
num$integral
I3


test_quadrature <- function(quad){
  
  vals1 <- f1(quad[,1], quad[,2])
  vals2 <- f2(quad[,1], quad[,2])
  vals3 <- f3(quad[,1], quad[,2])
  
  d <- data.frame(N = nrow(quad),
                  err1 = sum(vals1 * quad[,3]) - I1/(4*pi),
                  err2 = sum(vals2 * quad[,3]) - I2/(4*pi),
                  err3 = sum(vals3 * quad[,3]) - I3/(4*pi))
  
  d
}

library(purrr)
data("lebedev")
data("sphericaldesigns")
res1 <- map_df(lebedev, test_quadrature)
res2 <- map_df(sphericaldesigns, test_quadrature)
# str(res)

resm1 <- res1 %>% mutate(quad = 'lebedev') %>% 
  pivot_longer(c('err1','err2','err3'))

resm2 <- res2 %>% mutate(quad = 'sphericaldesigns') %>% 
  pivot_longer(c('err1','err2','err3'))

resm <- rbind(resm1,resm2)
p <- ggplot(subset(resm, N > 1 & N < 250 & !(quad %in% c('grid2','grid','qmc'))),
            aes(N, abs(value),colour=quad)) +
  facet_grid(name~.,scales = 'fixed')+
  geom_line() +
  scale_x_log10() +
  scale_y_log10() +
  theme() +
  labs(x=expression(N[nodes]),y='abs(error)',colour='')+
  theme()

p
