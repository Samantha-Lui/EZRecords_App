# **EZRecords App**



## Overview

EZRecords App is an application designed for retail/reselling business for bookkeeping and management of stock. Upon 
data entry of a transaction (sale, purchase of the materials, other expenses, etc), the status of stock 
is updated, and the record of the transaction will be ready to view or use for future calculations and analyses.

This application was built on R(3.3.2) and required public-licensed packages [*shiny*](https://cran.r-project.org/web/packages/shiny/index.html), [*shinyjs*](https://cran.r-project.org/web/packages/shinyjs/index.html), [*dplyr*](https://cran.r-project.org/web/packages/dplyr/index.html), and [*tidyr*](https://cran.r-project.org/web/packages/tidyr/index.html) 
and private package [*EZRecords*](https://github.com/Samantha-Lui/EZRecords).



## Installation

Please visit https://samantheluidatascience.shinyapps.io/EZRecords_App_Demo/ for demonstration.



## Getting started
1. Create the unique pattern for the invoice numbers. Go to Control Panel > Invoice, then follow the instruction to create the invoice log and pattern for the invoice number.

2. Prepare clean slates for upcoming data. Go to Control Panel > Reset to Default, select all files and confirm for the selection.

*(The functions in the Control Panel are disabled in the demonstration. A unique pattern for the invoice numbers, the invoice log file, and some sample data for the various structural and log files have already been created for the demonstration purposes.)*


## Functionality
* Journal : Enter the data either by traditional data entry for the transaction at the respective panel or upload the data from the computer. 
    + Sale : A sale of goods to the customer 
    + Purchase : A purchase of goods from the manufacturer or distributor
    + Other : Any transaction other than a sale or a purchase as defined above \*\*
    fdytw
    + Upload from computer : A _comma_separated_value_ file (.csv) consisting of the following columns. Each row of the file represents an item in a transaction.
        + transac: The type of the transaction (\'sale\' for sale of the item, \'purchase\' for the purchase of a production material, and \'other\' for any         + type of transaction other than sale and purchase).*
        + date: The date of the transaction with format YYYY-MM-DD, MM/DD/YYYY, or MM/DD/YY.*
        + supplier_customer: The name of the supplier of the item or the customer purchasing the item.*
        + order_no: The order number of the transaction. Leave blank if not applicable.*
        + tax: The total amount of tax paid  in the transaction.*
        + shipment: The total amount of paid for shipment and handling in the transaction.*
        + mcat: The generic category in which the item belongs. Leave blank if not applicable.
        + category: Ther category in which the item belongs.
        + model: Model number of the item.
        + descrp: Description of the item.
        + quant: Quantity of the item involved in the transaction.
        + price: Unit price of the item. Enter original price if the transaction is a sale and the actual price for all others.
        + discount: Discount on the item,  either in the format \'x%\' or \'None\' for a sale and \'None\' for all others.
        + sample: Whether the item is a sample (\'Yes\', \'No\').
        + sampling: Whether the item is a sampling item used in the production(\'Yes\', \'No\'). This should be \'No\' for all transactions besides sale.

            \* Repeats in all items involved in the same transaction.
        
        *(An example of the upload file, upload.csv, is included in this repo. The viewer is invited to [download](https://www.google.com/search?q=how+to+download+a+file+from+github&oq=how+to+download+a+file+f&aqs=chrome.0.0j69i57j0l4.6122j0j7&sourceid=chrome&ie=UTF-8) the file to try on the upload function in the demonstration)*
        
* View : View or download the transaction records, summaries of the incomes/spendings, or the stock status.
    + Journal : The transaction records
    + Income/Spendings : Summaries of the incomes and spendings
    + Stock : The stock status; updated whenever the is an entry of a new transaction 
* Control Panel : Administration of the app for the particular user.
    + Invoice : Create the invoice log and pattern for the invoice number
    + Reset to default : Remove all content of the selected file(s) leaving a clean slate
    + Update restore point : Update the restore point(s) for the selected file(s)
    + Restore file : Rollback for the selected file(s)
    + System log : Records of any of the above four activities
    
    
*(All changes made in the demonstration are confined to the scope of the current session and will be restored to the original states once the session is over.)*


## Coming up
* Interface to transaction records from various online selling platforms
* Analytic tools
* Predictive models for sale trends, likelihood of success for a product, demand projection, etc -- as data grows
* Restock level alert
* Modifiable journal entries


## Related work
The private package, [EZRecords](https://github.com/Samantha-Lui/EZRecords), which supports the underlying structure of the application.
