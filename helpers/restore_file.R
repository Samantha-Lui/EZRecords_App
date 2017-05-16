# Restores the files specified in the input.
# @param files A vector of number representing various files.
restore_file <- function(files){
  if(1 %in% files){
    saveRDS(readRDS("current FREEZE.Rds"), file="current.Rds")
  }
  
  if(2 %in% files){
    saveRDS(readRDS("other_current FREEZE.Rds"), file="other_current.Rds")
  }
  
  if(3 %in% files){
    saveRDS(readRDS("product_logs_current FREEZE.Rds"), file="product_logs_current.Rds")
  }
  
  if(4 %in% files){
    saveRDS(readRDS("other_logs_current FREEZE.Rds"), file="other_logs_current.Rds")
  }
  
  results <- list(readRDS("current.Rds"), 
                  readRDS("other_current.Rds"), 
                  readRDS("product_logs_current.Rds"), 
                  readRDS("other_logs_current.Rds"))

  return(results)
}