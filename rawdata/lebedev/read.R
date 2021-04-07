library(here)
# setwd(here('quadrature','lebedev'))
# setwd("~/Documents/nano-optics/terms-studies/quadrature/lebedev")
setwd("~/Documents/nano-optics/cubs/rawdata/lebedev")
# 
# $ gcc -O2 sphere_lebedev_rule_test.c sphere_lebedev_rule.c  -o leb
# $ ./leb > rules.txt

leb <- read.table('rules.txt')
info <- readLines('rules.txt')[-1]
ids <- grep("#  Order", info)
info[ids]
library(stringr)
tmp <- str_extract_all(info[ids], '(\\d)+')
orders <- as.integer(sapply(tmp, '[',1))
lmax <- as.integer(sapply(tmp, '[',2))

sum(orders)
nrow(leb)
starts <- c(0,cumsum(orders)[-length(orders)])+1
ends <- cumsum(orders)
library(glue)

lebedev <- list()
for(ii in seq_along(ids)){
  # print(c(starts[ii],ends[ii]))
  N <- diff(c(starts[ii],ends[ii]))+1
  outfile <- glue('inc_leb_{lmax[ii]}_{N}')
  cat(N,"\n", file = outfile)
  rule <- leb[seq(starts[ii],ends[ii]), ]
  
  # note: even though called theta,phi, don't change order
  # since ranges are theta [-180,180] and phi [0, 180]
  towrite <- cbind(rule[,1:2] * pi/180, 0, rule[,3])
  
  lebedev[[ii]] <- cbind(rule[,1:2] * pi/180, rule[,3])
  # towrite2 <- cbind(rule[,2:1] , 0, rule[,3])
  
  # write.table(format(towrite2, format = 'f'), file=paste0('deg',outfile), 
  #             append = FALSE,
  #             row.names = FALSE, col.names = FALSE, quote=FALSE)
  write.table(format(towrite, digits=15), file=outfile, append = TRUE,
              row.names = FALSE, col.names = FALSE, quote=FALSE)
}
names(lebedev) <- orders
pars <- data.frame(degree = lmax, N=orders)
save(lebedev,file='lebedev.rda')
save(pars,file='lebedev_table.rda')

# library(cda)
# 
# q <- quadrature_sphere(300, quadrature = 'gl')
# 
# cat(length(q$weights), "\n", file = 'incidence')
# write.table(format(cbind(t(q$nodes), q$weights), mode='double'), 
#             file = 'incidence', 
#             col.names = FALSE, append = TRUE, row.names = FALSE, quote = FALSE)
