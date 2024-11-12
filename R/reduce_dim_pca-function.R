reduce_dim_pca <-
  function(data, pca_model, outcome_name, type_name, min_epv_name, set){
    new_dim_df <-
      pca_model[[outcome_name]][[type_name]][[min_epv_name]] |>
      predict(
        newdata =
          data[[outcome_name]][[type_name]][[min_epv_name]][[set]] |>
          select_if(
            !colnames(data[[outcome_name]][[type_name]][[min_epv_name]][[set]])
            %in% c("id", "t", "outcome")
          ) |>
          scale(
            center =
              pca_model[[outcome_name]][[type_name]][[min_epv_name]]$center
            , scale =
              pca_model[[outcome_name]][[type_name]][[min_epv_name]]$scale
          )
      ) |>
      as.data.frame() |>
      select(
        dim_red_train_regression |>
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
            new_dimension_new_name |>
              filter(
                outcome == outcome_name
                & type == type_name
              )
            , by = join_by(outcome, type, old_name)
          ) |>
          pull(new_name)
      ) |>
      cbind(
        data[[outcome_name]][[type_name]][[min_epv_name]][[set]] |>
          select_if(
            colnames(data[[outcome_name]][[type_name]][[min_epv_name]][[set]])
            %in% c("id", "t", "outcome")
          )
      )
    
    if("t" %in% colnames(new_dim_df)){
      new_dim_df |>
        select(id, outcome, t, everything())
    }else{
      new_dim_df |>
        select(id, outcome, everything())
    }
  }