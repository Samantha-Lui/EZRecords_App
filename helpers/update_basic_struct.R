# Updates the database for the categories, models, and descriptions of the items.
# @param data A data frame, the original database.
# @param purchase A data frame, the new purchase which may or may not contain items which have not existed in the database.
# @param fname A character string, the name of the file in which the updated database is stored.
update_basic_struct <- function(purchase, data, fname){
  n <- nrow(data)
  df <- unique(rbind(purchase, data, stringsAsFactors = FALSE))
  if(n < nrow(df)){
    data <- df
    saveRDS(data, file=fname)
  }
  df
}