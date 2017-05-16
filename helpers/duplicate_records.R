# Compares the unique codes created for the transactions listed in the uploaded file against 
# those of the transactions in the log and returns the duplicated listed transaction(s) if
# is any.
# @param log The log which is a product_log object.
# @param date A vector of character strings representing the dates of transactions.
# @param orn A vector of character strings representing the order numbers of transactions.
# @param sup A vector of character strings representing the suppliers of the goods traded in transactions.
# @return where The location(s) of the duplicate records in the uploaded file and integer(0) if there is none.
duplicate_records <- function(log, date, orn, sup){
  codes <- code_transac(date, orn, sup)
  where <- which(codes %in% order_track(log))
  return(where)
}