# Extracts the distinct names of the main categories in the given data provided by the given supplier(s) and returns them sorted.
# @param data A data frame holding the data.
# @param supplier A character string, the name of the supplier.
# @returm A sorted character vector of distinct main categories.  
mcat_choice <- function(data, supplier = 'All'){
  if(nrow(data) == 0)
    return('None exists currently. Add a new main category?')
  if(supplier == '')
    return('Please select a supplier then try again')
  df <- data
  if(supplier != 'All')
    df <- df[df[ ,'supplier'] == supplier, ]
  choices <- df$mcat
  if(length(choices) == 0)
    return('None exists currently. Add a new main category?')
  return(sort(unique(choices)))
}