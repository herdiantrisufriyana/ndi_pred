reduce_dim_pca <- function(data, pca_model, outcome_name, type_name, set){
  new_dim_df <-
    pca_model[[outcome_name]][[type_name]] |>
    predict(
      newdata =
        data[[outcome_name]][[type_name]][[set]] |>
        select(-id, -outcome) |>
        scale(
          center = pca_model[[outcome_name]][[type_name]]$center
          , scale = pca_model[[outcome_name]][[type_name]]$scale
        )
    ) |>
    as.data.frame() |>
    select(
      dim_red_train_regression |>
        filter(outcome == outcome_name & type == type_name) |>
        pull(max_pred) |>
        seq()
    )
  
  new_dim_df |>
    `colnames<-`(
      as.matrix(
        new_dimension_new_name |>
          filter(outcome == outcome_name & type == type_name) |>
          select(old_name, new_name) |>
          column_to_rownames(var = "old_name")
      )[colnames(new_dim_df), ]
    ) |>
    cbind(select(data[[outcome_name]][[type_name]][[set]], id, outcome)) |>
    select(id, outcome, everything())
}