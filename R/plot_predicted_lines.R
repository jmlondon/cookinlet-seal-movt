plot_predicted_lines <- function(locs, land_region) {
  path_lines <- do.call("rbind", locs$pred_lines)
  
  ggplot() +
    ggspatial::annotation_spatial(land_region, fill = "cornsilk3", size = 0) +
    ggspatial::layer_spatial(path_lines, color = "deepskyblue3", size = 0.5,
                             alpha = 0.35) + 
    theme_void()
}