# Returns the stock of the items with the given parameters.
# @param data A product_logs object containing the pertinent data.
# @param dates A vector of two Date objects: the start date and the end date.
# @param cat A character string, the category(ies) parameter for the search.
# @return The stock of the items with the given parameters in a list of two data frames: a summary and a breakdown.
stockTable_stock <- function(data, dates,cat){
  trans <- show_stock(data)
  if(nrow(print(data)) == 0)
    return(list(data.frame(), data.frame()))
  later <- which(trans$date>=dates[1])
  earlier <- which(trans$date<=dates[2])
  tra <- trans[intersect(later, earlier), ]
  if(!'All' %in% cat & length(cat)!=0){
    cats <- which(tra$category %in% cat)
    tra <- tra[cats, ]
  }
  
  star <- tra %>% group_by(category, model, descrp) %>% summarise(debit=sum(debit), credit=sum(credit), net=credit-debit)
  
  return(list(tra, star))
}