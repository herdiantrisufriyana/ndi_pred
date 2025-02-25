add_pred_by_shap <- function(shap_feature_values, model_name){
  
  algorithm <-
    dr_before_modeling_desc |>
    filter(model == model_name) |>
    pull(algorithm)
  
  data <-
    shap_feature_values |>
    group_by(id_t) |>
    summarize(pred_by_shap = sum(shap_value))
  
  if(algorithm == "rr"){
    results <-
      data |>
      mutate(pred_by_shap = 1 / (1 + exp(-pred_by_shap)))
  }else{
    results <- data
  }
  
  shap_feature_values |>
    left_join(results, by = join_by(id_t))
}