# Extracts the distinct models in the given data provided by the given supplier(s), category, the type of transaction, and returns them sorted.
# @param data A data frame holding the data.
# @param supplier A character string, the name of the supplier.
# @param cat A character string, the category.
# @param type A character string, the type of transaction (sale, purchase, other).
# @returm A sorted character vector of distinct models. 
model_choice <- function(data, cat, supplier = 'All', type){
  if(nrow(data) == 0)
    return('None exists currently. Add a new model?')
  if(type=='other'){
    if(supplier == '')
      return('Please select a supplier then try again')
    if(cat == '')
      return('Please select a category then try again')
    df <- data
    choices <- df$model[df$supplier == supplier & df$category == cat]
    if(length(choices) == 0)
      return('None exists currently. Add a new model?')
    return(sort(unique(choices)))
  }
  else{
    if(type %in% c('sale', 'purchase')){
      if(cat == '')
        return('Please select a subcategory then try again')
      df <- data
      if(supplier != 'All')
        df <- df[df$supplier == supplier, ]
      choices <- df$model[df$category == cat]
      if(length(choices) == 0)
        return('None exists currently. Add a new model?')
      return(sort(unique(choices)))
    }
    else
      return('None')
  }
}