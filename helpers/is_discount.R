# Checks if the main arguement is a a vaid expression for a discount.
# @param s A character string representing the main argument.
# @return The character string representing the result of the check.
is_discount <- function(d){
  if(nchar(d) == 0)
    return("<font size='4', color=\"#C65555\"><b>Failure at input for discount: Check for missing input or obvious errors</b></font>")
  if(d != 'None' & !grepl('[0-9]?[0-9]%', d))
    return("<font size='4', color=\"#C65555\"><b>Warning: If there is a discount, it should be indicated by the number of percentage followed by a % symbol (without space); otherwise, \'None\'</b></font>")
  return('Pass')
}