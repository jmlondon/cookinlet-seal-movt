library(targets)
library(future)
library(future.callr)
plan(callr)

files <- fs::dir_ls("R",recurse = TRUE, glob = "*.R")
sapply(files, source)

# Set target-specific options such as packages.
tar_option_set(packages = c(
  "dplyr",
  "tidyr",
  "purrr",
  "forcats",
  "foreach",
  "progressr",
  "sf",
  "rmapshaper",
  "lubridate",
  "odbc",
  "RPostgres",
  "DBI",
  "dbplyr",
  "here",
  "keyringr",
  "pingr",
  "argosfilter",
  "wcUtils",
  "crawl",
  "pathroutr",
  "ggplot2",
  "ggspatial",
  "pins"
)
)


# End this file with a list of target objects.
list(
  tar_target(timeline_data, get_ci_data("timelines")),
  tar_target(locs_data, get_ci_data("locs")),
  tar_target(locs_data_filt, speed_filter_locs(locs_data)),
  tar_target(land_osm, get_land_osm(locs_data_filt)),
  tar_target(vis_graph, create_vis_graph(land_osm)),
  tar_target(locs_fit, fit_crawl(locs_data_filt)),
  tar_target(locs_refit, refit_crawl(locs_fit)),
  tar_target(paths, reroute_paths(locs_refit, land_osm, vis_graph)),
  tar_target(path_lines, create_path_lines(paths)),
  tar_target(predicted_plot, plot_predicted_lines(path_lines, land_osm)),
  tar_target(joint_data, join_w_timeline(paths, timeline_data)),
  tar_target(pin, publish_as_pin(joint_data))
)
