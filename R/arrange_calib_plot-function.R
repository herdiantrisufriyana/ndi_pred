arrange_calib_plot <- function(calib_obj){
  labels <-
    calib_obj$metrics |>
    mutate(term = ifelse(term == "rmse", "Brier score", str_to_sentence(term))) |>
    mutate(lb = estimate - ci, , ub = estimate + ci) |>
    mutate_at(c("estimate", "lb", "ub"), format, digits = 3) |>
    unite(ci, lb, ub, sep = ", ") |>
    mutate_at("ci", \(x) paste0("(", x, ")")) |>
    unite(summary, term, estimate, ci, sep = " ") |>
    pull(summary) |>
    paste0(collapse = "\n")
  
  ggarrange(
    calib_obj$plot +
      annotate(
        x = 0.1, y = 0.9, geom = "label", label = labels, hjust=0, size=3
      )
    , calib_obj$dist
    , nrow = 2
    , ncol = 1
    , heights=c(4,2)
  )
}