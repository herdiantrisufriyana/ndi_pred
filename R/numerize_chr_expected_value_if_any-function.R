numerize_chr_expected_value_if_any <- function(data){
  if(any(str_detect(data$expected_value, "\\[|\\]"))){
    data |>
      mutate_at("expected_value", str_remove_all, "\\[|\\]")|>
      mutate(
        expected_value =
          sapply(expected_value, \(x) str_split(x, " ")[[1]][2]) |>
          as.numeric()
      )
  }else{
    data
  }
}