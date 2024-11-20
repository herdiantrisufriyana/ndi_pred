obtain_pred_features <- function(pred_features, dr_model_list){
  pred_features |>
    lapply(obtain_features) |>
    reduce(rbind) |>
    filter(feature != "prior") |>
    left_join(
      new_dimension_new_name |>
        select(feature = new_name, new_dim = old_name)
      , by = join_by(feature)
    ) |>
    left_join(
      dr_model_list |>
        imap(~ mutate(.x, model = .y)) |>
        reduce(rbind) |>
        select(model, new_dim, old_dim)
      , by = join_by(model, new_dim)
    ) |>
    mutate(feature = ifelse(is.na(new_dim), feature, old_dim)) |>
    select(model, feature) |>
    unique() |>
    mutate_all(\(x) factor(x, unique(x))) |>
    mutate(used = 1) |>
    spread(model, used, fill = 0) |>
    `colnames<-`(c("feature", names(pred_features)))
}