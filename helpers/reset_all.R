# Resets the input elements back to their riginal values. 
# @param ids A vector of character strings representing the input elements' id's.
reset_all <- function(ids){
  for(i in 1:length(ids))
    reset(ids[i])
}