library(shiny)
library(tidyr)
library(dplyr)

library(EZRecords) # Package created by Samantha Lui

source('helpers.R') # Helper functions


shinyServer(function(input, output, session){ #start Server
    
    ## Reactive values shared across all sections
    ## Data from the existing databases; 
    ## changes along  will be reflected in the respective files.  
    rvs <- reactiveValues()
    rvs$curData <- readRDS("current.Rds")
    rvs$curOData <- readRDS("other_current.Rds")
    rvs$logs_other <- readRDS("other_logs_current.Rds")
    rvs$logs_product <- readRDS("product_logs_current.Rds")
    
    ## A combination of the log for the products and the log for the others
    ## Reactive to rvs$logs_product and rvs$logs_other
    journal_combined <- reactive(join(rvs$logs_product, rvs$logs_other))

        
    
    ### start J:Sale ###
    ## Reactive values shared across the Journal entry for Sale section
    rvs$items_js <- new('all_items') # Stores items which have been added until the transaction is confirmed and added to the database.
    rvs$is_sampling_js <- TRUE # Checks whether an item is used in the production sampling
    rvs$err_js <- character(0) # Warnings for inputs during the item adding process
    rvs$err2_js <- character(0) # Warnings for inputs after the list of added items is confirmed
    
    inv <- readRDS("invoice_object.Rds") # The unique invoice object for a particular user
    
    observeEvent(input$add_js, {
        ## Check for validity of inputs during the item adding process
        ## Error message(s) will be generated and displayed on the app if there is an error;
        ## the item is added to the list other
        rvs$err_js <- character(0)
        tests <- c(is_int(quant_js(), 'quantity', checkMin = TRUE, min = 1),
                   is_string(category_js(), 'category'),
                   is_string(descrp_js(), 'description'),
                   is_string(model_js(), 'model'),
                   is_nonneg(price_js(), 'price'),
                   is_discount(discount_js()),
                   not_sams(sample_js(), sampling_js()))
        validity_test <- check_validity(tests)
        if(validity_test != 'Pass'){
            rvs$err_js <- validity_test
        }
        else{
            newItem = new('single_item',
                          category=category_js(), 
                          descrp=descrp_js(), 
                          model=model_js(), 
                          quant=quant_js(),
                          price=price_js(),
                          discount=discount_js(),
                          sample=sample_js(),
                          sampling=sampling_js())
            newItem@amount <- amount(newItem)
            rvs$items_js <- add(rvs$items_js, newItem)
            rvs$subtotal_js <- amount(rvs$items_js)
            reset_all(c('category_js','model_js','descrp_js','quant_js','price_js','discount_js')) # Reset values of the fields in the app
            rvs$is_sampling_js <- rvs$is_sampling_js & (sampling_js()=='Yes')
            }
        }
    )
    
    ## Removes the most recently added item on the list
    observeEvent(input$undo_js, {
        rvs$items_js <- remove_last(rvs$items_js)
        rvs$subtotal_js <- amount(rvs$items_js)
        }
    )
    
    ## Confirmed by the user,
    ## adds the transaction record of the sale to the database
    ## and generates a unique invoice number for the transaction
    observeEvent(input$finish_js, {
        rvs$err2_js <- character(0)
        tests <- c(is_nonneg(tax_js(), 'tax'),
                   is_nonneg(shipment_js(), 'shipment'))
        validity_test <- check_validity(tests)
        if(validity_test != 'Pass'){
            rvs$err2_js <- validity_test
            }
        else{
            if(length(rvs$items_js@items)>0){
                transaction <- new('product_transac',
                                   date = date_js(),
                                   transac = 'credit',
                                   category = 'sale',
                                   descrp = rvs$items_js,
                                   supplier_customer = customer_js(),
                                   order_no = invoice(inv, rvs$is_sampling_js),
                                   value = rvs$subtotal_js,
                                   tax = tax_js(),
                                   shipment = shipment_js(),
                                   total = sum(rvs$subtotal_js, shipment_js(), tax_js()),
                                   time_stamp = Sys.time())
                rvs$logs_product <- add(rvs$logs_product, transaction)
                backup = paste('pl', Sys.Date(), 'Rds', sep='.')
                saveRDS(rvs$logs_product, file="product_logs_current.Rds")
                saveRDS(rvs$logs_product, file=backup) # The record is also saved in a backup file
                ## Resets everything for a fresh start in the next round
                rvs$items_js <- new('all_items')
                reset_all(c('date_js','supplier_js','order_js','sample_js','sampling_js','shipment_js', 'tax_js'))
                rvs$subtotal_js <- 0
                rvs$is_sampling_js <- FALSE
                }
            }
        }
    )
    
    ## Retrieves the relevant information of the item with the given supplier(s) and model number
    revSearch_js <- reactive({input$revSearch_js})
    output$revTable_js <- renderTable(reverse_lookup(rvs$curData, 'all', revSearch_js()))
    
    date_js <- reactive({input$date_js})
    
    customer_js <- reactive({input$customer_js})
    
    ## Provides options for the main category selection
    observe({
        updateSelectizeInput(session, 'mcat_js', 
                             choices = mcat_choice(rvs$curData))
        }
    )
    mcat_js <- reactive({input$mcat_js})
    
    ## Provides options for the secondary category selection based on the main category selected
    observe({
        updateSelectizeInput(session, 'category_js', 
                             choices = cat_choice(data=rvs$curData, mcat=mcat_js(), type='sale'))
        }
    )
    category_js <- reactive({input$category_js})
    
    ## Provides options for the model selection based on the main category and secondary category selected
    observe({
        updateSelectizeInput(session, 'model_js', 
                             choices = model_choice(data=rvs$curData, cat=category_js(), type='sale'))
        }
    )
    model_js <- reactive({input$model_js})
    
    ## Provides options for the description selection based on the main categorym secondary category, and model selected
    observe({
        updateSelectizeInput(session, 'descrp_js', 
                             choices = descrp_choice(rvs$curData, model=model_js(), cat=category_js()))
        }
    )
    descrp_js <- reactive({input$descrp_js})
    
    quant_js <- reactive({input$quant_js})
    
    price_js <- reactive({input$price_js})
    
    discount_js <- reactive({input$discount_js})
    
    ## Calculation of the amount of a particular item on the fly
    output$amount_js <- renderText({amount_l(quant_js(), price_js(), discount_js())})
    
    sample_js <- reactive({input$sample_js})
    
    sampling_js <- reactive({input$sampling_js})
    
    rvs$subtotal_js <- 0
    output$sTotal_js <- renderText(rvs$subtotal_js)
    
    shipment_js <- reactive({input$shipment_js})
    
    tax_js <- reactive({input$tax_js})
    
    ## Displays the list of items added
    output$tempTable_js <- renderTable(display(rvs$items_js))
    
    ## Calculation of the grand total of the transaction on the fly
    output$total_js <- renderText(sum(rvs$subtotal_js, shipment_js(), tax_js()))
    
    output$error_js <- renderText(rvs$err_js) # Shows warnings about inputs for a single item to be added 
    output$error2_js <- renderText(rvs$err2_js) # Show warnings about inputs after all items have been added
    ### end J:Sale ###

    
    
    ### start J:Purchase ###
    rvs$items_jp <- new('all_items')
    rvs$purchase_jp <- data.frame()
    rvs$err_jp <- character(0)
    rvs$err2_jp <- character(0)
    rvs$err3_jp <- character(0)
    rvs$duptab_jp <- data.frame()
    
    observe({
        don <- show_duplicate(rvs$logs_product, date=as.character(date_jp()), orn=order_jp(), sup=supplier_jp())
        rvs$err3_jp <- don[[1]]
        rvs$duptab_jp <- don[[2]]
        }
    )
    
    observeEvent(input$add_jp, {
        rvs$err_jp <- character(0)
        tests <- c(is_int(quant_jp(), 'quantity', checkMin = TRUE, min = 1),
                   is_string(supplier_jp(), 'supplier'),
                   is_string(order_jp(), 'order_no'),
                   is_string(category_jp(), 'category'),
                   is_string(descrp_jp(), 'description'),
                   is_string(model_jp(), 'model'),
                   is_nonneg(price_jp(), 'price'))
        validity_test <- check_validity(tests)
        if(validity_test != 'Pass'){
            rvs$err_jp <- validity_test
        }
        else{
            newItem = new('single_item',
                      category=category_jp(), 
                      descrp=descrp_jp(), 
                      model=model_jp(), 
                      quant=quant_jp(),
                      price=price_jp(),
                      discount=discount_jp(),
                      sample='No',
                      sampling='No')
            newItem@amount <- amount(newItem)
            rvs$items_jp <- add(rvs$items_jp, newItem)
            rvs$subtotal_jp <- amount(rvs$items_jp)
            reset_all(c('category_jp','model_jp','descrp_jp','quant_jp','price_jp','discount_jp'))
            df <- data.frame(supplier=supplier_jp(), 
                            model=model_jp(),  
                            mcat=mcat_jp(),            
                            category=category_jp(),
                            descrp=descrp_jp(),
                            stringsAsFactors = FALSE)
            rvs$purchase_jp <-rbind(df, rvs$purchase_jp, stringsAsFactors = FALSE)
            }
        }
    )
    
    observeEvent(input$undo_jp, {
        rvs$items_jp <- remove_last(rvs$items_jp)
        rvs$subtotal_jp <- amount(rvs$items_jp)
        rvs$purchase_jp <- rvs$purchase_jp[-1, ]
        }
    )
    
    observeEvent(input$finish_jp, {
        rvs$err2_jp <- character(0)
        tests <- c(is_nonneg(tax_jp(), 'tax'),
                   is_nonneg(shipment_jp(), 'shipment'))
        validity_test <- check_validity(tests)
        if(validity_test != 'Pass'){
            rvs$err2_jp <- validity_test
        }
        else{
            if(length(rvs$items_jp@items)>0){
                transaction <- new('product_transac',
                                   date = date_jp(),
                                   transac = 'debit',
                                   category = 'purchase',
                                   descrp = rvs$items_jp,
                                   supplier_customer = supplier_jp(),
                                   order_no = order_jp(),
                                   value = rvs$subtotal_jp,
                                   tax = tax_jp(),
                                   shipment = shipment_jp(),
                                   total = sum(rvs$subtotal_jp, shipment_jp(), tax_jp()),
                                   time_stamp = Sys.time())
                rvs$logs_product <- add(rvs$logs_product, transaction)
                backup = paste('pl', Sys.Date(), 'Rds', sep='.')
                saveRDS(rvs$logs_product, file="product_logs_current.Rds")
                saveRDS(rvs$logs_product, file=backup)
                rvs$items_jp <- new('all_items')
                reset_all(c('date_jp','supplier_jp','order_jp', 'shipment_jp', 'tax_jp'))
                rvs$subtotal_jp <- 0
                rvs$curData <- update_basic_struct(data=rvs$curData, purchase=rvs$purchase_jp, "current.Rds")
                rvs$purchase_jp <- data.frame()
                }
            }
        }
    )
    
    revSearch_jp <- reactive({input$revSearch_jp})
    output$revTable_jp <- renderTable(reverse_lookup(data=rvs$curData, supplier=supplier_jp(), model=revSearch_jp()))
    
    date_jp <- reactive({input$date_jp})
    
    observe({
        updateSelectizeInput(session, 'supplier_jp', 
                             choices = supplier_choice(rvs$curData, 'supplier'))
        }
    )
    supplier_jp <- reactive({input$supplier_jp})
    
    order_jp <- reactive({input$order_jp})
    
    observe({
        updateSelectizeInput(session, 'mcat_jp', 
                             choices = mcat_choice(rvs$curData, supplier_jp()))
        }
    )
    mcat_jp <- reactive({input$mcat_jp})
    
    observe({
        updateSelectizeInput(session, 'category_jp', 
                             choices = cat_choice(data=rvs$curData, supplier=supplier_jp(), mcat=mcat_jp(), type='purchase'))
        }
    )
    category_jp <- reactive({input$category_jp})
    
    observe({
        updateSelectizeInput(session, 'model_jp', 
                             choices = model_choice(data=rvs$curData, cat=category_jp(), supplier=supplier_jp(), type='purchase'))
        }
    )
    model_jp <- reactive({input$model_jp})
    
    observe({
        updateSelectizeInput(session, 'descrp_jp', 
                             choices = descrp_choice(data=rvs$curData, model=model_jp(), cat=category_jp()))
        }
    )
    descrp_jp <- reactive({input$descrp_jp})
    
    quant_jp <- reactive({input$quant_jp})
    
    price_jp <- reactive({input$price_jp})
    
    discount_jp <- reactive({input$discount_jp})
    
    output$amount_jp <- renderText({amount_l(quant_jp(), price_jp(), discount_jp())})
    
    rvs$subtotal_jp <- 0
    output$sTotal_jp <- renderText(rvs$subtotal_jp)
    
    shipment_jp <- reactive({input$shipment_jp})
    
    tax_jp <- reactive({input$tax_jp})
    
    output$tempTable_jp <- renderTable(display(rvs$items_jp))
    
    output$total_jp <- renderText(sum(rvs$subtotal_jp, shipment_jp(), tax_jp()))
    
    output$error_jp <- renderText(rvs$err_jp)
    output$error2_jp <- renderText(rvs$err2_jp)
    output$error3_jp <- renderText(rvs$err3_jp)
    output$dup_table_jp <- renderDataTable(rvs$duptab_jp)
    ### end J:Purchase ###
    
    
    
    ### start J:Other ###
    rvs$items_jo <- new('all_items')
    rvs$purchase_jo <- data.frame()
    rvs$err_jo <- character(0)
    rvs$err2_jo <- character(0)
    rvs$err3_jo <- character(0)
    rvs$duptab_jo <- data.frame()
    
    observe({
        don <- show_duplicate(rvs$logs_other, date=as.character(date_jo()), orn=order_jo(), sup=supplier_jo())
        rvs$err3_jo <- don[[1]]
        rvs$duptab_jo <- don[[2]]
        }
    )
    
    observeEvent(input$add_jo, {
        rvs$err_jo <- character(0)
        tests <- c(is_int(quant_jo(), 'quantity', checkMin = TRUE, min = 1),
                   is_string(supplier_jo(), 'supplier'),
                   is_string(category_jo(), 'category'),
                   is_string(descrp_jo(), 'description'),
                   is_string(model_jo(), 'model'),
                   is_nonneg(price_jo(), 'price'))
        validity_test <- check_validity(tests)
        if(validity_test != 'Pass'){
            rvs$err_jo <- validity_test
        }
       else{ 
        newItem = new('single_item',
                      category= category_jo(), 
                      descrp=descrp_jo(), 
                      model=model_jo(), 
                      quant=quant_jo(),
                      price=price_jo(),
                      discount='None',
                      sample='No',
                      sampling='No')
        newItem@amount <- amount(newItem)
        rvs$items_jo <- add(rvs$items_jo, newItem)
        rvs$subtotal_jo <- amount(rvs$items_jo)
        reset_all(c('category_jo','model_jo','descrp_jo','quant_jo','price_jo'))
        df <- data.frame(supplier_customer=supplier_jo(), 
                         model=model_jo(),  
                         category=category_jo(),
                         stringsAsFactors = FALSE)
        rvs$purchase_jo <-rbind(df, rvs$purchase_jo, stringsAsFactors = FALSE)}
        }
    )
    
    observeEvent(input$undo_jo, {
        rvs$items_jo <- remove_last(rvs$items_jo)
        rvs$subtotal_jo <- amount(rvs$items_jo)
        rvs$purchase_jo <- rvs$purchase_jo[-1, ]
        }
    )
    
    observeEvent(input$finish_jo, {
        rvs$err2_jo <- character(0)
        tests <- c(is_nonneg(tax_jo(), 'tax'),
                   is_nonneg(shipment_jo(), 'shipment'))
        validity_test <- check_validity(tests)
        if(validity_test != 'Pass'){
            rvs$err2_jo <- validity_test
        }
        else{
            if(length(rvs$items_jo@items)>0){
                transaction <- new('product_transac',
                                   date = date_jo(),
                                   transac = 'debit',
                                   category = 'other',
                                   descrp = rvs$items_jo,
                                   supplier_customer = supplier_jo(),
                                   order_no = order_jo(),
                                   value = rvs$subtotal_jo,
                                   tax = tax_jo(),
                                   shipment = shipment_jo(),
                                   total = sum(rvs$subtotal_jo, shipment_jo(), tax_jo()),
                                   time_stamp = Sys.time())
                rvs$logs_other <- add(rvs$logs_other, transaction)
                backup = paste('ol', Sys.Date(), 'Rds', sep='.')
                saveRDS(rvs$logs_other, file="other_logs_current.Rds")
                saveRDS(rvs$logs_other, file=backup)
                rvs$items_jo <- new('all_items')
                reset_all(c('date_jo','category_jo', 'supplier_jo','order_jo', 'shipment_jo', 'tax_jo'))
                rvs$subtotal_jo <- 0
                rvs$curOData <- update_basic_struct(data=rvs$curOData, purchase=rvs$purchase_jo, "other_current.Rds")
                rvs$purchase_jo <- data.frame()
                }
            }
        }
    )
    
    date_jo <- reactive({input$date_jo})
    
    observe({
        updateSelectizeInput(session, 'supplier_jo', 
                             choices = supplier_choice(rvs$curOData, 'supplier_customer'))
        }
    )
    supplier_jo <- reactive({input$supplier_jo})
    
    observe({
        updateSelectizeInput(session, 'category_jo', 
                             choices = cat_choice(data=rvs$curOData, supplier=supplier_jo(), mcat='', type='other'))
        }
    )
    category_jo <- reactive({input$category_jo})
    
    order_jo <- reactive({input$order_jo})
    
    observe({
        updateSelectizeInput(session, 'model_jo', 
                             choices = model_choice(data=rvs$curOData, cat=category_jo(), supplier=supplier_jo(), type='other'))
        }
    )
    model_jo <- reactive({input$model_jo})
    
    descrp_jo <- reactive({input$descrp_jo})
    
    quant_jo <- reactive({input$quant_jo})
    
    price_jo <- reactive({input$price_jo})
    
    output$amount_jo <- renderText({amount_l(quant_jo(), price_jo(), 'None')})
    
    rvs$subtotal_jo <- 0
    output$sTotal_jo <- renderText(rvs$subtotal_jo)
    
    shipment_jo <- reactive({input$shipment_jo})
    
    tax_jo <- reactive({input$tax_jo})
    
    output$tempTable_jo <- renderTable(display(rvs$items_jo))
    
    output$total_jo <- renderText(sum(rvs$subtotal_jo, shipment_jo(), tax_jo()))
    
    output$error_jo <- renderText(rvs$err_jo)
    output$error2_jo <- renderText(rvs$err2_jo)
    output$error3_jo <- renderText(rvs$err3_jo)
    output$dup_table_jo <- renderDataTable(rvs$duptab_jo)
    ### end J:Other ###

    
    
    ### start J: Upload ###
    rvs$err_ju <- character(0)
    # A warning message will be issued if there is the file cannot be opened, is
    # in a wrong format, or does not have the correct columns.
    upload_ju <- reactive({validate(validate_upload(successful_upload(input$upload_ju)))
        input$upload_ju})
    # Content of the uploaded file
    upload_table_ju <- reactive({upload_table(upload_ju())})
    # Shows first 6 rows of the file for user to confirm
    output$tempTable_ju <- renderDataTable(head(upload_table_ju()))
    # Option to either append the data to the existing data or overwrite
    append_ju <- reactive({input$append_ju})
    # Processes content of the uploaded file upon user's confirmation
    observeEvent(input$finish_ju, {
        rvs$results_ju <- process_upload_data(data = upload_table_ju(),
                                           append = append_ju(),
                                           # ex_* are updated data to be returned for current session 
                                           ex_prod_skel = rvs$curData,
                                           ex_prod_log = rvs$logs_product,
                                           ex_other_skel = rvs$curOData,
                                           ex_other_log = rvs$logs_other,
                                           # Updated data are written in the *_fname files respectively
                                           xps_fname = "current.Rds",
                                           xpl_fname = "product_logs_current.Rds",
                                           xos_fname = "other_current.Rds",
                                           xol_fname = "other_logs_current.Rds")
        # Updates data for current session
        rvs$curData <- rvs$results_ju[[1]]
        rvs$logs_product <- rvs$results_ju[[2]]
        rvs$curOData <- rvs$results_ju[[3]]
        rvs$logs_other <- rvs$results_ju[[4]]
        # A warning/error message is issued if there is problem with the process
        # or else a notification of the successful process 
        rvs$err_ju <- rvs$results_ju[[5]]
        reset_all('append_ju')
        }
    )
    # Displays warning/error message if there is one
    output$err_ju <- renderText(rvs$err_ju)
    ### end J: Upload ###
    
    
    
    ### start V:Journal ###
    # Obtains a data frame for the combination of the product log and log for other transactions
    pjc <- reactive(print(journal_combined()))
    
    dates_vj <- reactive({input$dates_vj})
    
    observe({
        updateSelectizeInput(session, 'category_vj',
                             choices = c('All', view_category(pjc(), dates_vj())),
                             selected = 'All')
        }
    )
    category_vj <- reactive({input$category_vj})
    
    observe({
        updateSelectizeInput(session, 'supplier_vj',
                             choices = c('All', view_supplier_customer(pjc(), category_vj(),dates_vj())),
                             selected = 'All')
        }
    )
    supplier_vj <- reactive({input$supplier_vj})

    also_show_vj <- reactive({input$also_show_vj})

    output$select_order_vj <- renderUI({selectInput('select_order_vj', 'Order Columns by',
                                                    choices = c('date', 'transac', 'category', 'descrp', 'supplier_customer', 'value', 'total', 
                                                                also_show_vj()),
                                                    multiple = TRUE,
                                                    selected = c('date', 'transac', 'category', 'descrp', 'supplier_customer', 'value', 'total'),
                                                    width = '80%')})
    select_order_vj <- reactive({input$select_order_vj})

    view_table_vj <- reactive(showViewTable(pjc(), 
                                            dates_vj(), category_vj(), supplier_vj(),
                                            c(select_order_vj(),
                                              setdiff(also_show_vj(), select_order_vj()))))

    output$tempTable_vj <- renderDataTable(view_table_vj())

    output$download_vj <- downloadHandler(
        filename = function() {
            file_name('Journal_Entries ', dates_vj())
        },
        content = function(file) {
            write.csv(view_table_vj(),
                      file,
                      row.names = FALSE)
        }
    )
    ### end V:Journal ###

    
    
    ### start V:Incomes/Spendings ###
    info_jc <- reactive(show_all_items_info(journal_combined()))
    
    dates_vis <- reactive({input$dates_vis})
    
    observe({
        updateSelectizeInput(session, 'category_vis',
                             choices = c('All', view_category(info_jc(), dates_vis())),
                             selected = 'All')
        }
    )
    category_vis <- reactive({input$category_vis})
    
    observe({
        updateSelectizeInput(session, 'model_vis',
                             choices = c('All', view_model(info_jc(), category_vis(), dates_vis())),
                             selected = 'All')
        }
    )
    model_vis <- reactive({input$model_vis})
    
    summaries <- reactive({incomes_spendings_summaries(info_jc(), dates_vis(), category_vis(), model_vis())})
    output$ex1_vis <- renderDataTable(summaries()[[1]][1,])
    output$ex2_vis <- renderDataTable(summaries()[[2]][1,])
    output$ex3_vis <- renderDataTable(summaries()[[3]][1,])
    summary_type_vis <- reactive({input$summary_type_vis})
    
    output$tempTable_vis <- renderDataTable(summaries()[[as.numeric(summary_type_vis())]])
    
    output$download_vis <- downloadHandler(
        filename = function() {
            summary_file_name(summary_type_vis(), dates_vis())
        },
        content = function(file) {
            write.csv(summaries()[[as.numeric(summary_type_vis())]],
                      file,
                      row.names = FALSE)
        }
    )
    ### end V:Incomes/Spendings ###
    



    ### V:Stock ###
    pl <- reactive(rvs$logs_product)
    
    dates_vs <- reactive(input$dates_vs)
    
    observe({
        updateSelectizeInput(session, 'category_vs',
                             choices = category_stock(pl(), dates_vs()),
                             selected = 'All')
        }
    )
    category_vs <- reactive(input$category_vs)

    stock_table_vs <- reactive(stockTable_stock(pl(), dates_vs(), category_vs()))

    output$stock_vs <- renderDataTable(stock_table_vs()[[2]])
    
    output$logs_vs <- renderDataTable(stock_table_vs()[[1]])
    
    output$download_vs <- downloadHandler(
        filename = function() {
            file_name('Stock Status ', dates_vs())
        },
        content = function(file) {
            write.csv(stock_table_vs()[[2]],
                      file,
                      row.names = FALSE)
        }
    )
    
    output$download_breakdown_vs <- downloadHandler(
        filename = function() {
            file_name('Stock Status Breakdown ', dates_vs())
        },
        content = function(file) {
            write.csv(stock_table_vs()[[1]],
                      file,
                      row.names = FALSE)
        }
    )
    ### end V:Stock ###

}
)#end Server