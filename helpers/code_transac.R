# Creates a code for a transaction with its date, order number, and supplier.
# @param date A character string representing the date of the transaction.
# @param orn A character string representing the order number of the transaction.
# @param sup A character string representing the supplier of the item(s) traded in the transaction.
# @return A string representation , a unique code for the transaction.
code_transac <- function(date, orn, sup){
  gsub('[ ,\\-_@]', '', paste(date, substring(sup, 1,3), orn, sep=''))
}