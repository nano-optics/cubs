library(cubs)
# cubs(N = 30, cubature = 'lebedev')


cs <- list(qmc = qmc_table,
fib = fibonacci_table,
gl = gl_table,
rand = random_table,
grid = grid_table,
lebedev = lebedev_table$N,
sd = sphericaldesigns_table$N)

library(purrr)

all <- purrr::map2_df(names(cs), cs, function(.x,.y) data.frame(cubature = .x, N=.y, stringsAsFactors = FALSE))

all$cubature <- factor(all$cubature, levels = unique(all$cubature))
library(ggplot2)

p <- ggplot(all %>% filter(N<200), aes(cubature, N)) +
  geom_point(pch='|') +
  coord_flip() +
  theme_void() +
  theme(axis.text = element_text(), panel.grid.major.x = element_line(colour = 'grey90'),
        axis.ticks.x = element_line(), axis.ticks.length=unit(2,'mm'))

p
ggsave('coverage.pdf',p,width=8,height=1.5)
