paper_arrange_eval_plot <-
  function(
    calibration_plot, decision_plot, discrimination_plot, threshold
    , shap_beeswarm_obj
    , outcome_name, model_name, timing
    , ghi = c(12.5, 5, 2.5)
    , ghi_label = LETTERS[7:9]
  ){
    calibration_plot <-
      calibration_plot |>
      `names<-`(
        rop_severe_stack_eval_calibration_plot |>
          names() |>
          sapply(\(x) str_extract_all(x, paste0("[:alpha:]+$"))[[1]])
      )
    
    calibration_plot <- calibration_plot[sort(names(calibration_plot))]
    
    ggarrange(
      ggarrange(
        calibration_plot[[1]]
        , calibration_plot[[2]]
        , calibration_plot[[3]]
        , calibration_plot[[4]]
        , nrow = 4, ncol = 1, heights = c(6, 6, 6, 6), labels = LETTERS[1:4]
      )
      , ggarrange(
        ggarrange(
          decision_plot +
            geom_vline(xintercept = threshold, lty = 2) +
            theme(legend.position = "none")
          , discrimination_plot +
            geom_point(
              data =
                discrimination_plot$data |>
                cbind((data.frame(selected_th = threshold))) |>
                filter(th == selected_th & model == model_name)
            )
          , nrow = 1, ncol = 2
          , widths = c(4, 5)
          , labels = LETTERS[5:6]
        )
        , ggarrange(
            shap_beeswarm_obj
            , mutate(cm_selected_time_summary_val, set = "Validation") |>
              rbind(mutate(cm_selected_time_summary, set = "Test")) |>
              timing_selection_plot(outcome_name, timing)
            , figure48 |>
              filter(str_detect(outcome, paste0("^", outcome_name))) |>
              ggplot(aes(metric, avg))  +
              geom_hline(yintercept = -0.05, lty = 2) +
              geom_errorbar(
                aes(ymin = lb, ymax = ub), width = 0.5, na.rm = TRUE
              ) +
              geom_point(size = 1, na.rm = TRUE) +
              coord_flip() +
              xlab("") +
              scale_y_continuous(
                paste0(
                  "Difference in AUC-ROCs (95% CI) "
                  , "(estimates of independent test set - "
                  , "lower bound of test set)"
                )
                , breaks = seq(-1, 1, 0.1), limits = c(-0.25, 0.25)
              ) +
              theme(
                strip.text.y.left = element_text(angle = 0, hjust = 1)
                , strip.background = element_blank()
                , strip.placement = "outside"
              )
            , nrow = 3, ncol = 1, heights = ghi
            , labels = ghi_label
          )
        , nrow = 2, ncol = 1, heights = c(4, 20)
      )
      , nrow = 1, ncol = 2, widths = c(5, 9)
    )
  }