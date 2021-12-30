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
  "pathroutr"
)
)


# End this file with a list of target objects.
list(
  tar_target(locs_data, get_ci_data("locs")),
  tar_target(timeline_data, get_ci_data("timelines")),
  tar_target(locs_data_filt, speed_filter_locs(locs_data)),
  tar_target(land_osm, get_land_osm(locs_data_filt)),
  tar_target(locs_fit, fit_crawl(locs_data_filt)),
  tar_target(locs_refit, refit_crawl(locs_fit)),
  tar_target(paths, reroute_paths(locs_refit, land_osm)),
  tar_target(output_file,create_output_data(paths,timeline_data))
)
