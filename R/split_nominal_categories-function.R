split_nominal_categories <- function(data){
  output <- list()
  
  for(i in seq(ncol(data))){
    output[[i]] <-
      data |>
      select(all_of(i))
    
    if(is.factor(data[[i]])){
      if(!all(str_detect(levels(data[[i]]), "[:digit:]-"))){
        output[[i]] <-
          output[[i]] |>
          mutate(seq = seq(n())) |>
          gather(old_colname, new_colname, -seq) |>
          select(-old_colname) |>
          mutate(
            new_colname =
              new_colname |>
              factor(
                processed_data_new_cat |>
                  filter(colname == colnames(data)[i]) |>
                  pull(new_cat) |>
                  unique() |>
                  setdiff(NA)
              )
          ) |>
          mutate(cat = "1-yes") |>
          spread(new_colname, cat, fill = "0-no") |>
          arrange(seq) |>
          select(-seq) |>
          mutate_all(as.factor)
        
        if("(removed)" %in% colnames(output[[i]])){
          output[[i]] <-
            output[[i]] |>
            select_if(colnames(output[[i]]) != "(removed)")
        }
        
        if("(missing)" %in% colnames(output[[i]])){
          output[[i]] <-
            output[[i]] |>
            mutate_all(as.character) |>
            mutate(seq = seq(n())) |>
            gather(colname, cat, -seq, -`(missing)`) |>
            mutate(cat = ifelse(`(missing)` == "1-yes", NA, cat)) |>
            mutate_at("colname", \(x) factor(x, unique(x))) |>
            spread(colname, cat) |>
            arrange(seq) |>
            select(-seq, -`(missing)`) |>
            mutate_all(as.factor)
        }
        
        if(any(str_detect(colnames(output[[i]]), "\\*$"))){
          output[[i]] <-
            output[[i]] |>
            mutate_if(
              str_detect(colnames(output[[i]]), "\\*$")
              , \(x) as.factor(ifelse(x == "1-yes", "0-no", "1-yes"))
            ) |>
            `colnames<-`(str_remove_all(colnames(output[[i]]), "\\*$"))
        }
      }
    }
  }
  
  output <-
    output |>
    reduce(cbind)
  
  return(output)
}