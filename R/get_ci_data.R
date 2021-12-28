get_ci_data <- function(kind = c("locs", "timelines")) {
  kind <- match.arg(kind)
  
  stopifnot(
    "PEP Postgres Database Not Available; did you start VPN? ;)" =
      pingr::is_up("161.55.120.122", "5432")
  )
  
  con <- dbConnect(
    odbc::odbc(),
    dsn = "PostgreSQL pep",
    uid = keyringr::get_kc_account("pgpep_londonj"),
    pwd = keyringr::decrypt_kc_pw("pgpep_londonj")
  )
  
  on.exit(dbDisconnect(con))
  
  if (kind %in% c("locs")) {
    qry <- sql(
      "SELECT a.deployid deployid, b.speno, sex, age, tag_family, deploy_dt, end_dt,
  a.ptt ptt, instr, locs_dt, type, quality,
  latitude, longitude, error_radius, error_semi_major_axis,
  error_semi_minor_axis, error_ellipse_orientation, data_status,
  a.meta_project meta_project, geom
  FROM telem.geo_wc_locs_qa a
  LEFT JOIN telem.tbl_tag_deployments b ON a.deployid = b.deployid
  LEFT JOIN capture.for_telem c ON b.speno = c.speno
  WHERE a.meta_project = 'Cook Inlet Harbor Seals'"
    )
    
    locs <- sf::st_read(con, query = qry) %>%
      sf::st_transform(3338) %>%
      dplyr::arrange(deployid, locs_dt)
    
    return(locs)
  } 
  
  if (kind %in% c("timeline")) {
    qry <- sql(
      "SELECT a.deployid deployid, b.speno, sex, age, tag_family, deploy_dt, end_dt,
  hist_type, timeline_start_dt, percent_dry
  FROM telem.tbl_wc_histos_timeline_qa a
  LEFT JOIN telem.tbl_tag_deployments b ON a.deployid = b.deployid
  LEFT JOIN capture.for_telem c ON b.speno = c.speno
  WHERE a.meta_project = 'Cook Inlet Harbor Seals'"
    )
    
    timelines <- tbl(con, qry) %>%
      dplyr::arrange(deployid, timeline_start_dt)
    
    return(timelines)
  } 
  
}