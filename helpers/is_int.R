# Checks if the main arguement is an integer and if opted, if the argument satisfies the minimum and maximum restriction(s).
# @param x A numeric value of the main argument.
# @param s A character string representing the variable name of the main argument.
# @param checkMin A boolean indicating whether the argument satisfies the required minimum.
# @param min A numeric value, the required minimum for the argument.
# @param checkMax A boolean indicating whether the argument satisfies the required maximum.
# @param max A numeric value, the required maximum for the argument.
# @return The character string representing the result of the check.
is_int <- function(x, s, checkMin = FALSE, min = 0, checkMax = FALSE, max = 0){
  if(is.na(x))
    return(paste("<font size='4', color=\"#C65555\"><b>Failure at input for", s, ": Check for missing input or obvious errors</b></font>"))
  if(!is.numeric(x))
    return(paste("<font size='4', color=\"#C65555\"><b>Failure at input for", s, ": Check for missing input or obvious errors</b></font>"))
  if(as.integer(x) != x)
    return(paste("<font size='4', color=\"#C65555\"><b>Warning:", s, "must be an integer</b></font>"))
  if(checkMin | checkMax){
    err <- ''
    if(checkMin)
      if(x < min)
        err <- paste("<font size='4', color=\"#C65555\"><b>Warning:", s, "must be at least", min, "</b></font>")
      if(checkMax)
        if(x > max)
          if(err == '')
            err <- paste("<font size='4', color=\"#C65555\"><b>Warning:", s, "must be at most", max, "</b></font>")
          else
            err <- paste(err, paste("<font size='4', color=\"#C65555\"><b>Warning:", s, 'must be at most', max, "</b></font>"), sep='<br><br>')
          if(err != '')
            return(err)
  }
  return('Pass')
}