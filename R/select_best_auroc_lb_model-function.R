select_best_auroc_lb_model <- function(discrimination_obj_list){
  discrimination_obj_list |>
    imap(
      ~ .x$validation$metrics |>
        mutate(model = .y)
    ) |>
    reduce(rbind) |>
    mutate(lb = estimate - ci, ub = estimate + ci) |>
    filter(lb == max(lb)) |>
    slice(1) |>
    pull(model)
}