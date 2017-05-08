require(shinyjs)

ui = tagList(useShinyjs(),
             navbarPage("EZRecords",
                        tabPanel("Journal Entry",
                                 tabsetPanel(type = "tabs",
                                             ## start J:Sale
                                             tabPanel("Sale",
                                                      fluidPage(
                                                          h3('JOURNAL: SALE'),
                                                          hr(),
                                                          h4('Order Description'),
                                                          column(12,dateInput('date_js', label = 'Date', value = Sys.Date())),
                                                          column(12, 
                                                                 fluidRow(
                                                                     column(3,
                                                                            selectizeInput('customer_js',
                                                                                           'Customer',choices = c('Etsy', 'Amazon'),
                                                                                           options = list(create = TRUE)))
                                                                 )
                                                          ),
                                                          br(),
                                                          h4('Item Description'),
                                                          hr(),
                                                          column(12,
                                                                 fluidRow(
                                                                     column(3, 
                                                                            textInput('revSearch_js', 'Reverse Lookup: Enter the model Number', 
                                                                                      value = "", width = '100%', placeholder = TRUE)),
                                                                     column(9, tableOutput('revTable_js'))
                                                                 )),
                                                          column(12,
                                                                 fluidRow(
                                                                     column(3,
                                                                            selectizeInput('mcat_js', 
                                                                                           'Category',choices = sort('Amazon'),
                                                                                           options = list(create = TRUE))),
                                                                     column(3,
                                                                            selectizeInput('category_js', 'Subcategory',
                                                                                           choices = sort('a'),
                                                                                           options = list(create = TRUE))),
                                                                     column(3,
                                                                            selectizeInput('model_js', 'Model',
                                                                                           choices = sort('a'),
                                                                                           options = list(create = TRUE)))
                                                                 )
                                                          ),
                                                          column(12,
                                                                 selectizeInput('descrp_js', 'Description',
                                                                                choices = sort('a'),
                                                                                options = list(create = TRUE),
                                                                                width = '100%')),
                                                          column(12,
                                                                 fluidRow(
                                                                     column(2, numericInput("quant_js", 
                                                                                            label = "Quantity", value = 1, min = 1)),
                                                                     column(2, numericInput("price_js", label = "Unit Price", value = 0, min = 0)),
                                                                     column(2, 
                                                                            selectizeInput('discount_js', 'Discount',
                                                                                           choices = c('None','5%', '10%', '15%', '20%', '25%',
                                                                                                       '30%', '35%', '40%', '45%', '50%', '100%'),
                                                                                           options = list(create = TRUE))),
                                                                     column(2, offset = 1,
                                                                            tags$b("Amount"),
                                                                            verbatimTextOutput("amount_js", placeholder = TRUE)
                                                                     )
                                                                 )
                                                          ),
                                                          column(12,
                                                                 fluidRow(
                                                                     column(2, 
                                                                            selectInput('sample_js', 
                                                                                        "Sample for Customer",
                                                                                        c('No', 'Yes'))),
                                                                     column(2, selectInput('sampling_js',
                                                                                           "Production Sampling",
                                                                                           c('No', 'Yes'))))
                                                          ),
                                                          column(12, 
                                                                 br(),
                                                                 htmlOutput("error_js")),
                                                          column(12,
                                                                 fluidRow(
                                                                     br(),
                                                                     column(1, actionButton("add_js", label = "Add")),
                                                                     column(1, actionButton("undo_js", label = "Undo"))
                                                                 )
                                                          ),
                                                          column(12,
                                                                 br(),
                                                                 hr(),
                                                                 tableOutput('tempTable_js'),
                                                                 hr()
                                                          ),
                                                          column(2,
                                                                 tags$b("Subtotal"),
                                                                 verbatimTextOutput("sTotal_js", placeholder = TRUE)
                                                          ),
                                                          column(12,
                                                                 fluidRow(
                                                                     column(2, numericInput("shipment_js", 
                                                                                            label = "Shipping & Handling", 
                                                                                            value = 0, min = 0))
                                                                 )
                                                          ),
                                                          column(12, numericInput("tax_js", label = "Tax", value = 0, min = 0)),
                                                          column(12, 
                                                                 br(),
                                                                 htmlOutput("error2_js")),
                                                          column(2,
                                                                 tags$b("Total"),
                                                                 verbatimTextOutput("total_js", placeholder = TRUE)),
                                                          column(12,
                                                                 br(),
                                                                 h4('The purchase listed above will be added to the database, and the system will start over.',
                                                                    style = "color:blue"),
                                                                 br(),
                                                                 h4('Click the button below to confirm.', style = "color:blue"),
                                                                 br(),
                                                                 actionButton("finish_js", label = "Confirm Purchase List"))
                                                      )
                                             ),
                                             ## end J:Sale
                                             
                                             
                                             ## start J:Purchase
                                             tabPanel("Purchase", 
                                                      fluidPage(
                                                          h3('JOURNAL: PURCHASE'),
                                                          hr(),
                                                          h4('Order Description'),
                                                          column(12,dateInput('date_jp', label = 'Date', value = Sys.Date())),
                                                          column(12,
                                                                 fluidRow(
                                                                     column(3,
                                                                            selectizeInput('supplier_jp', 
                                                                                           'Supplier',
                                                                                           choices = sort('Amazon'),
                                                                                           options = list(create = TRUE))),
                                                                     column(9, textInput('order_jp', "Order Number", width = '100%'))
                                                                 ),
                                                                 br()
                                                          ),
                                                          column(12, 
                                                                 br(),
                                                                 htmlOutput("error3_jp"),
                                                                 dataTableOutput('dup_table_jp')
                                                                 ),
                                                          h4('Item Description'),
                                                          hr(),
                                                          column(12,
                                                                 fluidRow(
                                                                     column(3, 
                                                                            textInput('revSearch_jp', 'Reverse Lookup: Enter the model Number', 
                                                                                      value = "", width = '100%', placeholder = TRUE)),
                                                                     column(9, tableOutput('revTable_jp'))
                                                                 )),
                                                          column(12,
                                                                 fluidRow(
                                                                     column(3,
                                                                            selectizeInput('mcat_jp', 
                                                                                           'Category',choices = sort('Amazon'),
                                                                                           options = list(create = TRUE))),
                                                                     column(3,
                                                                            selectizeInput('category_jp', 'Subcategory',
                                                                                           choices = sort('a'),
                                                                                           options = list(create = TRUE))),
                                                                     column(3,
                                                                            selectizeInput('model_jp', 'Model',
                                                                                           choices = sort('a'),
                                                                                           options = list(create = TRUE)))
                                                                 )),
                                                          column(12,
                                                                 selectizeInput('descrp_jp', 'Description',
                                                                                choices = sort('a'),
                                                                                options = list(create = TRUE),
                                                                                width = '100%')),
                                                          column(12,
                                                                 fluidRow(
                                                                     column(2, numericInput("quant_jp", label = "Quantity", value = 1, min = 1)),
                                                                     column(2, numericInput("price_jp", label = "Unit Price", value = 0, min = 0)),
                                                                     column(2, selectizeInput('discount_jp', 'Discount',
                                                                                              choices = c('None','5%', '10%', '15%', '20%', '25%',
                                                                                                          '30%', '35%', '40%', '45%', '50%'),
                                                                                              options = list(create = TRUE))),
                                                                     column(2, offset = 1,
                                                                            tags$b("Amount"),
                                                                            verbatimTextOutput("amount_jp", placeholder = TRUE)
                                                                     )
                                                                 )
                                                          ),
                                                          column(12, 
                                                                 br(),
                                                                 htmlOutput("error_jp")),
                                                          column(12,
                                                                 fluidRow(
                                                                     br(),
                                                                     column(1, actionButton("add_jp", label = "Add")),
                                                                     column(1, actionButton("undo_jp", label = "Undo"))
                                                                 )
                                                          ),
                                                          column(12,
                                                                 br(),
                                                                 hr(),
                                                                 tableOutput('tempTable_jp'),
                                                                 hr()
                                                          ),
                                                          column(2,
                                                                 tags$b("Subtotal"),
                                                                 verbatimTextOutput("sTotal_jp", placeholder = TRUE)
                                                          ),
                                                          column(12,
                                                                 fluidRow(
                                                                     column(2, numericInput("shipment_jp", 
                                                                                            label = "Shipping & Handling", 
                                                                                            value = 0, min = 0))
                                                                 ) 
                                                          ),
                                                          column(12, numericInput("tax_jp", label = "Tax", value = 0, min = 0)),
                                                          column(12, 
                                                                 br(),
                                                                 htmlOutput("error2_jp")),
                                                          column(2,
                                                                 tags$b("Total"),
                                                                 verbatimTextOutput("total_jp", placeholder = TRUE)),
                                                          column(12,
                                                                 br(),
                                                                 h4('The purchase listed above will be added to the database, and the system will start over.',
                                                                    style = "color:blue"),
                                                                 br(),
                                                                 h4('Click the button below to confirm.', style = "color:blue"),
                                                                 br(),
                                                                 actionButton("finish_jp", label = "Confirm Purchase List"))
                                                      )
                                             ),
                                             ## end J:Purchase
                                             
                                             
                                             ## start J:Other
                                             tabPanel("Other", 
                                                      fluidPage(
                                                          h3('JOURNAL: OTHER'),
                                                          hr(),
                                                          h4('Order Description'),
                                                          column(12,dateInput('date_jo', label = 'Date', value = Sys.Date())),
                                                          column(12,
                                                                 fluidRow(
                                                                     column(3,
                                                                            selectizeInput('supplier_jo', 
                                                                                           'Supplier',
                                                                                           choices = sort(c('Amazon', 'Adobe', 'Conde', 'PG&E', 'Ooma')),
                                                                                           options = list(create = TRUE))),
                                                                     column(9, textInput('order_jo', "Order Number", width = '100%'))
                                                                 ),
                                                                 br()
                                                          ),
                                                          br(),
                                                          column(12, 
                                                                 br(),
                                                                 htmlOutput("error3_jo")
                                                          ),
                                                          br(),
                                                          column(12, 
                                                                 br(),
                                                                 dataTableOutput('dup_table_jo')
                                                          ),
                                                          br(),
                                                          br(),
                                                          h4('Item Description'),
                                                          hr(),
                                                          column(12, selectizeInput('category_jo', 'Category',
                                                                                   choices = sort(c('machinery', 'utilities', 
                                                                                                    'consumables (useful up to 3 years)', 
                                                                                                    'durables (useful over 3 years)')),
                                                                                   options = list(create = TRUE))),
                                                          column(12, selectizeInput('model_jo', 'Subcategory',
                                                                                           choices = sort('a'),
                                                                                           options = list(create = TRUE))),
                                                          column(12, textInput('descrp_jo', 'Description',
                                                                                value = '',
                                                                                placeholder = TRUE,
                                                                                width = '100%')),
                                                          column(12,
                                                                 fluidRow(
                                                                     column(2, numericInput("quant_jo", label = "Quantity", value = 1, min = 1)),
                                                                     column(2, numericInput("price_jo", label = "Unit Price", value = 0, min = 0)),
                                                                     column(2, offset = 1,
                                                                            tags$b("Amount"),
                                                                            verbatimTextOutput("amount_jo", placeholder = TRUE)
                                                                     )
                                                                 )
                                                          ),
                                                          column(12, 
                                                                 br(),
                                                                 htmlOutput("error_jo")),
                                                          column(12,
                                                                 fluidRow(
                                                                     br(),
                                                                     column(1, actionButton("add_jo", label = "Add")),
                                                                     column(1, actionButton("undo_jo", label = "Undo"))
                                                                 )
                                                          ),
                                                          column(12,
                                                                 br(),
                                                                 hr(),
                                                                 tableOutput('tempTable_jo'),
                                                                 hr()
                                                          ),
                                                          column(2,
                                                                 tags$b("Subtotal"),
                                                                 verbatimTextOutput("sTotal_jo", placeholder = TRUE)
                                                          ),
                                                          column(12,
                                                                 fluidRow(
                                                                     column(2, numericInput("shipment_jo", 
                                                                                            label = "Shipping & Handling", 
                                                                                            value = 0, min = 0))
                                                                 ) 
                                                          ),
                                                          column(12, numericInput("tax_jo", label = "Tax", value = 0, min = 0)),
                                                          column(12, 
                                                                 br(),
                                                                 htmlOutput("error2_jo")),
                                                          column(2,
                                                                 tags$b("Total"),
                                                                 verbatimTextOutput("total_jo", placeholder = TRUE)),
                                                          column(12,
                                                                 br(),
                                                                 h4('The transaction listed above will be added to the database, and the system will start over.',
                                                                    style = "color:blue"),
                                                                 br(),
                                                                 h4('Click the button below to confirm.', style = "color:blue"),
                                                                 br(),
                                                                 actionButton("finish_jo", label = "Confirm Transaction"))
                                                      )
                                             ),
                                             ## end J:Other
                                             
                                             ## start L:Upload
                                             tabPanel("Upload from Computer",
                                                      fluidPage(
                                                          h3('JOURNAL: UPLOAD FROM COMPUTER'),
                                                          hr(),
                                                          h4('Choose .csv file to upload'),
                                                          #column(12, verbatimTextOutput('test')),
                                                          column(12,
                                                                 fileInput('upload_ju', '',
                                                                           accept=c('text/csv', 
                                                                                    'text/comma-separated-values,text/plain', 
                                                                                    '.csv'))),
                                                          column(12,
                                                                 h4('Upon successful upload, the following shows the first 6 rows of the uploaded file:'),
                                                                 br(),
                                                                 hr(),
                                                                 dataTableOutput('tempTable_ju'),
                                                                 hr()
                                                          ),
                                                          column(12,
                                                                 br(),
                                                                 h4('Append data to the existing database?'),
                                                                 radioButtons("append_ju", "",
                                                                              c('Add data to the existing database' = TRUE, 'Overwrite database' = FALSE), 
                                                                              selected = TRUE, inline = TRUE),
                                                                 br()
                                                          ),
                                                          # column(12, 
                                                          #        br(),
                                                          #        htmlOutput("err_ju")),
                                                          column(12,
                                                                 br(),
                                                                 h4('The data from the uploaded file will be added to the database by the selected method above (append/overwrite).',
                                                                    style = "color:blue"),
                                                                 br(),
                                                                 h4('Click the button below to confirm.', style = "color:blue"),
                                                                 br(),
                                                                 htmlOutput("err_ju"),
                                                                 br(),
                                                                 actionButton("finish_ju", label = "Confirm"))
                                                          
                                                          ))
                                             ## end J:Upload
                                 )
                        ),
                        
                        
                        
                        tabPanel("View", 
                                 tabsetPanel(type = "tabs", 
                                             ## start V:Journal
                                             tabPanel('Journal',
                                                      fluidPage(
                                                          h3('VIEW: JOURNAL'),
                                                          hr(),
                                                          column(12, dateRangeInput('dates_vj',
                                                                                    label = 'Date range input: yyyy-mm-dd',
                                                                                    start = "2016-01-01", end = Sys.Date())),
                                                          column(12,
                                                                 selectizeInput('category_vj', 'Category',
                                                                                choices = sort(c('stationary')),
                                                                                options = list(create = TRUE),
                                                                                multiple=TRUE)
                                                          ),
                                                          column(12,
                                                                 selectizeInput('supplier_vj', 'Supplier/Customer',
                                                                                choices = sort(c('a','b')),
                                                                                options = list(create = TRUE),
                                                                                multiple=TRUE)
                                                          ),
                                                          column(12,
                                                                 selectizeInput('also_show_vj', 'Also show Column:',
                                                                                choices=c('tax', 'shipment', 'order_no'),
                                                                                selected = NULL, multiple = TRUE)),
                                                          br(),
                                                          br(),
                                                          column(12, uiOutput('select_order_vj')),
                                                          column(12,
                                                                 br(),
                                                                 hr(),
                                                                 dataTableOutput('tempTable_vj'),
                                                                 hr()
                                                          ),
                                                          column(12,
                                                                 h5('Download the selected journal entries in .csv file'),
                                                                 downloadButton('download_vj', label = "Download Journal Entries"),
                                                                 br(),
                                                                 br())
                                                      )
                                             ),
                                             
                                             ## start V:Incomes/Spendings
                                             tabPanel('Incomes/Spendings',
                                                      fluidPage(
                                                          h3('VIEW: INCOMES/SPENDINGS'),
                                                          hr(),
                                                          column(12, dateRangeInput('dates_vis',
                                                                                    label = 'Date range input: yyyy-mm-dd',
                                                                                    start = "2016-01-01", end = Sys.Date())),
                                                          column(12,
                                                                 selectizeInput('category_vis', 'Category',
                                                                                choices = sort(c('stationary')),
                                                                                options = list(create = TRUE),
                                                                                multiple=TRUE)
                                                          ),
                                                          column(12,
                                                                 selectizeInput('model_vis', 'Model',
                                                                                choices = sort(c('a','b')),
                                                                                options = list(create = TRUE),
                                                                                multiple=TRUE)
                                                          ),
                                                          br(),
                                                          column(12,
                                                          br(),
                                                          h4('See following for types of summary available:')),
                                                          column(12,
                                                                 hr(),
                                                                 tags$b("Example 1: Summary by main category"),
                                                                 dataTableOutput('ex1_vis')
                                                          ),
                                                          column(12,
                                                                 br(),
                                                                 tags$b("Example 2: Summary by main and secondary category"),
                                                                 dataTableOutput('ex2_vis')
                                                          ),
                                                          column(12,
                                                                 br(),
                                                                 tags$b("Example 3: Breakdown of all items"),
                                                                 dataTableOutput('ex3_vis'),
                                                                 br()
                                                          ),
                                                          column(12,
                                                                 br(),
                                                                 radioButtons("summary_type_vis", "Select type of summary:",
                                                                              c('1' = '1', '2' = '2', '3' = '3'), 
                                                                              selected = 1, inline = TRUE),
                                                                 br()
                                                          ),
                                                          column(12,
                                                                 br(),
                                                                 hr(),
                                                                 dataTableOutput('tempTable_vis'),
                                                                 hr()
                                                          ),
                                                          column(12,
                                                                 h5('Download the selected incomes/spendings summary in .csv file'),
                                                                 downloadButton('download_vis', label = "Download Summary File"),
                                                                 br(),
                                                                 br())
                                                      )
                                             ),
                                             
                                             ## start V:Stock
                                             tabPanel('Stock',
                                                      fluidPage(
                                                          h3('VIEW: STOCK'),
                                                          hr(),
                                                          column(12,
                                                                 fluidRow(
                                                                     column(4, dateRangeInput('dates_vs',
                                                                                              label = 'Date range input: yyyy-mm-dd',
                                                                                              start = "2016-01-01", end = Sys.Date())),
                                                                     column(6, selectizeInput('category_vs',
                                                                                              'Category',
                                                                                              choices = c('1','b'),
                                                                                              width = '80%',
                                                                                              multiple = TRUE))
                                                                     
                                                                 ),
                                                                 br(),
                                                                 hr()),
                                                          h4('Stock of the selected items'),
                                                          column(12, dataTableOutput('stock_vs'), br()),
                                                          column(12,
                                                                 downloadButton('download_vs', label = "Download Stock Status"),
                                                                 br(),
                                                                 hr()),
                                                          h4('Breakdown of the stock status below'),
                                                          column(12, dataTableOutput('logs_vs'), br()),
                                                          column(12,
                                                                 downloadButton('download_breakdown_vs', label = "Download Stock Status Breakdown"),
                                                                 br(),
                                                                 br())
                                                      )
                                             )
                                             
                                             
                                 )
                        )
                        
                        
             ) # end navbarPage 1
) # end ui
