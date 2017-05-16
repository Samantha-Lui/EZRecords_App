# Create a filename with the arguments.
# @param type A numeric-character indicating the type of summary of interest. 
# @param dates A vector of two Date objects: the start date and the end date.
# @return The file name with the arguments.
summary_file_name <- function(type, dates){
  name <- switch(type,
                 '1' = 'summary_by_main_category ',
                 '2' = 'summary_by_main_n_secondary_category ',
                 '3' = 'summary_breakdown ')
  name <- paste(name, dates[1], ' to ', dates[2], '.csv', sep='')
  return(name)
}