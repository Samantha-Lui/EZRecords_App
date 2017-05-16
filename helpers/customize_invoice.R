# Creates the pattern of invoice number specified by the input.
# @param fname A character string for the name of the log of the invoices generated.
# @param part1 A character string, first part of the pattern of the invoice numbers.
# @param part2 A character string, second part of the pattern of the invoice numbers.
# @param count_begins_at A character string indicating when the count begins.
customize_invoice <- function(fname, part1, part2, count_begins_at){
  vt <- new('invoice',
            fname = fname,
            part1 = part1,
            part2 = part2,
            count_begins_at = count_begins_at)
  saveRDS(vt, file="invoice_object.Rds")
  saveRDS(data.frame(), file=paste(fname, '.Rds', sep=''))
}
