fit_crawl <- function(locs_data_filt) {
  locs <- locs_data_filt %>% 
    dplyr::select(-(starts_with("error_"))) %>% 
    mutate(quality = forcats::as_factor(quality) %>% 
             forcats::fct_relevel("3","2","1","0","A","B")) %>% 
    group_by(speno) %>% 
    arrange(locs_dt) %>% 
    nest()
  
  locs$fit <- foreach(i=1:nrow(locs))%do%{
    cat(locs$speno[[i]],":\n")
    tmp <- locs$data[[i]]
    tmp <- arrange(tmp, locs_dt)
    fit <- try(crwMLE(
      tmp, err.model=list(x=~quality-1),
      Time.name = "locs_dt",
      fixPar = c(log(250), log(500), log(1500), rep(NA,5)),
      constr=list(lower=c(rep(log(1500),3), rep(-Inf,2)),
                  upper=rep(Inf,5)),
      attempts=8,
      retrySD=0.25,
      initialSANN=NULL,
      # prior=function(x){dexp(x[1],1/2,log=TRUE) + dnorm(x[3],2,2.5)},
      method="L-BFGS-B"
    ))
    if(inherits(fit,"error")) fit <- "fit_error"
    fit
  }
  return(locs)
}