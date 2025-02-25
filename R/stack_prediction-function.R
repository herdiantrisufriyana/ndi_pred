stack_prediction <-
  function(
    stacker_df_list
    , data_dir
    , model_dir
    , prior_model_name
    , indices
    , set = c("train", "validation", "test", "independent_test")
  ){
    
    `names<-`(set, set) |>
      lapply(
        \(x)
        cbind(
            read_csv(
                paste0(data_dir, prior_model_name, "_", x, ".csv")
                , show_col_types = F
              ) |>
              select_at(indices) |>
              mutate(id = as.character(id))
            , read_csv(
                paste0(model_dir, prior_model_name, "_", x, "_prob.csv")
                , show_col_types = F
              )
          ) |>
          rename(prior = predicted_probability) |>
          right_join(stacker_df_list[[x]], by = indices)
      )
    
  }
