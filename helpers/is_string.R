# Checks if the argument is a nonempty string.
# @param t A character string representing the value of the main argument.
# @param s A character string representing the variable name of the main argument.
# @return The character string representing the result of the check.
is_string <- function(t, s){
  if(nchar(t) == 0)
    return(paste("<font size='4', color=\"#C65555\"><b>Failure at input for", s , ": Check for missing input or obvious errors</b></font>"))
  return('Pass')
}