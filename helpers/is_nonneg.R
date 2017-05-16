# Checks if the main arguement is a nonnegative integer.
# @param x A numeric value of the main argument.
# @param s A character string representing the variable name of the main argument.
# @return The character string representing the result of the check.
# Checks if the main arguement is a nonnegative integer.
# @param x A numeric value of the main argument.
# @param s A character string representing the variable name of the main argument.
# @return The character string representing the result of the check.
is_nonneg <- function(x, s){
  if(is.na(x))
    return(paste("<font size='4', color=\"#C65555\"><b>Failure at input for", s, ": Check for missing input or obvious errors</b></font>"))
  if(!is.numeric(x))
    return(paste("<font size='4', color=\"#C65555\"><b>Failure at input for", s, ": Check for missing input or obvious errors</b></font>"))
  if(x < 0)
    return(paste("<font size='4', color=\"#C65555\"><b>Warning:", s, "must be at least zero", "</b></font>"))
  return('Pass')
}