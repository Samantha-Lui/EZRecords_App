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