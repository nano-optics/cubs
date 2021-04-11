
library(cubs)
library(ggplot2)
library(dplyr)
library(tidyr)


f0_manual <- function(phi, theta){
  
  # https://math.stackexchange.com/a/1847806/4964
  
  # https://www.wolframalpha.com/input/?i=+SphericalHarmonicY%5B35%2C27%2C%CE%B8%2C%CF%95%5D+
  
  # https://www.wolframalpha.com/input/?i=Integrate+sin%28theta%29*+SphericalHarmonicY%5B12%2C-7%2C%CE%B8%2C%CF%95%5D++from+theta%3D0%2C+phi%3D0+to+theta%3Dpi%2Cphi%3D2*pi
  
  yl35m27 = Re(-exp(27i*phi)*sin(theta)^27*(180297*cos(theta)^8 - 73164*cos(theta)^6 + 8190*cos(theta)^4 - 252*cos(theta)^2 + 1))
  
  yl12mm7 = Re((exp(-7i* phi)* sin(theta)^7* cos(theta)* (161 *cos(theta)^4 - 70* cos(theta)^2 + 5)))
  
  yl12m0 = Re(5 *(676039*  cos(theta)^12 - 1939938 * cos(theta)^10 + 2078505 * cos(theta)^8 - 1021020 * cos(theta)^6 + 225225 * cos(theta)^4 - 18018 * cos(theta)^2 + 231)/2000)
  
  yl1m1 <- Re(exp(1i*phi)*sin(theta))
  yl2m1 <- Re(exp(1i*phi)*sin(theta)*cos(theta))
  yl3m1 <- Re(exp(1i*phi)*sin(theta)*(5*cos(theta)^2 - 1))
  yl5m1 <-  Re(exp(1i*phi)*sin(theta)*(21* cos(theta)^4 - 14 *cos(theta)^2 + 1))
  yl5m3 <- Re(exp(3i*phi)* sin(theta)^3 * (9 * cos(theta)^2 - 1))
  
  yl8m5 <- Re( exp(5i*phi)* sin(theta)^5 * cos(theta)* (5 * cos(theta)^2 - 1))
  yl15m15 <- Re( exp(15i*phi)* sin(theta)^15)
  yl20m20 <- Re( exp(20i*phi)* sin(theta)^20)
  yl30m30 <- Re( exp(30i*phi)* sin(theta)^30)
  
  yl20m13 <- -Re( (15 *sqrt(63253693041/(2*pi)) * exp(13i*phi) *sin(theta)^13 *cos(theta) * (481*cos(theta)^6 - 259*cos(theta)^4 + 35*cos(theta)^2 - 1))/262144)
  yl12mm7
  yl12m0
  yl20m20
  yl35m27
  # yl20m13
  yl12m0
  yl8m5
  yl2m2 <- Re(1/4*sqrt(15/(2*pi))*exp(2i*phi)*sin(theta)^2)
  yl2m2
  yl5m2 <- Re(1/8*sqrt(1155/(2*pi))*exp(2i*phi)*sin(theta)^2* cos(theta)*(3*cos(theta)^2 - 1))
  yl5m2
  yl15m15 
  Re(exp(12i*phi)*sin(theta)^12*cos(theta)*(29*cos(theta)^2 - 3))
  Re(exp(7i*phi)*sin(theta)^7* (30015*cos(theta)^8 - 28980 *cos(theta)^6 + 8050 *cos(theta)^4 - 644*cos(theta)^2 + 7))
  yl12mm7
  yl20m20
  yl19m17 <- Re(exp(17i*phi)*sin(theta)^17*(37*cos(theta)^2 - 1))
  yl19m17
  yl5m2 # ghost
  
  #  SphericalHarmonicY[20,10,θ,ϕ] good example
  Re(exp(10i*phi)*sin(theta)^10*(164021*cos(theta)^10 - 189255*cos(theta)^8 + 71610*cos(theta)^6 - 10230*cos(theta)^4 + 465*cos(theta)^2 - 3))
  }

rotate_x <- function(phi, theta, alpha){
  
  Rx = rbind(c(cos(alpha/2),-1i*sin(alpha/2)),
             c(-1i*sin(alpha/2),cos(alpha/2)))
  
  Q <- rbind(cos(theta/2), exp(1i*phi)*sin(theta/2))
  
  RQ <- Rx %*% Q
  
  thetap <- apply(RQ, 2, function(z) 2*atan2(Mod(z[2]),Mod(z[1])))
  phip <- apply(RQ, 2, function(z) Arg(z[2]) - Arg(z[1]))
  
  data.frame(phi = phip, theta = thetap)
}

pt <- expand.grid(phi = seq(-pi,pi,length=10),
                  theta = seq(0,pi,length=10))

pt2 <- rotate_x(pt$phi, pt$theta, alpha=10*pi/180)
# 
# ggplot(pt, aes(phi,theta)) +
#   geom_point()+
#   geom_point(data=pt2,colour='red',alpha=0.5)


g <- expand.grid(phi=seq(0,2*pi,length=360), theta=seq(0,pi,length=180))

g2 <- rotate_x(g$phi-pi, g$theta, alpha=-27.1*pi/180)

g$f0 <- f0(g$phi,g$theta)
g$f0r <- f0(g2$phi,g2$theta)
g$f1 <- f1(g$phi,g$theta)
g$f2 <- f2(g$phi,g$theta)
# g$f3 <- f3(g$phi,g$theta)

gm <- g %>% pivot_longer(c('f0r','f0','f1','f2')) %>% 
  group_by(name) %>% 
  mutate(normalised = scales::rescale(value))

str(gm)

# gg <- gm %>% filter(name %in% c('f0','f0r')) %>% 
#   mutate(name = recode(name,f0='Y["5,2"]',f00='Y["5,2"]~rotated'))

  # ggplot(gg, 
  #        aes(phi, theta, fill=normalised)) +
  # facet_grid(~name,labeller = label_parsed)+
  # geom_raster() +
  # coord_equal()+
  # theme_minimal()+ theme(legend.position = 'none')+
  # scale_x_continuous(expression(phi),expand=c(0,0),breaks=c(0,pi,2*pi),labels=expression(0,pi,2*pi)) +
  # scale_y_continuous(expression(theta),expand=c(0,0),
  #                    breaks=c(0,pi/2,pi),labels=expression(0,pi/2,pi))  

# ggsave('ghost.png', width=10,height=3)
  

p0 <- ggplot(gm,
       aes(phi, theta, fill=normalised)) +
facet_wrap(~name,labeller = label_parsed,ncol=1)+
geom_raster() +
coord_equal()+
theme_minimal()+ theme(legend.position = 'none')+
scale_x_continuous(expression(phi),expand=c(0,0),breaks=c(0,pi,2*pi),labels=expression(0,pi,2*pi)) +
scale_y_continuous(expression(theta),expand=c(0,0),
                   breaks=c(0,pi/2,pi),labels=expression(0,pi/2,pi))


  
rg <- ggplot(gm %>% filter(name=='f0'), aes(phi, theta, fill=normalised)) +
  # facet_wrap(~name,ncol=1)+
  geom_raster() +
  coord_equal()+
  scale_fill_distiller(palette = 'PiYG') +
  theme_void()+ theme(legend.position = 'none')+
  scale_x_continuous(expand=c(0,0)) +
  scale_y_continuous(expand=c(0,0)) 

# ggsave('f0.png',rg, width=6,height=3)

rg <- ggplot(gm %>% filter(name=='f0r'), aes(phi, theta, fill=normalised)) +
  # facet_wrap(~name,ncol=1)+
  geom_raster() +
  scale_fill_distiller(palette = 'PiYG') +
  coord_equal()+
  theme_void()+ theme(legend.position = 'none')+
  scale_x_continuous(expand=c(0,0)) +
  scale_y_continuous(expand=c(0,0)) 

# ggsave('f00.png',rg, width=6,height=3)
# 
# library(rgl)
# open3d()
# texture <- "f0.png"
# 
# lat <- matrix(seq(90, -90, len = 50)*pi/180, 50, 50, byrow = TRUE)
# long <- matrix(seq(-180, 180, len = 50)*pi/180, 50, 50)
# 
# r <- 1
# x <- r*cos(lat)*cos(long)
# y <- r*cos(lat)*sin(long)
# z <- r*sin(lat)
# 
# 
# open3d()
# texture <- "f0.png"
# texture2 <- "f00.png"
# 
# persp3d(x, y, z, col = "white", 
#         texture = texture, alpha=1,
#         specular = "black", axes = F, box = F, xlab = "", ylab = "", zlab = "",
#         normal_x = x, normal_y = y, normal_z = z)
# 
# 
# persp3d(x+2.5*max(x), y, z, col = "white", 
#         texture = texture2, alpha=1,
#         specular = "black", axes = F, box = F, xlab = "", ylab = "", zlab = "",
#         normal_x = x, normal_y = y, normal_z = z, add = TRUE)
# 


library(cubature)

I0 <- 0
I1 <- 216*pi/35
I2 <- 6.6961822200736179523
I3 <- 4*pi/9

# num <- hcubature(function(x) matrix(sin(x[2,]) * f0(x[1,],x[2,])), 
#                  c(0,0), c(2*pi, pi), vectorInterface = TRUE)
# num$integral

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
  
  q2 <- rotate_x(quad[,1]-pi, quad[,2], alpha=-27.1*pi/180)
  
  vals0 <- f0(quad[,1], quad[,2])
  vals0r <- f0(q2[,1], q2[,2])
  vals1 <- f1(quad[,1], quad[,2])
  vals2 <- f2(quad[,1], quad[,2])
  # vals3 <- f3(quad[,1], quad[,2])
  
  d <- data.frame(N = nrow(quad),
                  sum0 = sum(vals0 * quad[,3]),
                  sum0r = sum(vals0r * quad[,3]),
                  sum1 = sum(vals1 * quad[,3]),
                  sum2 = sum(vals2 * quad[,3]))
  
  mutate(d,
         err0r = sum0r - I0/(4*pi),
         err0 = sum0 - I0/(4*pi),
         err1 = sum1 - I1/(4*pi),
         err2 = sum2 - I2/(4*pi))
}

library(purrr)
data("lebedev")
data("sphericaldesigns")
res1 <- map_df(lebedev, test_quadrature)
resm1 <- res1 %>% mutate(quad = 'lebedev') %>% 
  pivot_longer(c('err0r','err0','err1','err2'))


res2 <- map_df(sphericaldesigns, test_quadrature)
resm2 <- res2 %>% mutate(quad = 'sphericaldesigns') %>% 
  pivot_longer(c('err0r','err0','err1','err2'))

gausslegendre <- lapply(c(5:150,seq(200,1e4,by=100)), cubs, cubature = 'gl')
res3 <- map_df(gausslegendre, test_quadrature)
resm3 <- res3 %>% mutate(quad = 'gausslegendre') %>% 
  pivot_longer(c('err0r','err0','err1','err2'))

fibonacci <- lapply(c(5:150,seq(200,1e4,by=100)), 
                    cubs, cubature = 'fibonacci')
res4 <- map_df(fibonacci, test_quadrature)
resm4 <- res4 %>% mutate(quad = 'fibonacci') %>% 
  pivot_longer(c('err0r','err0','err1','err2'))


qmc <- lapply(c(5:150,seq(200,1e4,by=100)), cubs, cubature = 'qmc')
res6 <- map_df(qmc, test_quadrature)
resm6 <- res6 %>% mutate(quad = 'qmc') %>% 
  pivot_longer(c('err0r','err0','err1','err2'))


random <- lapply(c(5:150,seq(200,1e4,by=100)), cubs, cubature = 'random')
res7 <- map_df(random, test_quadrature)
resm7 <- res7 %>% mutate(quad = 'random') %>% 
  pivot_longer(c('err0r','err0','err1','err2'))

grid <- lapply(c(5:150,seq(200,1e4,by=100)), cubs, cubature = 'grid')
res8 <- map_df(grid, test_quadrature)
resm8 <- res8 %>% mutate(quad = 'grid') %>% 
  pivot_longer(c('err0r','err0','err1','err2'))

# 
# naive <- lapply(c(5:150,seq(200,1e4,by=100)), cubs, cubature = 'naive')
# res9 <- map_df(naive, test_quadrature)
# resm9 <- res9 %>% mutate(quad = 'naive') %>% 
#   pivot_longer(c('err00','err0','err1','err2','err3'))


# str(res)


resm <- rbind(resm1,resm2,resm3,resm4,resm6,resm7,resm8) 
resm$value[abs(resm$value)<1e-16] <- 1e-16

p <- ggplot(subset(resm, N > 1 & N < 5e4 & !(quad %in% c('lebedev2','gausslegendre2','sphericaldesigns2','random2'))),
aes(N, abs(value),colour=quad)) +
  # 
  # p <- ggplot(subset(resm, N > 1 & N < 100 & (quad %in% c('fibonacci','fibonacci2'))),
  #             aes(N, abs(value),colour=quad)) +
  facet_wrap(~name,scales = 'free_y',ncol=1)+
  geom_line() +
  scale_x_log10() +
  scale_y_log10() +
  theme() +
  scale_colour_brewer(palette = 'Set1')+
  labs(x=expression(N[nodes]),y='abs(error)',colour='')+
  theme()

# p 
egg::ggarrange(p0+coord_cartesian()+theme(legend.position = 'none'),p,ncol=2)

