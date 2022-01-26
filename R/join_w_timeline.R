join_w_timeline <- function(pred_locs, timeline_data) {
  timeline_data <- timeline_data %>% 
    select(deployid,speno,hist_type,timeline_start_dt,percent_dry)
  
  l <- pred_locs[, c("speno","pred")] %>%
    tidyr::unnest(pred) %>%
    dplyr::select(speno, deployid, sex, age, deploy_dt, end_dt, locs_dt,
                  nu.x, nu.y, geometry) %>% 
    dplyr:: left_join(timeline_data, 
                      by = c("deployid" = "deployid", "speno" = "speno", 
                             "locs_dt" = "timeline_start_dt")) %>% 
    sf::st_as_sf()
}