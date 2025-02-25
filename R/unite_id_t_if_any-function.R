unite_id_t_if_any <- function(data){
  if("t" %in% colnames(data)){
    data |>
      unite(id_t, id, t, sep = "_", remove = FALSE) |>
      select(-id)
  }else{
    data |>
      rename(id_t = id)
  }
}