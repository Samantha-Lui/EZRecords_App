# Edits a string represention of a date in one of the three formats (YYYY-MM-DD,
# MM/DD/YYYY, MM/DD/YY) such that it is in the form YYYY-MM-DD.
# @param d A string represention of a date in one of the three formats described above.
# @return A string representation of the date in the YYYY-MM-DD format.
date_format <- function(d){
  if(grepl('[1-2][0-9][0-9][0-9]-[0-1]?[0-9]-[0-2]?[0-9]', d))
    return('%Y-%m-%d')
  if(grepl('[0-1]?[0-9]/[0-2]?[0-9]/[1-2][0-9][0-9][0-9]', d))
    return('%m/%d/%Y')
  if(grepl('[0-1]?[0-9]/[0-2]?[0-9]/[0-9][0-9]', d))
    return('%m/%d/%y')
}