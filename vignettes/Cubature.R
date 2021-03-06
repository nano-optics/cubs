## ----setup, include=FALSE-----------------------------------------------------
knitr::opts_chunk$set(echo = TRUE, warning = FALSE, message = FALSE)

## ----demo, message=FALSE, echo=FALSE, results='asis'--------------------------
library(cubs)
library(glue)
for (method in c('lebedev', 'sphericaldesigns', "gl", 'fibonacci', 'grid', "qmc", "random")){
  # cat(glue("", method))
  print(knitr::kable(cubs(N = 5, method), caption = method))
}

## ----granularity, echo=FALSE, fig.height=2------------------------------------
library(purrr)
library(ggplot2)
library(dplyr)
cs <- list(qmc = cubs::qmc_table,
           fibonacci = cubs::fibonacci_table,
           gl = cubs::gl_table,
           random = cubs::random_table,
           grid = cubs::grid_table,
           lebedev = cubs::lebedev_table$N,
           sphericaldesigns = cubs::sphericaldesigns_table$N)


all <- purrr::map2_df(names(cs), cs, function(.x,.y) 
  data.frame(cubature = .x, N=.y, stringsAsFactors = FALSE))

all$cubature <- factor(all$cubature, levels = unique(all$cubature))

all$cubature <- factor(all$cubature, 
                       levels = c("random","qmc","grid",  "fibonacci", "gl", "sphericaldesigns", "lebedev"),
                       labels = c("random","qmc","grid",  "fibonacci", "gl", "sd", "lebedev"))

ggplot(all %>% filter(N<200), aes(cubature, N, colour=cubature)) +
  geom_point(pch='|',size=5) +
  coord_flip() +
  scale_y_continuous(expand=c(0,0),breaks=seq(0,200,by=50),lim=c(0,200))+
  theme_bw() + guides(colour='none') +
  theme(axis.title.y = element_blank(),
        axis.ticks.y = element_blank(),
        panel.border = element_blank(),
        axis.text.y = element_text(hjust = 1), 
        axis.text.x = element_text(), 
        plot.margin = margin(5,20,5,5),
        panel.grid.major.x = element_line(colour = 'grey90'),
        axis.ticks.x = element_line(), axis.ticks.length=unit(2,'mm'))+
  labs(y = "N", colour='cubature')


## ----integrands, echo=FALSE, fig.height=2-------------------------------------
library(dplyr)
library(ggplot2)
g <- expand.grid(phi=seq(0,2*pi,length=360), theta=seq(0,pi,length=180))

g$f1 <- cubs:::f1(g$phi,g$theta)
g$f2 <- cubs:::f2(g$phi,g$theta)
g$f3 <- cubs:::f3(g$phi,g$theta)

library(tidyr)
gm <- g %>% pivot_longer(c('f1','f2','f3')) %>% 
  group_by(name) %>% 
  mutate(normalised = scales::rescale(value))

gm$name <- factor(gm$name, labels = c('f[1]','f[2]','f[3]'))

p <- ggplot(gm, aes(phi, theta, fill=normalised)) +
  facet_grid(~name, labeller = label_parsed)+
  geom_raster() +
  coord_equal()+
  scale_fill_viridis_c() +
  theme_minimal(base_size = 12) +
  theme(legend.position = 'none', panel.spacing.x = unit(3,'mm'),
        axis.text.x = element_text(vjust=0.5)) +
  scale_x_continuous(expand=c(0,0), breaks=seq(0,2,by=1/2)*pi, labels=expression(0,pi/2,pi,3*pi/2,2*pi)) +
  scale_y_continuous(expand=c(0,0), breaks=seq(0,1,by=1/4)*pi, labels=expression(0,pi/4,pi/2,3*pi/4,pi)) +
  labs(x=expression(varphi), y=expression(theta))
p

## ----params, echo=FALSE, results='asis'---------------------------------------
library(purrr)
cs <- list(
  qmc = cubs::qmc_table[!as.logical(cubs::qmc_table %% 10)],
  fibonacci = cubs::fibonacci_table[!as.logical(cubs::fibonacci_table %% 10)],
  gl = cubs::gl_table,
  random = cubs::random_table[!as.logical(cubs::random_table %% 10)],
  grid = c(cubs::grid_table),
  lebedev = cubs::lebedev_table$N,
  sphericaldesigns = cubs::sphericaldesigns_table$N)

allcubs <- purrr::map2_df(names(cs), cs, 
                          function(.x,.y) data.frame(cubature = .x, N=.y, stringsAsFactors = FALSE))


params <- allcubs %>% filter(N <= 5000) %>% 
  arrange(N, cubature) %>% mutate(ID = row_number())


## ----convergence, echo=FALSE, fig.height=3------------------------------------
set.seed(123)

I1 <- 216*pi/35
I2 <- 6.6961822200736179523
I3 <- 1

test_quadrature <- function(ii){  
  q <- data.frame(cubs(params$N[ii], params$cubature[ii]))
  
  vals1 <- cubs:::f1(q$phi, q$theta) 
  vals2 <- cubs:::f2(q$phi, q$theta) 
  vals3 <- cubs:::f3(q$phi, q$theta) 
  
  d1 <- data.frame(sum1 = 4*pi*sum(vals1 * q$weight),
                   sum2 = 4*pi*sum(vals2 * q$weight),
                   sum3 = 4*pi*sum(vals3 * q$weight))
  mutate(d1, ID=ii,
         err1 = abs(sum1 - I1)/I1,
         err2 = abs(sum2 - I2)/I2,
         err3 = abs(sum3 - I3)/I3)
}



res <- map_df(params$ID, test_quadrature)

m <- left_join(params, res, by='ID') %>% pivot_longer(c("err1",'err2','err3'))
m[m$value <1e-16, 'value'] <- 1e-16

m$cubname <- factor(m$cubature, levels = c("sphericaldesigns", "lebedev", "gl", "grid", "fibonacci", 
                                           "random", "qmc"),
                    labels = c("sph. des.", "Lebedev", "Gauß-L.", "grid", "Fibonacci", 
                               "random", "QMC"))

name.labs <- setNames(c("rel. error (f1)","rel. error (f2)","rel. error (f3)"), 
                      c("err1",'err2','err3'))

ggplot(m, aes(N, value, colour=cubname)) +
  geom_line()+
  scale_colour_brewer(palette = 'Set1') +
  facet_grid(.~name, labeller = labeller(name = name.labs)) +
  annotation_logticks(sides = 'b', colour = 'grey70', size = 0.15,
                      long = unit(2,'mm'), mid = unit(1,'mm')) +
  scale_y_log10(lim=c(10^(-16),10^1.2), minor_breaks=10^seq(-16,4),
                breaks = scales::trans_breaks("log10", function(x) 10^x),
                labels = scales::trans_format("log10", scales::math_format(10^.x))
  ) +
  scale_x_log10(lim=c(2,10^4),
                minor_breaks=scales::log_breaks(n=35),
                expand=c(0,0),
                breaks = scales::trans_breaks("log10", function(x) 10^x),
                labels = scales::trans_format("log10", scales::math_format(10^.x))
  ) +
  theme_minimal(base_size = 12) +
  theme(legend.position='top', #
        # legend.position = c(0.32,0.35),
        panel.spacing.x = unit(3,'mm'),
        strip.placement.y = 'outside',
        panel.background = element_rect(colour = 'grey20', size = 0.2),
        panel.grid.major = element_line(colour = 'grey70', size = 0.15),
        panel.grid.minor = element_line(colour = 'grey70', size = 0.05),
        legend.background = element_rect(fill='white'), 
        strip.text.y = element_blank(),
        strip.text.x = element_blank(),
        # legend.text = element_text(size=8),
        legend.title = element_blank(),
        legend.key.height = unit(3,'mm'),
        legend.key.width = unit(3,'mm'),
        # axis.title.y = element_blank(),
        plot.margin = margin(0,0,0,r = 2),
        legend.margin = margin(1, 1, 1, 1,'mm'),
        legend.spacing.x = unit(2, "mm"),
        legend.spacing.y = unit(0, "mm")) +
  # guides(colour=guide_legend(nrow=1)) +
  labs(x = expression(N[inc]), y='relative error',
       colour='')

