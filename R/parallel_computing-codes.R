if(start){
  # Create multiple CPU clusters for parallel computing.
  cl=makePSOCKcluster(cl)
  registerDoParallel(cl)
  
  # Bring these packages to the CPU clusters.
  clusterEvalQ(cl,{
    library(tidyverse)
    library(knitr)
    library(kableExtra)
    library(ggpubr)
    library(readxl)
    library(broom)
    library(MASS)
    select <- dplyr::select
    library(igraph)
    library(ggnetwork)
    library(brms)
    library(broom.mixed)
    library(pbapply)
    library(mice)
    filter <- dplyr::filter
    cbind <- base::cbind
    rbind <- base::rbind
    library(parallel)
    library(doParallel)
  })
}else{
  # Close the CPU clusters and clean up memory.
  stopCluster(cl)
  registerDoSEQ()
  rm(cl)
  gc()
}