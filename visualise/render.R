library(cubs)
library(rayrender)
ang = seq(0,360/32*2,length=33)[-1]

N1 <- 90
N2 <- 90
g <- expand.grid(phi=seq(-pi,pi,length=N1),theta=seq(0,pi,length=N2))
g$Y <- Re(cubs::Ylm(5,2,phi = g$phi, theta = g$theta))

library(threed)
library(rgl)  ## latest 0.106.8
library(ggplot2)

library(raster)
r <- raster(xmn=-180, ymn=-90, xmx=180, ymx=90, ncols=N1,nrow=N2)
r <- setValues(r, g$Y)

# plot(r)

mesh0 <- quadmesh::quadmesh(r)

## globe versions of longlat
verts <- t(quadmesh::llh2xyz(cbind(mesh0$vb[1, ], mesh0$vb[2,], 0)))
mesh <- mesh3d(vertices = verts, quads = mesh0$ib, meshColor = "faces")
plot3d(mesh)
# mesh$material$color <- hcl.colors(raster::ncell(r))
# 
# plot3d(mesh)

camera_to_world <- threed::look_at_matrix(eye = c(3, 4, 5)*100, at = c(0, 0, 0))

obj <- mesh %>%
  transform_by(invert_matrix(camera_to_world)) %>%
    orthographic_projection()

fort <- fortify.mesh3d(obj)
fort$value <- rep(g$Y,each=4)
str(fort)
nrow(g)
ggplot(fort) + 
  geom_polygon(aes(x = x, y = y, group = zorder, fill =value), colour = NA, size = 0.2) +
  theme_grey() +
  scale_fill_distiller(palette = 'BrBG') +
  scale_colour_distiller(palette = 'BrBG') +
  theme(
    legend.position = 'none',
    axis.text       = element_blank()
  ) +
  coord_equal() 




# 
# 
# cols <- colorRamp(RColorBrewer::brewer.pal(11,'BrBG'))(scales::rescale(g$Y))
# r <- (matrix(cols[,1]/255, N2,N1,byrow=TRUE))
# g <- (matrix(cols[,2]/255, N2,N1,byrow=TRUE))
# b <- (matrix(cols[,3]/255, N2,N1,byrow=TRUE))
# 
# 
# # grid::grid.raster(m)
# library(abind)
# texture <- abind::abind(r,g,b, along=3)
# dim(texture)
# # grid::grid.raster(texture[,,1])
# # dim(texture) <- c(36,18,4)
# 
# for(i in 1:1) {
#   sphere(r=0.45,angle=c(0,ang[i],0),material=light(intensity=1,
#                                                    image_texture = texture)) %>% 
#     render_scene(lookfrom=c(0,10,10),fov=0)
# }
# 
# 




