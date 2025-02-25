timing_selection_plot <-
  function(data, outcome_name = NULL, selected_time = NULL, show_plot = TRUE){
    data <-
      data |>
      mutate(
        used =
          case_when(
            outcome == "survive" & timing %in% paste0("t_", c(1, 7, 14)) ~ "yes"
            , outcome
            %in% c(
              "rop_severe", "bpd", "bpd_moderate_severe", "eugr_hc", "eugr_bw"
            )
            & timing != "ga_wk_t_36"
            ~ "yes"
            , outcome == "hearing" & timing %in% paste0("t_", c(7, 14, 28, 42))
            ~ "yes"
            , TRUE ~ "no"
          )
      ) |>
      filter(used == "yes")
    
    if(!is.null(outcome_name)){
      data <-
        data |>
        filter(outcome == outcome_name)
    }
    
    if(!is.null(selected_time)){
      data <-
        data |>
        mutate(selection = ifelse(timing %in% selected_time, "Yes", "No"))
    }
    
    data <-
      data |>
      mutate(
        avg = ifelse(metric == "F1", avg, avg / 100)
        , lb = ifelse(metric == "F1", lb, lb / 100)
        , ub = ifelse(metric == "F1", ub, ub / 100)
      ) |>
      mutate_at(c("outcome", "set"), \(x) factor(x, unique(x))) |>
      mutate_at(c("timing"), \(x) factor(x, rev(unique(x)))) |>
      mutate_at(
        c("metric"), \(x) factor(x, c("TPR", "PPV", "F1", "TNR", "NPV"))
      )
    
    if(show_plot){
      if(!is.null(selected_time)){
        data_plot <-
          data |>
          ggplot(aes(timing, avg, color = selection))
      }else{
        data_plot <-
          data |>
          ggplot(aes(timing, avg))
      }
      
      data_plot  +
        geom_errorbar(aes(ymin = lb, ymax = ub), width = 0.5, na.rm = TRUE) +
        geom_point(size = 1, na.rm = TRUE) +
        facet_grid(metric ~ set, scale = "free", space = "free", switch = "y") +
        coord_flip() +
        xlab("") +
        ylab("Average (95% CI)") +
        scale_color_manual("Selected", values = c("black", "red")) +
        theme(
          strip.text.y.left = element_text(angle = 0, vjust = 1, hjust = 1)
          , strip.background.y = element_blank()
          , strip.placement = "outside"
        )
    }else{
      data
    }
  }