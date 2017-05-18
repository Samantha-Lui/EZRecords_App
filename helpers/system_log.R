system_log <- function(file, event, inv=character(0)){
  files <- c('current.Rds', 'other_current.Rds', 'product_logs_current.Rds', 'other_logs_current.Rds', paste('invoice log:', inv))
  log <- data.frame()
  for(i in 1:length(files)){
    log <- rbind(log, data.frame(Date = Sys.time(), Event = event, File = files[i], stringsAsFactors = FALSE))
  }
  saveRDS(rbind(readRDS('System_log.Rds'), log))
}