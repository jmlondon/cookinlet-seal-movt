publish_as_pin <- function(data) {
  board_rsconnect() %>% 
    pin_write(data, access_type = "all",
              name = "cookinlet_pv_data",
              title = "Harbor seal haul-out behavior data",
              description = "This is a dataset of harbor seal locations from Cook Inlet, Alaska",
              versioned = TRUE)
}