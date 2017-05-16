# Calculates the amount due for an item at the given price, quantity, and discount.
# @param quant A numeric value, the quantity of the item of interest.
# @param price A numeric value, the unit price of the item of interest.
# @param discount  A charater string representing the percentage discount. ('None' or 'x%' where x is some number between 1 and 100, inclusive.)
# @return The amount due for an item at the given price, quantity, and discount.
amount_l <- function(quant, price, disc){
  return(sum(quant * price * discount(disc)))
}