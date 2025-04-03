timing_selection_filter <- function(data){
  data |>
    mutate_at("timing", str_replace_all, "^t_", "Day ") |>
    mutate(
      used =
        case_when(
          timing == "Day 7" & outcome %in% c("survive") ~ "yes"
          , timing == "Day 14" & outcome %in% c("rop_severe", "eugr_bw", "hearing")
          ~ "yes"
          , timing == "Day 28"
          & outcome %in% c("bpd", "bpd_moderate_severe", "eugr_hc")
          ~ "yes"
          , TRUE ~ "no"
        )
    ) |>
    filter(used == "yes") |>
    select(-used)
}