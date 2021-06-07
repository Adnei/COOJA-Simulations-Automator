library(ggplot2)
source("parse_data.R")
################################################################################
#                            Delay Boxplot                                     #
################################################################################
#compute lower and upper whiskers
data_ylim <- boxplot.stats(parse_data.df$DELAY/us_to_s)$stats[c(1,5)]
delay_boxplot.plot <- ggplot(parse_data.df, aes(x = factor(1), y = DELAY/us_to_s)) +
  geom_boxplot(outlier.shape = NA) +
  geom_point(color="red")+
  ylab("Delay (s)") + # OLD -> µs
  xlab("Data from 10 executions") +
  ggtitle("Delay Boxplot") +
  theme_minimal() +
  coord_cartesian(ylim = data_ylim * 1.05) # zoom rather than excluding data
ggsave(filename='delay_boxplot.pdf', plot=delay_boxplot.plot)
################################################################################
#                            Delivery Rate By Execution                        #
################################################################################

recv_rate <- c()
for(i_exec in c(1:max_exec)){
  rate <- length(parse_data.df[parse_data.df$EXEC == i_exec &
    parse_data.df$RECEIVED == TRUE, ]$RECEIVED) /
  length(parse_data.df[parse_data.df$EXEC == i_exec, ]$RECEIVED)
  recv_rate <- c(recv_rate, rate)
}

plot_info.df <- data.frame(x_axis=c(1:max_exec), y_axis=recv_rate)

delivery_rate_exec.plot <- ggplot(plot_info.df, aes(x=x_axis,y=y_axis, color=x_axis)) +
  geom_line() +
  geom_point() +
  geom_hline(aes(yintercept = mean(y_axis), linetype=as.character(round(mean(y_axis),4)), group=mean(y_axis)),
    show.legend=TRUE,
    color="red") +
  scale_linetype_manual(name="Média", values = c(2)) +
  ylab("Taxa de entrega") +
  xlab("ID de execução") +
  ggtitle("Taxa de Entrega de pacotes: CTP") +
  theme_minimal() +
  scale_x_continuous(breaks=seq(1,max(plot_info.df$x_axis),1) ) +
  scale_y_continuous(limits=c(0, 1) )

ggsave(filename='delivery_rate_exec.pdf', plot=delivery_rate_exec.plot)
################################################################################
#                         Packet Delay Avg By Execution                        #
################################################################################
# @DEPRECATED  --> Use the boxpload approach.
delay_avg_exec.df <- aggregate(DELAY ~ EXEC, data=parse_data.df, FUN=mean)
delay_exec.plot <- ggplot(delay_avg_exec.df, aes(x=EXEC,y=DELAY/us_to_s)) +
  geom_line() +
  geom_point() +
  ylab("Atraso médio (s)") + # OLD -> µs
  xlab("ID de execução") +
  ggtitle("Atraso de entrega de pacotes") +
  theme_minimal() +
  scale_x_continuous(breaks=seq(1,max(plot_info.df$x_axis),1) )
ggsave(filename='delay_exec.pdf', plot=delay_exec.plot)
################################################################################
#                         RPL Power mW By Time                                 #
################################################################################
source("parse_data_power.R")

# Mote 1 is ignored
lt_min_precision.df <- listen_transmit.df[listen_transmit.df$ID != 1, ]
lt_min_precision.df$Time <- as.integer(lt_min_precision.df$Time)/us_to_min
breakpoints <- seq(0, 20, by=0.5)

half_min_aggregation.df <- aggregate(list(
    LISTEN = lt_min_precision.df$LISTEN,
    TRANSMIT=lt_min_precision.df$TRANSMIT),
  by=list(
    breakpoints=cut(lt_min_precision.df$Time, breaks = breakpoints)),
  FUN=mean)

half_min_aggregation.df$breakpoints <- seq(0.5, 20, by=0.5)

power_avg_min.plot <- ggplot(half_min_aggregation.df, aes(x = breakpoints)) +
  geom_line(aes(y=LISTEN  *  rx_current * 3 / 32768 * 5, color="RX")) +
  geom_line(aes(y=TRANSMIT * tx_current * 3 / 32768 * 5, color="TX")) +
  ylab("Power Consumption Average (mW)") +
  xlab("Time (min)") +
  ggtitle("XX") +
  theme_minimal()
ggsave(filename='power_avg_sec.pdf', plot=power_avg_min.plot)
################################################################################
#                         Power mW By Mote                                     #
################################################################################

listen_transmit_fix.df <- listen_transmit.df[listen_transmit.df$ID != 1, ]
energest_avg_by_mote <- aggregate(list(
    LISTEN=listen_transmit_fix.df$LISTEN,
    TRANSMIT=listen_transmit_fix.df$TRANSMIT),
  by=list(Mote=listen_transmit_fix.df$ID),
  FUN=mean)

 # Current from TmoteSky data sheet:
 #    http://www.crew-project.eu/sites/default/files/tmote-sky-datasheet.pdf
power_avg_mote.plot <- ggplot(energest_avg_by_mote, aes(x = Mote)) +
  geom_line(aes(y=LISTEN  *  rx_current * 3 / 32768 * 5, color="RX")) +
  geom_line(aes(y=TRANSMIT * tx_current * 3 / 32768 * 5, color="TX")) +
  ylab("Power Consumption (mW)") +
  xlab("Mote ID") +
  ggtitle("Power Consumption Average by Mote") +
  theme_minimal() +
  scale_x_continuous(breaks=seq(2,max(energest_avg_by_mote$Mote),1) )
ggsave(filename='power_avg_mote.pdf', plot=power_avg_mote.plot)
################################################################################
#                               Bully Overhead                                 #
################################################################################
source("bully_overhead.R")

bully_overhead.plot <- ggplot(packet_overhead_by_voting.df) +
  geom_line(aes(x = voting,
      y=total_packets, group=exec, color=exec)) +
  geom_line(data=packet_overhead_average_by_voting.df,
      aes(x = voting,
      y = avg_packets),
      linetype="dashed",
      color = "red") +
  ylab("Total de Pacotes") +
  xlab("Votação") +
  ggtitle("Overhead de pacotes por votação") +
  theme_minimal()
ggsave(filename='packet_overhead.pdf', plot=bully_overhead.plot)
