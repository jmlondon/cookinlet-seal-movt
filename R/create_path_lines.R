create_path_lines <-function(locs) {
  cast2line <- function(sf_pts) {
    sf_pts %>% summarise(do_union = FALSE) %>% st_cast('LINESTRING')
  }
  locs <- locs %>% 
    
    rowwise() %>% 
    mutate(pred_lines = list(cast2line(pred)))
  return(locs)
}