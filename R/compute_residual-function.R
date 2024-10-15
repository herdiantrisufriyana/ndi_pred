compute_residual <-
  function(
      base_df_list
      , resid_df_list
      , model_dir
      , outcome
      , stack
      , set = c("train", "validation", "test")
    ){
    
    `names<-`(set, set) |>
      lapply(
        \(x)
        cbind(
            base_df_list[[x]] |>
              select(id, outcome)
            , read_csv(
                paste0(model_dir, outcome, "_baseline", stack, "_", x, "_prob.csv")
                , show_col_types = F
              )
          ) |>
          mutate(outcome = predicted_probability - outcome) |>
          select(-predicted_probability) |>
          right_join(
            resid_df_list[[x]] |>
              select(-outcome)
            , by = join_by(id)
          )
      )
    
  }
