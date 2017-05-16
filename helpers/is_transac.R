# Checks if the argument is assigned to a valid value: 'credit' or 'debit' or not.
# @param t A character string representing the value of the argument.
# @return The character string representing the result of the check.
is_transac <- function(t){
  if(nchar(t) == 0)
    return("<font size='4', color=\"#C65555\"><b>Failure at input for transaction: Check for missing input or obvious errors</b></font>")
  if(! t %in% c('credit', 'debit'))
    return("<font size='4', color=\"#C65555\"><b>Warning: Transaction should be either \'credit\' or \'debit\'</b></font>")
  return('Pass')
}