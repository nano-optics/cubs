
library(cubs)
library(ggplot2)
library(dplyr)
library(tidyr)

g <- expand.grid(phi=seq(0,2*pi,length=360), theta=seq(0,pi,length=180))

pars <- rowwise(data.frame(l=0:5)) %>% mutate(m = list(seq(-l, l))) %>% unnest(cols = c(m))
# test <- rowwise(pars) %>% mutate(Y = list(Ylm(l,m,g$phi,g$theta)),g=list(g)) %>% unnest(cols = c(Y,g))
# str(test)
# test %>% group_by(l,m) %>% mutate(Yn=Re(Y)/max(Re(Y))) 

# ggplot(test, aes(phi,theta,fill=Yn)) +
#   facet_grid(l~m)+
#   geom_tile() +
#   coord_polar()+
#   scale_fill_distiller(palette = 'PiYG') +
#   theme_void() +
#   theme(legend.position = 'none')

test <- rowwise(pars) %>% mutate(Y = list(Ylm(l,m,g$phi,g$theta)), 
                                 data=list(data.frame(Yn=Re(Y)/max(Re(Y)), g)))

str(test)

plot_ylm <- function(l,m,data,...){
  p <- ggplot(data, aes(phi,theta,fill=Yn)) +
    geom_raster() +
    # coord_equal()+
    # scale_fill_distiller(palette = 'PiYG') +
    # scale_fill_distiller(palette = 'RdYlGn') +
    scale_fill_distiller(palette = 'BrBG') +
    # scale_fill_distiller(palette = 'RdYlBu') +
    # scale_fill_distiller(palette = 'PRGn') +
    theme_void() +
    scale_x_continuous(expand = c(0,0)) +
    scale_y_continuous(expand = c(0,0)) +
    theme(legend.position = 'none', 
          plot.background = element_blank(), 
          panel.border = element_blank(), 
          panel.background = element_blank(),
          plot.margin = margin(0,-1,0,-1)) +
    labs(x=NULL, y='wtf', title=NULL) 
  library(grid)
  # g <- rectGrob(gp=gpar(fill='yellow',col='yellow'))
  ggsave(plot=p,file=glue('y_{l}_{m}.png'),width=4,height=2, bg = 'red')
  print(p)
}



library(purrr)
library(glue)

str(test)
# rowwise(test[1,]) %>% pwalk(plot_ylm)
rowwise(test) %>% pwalk(plot_ylm)

# ggsave(plot=.,file=glue::glue('y_{unique(.$l)}_{unique(.$m)}.png')



