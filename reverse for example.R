library(EZRecords)

upload <- read.csv("upload.csv", stringsAsFactors = FALSE)
head(upload)

f3 <- readRDS("product_logs_current FREEZE.Rds"); print(f3)
g3 <- data.frame(print(f3), stringsAsFactors = FALSE)
g3[1, ]
g3$transac <- g3$category
g3$value <- NULL
g3$total <- NULL
g3$time_stamp <- NULL
g3$descrp[1]
g3$descrp <- gsub('Slate:', 'Slate: Slate:', g3$descrp)
g3$descrp <- gsub('Bib:', 'Accessory: Bib:', g3$descrp)
g3$descrp <- gsub('Hair Barrette:', 'Accessory: Hair Barrette:', g3$descrp)
g3$descrp <- gsub('Placemat:', 'Accessory: Placemat:', g3$descrp)
g3$descrp <- gsub('Misc:', 'Accessory: Misc:', g3$descrp)
df <- data.frame()
for(i in 1:nrow(g3)){
    descrp <- g3$descrp[i]
    descrp <- unlist(strsplit(descrp, ', '))
    #df2 <- data.frame()
    #for(j in 1:length(descrp)){
    mcats <- gsub(':.*', '', descrp)
    category <- gsub('^.*: ', '', descrp)
    model <- gsub('^.*:', '', category)
    quant <- as.numeric(gsub('.*x ', '', model))
    price <- gsub('.*@\\$', '', model); price <- as.numeric(gsub(' x.*', '', price))
    model <- gsub(' @.*', '', model)
    category <- gsub(':.*', '', category)
    df2 <- data.frame(transac = 'purchase',
                      date=g3$date[i],
                      supplier_customer = g3$supplier_customer[i],
                      order_no=g3$order_no[i],
                      tax=g3$tax[i],
                      shipment=g3$shipment[i],
                      discount = 'None',
                      sample = 'no',
                      sampling = 'no',
                      mcat = mcats,
                      category = category,
                      model=model,
                      quant=quant,
                      price=price,
                      stringsAsFactors = FALSE)
    #}
    df <- rbind(df, df2)
}
names(df)
names(upload)

f1 <- readRDS("current FREEZE.Rds"); f1
dsp <- unique(f1[, c('supplier', 'model', 'mcat', 'descrp')])
names(dsp)[1] <- 'supplier_customer'
dim(df)
df3 <- merge(df, dsp)
dim(df3)

df3$supplier_customer <- as.character(sapply(df3$supplier_customer, 
                                            function(x) {switch(EXPR=as.character(x), 
                                                                'Conde' = 'Supplier A',
                                                                'Coastal Business' = 'Supplier B',
                                                                'Sunmeta' = 'Supplier C',
                                                                as.character(x))}))
unique(df3$model); length(unique(df3$model))
df3$model <- gsub('5', '91', df3$model)
df3$model <- gsub('7', '5', df3$model)
df3$model <- gsub('91', '7', df3$model)
df3$model <- gsub('4', '123', df3$model)
df3$model <- gsub('9', '4', df3$model)
df3$model <- gsub('123', '9', df3$model)
df3$model <- gsub('10', '789', df3$model)
df3$model <- gsub('11', '10', df3$model)
df3$model <- gsub('789', '11', df3$model)
df3$model <- gsub('3', '245', df3$model)
df3$model <- gsub('8', '3', df3$model)
df3$model <- gsub('245', '8', df3$model)
df3$model <- gsub('S', 'PK', df3$model)
df3$model <- gsub('Q', 'S', df3$model)
df3$model <- gsub('PK', 'Q', df3$model)

up <- function(x){
    if(x<=1.5)
        return(2.5*x)
    if(x<=5)
        return(2*x)
    return(round(1.5*x, 2))
}
df3$price <- sapply(df3$price, up)

write.csv(df3, 'upload_jproduct.csv', row.names = FALSE)



f4 <- readRDS("other_logs_current FREEZE.Rds"); print(f4)[1, ]
g4 <- read.csv("jother.csv", stringsAsFactors = FALSE)
head(g4)
upload <- read.csv("upload.csv", stringsAsFactors = FALSE)
head(upload)
g4$transac <- 'other'
g4$mcat <- ''
g4$discount <- 'None'
g4$sample <- 'no'
g4$sampling <- 'no'
g4$quant <- 1
g4$price <- g4$value
g4$value <- NULL
g4$total <- NULL
sort(names(g4)) == sort(names(upload))
dsp <- unique(f4[, c('supplier', 'model', 'mcat', 'descrp')])
names(dsp)[1] <- 'supplier_customer'
dim(df)
df3 <- merge(df, dsp)
dim(df3)

g4$supplier_customer <- as.character(sapply(g4$supplier_customer, 
                                             function(x) {switch(EXPR=as.character(x), 
                                                                 'Conde' = 'Supplier A',
                                                                 'Coastal Business' = 'Supplier B',
                                                                 'Sunmeta' = 'Supplier C',
                                                                 as.character(x))}))
write.csv(g4, 'upload_jother.csv', row.names = FALSE)