obtain_features <- function(model_name){
  data.frame(
    model = model_name
    , feature =
      paste0("inst/extdata/modeval_data_set/", model_name, "_validation.csv") |>
      read_csv(show_col_types = FALSE) |>
      colnames() |>
      setdiff(c("id", "t", "outcome"))
  )
}