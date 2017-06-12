# Adds uploaded data to the database and updates the stock status accordingly. If argument append is TRUE,
# new data is appended to the existing data in database; new data overwrites the existing ones if the argument append 
# is FALSE. Results of the process are saved to the files provided in the arguments.
# @param data The content of the file in a data frame.
# @param append A boolean indicating whether the new data will be appended to or overwrite the existing data.
# @param ex_prod_skel A data frame holding generic information about the items associated with sales of products and purchases
#                     materials for production.
# @param ex_prod_log A product_log object serving as a database of the sale and purchase transactions.
# @param ex_other_skel A data frame holding generic information about the items associated with any transactions other than sales of product
#                      or purchases of materials for production.
# @param ex_other_log A product_log object serving as a database of the transactions other than those for sale and purchase.
# @param xps_fname A character string, name of the .Rd file for the data frame holding generic information about the items associated with sales of products                    and purchases materials for production.
# @param xpl_fname A character string, name of the .Rd file for the database of the sale and purchase transactions.
# @param xos_fname A character string, name of the .Rd file for the data frame holding generic information about the itemss associated with any transactions other than sales of product  or purchases of materials for production.
# @param xol_fname A character string, name of the .Rd file for the database of the transactions other than those for sale and purchase.
process_upload_data <- function(data, append = TRUE, 
                                ex_prod_skel, ex_prod_log, ex_other_skel, ex_other_log,
                                xps_fname = 'ps.Rds', xpl_fname = 'pl.Rds', xos_fname = 'os.Rds', xol_fname = 'ol.Rds'){
  if(nrow(data) == 0)
    return(list(ex_prod_skel, ex_prod_log, ex_other_skel, ex_other_log, character(0)))
  names(data) <- tolower(names(data))
  data$id <- 1:nrow(data); duplicate_rows <- c()
  data$date <- as.Date(data$date, date_format(data$date[1]))
  data$sample <- ifelse(grepl('no', data$sample, ignore.case = TRUE), 'No', 'Yes')
  data$sampling <- ifelse(grepl('no', data$sampling, ignore.case = TRUE), 'No', 'Yes')
  data$transac <- tolower(data$transac)
  data$code <- paste(data$supplier_customer, data$order_no, data$date)
  data <- data[with(data, order(code)), ]
  prod <- subset(data, transac %in% c('sale', 'purchase'))
  other <- subset(data, transac == 'other')
  # Check if any of the uploaded entries have already existed in the database
  # if the uploaded data is opted to append to the existing data.
  # The duplicate rows will be ignored in the process.
  rows_already_existed <- '<font size=\'4\', color=\"#42d162\"><b>Uploaded data has been successfully processed.</b></font>'
  if(append){
    duplicate_prod <- prod$id[duplicate_records(ex_prod_log, prod$date, prod$order_no, prod$supplier_customer)]
    duplicate_other <- other$id[duplicate_records(ex_other_log, other$date, other$order_no, other$supplier_customer)]
    d <- sort(c(duplicate_prod, duplicate_other))
    if(!identical(d, integer(0))){
      rows_already_existed <- paste('<font size=\'4\', color=\"#C65555\"><b>', 'Row(s):', paste(d, collapse=', '), 
                                    'already existed in the database and was/were ignored.', '</b></font>')
      data <- subset(data, ! id %in% d)
    }
    data$id <- NULL
    prod <- subset(data, transac %in% c('sale', 'purchase'))
    other <- subset(data, transac == 'other')
  }
  # This block processes uploaded data of sales and purchases.
  pl <- new('product_logs')
  skeleton_prod <- data.frame()
  for(code in unique(prod$code)){
    p <- prod[prod$code == code, ]
    pt <- new('product_transac')
    pt@date <- unique(p$date)
    pt@transac <- unique(ifelse(p$transac=='sale', 'credit', 'debit'))
    pt@category <- unique(p$transac)
    pt@supplier_customer <- unique(p$supplier_customer)
    pt@order_no <- unique(p$order_no)
    pt@shipment <- unique(p$shipment)
    pt@tax <- unique(p$tax)
    ai <- new('all_items')
    for(i in 1:nrow(p)){
      item <- new('single_item')
      item@category <- p$category[i]
      item@descrp <- p$descrp[i]
      item@model <- p$model[i]
      item@quant <- p$quant[i]
      item@price <- p$price[i]
      item@discount <- p$discount[i]
      item@amount <- amount(item)
      item@sample <- p$sample[i]
      item@sampling <- p$sampling[i]
      ai <- add(ai, item)
      df <- data.frame(supplier=pt@supplier_customer, 
                       model=p$model[i],  
                       mcat=p$mcat[i],            
                       category=p$category[i],
                       descrp=p$descrp[i],
                       stringsAsFactors = FALSE)
      skeleton_prod <- rbind(df, skeleton_prod, stringsAsFactors = FALSE)
    }
    pt@descrp <- ai
    pt@value <- amount(pt@descrp)
    pt@total <- sum(pt@value, pt@shipment, pt@tax)
    pt@time_stamp <- Sys.time()
    pl <- add(pl, pt)
  }
  # This block processes uploaded data of transactions other than sale and purchase.
  ol <- new('product_logs')
  skeleton_other <- data.frame()
  for(code in unique(other$code)){
    o <- other[other$code == code, ]
    ot <- new('product_transac')
    ot@date <- unique(o$date)
    ot@transac <- 'debit'
    ot@category <- unique(o$transac)
    ot@supplier_customer <- unique(o$supplier_customer)
    ot@order_no <- unique(o$order_no)
    ot@shipment <- unique(o$shipment)
    ot@tax <- unique(o$tax)
    ai <- new('all_items')
    for(i in 1:nrow(o)){
      item <- new('single_item')
      item@category <- o$category[i]
      item@descrp <- o$descrp[i]
      item@model <- o$model[i]
      item@quant <- o$quant[i]
      item@price <- o$price[i]
      item@discount <- o$discount[i]
      item@amount <- amount(item)
      item@sample <- o$sample[i]
      item@sampling <- o$sampling[i]
      ai <- add(ai, item)
      df <- data.frame(supplier_customer=ot@supplier_customer, 
                       model=o$model[i],  
                       category=o$category[i],
                       descrp=o$descrp[i],
                       stringsAsFactors = FALSE)
      skeleton_other <- rbind(df, skeleton_other, stringsAsFactors = FALSE)
    }
    ot@descrp <- ai
    ot@value <- amount(ot@descrp)
    ot@total <- sum(ot@value, ot@shipment, ot@tax)
    ot@time_stamp <- Sys.time()
    ol <- add(ol, ot)
  }
  # Append the uploaded data to the database
  if(append){
    pl <- join(ex_prod_log, pl)
    skeleton_prod <- unique(rbind(skeleton_prod, ex_prod_skel, stringsAsFactors = FALSE))
    ol <- join(ex_other_log, ol)
    skeleton_other <- unique(rbind(skeleton_other, ex_other_skel, stringsAsFactors = FALSE))
  }
  # Save results to the files
  saveRDS(skeleton_prod, file = xps_fname)
  saveRDS(pl, file = xpl_fname)
  saveRDS(skeleton_other, file = xos_fname)
  saveRDS(ol, file = xol_fname)
  
  # Return results to continue calulations in the app
  results <- list(skeleton_prod, pl, skeleton_other, ol, rows_already_existed)
  return(results)
}