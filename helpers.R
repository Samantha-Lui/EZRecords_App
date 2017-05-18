files <- list.files('./helpers')
sources <- paste('source(\"', paste('./helpers', files, sep = '/'), '\")', sep = '')
for(i in 1:length(sources))
  eval(parse(text=sources[i]))
