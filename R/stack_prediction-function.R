stack_prediction <-
  function(base, resid, set = c("train", "validation", "test")){
    `names<-`(set, set) |>
      lapply(
        \(x)
        base[[x]] |>
          right_join(select(resid[[x]], -outcome), by = join_by(id)) |>
          mutate(pred = predicted_probability + prediction) |>
          select(-predicted_probability, -prediction)
      )
  }