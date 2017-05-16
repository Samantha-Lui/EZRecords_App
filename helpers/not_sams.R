# Checks if an item is not mistakenly assigned as both a sample for a customer and a production sampling. 
# @param sam1 A character string representing the value of the sample variable.
# @param sam2 A character string representing the value of the sampling variable.
# @return The character string representing the result of the check.
not_sams <- function(sam1, sam2){
  if(nchar(sam1) == 0 | nchar(sam2) == 0)
    return("<font size='4', color=\"#C65555\"><b>Failure at input for sample or sampling: Check for missing input or obvious errors</b></font>")
  if(sam1 == 'Yes' & sam2 == 'Yes')
    return("<font size='4', color=\"#C65555\"><b>Warning: An item cannot be a sample for customer and a production sampling at the same time</b></font>")
  if(!sam1 %in% c('Yes', 'No') | !sam2 %in% c('Yes', 'No'))
    return(paste("<font size='4', color=\"#C65555\"><b>Warning:", 'Please enter \'Yes\' or \'No\'',  "</b></font>"))
  return('Pass')
}