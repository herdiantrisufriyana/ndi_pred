obtain_old_dim_shap_values_if_any <-
  function(shap_feature_values, model_name, set = "train"){
    
    dr_before_modeling_desc <-
      dr_before_modeling_desc |>
      lapply(as.data.frame) |>
      imap(~ mutate(.x, model = .y)) |>
      reduce(rbind)
    
    target <- filter(dr_before_modeling_desc, model == model_name)$outcome
    model_type <- filter(dr_before_modeling_desc, model == model_name)$type
    min_epv <- filter(dr_before_modeling_desc, model == model_name)$min_epv
    min_epv <- as.character(min_epv)
    
    if(!is.null(dr_model[[target]][[model_type]][[min_epv]]$rotation)){
      shap_feature_values |>
        mutate_at("id_t", as.character) |>
        left_join(
          new_dimension_new_name |>
            filter(outcome == target & type == model_type) |>
            select(feature = new_name, new_dim = old_name)
          , by = join_by(feature)
        ) |>
        left_join(
          as.data.frame(dr_model[[target]][[model_type]][[min_epv]]$rotation) |>
            rownames_to_column(var = "old_dim") |>
            gather(new_dim, weight, -old_dim)
          , by = join_by(new_dim)
          , relationship = "many-to-many"
        ) |>
        left_join(
          dr_input[[target]][[model_type]][[min_epv]][[set]] |>
            unite_id_t_if_any() |>
            gather(old_dim, input_value, -id_t)
          , by = join_by(id_t, old_dim)
        ) |>
        left_join(
          data.frame(
            center = dr_model[[target]][[model_type]][[min_epv]]$center
            , scale = dr_model[[target]][[model_type]][[min_epv]]$scale
          ) |>
            rownames_to_column(var = "old_dim")
          , by = join_by(old_dim)
        ) |>
        mutate(input_value_scaled = (input_value - center) / scale) |>
        mutate(
          input_shap_value = shap_value / feature_value * input_value_scaled
        ) |>
        mutate(
          feature = ifelse(is.na(old_dim), feature, old_dim)
          , shap_value =
            ifelse(is.na(input_shap_value), shap_value, weight * input_shap_value)
          , feature_value = ifelse(is.na(input_value), feature_value, input_value)
        ) |>
        group_by_at(
          colnames(shap_feature_values)[
            colnames(shap_feature_values) != "shap_value"
          ]
        ) |>
        summarize(shap_value = sum(shap_value), .groups = "drop") |>
        select_at(colnames(shap_feature_values))
    }else{
      shap_feature_values
    }
    
  }