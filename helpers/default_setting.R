# Removes all content in the files specified in the input.
# @param files A vector of number representing various files.
default_setting <- function(files){
  if(1 %in% files){
    ## Skeleton for sale and purchase ('current.Rds')
    saveRDS(data.frame(), file='current.Rds')
  }

  if(2 %in% files){
    ## Skeleton for other kinds of transactions ("other_current.Rds")
    saveRDS(data.frame(), file="other_current.Rds")
  }
  
  if(3 %in% files){
    ## Transaction records of sale and purchase ('product_logs_current.Rds')
    saveRDS(new('product_logs'), file="product_logs_current.Rds")
  }
  
  if(4 %in% files){
    ## Records of transaction other than sale and purchase ("other_logs_current.Rds")
    saveRDS(new('product_logs'), file="other_logs_current.Rds")
  }
  
  results <- list(readRDS("current.Rds"), 
                  readRDS("other_current.Rds"), 
                  readRDS("product_logs_current.Rds"), 
                  readRDS("other_logs_current.Rds"))
  return(results)
}