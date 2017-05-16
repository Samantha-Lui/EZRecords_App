# Summarises the incomes/spendings.
# @param data A data frame containing the pertinent data.
# @param dates A vector of two Date objects: the start date and the end date.
# @param cat A character string, the category(ies) parameter for the calculation.
# @param model A character string, the model(s) parameter for the calculation.
# @return A summary of the incomes/spendings in a data frame.
incomes_spendings_summaries <- function(data, dates, cat, model){
  if(nrow(data) == 0)
    return(list(data.frame(), data.frame(), data.frame()))
  later <- which(data$date>=dates[1])
  earlier <- which(data$date<=dates[2])
  df <- data[intersect(later, earlier), ]
  if(!'All' %in% cat & length(cat)!=0){
    cats <- which(df$category %in% cat)
    df <- df[cats, ]
  }
  if(!'All' %in% model & length(model)!=0){
    model <- which(df$model %in% model)
    df <- df[model, ]
  }
  
  credit <- 0
  if(!'credit' %in% names(df))
    df <- data.frame(df, credit, stringsAsFactors = FALSE)
  debit <- 0
  if(!'debit' %in% names(df))
    df <- data.frame(df, debit, stringsAsFactors = FALSE)
  
  df_by_cat_mod <- df %>% group_by(category, model) %>% summarise(debit=sum(debit), credit=sum(credit), net=credit-debit)
  
  df_by_cat <- df %>% group_by(category) %>% summarise(debit=sum(debit), credit=sum(credit), net=credit-debit)
  
  return(list(df_by_cat, df_by_cat_mod, df))
}