library(cubs)
setwd("~/Documents/nano-optics/cubs/dev")


data("lebedev_table")
lebedev_table

for(n in lebedev_table$N[1:5]){
  out <- glue('incidence_leb_{n}')
  q <- cubs(N = n, cubature = 'lebedev')
  cat(nrow(q), "\n", file = out)
  write.table(format(cbind(q[,1],q[,2],0,q[,3]), mode='double'), file = out, 
              col.names = FALSE, append = TRUE, row.names = FALSE, quote = FALSE)
}

