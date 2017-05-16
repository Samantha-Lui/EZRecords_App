# Checks if the file uploaded can be opened properly and if it is in the right format.
# @param fname A data frame containing the datapath to access the file.
# @return TRUE if the uploaded file can be opened properly and in the right format; 
#         FALSE if the uploaded file can be opened properly and but in the wrong format;
#         an error or warning message if there are issues in opening the file. 
successful_upload <- function(fname){
  out <- tryCatch(
    {
      if(is.null(fname))
        return(TRUE)
      identical(tolower(sort(names(read.csv(fname$datapath, stringsAsFactors = FALSE, strip.white = TRUE)))),
                sort(c('transac','date','supplier_customer','order_no','tax','shipment','mcat','category','model',
                       'descrp','discount','sample','sampling','price','quant')))
    },
    error=function(cond) {
      return(cond)
    },
    warning=function(cond) {
      return(cond)
    },
    finally={
    }
  )    
  return(out)
}