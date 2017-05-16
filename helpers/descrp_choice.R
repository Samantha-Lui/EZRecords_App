# Extracts the distinct description of the items in the given data by the given category and model and returns them sorted.
# @param data A data frame holding the data.
# @param model A character string, the model of the item.
# @param cat A character string, the category of the item.
# @returm A sorted character vector of distinct descriptions. 
descrp_choice <- function(data, model, cat){
  if(nrow(data) == 0)
    return('None exists currently. Add a new description?')
  if(model == '')
    return('Please select a model then try again')
  df <- data
  choices <- df$descrp[df$model == model & df$category == cat]
  if(length(choices) == 0)
    return('None exists currently. Add a new description?')
  return(sort(unique(choices)))
}