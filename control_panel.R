library(EZRecords)

## Skeleton for sale and purchase ('current.Rds')
# "current FREEZE.Rds"
# Retore: saveRDS(readRDS("current FREEZE.Rds"), file="current.Rds")
# Update retore point: saveRDS(readRDS("current FREEZE.Rds"), file="current FREEZE.Rds")
# data frame
# inpect
x <- readRDS("current.Rds"); x

## Skeleton for other kinds of transactions ("other_current.Rds")
# "other_current FREEZE.Rds"
# Retore: saveRDS(readRDS("other_current FREEZE.Rds"), file="other_current.Rds")
# Update retore point: saveRDS(readRDS("other_current.Rds"), file="other_current FREEZE.Rds")
# data frame
# inpect
y <- readRDS("other_current.Rds"); y

## Transaction records of sale and purchase ('product_logs_current.Rds')
# 'product_logs_current FREEZE.Rds'
# Retore: saveRDS(readRDS("product_logs_current FREEZE.Rds"), file="product_logs_current.Rds")
# Update retore point: saveRDS(readRDS("product_logs_current.Rds"), file="product_logs_current FREEZE.Rds")
# product_logs
# inpect
z <- readRDS('product_logs_current.Rds'); print(z)

## Records of transaction other than sale and purchase ("other_logs_current.Rds")
# "other_logs_current FREEZE.Rds"
# Retore: saveRDS(readRDS("other_logs_current FREEZE.Rds"), file="other_logs_current.Rds")
# Update retore point: saveRDS(readRDS("other_logs_current.Rds"), file="other_logs_current FREEZE.Rds")
# product_logs
# inpect
u <- readRDS("other_logs_current.Rds"); print(u)

## Invoice Generation ("m1314_inovice.Rds")
fname <- 'm1314_inovice'
vt <- new('invoice',
          fname = fname,
          part1 = 'D09',
          part2 = '072101',
          count_begins_at = '1828')
saveRDS(vt, file="invoice_object.Rds")
saveRDS(data.frame(), file=paste(fname, '.Rds', sep=''))
# inpect
w <- readRDS("m1314_inovice.Rds"); w
readRDS("invoice_object.Rds")