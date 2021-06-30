library(rayvertex)


cols = hsv(seq(0,1,length.out=6))

mat = material_list(diffuse="purple", type = "phong", ambient="purple", ambient_intensity = 0.2)
mat2 = material_list(diffuse="grey80", ambient="grey80", ambient_intensity = 0.2)

mats = list()
for(i in 1:5) {
  mats[[i]] = material_list(diffuse=cols[i], ambient=cols[i], type="phong",
                            ambient_intensity = 0.2)
}

generate_cornell_mesh(ceiling=FALSE) %>%
  add_shape(sphere_mesh(position=c(555,555,555)/2, radius=80, material=mat)) %>%
  add_shape(segment_mesh(start=c(555/2,0,555/2),end=c(555/2,196,555/2),
                         radius=30, material=mat2)) %>%
  add_shape(cube_mesh(position=c(555/2,555/2-90,555/2),
                      scale=c(160,20,160),material=mat2)) %>%
  add_shape(torus_mesh(position=c(100,100,100), radius = 50, ring_radius = 20,
                       angle=c(45,0,45),material=mats[[1]])) %>%
  add_shape(cone_mesh(start=c(555-100,0,100), end=c(555-100,150,100), radius = 50,
                      material=mats[[2]])) %>%
  add_shape(arrow_mesh(start=c(555-100,455,555-100), end=c(100,455,555-100),
                       radius_top = 50, radius_tail=10, tail_proportion = 0.8,
                       material=mats[[3]])) %>%
  add_shape(obj_mesh(r_obj(), position=c(100,200,555/2), angle=c(-10,200,0),
                     scale=80,material=mats[[4]])) %>%
  rasterize_scene(light_info = directional_light(c(0.4,0.2,-1)))