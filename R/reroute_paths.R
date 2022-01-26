reroute_paths <- function(locs, land, vis_graph) {
  
    plan("multisession", workers=6)
    locs$pred <- foreach(i=1:nrow(locs), .packages=c("sf","dplyr"))%dopar%{
      cat("\n\n",i, " ", locs$speno[i],"\n")
      fit <- locs$fit[[i]]
      pred <- crawl::crwPredict(fit, predTime="1 hour") %>% 
        crawl::crw_as_sf(ftype="POINT",locType="p") %>% 
        pathroutr::prt_trim(land)
      pred_fix <- pathroutr::prt_reroute(pred, land, vis_graph, blend=FALSE)
      pred <- pathroutr::prt_update_points(pred_fix, pred)
      pred
    }
    plan("sequential")
  return(locs)
}