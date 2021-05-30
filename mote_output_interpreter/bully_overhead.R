library(dplyr)
library(readr)
source("static.R")

overhead_log.df <- log_data.df[grepl('ANNOUNCEMENT',
    log_data.df$Message), -c(5,6)] #removes columns 5 and 6

overhead_min.df <-overhead_log.df
overhead_min.df$Time <- overhead_min.df$Time/us_to_min

overhead_voting <- overhead_min.df
overhead_voting$Time <- round(overhead_min.df$Time, 0) / 3

packet_overhead_by_voting.df <- aggregate(list(total_packets=overhead_voting$Time),
    by=list(exec=overhead_voting$EXEC, voting=overhead_voting$Time),
    FUN=length)
packet_overhead_average_by_voting.df <- aggregate(
    list(avg_packets=packet_overhead_by_voting.df$total_packets),
    by=list(voting=packet_overhead_by_voting.df$voting),
    FUN=mean)
