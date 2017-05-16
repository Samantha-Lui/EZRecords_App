# Calculates the fraction in decimal of a value after discount.
# @param d A charater string representing the percentage discount. ('None' or 'x%' where x is some number between 1 and 100, inclusive.)
# @return The fraction in decimal of a value after discount.
discount <- function(d){
  if(d=='None')
    return(1)
  d <- (100-as.numeric(gsub('%', '', d)))/100
  return(d)
}