# Returns the results for the journals search with the given parameters.
# @param data The data frame holding the data.
# @param dates A vector of Date objects, the start and end dates.
# @param cat A character string, the category(ies) parameter for the search.
# @param supplier A character string, the supplier(s) parameter for the search.
# @param cols A vector of character strings representing the column(s) to include in the results.
# @return The results for the journals search with the given parameters in a data frame.
showViewTable <- function(data, dates, cat, supplier, cols){
  if(nrow(data) == 0)
    return(data.frame())
  
  cols <- cols
  if(length(cols) == 0)
    cols <- c('date', 'transac', 'category', 'descrp', 'supplier_customer',
              'value', 'total')
  cat <- cat
  if(length(cat) == 0)
    cat <- 'All'
  
  supplier <- supplier
  if(length(supplier) == 0)
    supplier <- 'All'
  
  if(length(dates) <2)
    dates <- c('2016-01-01', as.character(Sys.Date()))
  
  
  if('All' %in% cat & 'All' %in% supplier)
    return(data[data$date>=dates[1] & data$date<=dates[2],
                cols])
  if(!'All' %in% cat & 'All' %in% supplier)
    return(data[data$date>=dates[1] & data$date<=dates[2] &
                  data$category %in% cat,
                cols])
  if('All' %in% cat & !'All' %in% supplier)
    return(data[data$date>=dates[1] & data$date<=dates[2] &
                  data$supplier_customer %in% supplier,
                cols])
  return(data[data$date>=dates[1] & data$date<=dates[2] &
                data$category %in% cat &
                data$supplier_customer %in% supplier,
              cols])
  
}