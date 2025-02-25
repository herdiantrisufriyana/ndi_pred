obtain_prior_feature_shap_values_if_any <-
  function(
    current_shap_feature_values, prior_shap_feature_values, connector = "id_t"
  ){
    
    current_shap_feature_values |>
      left_join(
        prior_shap_feature_values |>
          select_at(c(connector, "feature", "shap_value", "feature_value")) |>
          `colnames<-`(
            c(connector
              , "prior_feature", "prior_shap_value", "prior_feature_value"
            )
          ) |>
          mutate(feature = "prior")
        , by = c(connector, "feature")
        , relationship = "many-to-many"
      ) |>
      group_by_at(c("id_t", "feature")) |>
      mutate(
        min_prior_shap_value = min(prior_shap_value)
        , max_prior_shap_value = max(prior_shap_value)
      ) |>
      ungroup() |>
      mutate(
        prior_shap_value_norm =
          (prior_shap_value - min_prior_shap_value)
        / (max_prior_shap_value - min_prior_shap_value)
      ) |>
      group_by_at(c("id_t", "feature")) |>
      mutate(total_prior_shap_value_norm =  sum(prior_shap_value_norm)) |>
      ungroup() |>
      mutate(
        p_prior_shap_value_norm =
          prior_shap_value_norm / total_prior_shap_value_norm
        , prior_shap_value2 = p_prior_shap_value_norm * shap_value
        , feature = ifelse(is.na(prior_shap_value), feature, prior_feature)
        , shap_value =
          ifelse(is.na(prior_shap_value), shap_value, prior_shap_value2)
        , feature_value =
          ifelse(is.na(prior_shap_value), feature_value, prior_feature_value)
      ) |>
      group_by_at(
        colnames(current_shap_feature_values)[
          colnames(current_shap_feature_values) != "shap_value"
        ]
      ) |>
      summarize(shap_value = sum(shap_value), .groups = "drop") |>
      select_at(colnames(current_shap_feature_values))
    
  }