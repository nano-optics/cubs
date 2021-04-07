
setwd("~/Documents/nano-optics/cubs/rawdata/sphericaldesigns/")

lf <- list.files(patt='sf', path='SF29-Nov-2012')

pat <- 'sf([0-9]+).([0-9]+)'
proto <- data.frame(t = NA_integer_, N=NA_integer_)
pars <- strcapture(pat, lf, proto = proto)

sphericaldesigns <- list()
for (ii in seq_along(lf)){
  f <- lf[ii]
  p <- strcapture(pat, f, proto = proto)
  r <- read.table(glue::glue('SF29-Nov-2012/{f}'))
  phi <- atan2(r[,2],r[,1])
  theta <- acos(r[,3])
  d <- cbind(phi, theta, 0, 1/p$N)
  if(p$N < 1e4) # don't save beyond that
  sphericaldesigns[[ii]] <- cbind(phi, theta, 1/p$N)
  # print(head(d))
  out <- glue::glue('inc_sd_{p$t}_{p$N}')
  cat(p$N, '\n', file = out)
  write.table(format(d,digits=15), file=out, append = TRUE, quote=FALSE,
              row.names = FALSE, col.names = FALSE)
}
names(sphericaldesigns) <- pars$N[pars$N < 1e4]
pars2 <- data.frame(degree = pars$t[pars$N < 1e4], N=pars$N[pars$N < 1e4])

save(sphericaldesigns,file='sphericaldesigns.rda')

save(pars2,file='sphericaldesigns_table.rda')
