library(here)
setwd(here('data-raw/lebedev'))
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
  rule <- leb[seq(starts[ii],ends[ii]), ]
  
  # note: even though called theta,phi, don't change order
  # since ranges are theta [-180,180] and phi [0, 180]
  lebedev[[ii]] <- data.frame(phi = rule[,1] * pi/180, theta =  rule[,2] * pi/180, weight = rule[,3])
  
  # towrite <- cbind(rule[,1:2] * pi/180, 0, rule[,3])
  # outfile <- glue('inc_leb_{lmax[ii]}_{N}')
  # cat(N,"\n", file = outfile)
  # write.table(format(towrite, digits=15), file=outfile, append = TRUE,
  #             row.names = FALSE, col.names = FALSE, quote=FALSE)
}

names(lebedev) <- orders
lebedev_table <- data.frame(degree = lmax, N=orders)
save(lebedev, file=here('data/lebedev.rda'))
save(lebedev_table, file=here('data/lebedev_table.rda'))

