paper_arrange_disc_plot <- 
  function(
    discrimination_obj, threshold = 0.5, multiple = FALSE
    , path_linewidth = 0.5, point_size = 1, text_size = 3
    , axis_size = 5, legend_size = 5
  ){
    
    if(multiple){
      roc_curve <-
        discrimination_obj$plot$data |>
        ggplot(aes(tnr, tpr, color = model))
    }else{
      roc_curve <-
        discrimination_obj$plot$data |>
        ggplot(aes(tnr, tpr))
    }
    
    roc_curve <-
      roc_curve +
      geom_abline(slope = 1, intercept = 1, lty = 2)
    
    if(!multiple){
      roc_curve +
        geom_vline(
          xintercept = filter(discrimination_obj$plot$data, th == threshold)$tnr
          , lty = 2, na.rm = TRUE
        ) +
        geom_hline(
          yintercept = filter(discrimination_obj$plot$data, th == threshold)$tpr
          , lty = 2, na.rm = TRUE
        )
    }
    
    roc_curve <-
      roc_curve +
      geom_path(linewidth = path_linewidth)
    
    if(!multiple){
      roc_curve <-
        roc_curve +
        geom_point(
          aes(x=ifelse(th == threshold, tnr, NA))
          , size = point_size
          , na.rm = TRUE
        ) +
        geom_text(
          aes(label = ifelse(th == threshold, round(th, 2), NA))
          , hjust = -0.1, vjust = 1.1, size = text_size
          , check_overlap = TRUE, na.rm = TRUE
        )
    }
    
    roc_curve <-
      roc_curve +
      coord_equal() +
      scale_x_reverse("Specificity", breaks = seq(0, 1, 0.1)) +
      scale_y_continuous("Sensitivity", breaks = seq(0, 1, 0.1))
    
    if(multiple){
      roc_curve <-
        roc_curve +
        scale_color_discrete("Model")
    }
    
    roc_curve +
      theme_classic() +
      theme(
        axis.title = element_text(size = axis_size)
        , axis.text = element_text(size = axis_size)
        , legend.title = element_text(size = legend_size)
        , legend.text = element_text(size = legend_size)
      )
  }