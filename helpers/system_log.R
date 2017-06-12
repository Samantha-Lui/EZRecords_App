system_log <- function(file, event, inv=character(0)){
    if(!file.exists('system_log.Rds'))
        saveRDS(data.frame(), file = 'system_log.Rds')
    file <- as.numeric(file)
    files <- c('current.Rds', 'other_current.Rds', 'product_logs_current.Rds', 'other_logs_current.Rds', paste('invoice log:', inv))
    log <- data.frame()
    for(i in 1:length(file)){
        log <- rbind(log, data.frame(Date = Sys.time(), Event = event, File = files[file[i]], stringsAsFactors = FALSE))
    }
    sl <- tryCatch(readRDS('system_log.Rds'), 
                   error=function(e) 'Cannot open system log')
    df <- rbind(log, sl)
    saveRDS(df, file = 'system_log.Rds')
    df
}