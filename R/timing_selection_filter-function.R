timing_selection_filter <- function(data){
  data |>
    mutate(
      used =
        case_when(
          timing == "t_7" & outcome %in% c("survive") ~ "yes"
          , timing == "t_14" & outcome %in% c("rop_severe", "eugr_bw", "hearing")
          ~ "yes"
          , timing == "t_28"
          & outcome %in% c("bpd", "bpd_moderate_severe", "eugr_hc")
          ~ "yes"
          , TRUE ~ "no"
        )
    ) |>
    filter(used == "yes") |>
    select(-used)
}