
library(cubs)
library(ggplot2)
library(dplyr)
library(tidyr)

g <- expand.grid(phi=seq(0,2*pi,length=120), theta=seq(0,pi,length=60))

pars <- rowwise(data.frame(l=2)) %>% mutate(m = list(seq(0, l))) %>% unnest(cols = c(m))
test <- rowwise(pars) %>% mutate(Y = list(Ylm(l,m,g$phi,g$theta)),g=list(g)) %>% unnest(cols = c(Y,g))
str(test)

test <- test %>% group_by(l,m) %>% mutate(Yn=Re(Y)/max(Re(Y)))
ggplot(test, aes(phi,theta,fill=Yn)) +
  facet_grid(l~m)+
  geom_tile() +
  coord_polar()+
  scale_fill_distiller(palette = 'PiYG') +
  theme_void() +
  theme(legend.position = 'none')

