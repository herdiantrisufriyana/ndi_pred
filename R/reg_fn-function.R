reg_fn <- function(formula, data){
  if("t" %in% colnames(data)){
    data <-
      data |>
      rename_at(as.character(formula)[2], \(x) "outcome") |>
      mutate(outcome = Surv(t, outcome)) |>
      rename_at("outcome", \(x) as.character(formula)[2])
    
    coxph(formula, data, id = id)
  }else{
    glm(formula, binomial(), data)
  }
}