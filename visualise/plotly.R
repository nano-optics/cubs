
library(plotly)

Ylm <- function(l,m,phi,theta){
  
  ex <- Ryacas::yac_expr(glue::glue("(-1)^{m}*(1-x^2)^({m}/2)*D(x,{m})OrthoP({l}, x)"))
  
  sqrt((2*l+1)/(4*pi) * factorial(l-m) / factorial(l+m))*
    exp(1i*abs(m)*phi) * eval(ex, list(x = cos(theta)))
  
}

N <- 10
dd <- transform(expand.grid(r = 0.2,
                            theta=seq(0.1,pi-0.01,length=N),
                            phi=seq(0,2*pi-2*pi/N,length=N)),
                x = 0.5*r*sin(theta)*cos(phi),
                y = 0.5*r*sin(theta)*sin(phi),
                z = 0.5*r*cos(theta)) 

dd$v <- abs(Re(Ylm(3,2,phi = dd$phi, theta = dd$theta)))
# dd$v <- sin(dd$theta) * cos(2*dd$phi)

# ggplot(dd, aes(phi,theta,fill=Y)) +geom_raster()

dd <- dd %>% arrange(z)

plot_ly(type='isosurface',
        x = dd$x,
        y = dd$y,
        z = dd$z,
        value = abs(dd$v),
        # value = runif(N^2),
        isomin = 0.2,
        isomax = 1,
        colorscale='RdBu'
)





fig <- plot_ly(data=dd,
               type='isosurface',
               x = ~x,
               y = ~y,
               z = ~z,
               value = ~Y,
               isomin = -0.5,
               isomax = 0.5,
               colorscale='RdBu'
)

fig

plot_ly(type='isosurface',
        x = dd$x,
        y = dd$y,
        z = dd$z,
        value = abs(dd$Y),
        isomin = 0,
        isomax = 0.5,
        colorscale='RdBu'
)



fig <- plot_ly(
  type='isosurface',
  x = c(0,0,0,0,0.9,1,1,1),
  y = c(1,0,1,0,1,0,1,0),
  z = c(1,1,0,0,1,1,0,0)-0.5,
  value = runif(8),
  isomin=0,
  isomax=1
)

fig

