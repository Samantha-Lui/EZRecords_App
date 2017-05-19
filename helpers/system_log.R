system_log <- function(file, event, inv=character(0)){
  file <- as.numeric(file)
  files <- c('current.Rds', 'other_current.Rds', 'product_logs_current.Rds', 'other_logs_current.Rds', paste('invoice log:', inv))
  log <- data.frame()
  for(i in 1:length(file)){
    log <- rbind(log, data.frame(Date = Sys.time(), Event = event, File = files[file[i]], stringsAsFactors = FALSE))
  }
  df <- rbind(readRDS('system_log.Rds'), log)
  saveRDS(df, file = 'system_log.Rds')
  df
}