library(targets)
library(future)
library(future.callr)
plan(callr)

files <- fs::dir_ls("R",recurse = TRUE, glob = "*.R")
sapply(files, source)

# Set target-specific options such as packages.
tar_option_set(packages = c(
  "tidyverse",
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
  tar_target(ci_data, get_ci_data()),
  tar_target(tidy_data, tidy_ci_data()),
  tar_target(fits, fit_crawl()),
  tar_target(fits, refit_crawl()),
  tar_target(paths, reroute_paths()),
  tar_target(create_output_data())
)
