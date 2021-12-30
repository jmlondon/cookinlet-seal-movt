speed_filter_locs <- function(locs_data) {
  
  locs_data <- locs_data %>% 
    sf::st_drop_geometry() %>% 
    group_by(deployid) %>%
    nest() %>%
    mutate(n_records = map_int(data,nrow)) %>%
    filter(n_records > 5) 
  
  locs_data <- locs_data %>%
    mutate(filtered = purrr::map(data, ~ argosfilter::sdafilter(
      lat = .x$latitude,
      lon = .x$longitude,
      dtime = .x$locs_dt,
      lc = as.character(.x$quality),
      vmax = 7.5 ,ang = -1 
    ))) %>%
    unnest(cols = c(data, filtered)) %>%
    mutate(filtered = ifelse(filtered != "removed","retained",filtered)) %>% 
    ungroup()
  
  locs_data <- locs_data %>% 
    dplyr::filter(latitude < 62.5) %>% 
    dplyr::filter(latitude > 55) %>%
    dplyr::filter(longitude < -147.00) %>%
    dplyr::filter(longitude > -165.00)
  
  locs_data <- st_as_sf(locs_data, coords=c('longitude','latitude'), crs = 4326) %>%
    st_transform(3338)
}