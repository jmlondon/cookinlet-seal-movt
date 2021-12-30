refit_crawl <- function(locs) {
  ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  ### re-fit with prior for animals with errors
  ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  locs$ok_fit <- map_chr(locs$fit, class)!="character"
  
  prob_data <- dplyr::filter(locs, !ok_fit)
  
  locs <- dplyr::filter(locs, ok_fit)
  locs<- mutate(
    locs,
    par = map(fit, ~{.x$estPar}),
    cmat = map(fit, ~{.x$Cmat})
  )
  
  if(nrow(prob_data) == 0) {
    return(locs)
  }
  
  ### Create normal prior for non-fitting animals
  par <- do.call("rbind", locs$par)
  avg_cmat <- (Reduce(`+`, locs$cmat)/nrow(locs))[-c(1:3),-c(1:3)]
  pmu <- colMeans(par)
  pC <- var(par) + avg_cmat
  
  ### Re-fit problem animals
  if(nrow(prob_data)>0){
    ln_prior <- function(x){-0.5*t(x-pmu)%*%solve(pC,(x-pmu))}
    locs$fit <- foreach(i=1:nrow(locs))%do%{
      cat(locs$speno[[i]],":\n")
      tmp <- locs$data[[i]]
      tmp <- arrange(tmp, locs_dt)
      fit <- try(crwMLE(
        tmp, err.model=list(x=~quality-1),
        Time.name = "locs_dt",
        fixPar = c(log(250), log(500), log(1500), rep(NA,5)),
        theta = pmu,
        constr=list(lower=c(rep(log(1500),3), rep(-Inf,2)),
                    upper=rep(Inf,5)),
        attempts=10,
        retrySD=0.25,
        initialSANN=NULL,
        prior=ln_prior,
        method="L-BFGS-B"
      ))
      if(inherits(fit,"error")) fit <- "fit_error"
      fit
    }
    
    ### Check again to see if there are problem animals
   locs$ok_fit <-  map_chr(locs$fit, class)!="character"
    if(all(locs$ok_fit)){
      locs <- mutate(
        locs,
        par = map(fit, ~{.x$estPar}),
        cmat = map(fit, ~{.x$Cmat})
      )
    } else{
      cat("!!! There are still problem fits, must investigate !!!")
      cat("Animals: ", which(!locs$ok_fit))
    }
  }
  return(locs)
}