# Opens the uploaded file and reads in the content.
# @param fname A data frame containing the datapath to access the file.
# @return Content of the uploaded file.
upload_table <- function(fname){
  if(is.null(fname))
    return(data.frame())
  try(
    read.csv(fname$datapath, stringsAsFactors = FALSE, strip.white = TRUE)
  )
}