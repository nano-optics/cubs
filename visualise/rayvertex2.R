library(rayvertex)
#Set the material of an object

library(glue)
library(cubs)
library(ggplot2)
data("lebedev")
data("sphericaldesigns")
leb <- cubs::cubs(100, cubature = 'lebedev')
nrow(leb)
leb <- cubs::cubs(100, cubature = 'gl')
leb <- cubs::cubs(100, cubature = 'grid')

d <- setNames(data.frame(leb), c('phi','theta','weight'))

munchy <- data.frame(rbind(cbind(phi=rep(-90,10), theta=seq(-90,90, length=10)),
                           cbind(phi=seq(-90,90, length=10), theta=rep(90,10)),
                           cbind(phi=rep(90,10), theta=seq(90,-90, length=10)),
                           cbind(phi=seq(90,-90, length=10), theta=rep(-90,10))))

ggplot(d, aes(phi*180/pi, 90-theta*180/pi, size=weight))+
  geom_polygon(data=munchy, map=aes(phi, theta),fill='grey90', 
               alpha=0.3, colour = NA, inherit.aes = FALSE) +
  geom_point(col='darkorange') + #
  theme_void() +
  theme(panel.grid.major = element_line(colour = 'grey30', linetype =3),
        plot.margin = margin(10,10,10,10))+
  scale_x_continuous(breaks = seq(-90,90, by = 10))+
  scale_y_continuous(breaks = seq(-90,90, by = 10)) +
  coord_map("orthographic",orientation = c(0, 0, 0), clip='off', xlim = c(-90, 90)) +
  scale_size_area(max_size = 6) +
  guides(size='none')


plot_cubature <- function(cub){
  d <- setNames(data.frame(cub), c('phi','theta','weight'))
  if(max(d$phi) > 3.2) # some go from 0 to 2pi
    d$phi <- d$phi - pi
  ggplot(d, aes(phi, theta, size=weight))+
    geom_point(col='darkorange') + #
    theme_void() + theme(panel.background = element_rect(fill='grey95', colour = NA))+
    scale_x_continuous(expand=c(0,0), lim=c(-pi,pi))+
    scale_y_continuous(expand=c(0,0), lim=c(0,pi))+
    coord_equal() +
    scale_size_area(max_size = 5) +
    guides(size='none')
}

plot_cubature_wrapped <- function(cub){
  d <- setNames(data.frame(cub), c('phi','theta','weight'))
  if(max(d$phi) > 3.2) # some go from 0 to 2pi
    d$phi <- d$phi - pi
  
  ggplot(d, aes(phi*180/pi, 90-theta*180/pi, size=weight))+
    geom_polygon(data=munchy, map=aes(phi, theta),fill='grey90', 
                 alpha=0.3, colour = NA, inherit.aes = FALSE) +
    geom_point(col='darkorange') + #
    theme_void() +
    theme(panel.grid.major = element_line(colour = 'grey30', linetype =3),
          plot.margin = margin(10,10,10,10))+
    scale_x_continuous(breaks = seq(-90,90, by = 10))+
    scale_y_continuous(breaks = seq(-90,90, by = 10)) +
    coord_map("orthographic",orientation = c(0, 0, 0), clip='off', xlim = c(-90, 90)) +
    scale_size_area(max_size = 6) +
    guides(size='none')
  
}

# plot_cubature(leb)
# plot_cubature(sd)

wrap_texture <- function(texture = 'lebedev.png'){
  
  mat <- material_list(texture_location = texture, ambient = 0.1*c(1,1,1),
                       shininess=0, specular_intensity = 0, dissolve = 1,
                       ambient_intensity = 2.5,diffuse_intensity = 1,
                       emission_intensity = 0, type="diffuse", 
                       culling = 'back', transmittance = c(0,0,0))
  
  light1 <- directional_light(direction = c(1, 0, 0), color = "white", intensity = 0.3)
  light2 <- directional_light(direction = c(0, 1, 0), color = "white", intensity = 0.3)
  light3 <- directional_light(direction = c(0, 0, 1), color = "white", intensity = 1)
  light4 <- directional_light(direction = c(-1, 0, 0), color = "white", intensity = 0.3)
  light5 <- directional_light(direction = c(0, -1, 0), color = "white", intensity = 0.3)
  
  scene = sphere_mesh(position=c(0,0,0), angle = c(0,90,0),
                      material=mat,radius=1.5) 
  
  lights <- light1 %>% 
    add_light(light = light2) %>% 
    add_light(light = light3) %>% 
    add_light(light = light4) %>% 
    add_light(light = light5) 
  
  png(gsub('.png|.jpg', '-wrap.png', texture), width=8,height=8, units = 'in', res=300)
  scene %>% 
    rasterize_scene(light_info = lights, background = 'white')
  dev.off()
}

leb <- cubs::cubs(100, cubature = 'lebedev')
ggsave('lebedev.png', plot_cubature(leb), width = 8, height=4)
ggsave('lebedev_sp.png', plot_cubature_wrapped(leb), width = 4, height=4)
wrap_texture('lebedev.png')

sd <- cubs::cubs(100, cubature = 'sphericaldesigns')
ggsave('sd.png', plot_cubature(sd), width = 8, height=4)
ggsave('sd_sp.png', plot_cubature_wrapped(sd), width = 4, height=4)
wrap_texture('sd.png')

gl <- cubs::cubs(100, cubature = 'gl')
ggsave('gl.png', plot_cubature(gl), width = 8, height=4)
ggsave('gl_sp.png', plot_cubature_wrapped(gl), width = 4, height=4)
wrap_texture('gl.png')

fib <- cubs::cubs(100, cubature = 'fibonacci')
ggsave('fib.png', plot_cubature(fib), width = 8, height=4)
ggsave('fib_sp.png', plot_cubature_wrapped(fib), width = 4, height=4)
wrap_texture('fib.png')

grid <- cubs::cubs(100, cubature = 'grid')
ggsave('grid.png', plot_cubature(grid), width = 8, height=4)
ggsave('grid_sp.png', plot_cubature_wrapped(grid), width = 4, height=4)
wrap_texture('grid.png')

qmc <- cubs::cubs(100, cubature = 'qmc')
ggsave('qmc.png', plot_cubature(qmc), width = 8, height=4)
ggsave('qmc_sp.png', plot_cubature_wrapped(qmc), width = 4, height=4)
wrap_texture('qmc.png')

random <- cubs::cubs(100, cubature = 'random')
ggsave('random.png', plot_cubature(random), width = 8, height=4)
ggsave('random_sp.png', plot_cubature_wrapped(random), width = 4, height=4)
wrap_texture('random.png')


wrap_texture('bearcub.jpg')
