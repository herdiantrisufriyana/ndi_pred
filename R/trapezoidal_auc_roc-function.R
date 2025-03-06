trapezoidal_auc_roc <- function(sensitivity, specificity){
  square <- sensitivity * specificity
  sens_triangle <- 0.5 * sensitivity * (1 - specificity)
  spec_trinagle <- 0.5 * (1 - sensitivity) * specificity
  
  square + sens_triangle + spec_trinagle
}