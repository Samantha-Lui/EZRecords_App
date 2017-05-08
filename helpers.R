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



# Compares the unique codes created for the transactions listed in the uploaded file against 
# those of the transactions in the log and returns the duplicated listed transaction(s) if
# is any.
# @param log The log which is a product_log object.
# @param date A vector of character strings representing the dates of transactions.
# @param orn A vector of character strings representing the order numbers of transactions.
# @param sup A vector of character strings representing the suppliers of the goods traded in transactions.
# @return where The location(s) of the duplicate records in the uploaded file and integer(0) if there is none.
duplicate_records <- function(log, date, orn, sup){
    codes <- code_transac(date, orn, sup)
    where <- which(codes %in% order_track(log))
    return(where)
}



# Creates a code for a transaction with its date, order number, and supplier.
# @param date A character string representing the date of the transaction.
# @param orn A character string representing the order number of the transaction.
# @param sup A character string representing the supplier of the item(s) traded in the transaction.
# @return A string representation , a unique code for the transaction.
code_transac <- function(date, orn, sup){
    gsub('[ ,\\-_@]', '', paste(date, substring(sup, 1,3), orn, sep=''))
}



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



# Reports if the uploaded file can be opened successfully, and if it is in the right format.
# @param cond Result of the check.
# @return TRUE if the uploaded file can be opened successfully and in the right format;
#         a customized message about the issues otherwise.
validate_upload <- function(cond){
    if(is.logical(cond)){
        if(cond == TRUE)
            return(NULL)
        else
            return("WARNING: The file to be uploaded should consist of the following columns:

                   transac: The type of the transaction (\'sale\' for sale of the item, \'purchase\' for the purchase of a production material, and \'other\' for all other types).*
                   date: The date of the transaction with format YYYY-MM-DD, MM/DD/YYYY, or MM/DD/YY.*
                   supplier_customer: The name of the supplier of the item or the customer purchasing the item.*
                   order_no: The order number of the transaction. Leave blank if not applicable.*
                   tax: The total amount of tax paid  in the transaction.*
                   shipment: The total amount of paid for shipment and handling in the transaction.*
                   mcat: The generic category in which the item belongs. Leave blank if not applicable.
                   category: Ther category in which the item belongs.
                   model: Model number of the item.
                   descrp: Description of the item.
                   quant: Quantity of the item involved in the transaction.
                   price: Unit price of the item. Enter original price if the transaction is a sale and the actual price for all others.
                   discount: Discount on the item,  either in the format \'x%\' or \'None\' for a sale and \'None\' for all others. 
                   sample: Whether the item is a sample (\'Yes\', \'No\').
                   sampling: Whether the item is a sampling item used in the production(\'Yes\', \'No\'). This should be \'No\' for all transactions besides sale.
                   
                   *Repeats in all items involved in the same transaction.")
    }
    else
        return('WARNING: The upload file must be in .csv format. Please try again.')
}



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



# Reports the results of the list of tests. If all tests are passed, returns 'Pass' and the collection of the error messages otherwise.
# @param tests A list of tests and their results.
# @param s A character string representing the variable name of the main argument.
# @return The character string representing the result of the check.
# Example: check_validity(is_int(3, 'x'), is_discount('20%')) #returns 'Pass'
# Example: check_validity(is_int(4.7, 'x'), is_int(4, 'y', checkMin=TRUE, min=5)) #returns 'Warning: x must be an integer, Warning: y must be at least 5'
check_validity <- function(tests){
    if(length(tests) == 0)
        return('Pass')
    errs <- ''
    for(i in 1:length(tests)){
        if(grepl('Fail', tests[i]))
            return(tests[i])
        else{
            if(tests[i] != 'Pass')
                errs <- paste(tests[i], '<br><br>', errs)
        }
    }
    if(errs == '')
        return('Pass')
    else
        return(errs)
}


# Checks if the argument is a nonempty string.
# @param t A character string representing the value of the main argument.
# @param s A character string representing the variable name of the main argument.
# @return The character string representing the result of the check.
is_string <- function(t, s){
    if(nchar(t) == 0)
        return(paste("<font size='4', color=\"#C65555\"><b>Failure at input for", s , ": Check for missing input or obvious errors</b></font>"))
    return('Pass')
}


# Checks if the main arguement is a nonnegative integer.
# @param x A numeric value of the main argument.
# @param s A character string representing the variable name of the main argument.
# @return The character string representing the result of the check.
is_nonneg <- function(x, s){
    if(is.na(x))
        return(paste("<font size='4', color=\"#C65555\"><b>Failure at input for", s, ": Check for missing input or obvious errors</b></font>"))
    if(!is.numeric(x))
        return(paste("<font size='4', color=\"#C65555\"><b>Failure at input for", s, ": Check for missing input or obvious errors</b></font>"))
    if(x < 0)
        return(paste("<font size='4', color=\"#C65555\"><b>Warning:", s, "must be at least zero", "</b></font>"))
    return('Pass')
}


# Checks if the argument is assigned to a valid value: 'credit' or 'debit' or not.
# @param t A character string representing the value of the argument.
# @return The character string representing the result of the check.
is_transac <- function(t){
    if(nchar(t) == 0)
        return("<font size='4', color=\"#C65555\"><b>Failure at input for transaction: Check for missing input or obvious errors</b></font>")
    if(! t %in% c('credit', 'debit'))
        return("<font size='4', color=\"#C65555\"><b>Warning: Transaction should be either \'credit\' or \'debit\'</b></font>")
    return('Pass')
}


# Checks if an item is not mistakenly assigned as both a sample for a customer and a production sampling. 
# @param sam1 A character string representing the value of the sample variable.
# @param sam2 A character string representing the value of the sampling variable.
# @return The character string representing the result of the check.
not_sams <- function(sam1, sam2){
    if(nchar(sam1) == 0 | nchar(sam2) == 0)
        return("<font size='4', color=\"#C65555\"><b>Failure at input for sample or sampling: Check for missing input or obvious errors</b></font>")
    if(sam1 == 'Yes' & sam2 == 'Yes')
        return("<font size='4', color=\"#C65555\"><b>Warning: An item cannot be a sample for customer and a production sampling at the same time</b></font>")
    if(!sam1 %in% c('Yes', 'No') | !sam2 %in% c('Yes', 'No'))
        return(paste("<font size='4', color=\"#C65555\"><b>Warning:", 'Please enter \'Yes\' or \'No\'',  "</b></font>"))
    return('Pass')
}


# Checks if the main arguement is a a vaid expression for a discount.
# @param s A character string representing the main argument.
# @return The character string representing the result of the check.
is_discount <- function(d){
    if(nchar(d) == 0)
        return("<font size='4', color=\"#C65555\"><b>Failure at input for discount: Check for missing input or obvious errors</b></font>")
    if(d != 'None' & !grepl('[0-9]?[0-9]%', d))
        return("<font size='4', color=\"#C65555\"><b>Warning: If there is a discount, it should be indicated by the number of percentage followed by a % symbol (without space); otherwise, \'None\'</b></font>")
    return('Pass')
}


# Checks if the main arguement is an integer and if opted, if the argument satisfies the minimum and maximum restriction(s).
# @param x A numeric value of the main argument.
# @param s A character string representing the variable name of the main argument.
# @param checkMin A boolean indicating whether the argument satisfies the required minimum.
# @param min A numeric value, the required minimum for the argument.
# @param checkMax A boolean indicating whether the argument satisfies the required maximum.
# @param max A numeric value, the required maximum for the argument.
# @return The character string representing the result of the check.
is_int <- function(x, s, checkMin = FALSE, min = 0, checkMax = FALSE, max = 0){
    if(is.na(x))
        return(paste("<font size='4', color=\"#C65555\"><b>Failure at input for", s, ": Check for missing input or obvious errors</b></font>"))
    if(!is.numeric(x))
        return(paste("<font size='4', color=\"#C65555\"><b>Failure at input for", s, ": Check for missing input or obvious errors</b></font>"))
    if(as.integer(x) != x)
        return(paste("<font size='4', color=\"#C65555\"><b>Warning:", s, "must be an integer</b></font>"))
    if(checkMin | checkMax){
        err <- ''
        if(checkMin)
            if(x < min)
                err <- paste("<font size='4', color=\"#C65555\"><b>Warning:", s, "must be at least", min, "</b></font>")
        if(checkMax)
            if(x > max)
                if(err == '')
                    err <- paste("<font size='4', color=\"#C65555\"><b>Warning:", s, "must be at most", max, "</b></font>")
                else
                    err <- paste(err, paste("<font size='4', color=\"#C65555\"><b>Warning:", s, 'must be at most', max, "</b></font>"), sep='<br><br>')
        if(err != '')
            return(err)
    }
    return('Pass')
}


# Create a filename with the arguments.
# @param fname A character string, preceeding part of the filename.
# @param dates A vector of two Date objects: the start date and the end date.
# @return The file name with the arguments.
file_name <- function(fname, dates){
    name <- paste(fname, dates[1], ' to ', dates[2], '.csv', sep='')
    return(name)
}


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


# Summarises the incomes/spendings.
# @param data A data frame containing the pertinent data.
# @param dates A vector of two Date objects: the start date and the end date.
# @param cat A character string, the category(ies) parameter for the calculation.
# @param model A character string, the model(s) parameter for the calculation.
# @return A summary of the incomes/spendings in a data frame.
incomes_spendings_summaries <- function(data, dates, cat, model){
    if(nrow(data) == 0)
        return(data.frame())
    later <- which(data$date>=dates[1])
    earlier <- which(data$date<=dates[2])
    df <- data[intersect(later, earlier), ]
    if(!'All' %in% cat & length(cat)!=0){
        cats <- which(df$category %in% cat)
        df <- df[cats, ]
    }
    if(!'All' %in% model & length(model)!=0){
        model <- which(df$model %in% model)
        df <- df[model, ]
    }
    
    credit <- 0
    if(!'credit' %in% names(df))
        df <- data.frame(df, credit, stringsAsFactors = FALSE)
    debit <- 0
    if(!'debit' %in% names(df))
        df <- data.frame(df, debit, stringsAsFactors = FALSE)
    
    df_by_cat_mod <- df %>% group_by(category, model) %>% summarise(debit=sum(debit), credit=sum(credit), net=credit-debit)
    
    df_by_cat <- df %>% group_by(category) %>% summarise(debit=sum(debit), credit=sum(credit), net=credit-debit)
    
    return(list(df_by_cat, df_by_cat_mod, df))
}


# Returns the stock of the items with the given parameters.
# @param data A product_logs object containing the pertinent data.
# @param dates A vector of two Date objects: the start date and the end date.
# @param cat A character string, the category(ies) parameter for the search.
# @return The stock of the items with the given parameters in a list of two data frames: a summary and a breakdown.
stockTable_stock <- function(data, dates,cat){
    trans <- show_stock(data)
    if(nrow(print(data)) == 0)
        return(list(data.frame(), data.frame()))
    later <- which(trans$date>=dates[1])
    earlier <- which(trans$date<=dates[2])
    tra <- trans[intersect(later, earlier), ]
    if(!'All' %in% cat & length(cat)!=0){
        cats <- which(tra$category %in% cat)
        tra <- tra[cats, ]
    }
    
    star <- tra %>% group_by(category, model, descrp) %>% summarise(debit=sum(debit), credit=sum(credit), net=credit-debit)
    
    return(list(tra, star))
}


# Extracts the distinct names of the categories active during the given date range in the given data, and returns them sorted.
# @param data A product_logs object containing the pertinent data.
# @param dates A vector of two Date objects: the start date and the end date.
# @returm A sorted character vector of distinct categories. 
category_stock <- function(data, dates){
    trans <- show_stock(data)
    later <- which(trans$date>=dates[1])
    earlier <- which(trans$date<=dates[2])
    tra <- trans[intersect(later, earlier), ]
    cs <- sort(unique(tra$category))
    return(c('All', as.character(cs)))
}


# Returns the results for the journals search with the given parameters.
# @param data The data frame holding the data.
# @param dates A vector of Date objects, the start and end dates.
# @param cat A character string, the category(ies) parameter for the search.
# @param supplier A character string, the supplier(s) parameter for the search.
# @param cols A vector of character strings representing the column(s) to include in the results.
# @return The results for the journals search with the given parameters in a data frame.
showViewTable <- function(data, dates, cat, supplier, cols){
    
    cols <- cols
    if(length(cols) == 0)
        cols <- c('date', 'transac', 'category', 'descrp', 'supplier_customer',
                  'value', 'total')
    cat <- cat
    if(length(cat) == 0)
        cat <- 'All'
    
    supplier <- supplier
    if(length(supplier) == 0)
        supplier <- 'All'
    
    if(length(dates) <2)
        dates <- c('2016-01-01', as.character(Sys.Date()))
    
    
    if('All' %in% cat & 'All' %in% supplier)
        return(data[data$date>=dates[1] & data$date<=dates[2],
                                  cols])
    if(!'All' %in% cat & 'All' %in% supplier)
        return(data[data$date>=dates[1] & data$date<=dates[2] &
                                      data$category %in% cat,
                                  cols])
    if('All' %in% cat & !'All' %in% supplier)
        return(data[data$date>=dates[1] & data$date<=dates[2] &
                                      data$supplier_customer %in% supplier,
                                  cols])
    return(data[data$date>=dates[1] & data$date<=dates[2] &
                                  data$category %in% cat &
                                  data$supplier_customer %in% supplier,
                              cols])
    
}


# Extracts the distinct names of the suppliers for the given categories active during the given date range in the given data, 
# and returns them sorted.
# @param data A data frame holding the data.
# @param dates A vector of two Date objects: the start date and the end date.
# @param cat A character string, the category(ies).
# @returm A sorted character vector of distinct supplier(s). 
view_model <- function(data, cat, dates){
    if('All' %in% cat){
        m <- data$model[as.character(data$date)>=dates[1] & as.character(data$date)<=dates[2]]
        return(sort(unique(as.character(m))))
    }
    m <- data$model[as.character(data$date)>=dates[1] & as.character(data$date)<=dates[2] &
                                     as.character(data$category) %in% cat]
    return(sort(unique(as.character(m))))
}


# Extracts the distinct names of the suppliers for the given categories active during the given date range in the given data, 
# and returns them sorted.
# @param data A data frame holding the data.
# @param dates A vector of two Date objects: the start date and the end date.
# @param cat A character string, the category(ies).
# @returm A sorted character vector of distinct supplier(s). 
view_supplier_customer <- function(data, cat, dates){
    if('All' %in% cat){
        sc <- data$supplier_customer[as.character(data$date)>=dates[1] & as.character(data$date)<=dates[2]]
        return(sort(unique(as.character(sc))))
    }
    sc <- data$supplier_customer[as.character(data$date)>=dates[1] & as.character(data$date)<=dates[2] &
                                                   as.character(data$category) %in% cat]
    return(sort(unique(as.character(sc))))
}


# Extracts the distinct names of the categories active during the given date range in the given data, and returns them sorted.
# @param data A data frame holding the data.
# @param dates A vector of two Date objects: the start date and the end date.
# @returm A sorted character vector of distinct categories. 
view_category <- function(data, dates){
    c <- sort(unique(data$category[as.character(data$date)>=dates[1] & as.character(data$date)<=dates[2]]))
    c<- as.character(c)
    return(c)
}


# Retrieves the relevant information of the item with the given supplier(s) and model number. 
# @param data A data frame holding the data.
# @param model A character string, the model of the item.
# @param suuplier A character string, the supplier of the item.
# @returm A data frame containing the result of the retrieval.
reverse_lookup <- function(data, supplier, model){
    results <- data[as.character(data$model) == model, ]
    if(nrow(results) == 0)
        return(data.frame())
    if(supplier == 'all')
        return(unique(results[ ,c('mcat', 'category', 'descrp')]))
    return(unique(results[as.character(results$supplier) == supplier ,c('mcat', 'category', 'descrp')]))
}


# Resets the input elements back to their riginal values. 
# @param ids A vector of character strings representing the input elements' id's.
reset_all <- function(ids){
    for(i in 1:length(ids))
        reset(ids[i])
}


# Calculates the amount due for an item at the given price, quantity, and discount.
# @param quant A numeric value, the quantity of the item of interest.
# @param price A numeric value, the unit price of the item of interest.
# @param discount  A charater string representing the percentage discount. ('None' or 'x%' where x is some number between 1 and 100, inclusive.)
# @return The amount due for an item at the given price, quantity, and discount.
amount_l <- function(quant, price, disc){
    return(sum(quant * price * discount(disc)))
}


# Calculates the fraction in decimal of a value after discount.
# @param d A charater string representing the percentage discount. ('None' or 'x%' where x is some number between 1 and 100, inclusive.)
# @return The fraction in decimal of a value after discount.
discount <- function(d){
    if(d=='None')
        return(1)
    d <- (100-as.numeric(gsub('%', '', d)))/100
    return(d)
}


# Updates the database for the categories, models, and descriptions of the items.
# @param data A data frame, the original database.
# @param purchase A data frame, the new purchase which may or may not contain items which have not existed in the database.
# @param fname A character string, the name of the file in which the updated database is stored.
update_basic_struct <- function(purchase, data, fname){
    n <- nrow(data)
    df <- unique(rbind(purchase, data, stringsAsFactors = FALSE))
    if(n < nrow(df)){
        data <- df
        saveRDS(data, file=fname)
    }
    df
}


# Extracts the distinct description of the items in the given data by the given category and model and returns them sorted.
# @param data A data frame holding the data.
# @param model A character string, the model of the item.
# @param cat A character string, the category of the item.
# @returm A sorted character vector of distinct descriptions. 
descrp_choice <- function(data, model, cat){
    if(model == '')
        return('Please select a model then try again')
    df <- data
    choices <- df$descrp[df$model == model & df$category == cat]
    if(length(choices) == 0)
        return('None exists currently. Add a new description?')
    return(sort(unique(choices)))
}


# Extracts the distinct models in the given data provided by the given supplier(s), category, the type of transaction, and returns them sorted.
# @param data A data frame holding the data.
# @param supplier A character string, the name of the supplier.
# @param cat A character string, the category.
# @param type A character string, the type of transaction (sale, purchase, other).
# @returm A sorted character vector of distinct models. 
model_choice <- function(data, cat, supplier = 'All', type){
    if(type=='other'){
        if(supplier == '')
            return('Please select a supplier then try again')
        if(cat == '')
            return('Please select a category then try again')
        df <- data
        choices <- df$model[df$supplier == supplier & df$category == cat]
        if(length(choices) == 0)
            return('None exists currently. Add a new model?')
        return(sort(unique(choices)))
    }
    else{
        if(type %in% c('sale', 'purchase')){
            if(cat == '')
                return('Please select a subcategory then try again')
            df <- data
            if(supplier != 'All')
                df <- df[df$supplier == supplier, ]
            choices <- df$model[df$category == cat]
            if(length(choices) == 0)
                return('None exists currently. Add a new model?')
            return(sort(unique(choices)))
        }
        else
            return('None')
    }
}


# Extracts the distinct names of the categories in the given data provided by the given supplier(s), the type of transaction, and for sales and purchases, the given main category, and returns them sorted.
# @param data A data frame holding the data.
# @param supplier A character string, the name of the supplier.
# @param mcat A character string, the main category in cases where the transaction is either a sale or a purchase.
# @param type A character string, the type of transaction (sale, purchase, other).
# @returm A sorted character vector of distinct categories. 
cat_choice <- function(data, supplier = 'All', mcat, type){
    if(type == 'other'){
        if(supplier == '')
            return('Please select a supplier then try again')
        df <- data
        choices <- df$category[df$supplier_customer == supplier]
        if(length(choices) == 0)
            return('None exists currently. Add a new category?')
        return(sort(unique(choices)))
    }
    
    else{
        if(type %in% c('purchase', 'sale')){
            if(mcat == '')
                return('Please select a category then try again')
            df <- data
            if(supplier != 'All')
                df <- df[df$supplier == supplier, ]
            choices <- df$category[df$mcat == mcat]
            if(length(choices) == 0)
                return('None exists currently. Add a new subcategory?')
            return(sort(unique(choices)))
        }
        
        else
            return('None')
    }
}


# Extracts the distinct names of the main categories in the given data provided by the given supplier(s) and returns them sorted.
# @param data A data frame holding the data.
# @param supplier A character string, the name of the supplier.
# @returm A sorted character vector of distinct main categories.  
mcat_choice <- function(data, supplier = 'All'){
    if(supplier == '')
        return('Please select a supplier then try again')
    df <- data
    if(supplier != 'All')
        df <- df[df[ ,'supplier'] == supplier, ]
    choices <- df$mcat
    if(length(choices) == 0)
        return('None exists currently. Add a new category?')
    return(sort(unique(choices)))
}


# Extracts the distinct names of the suppliers in the given data and returns them sorted.
# @param data A data frame holding the data.
# @param colName A character string, the name of the column in the data for the supplier.
# @returm A sorted character vector of distinct supplier names.  
supplier_choice <- function(data, colName){
    c <- as.character(unique(data[, colName]))
    if(length(c)==0)
        return('None existed. Add a new supplier?')
    return(sort(c))
}