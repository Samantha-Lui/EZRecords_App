# Extracts the distinct names of the suppliers for the given categories active during the given date range in the given data, 
# and returns them sorted.
# @param data A data frame holding the data.
# @param dates A vector of two Date objects: the start date and the end date.
# @param cat A character string, the category(ies).
# @returm A sorted character vector of distinct supplier(s). 
view_supplier_customer <- function(data, cat, dates){
  if('All' %in% cat){
    sc <- data$supplier_customer[as.character(data$date)>=dates[1] & as.character(data$date)<=dates[2]]
    return(sort(unique(as.character(sc))))
  }
  sc <- data$supplier_customer[as.character(data$date)>=dates[1] & as.character(data$date)<=dates[2] &
                                 as.character(data$category) %in% cat]
  return(sort(unique(as.character(sc))))
}