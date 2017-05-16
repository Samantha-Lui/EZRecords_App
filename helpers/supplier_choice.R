# Extracts the distinct names of the suppliers in the given data and returns them sorted.
# @param data A data frame holding the data.
# @param colName A character string, the name of the column in the data for the supplier.
# @returm A sorted character vector of distinct supplier names.  
supplier_choice <- function(data, colName){
  if(nrow(data) == 0)
    return('None existed. Add a new supplier?')
  c <- as.character(unique(data[, colName]))
  if(length(c)==0)
    return('None existed. Add a new supplier?')
  return(sort(c))
}