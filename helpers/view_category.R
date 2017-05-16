# Extracts the distinct names of the categories active during the given date range in the given data, and returns them sorted.
# @param data A data frame holding the data.
# @param dates A vector of two Date objects: the start date and the end date.
# @returm A sorted character vector of distinct categories. 
view_category <- function(data, dates){
  c <- sort(unique(data$category[as.character(data$date)>=dates[1] & as.character(data$date)<=dates[2]]))
  c<- as.character(c)
  return(c)
}