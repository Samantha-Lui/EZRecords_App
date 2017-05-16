# Extracts the distinct names of the categories active during the given date range in the given data, and returns them sorted.
# @param data A product_logs object containing the pertinent data.
# @param dates A vector of two Date objects: the start date and the end date.
# @returm A sorted character vector of distinct categories. 
category_stock <- function(data, dates){
  trans <- show_stock(data)
  later <- which(trans$date>=dates[1])
  earlier <- which(trans$date<=dates[2])
  tra <- trans[intersect(later, earlier), ]
  cs <- sort(unique(tra$category))
  return(c('All', as.character(cs)))
}