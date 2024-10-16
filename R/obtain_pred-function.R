obtain_pred <-
  function(
    prefix
    , data_dir
    , model_dir
    , set = "train"
    , task = "classification"
    , identifiers = c("id", "t")
  ){
    read_csv(paste0(data_dir, prefix, "_", set, ".csv"), show_col_types = F) |>
      select_at(identifiers) |>
      cbind(
        read_csv(
          paste0(
            model_dir, prefix, "_", set, "_"
            , ifelse(task == "classification", "prob", "predictions"), ".csv"
          )
          , show_col_types = F
        )
      ) |>
      `colnames<-`(c(identifiers, "pred"))
  }