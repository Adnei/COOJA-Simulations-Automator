log_data.df <- read.csv("../all_logs.log", sep="|", header=T, stringsAsFactors = F)
us_to_s <- 1000000 #microseconds to seconds
us_to_min <- 60000000 #microseconds to minutes
max_exec <- max(log_data.df$EXEC)
