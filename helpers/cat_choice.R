# Extracts the distinct names of the categories in the given data provided by the given supplier(s), the type of transaction, and for sales and purchases, the given main category, and returns them sorted.
# @param data A data frame holding the data.
# @param supplier A character string, the name of the supplier.
# @param mcat A character string, the main category in cases where the transaction is either a sale or a purchase.
# @param type A character string, the type of transaction (sale, purchase, other).
# @returm A sorted character vector of distinct categories. 
cat_choice <- function(data, supplier = 'All', mcat, type){
  if(nrow(data) == 0)
    return('None exists currently. Add a new category?')
  if(type == 'other'){
    if(supplier == '')
      return('Please select a supplier then try again')
    df <- data
    choices <- df$category[df$supplier_customer == supplier]
    if(length(choices) == 0)
      return('None exists currently. Add a new category?')
    return(sort(unique(choices)))
  }
  
  else{
    if(type %in% c('purchase', 'sale')){
      if(mcat == '')
        return('Please select a category then try again')
      df <- data
      if(supplier != 'All')
        df <- df[df$supplier == supplier, ]
      choices <- df$category[df$mcat == mcat]
      if(length(choices) == 0)
        return('None exists currently. Add a new subcategory?')
      return(sort(unique(choices)))
    }
    
    else
      return('None')
  }
}