library(targets)
library(future)
library(future.callr)
plan(callr)

files <- fs::dir_ls("R",recurse = TRUE, glob = "*.R")
sapply(files, source)

# Set target-specific options such as packages.
tar_option_set(packages = c(
  "dplyr",
  "sf",
  "lubridate",
  "odbc",
  "RPostgres",
  "DBI",
  "dbplyr",
  "here",
  "keyringr",
  "pingr",
  "wcUtils"
)
)


# End this file with a list of target objects.
list(
  tar_target(locs_data, get_ci_data("locs")),
  tar_target(timeline_data, get_ci_data("timelines")),
  tar_target(locs_data_filt, speed_filter_locs()),
  tar_target(fits, fit_crawl()),
  tar_target(refits, refit_crawl()),
  tar_target(paths, reroute_paths()),
  tar_target(output_file,create_output_data(), format="file")
)
