# Retrieves the relevant information of the item with the given supplier(s) and model number. 
# @param data A data frame holding the data.
# @param model A character string, the model of the item.
# @param suuplier A character string, the supplier of the item.
# @returm A data frame containing the result of the retrieval.
reverse_lookup <- function(data, supplier, model){
  results <- data[as.character(data$model) == model, ]
  if(nrow(results) == 0)
    return(data.frame())
  if(supplier == 'all')
    return(unique(results[ ,c('mcat', 'category', 'descrp')]))
  return(unique(results[as.character(results$supplier) == supplier ,c('mcat', 'category', 'descrp')]))
}