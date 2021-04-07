library(here)
setwd(here('quadrature','sphericaldesigns'))

lf <- list.files('SF29-Nov-2012/')
lf
tags <- strsplit(lf, '\\.')
degree <- as.integer(gsub('sf','', sapply(tags, '[', 1)))
number <- as.integer(sapply(tags, '[', 2))

for(ii in seq_along(lf)){
  input <- lf[ii]
  out <- glue('inc_sd_{deg}_{N}', deg=degree[ii], N=number[ii])
  points <- read.table(paste0('SF29-Nov-2012/', input))
  
  towrite <- data.frame(phi=atan2(y = points[,2], x = points[,1]), 
                  theta = acos(points[,3]), psi=0,
                  weight=1/number[ii])
  cat(nrow(points),"\n", file=out, append=FALSE)
  write.table(format(towrite, format = 'f'), file=out, append = TRUE,
              row.names = FALSE, col.names = FALSE, quote=FALSE)
}

