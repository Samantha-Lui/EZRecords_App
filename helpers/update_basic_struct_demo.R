# Demonstration of the update_basic_struct function which behaves the same as the original function except for
# the restriction of the scope of the saved data to only the current session.
update_basic_struct.demo <- function(purchase, data, fname){
  n <- nrow(data)
  df <- unique(rbind(purchase, data, stringsAsFactors = FALSE))
  if(n < nrow(df)){
    data <- df
    ## Commented for demo
    # saveRDS(data, file=fname)
  }
  df
}