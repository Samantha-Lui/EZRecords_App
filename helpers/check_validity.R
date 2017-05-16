# Reports the results of the list of tests. If all tests are passed, returns 'Pass' and the collection of the error messages otherwise.
# @param tests A list of tests and their results.
# @param s A character string representing the variable name of the main argument.
# @return The character string representing the result of the check.
# Example: check_validity(is_int(3, 'x'), is_discount('20%')) #returns 'Pass'
# Example: check_validity(is_int(4.7, 'x'), is_int(4, 'y', checkMin=TRUE, min=5)) #returns 'Warning: x must be an integer, Warning: y must be at least 5'
check_validity <- function(tests){
  if(length(tests) == 0)
    return('Pass')
  errs <- ''
  for(i in 1:length(tests)){
    if(grepl('Fail', tests[i]))
      return(tests[i])
    else{
      if(tests[i] != 'Pass')
        errs <- paste(tests[i], '<br><br>', errs)
    }
  }
  if(errs == '')
    return('Pass')
  else
    return(errs)
}