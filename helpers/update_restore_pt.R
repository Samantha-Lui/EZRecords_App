# Updates the restore point(s) for the files specified in the input.
# @param files A vector of number representing various files.
update_restore_point <- function(files){
  if(1 %in% files){
    saveRDS(readRDS("current.Rds"), file="current FREEZE.Rds")
  }
  
  if(2 %in% files){
    saveRDS(readRDS("other_current.Rds"), file="other_current FREEZE.Rds")
  }
  
  if(3 %in% files){
    saveRDS(readRDS("product_logs_current.Rds"), file="product_logs_current FREEZE.Rds")
  }
  
  if(4 %in% files){
    saveRDS(readRDS("other_logs_current.Rds"), file="other_logs_current FREEZE.Rds")
  }
}