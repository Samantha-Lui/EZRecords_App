# Create a filename with the arguments.
# @param fname A character string, preceeding part of the filename.
# @param dates A vector of two Date objects: the start date and the end date.
# @return The file name with the arguments.
file_name <- function(fname, dates){
  name <- paste(fname, dates[1], ' to ', dates[2], '.csv', sep='')
  return(name)
}