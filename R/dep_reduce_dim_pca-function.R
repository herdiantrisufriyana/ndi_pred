dep_reduce_dim_pca <-
  function(data, pca_model, outcome_name, type_name, min_epv_name){
    newdata <-
      data |>
      select_if(!colnames(data) %in% c("id", "t", "outcome")) |>
      mutate(seq = seq(n())) |>
      gather(variable, value, -seq) |>
      left_join(
        data.frame(center = pca_model$center, scale = pca_model$scale) |>
          rownames_to_column(var = "variable")
        , by = join_by(variable)
      ) |>
      mutate(value_scaled = (value - center) / scale) |>
      select(-value, -center, -scale) |>
      mutate(variable = factor(variable, unique(variable))) |>
      spread(variable, value_scaled) |>
      arrange(seq) |>
      select(-seq)
    
    new_dim_df <-
      as.data.frame(as.matrix(newdata) %*% pca_model$rotation) |>
      as.data.frame() |>
      select(
        readRDS("data/dep_dim_red_train_regression.rds") |>
          filter(
            outcome == outcome_name
            & type == type_name
            & min_epv == min_epv_name
          ) |>
          pull(max_pred) |>
          seq()
      )
    
    new_dim_df <-
      new_dim_df |>
      `colnames<-`(
        data.frame(
          outcome = outcome_name
          , type = type_name
          , old_name = colnames(new_dim_df)
        ) |>
          left_join(
            readRDS("data/dep_new_dimension_new_name.rds") |>
              filter(
                outcome == outcome_name
                & type == type_name
              )
            , by = join_by(outcome, type, old_name)
          ) |>
          pull(new_name)
      ) |>
      cbind(select_if(data, colnames(data)%in% c("id", "t", "outcome")))
    
    if("t" %in% colnames(new_dim_df)){
      new_dim_df |>
        select(id, outcome, t, everything())
    }else{
      new_dim_df |>
        select(id, outcome, everything())
    }
  }