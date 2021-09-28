library(cubs)
# cubs(N = 30, cubature = 'lebedev')


cs <- list(qmc = qmc_table,
           fibonacci = fibonacci_table,
gl = gl_table,
random = random_table,
grid = grid_table,
lebedev = lebedev_table$N,
sphericaldesigns = sphericaldesigns_table$N)

library(purrr)

all <- purrr::map2_df(names(cs), cs, function(.x,.y) data.frame(cubature = .x, N=.y, stringsAsFactors = FALSE))

all$cubature <- factor(all$cubature, levels = unique(all$cubature))
library(ggplot2)

all$cubature <- factor(all$cubature, 
                       levels = c("random","qmc","grid",  "fibonacci", "gl", "sphericaldesigns", "lebedev"),
                               labels = c("random","qmc","grid",  "fibonacci", "gl", "sd", "lebedev"))

p <- ggplot(all %>% filter(N<200), aes(cubature, N)) +
  geom_point(pch='|',size=8) +
  coord_flip() +
  scale_y_continuous(expand=c(0,0),breaks=seq(0,200,by=50),lim=c(0,200))+
  egg::theme_presentation(base_family = 'Source Sans Pro', base_size = 32) +
  theme(axis.title.y = element_blank(),
        axis.ticks.y = element_blank(),
        panel.border = element_blank(),
    axis.text.y = element_text(hjust = 1), 
        axis.text.x = element_text(), 
    plot.margin = margin(5,20,5,5),
        panel.grid.major.x = element_line(colour = 'grey90'),
        axis.ticks.x = element_line(), axis.ticks.length=unit(2,'mm'))+
  labs(y = expression("Number of incidence directions, "*N[inc]),
       colour='cubature')


p
ggsave('coverage.pdf',p,width=14,height=5, dev=cairo_pdf)
