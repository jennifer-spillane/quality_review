################################################################################################################
################################################################################################################
########################################################
# Figure 6 - RF distances: symmetric difference density plot
########################################################
################################################################################################################
################################################################################################################

library(ggplot2)
setwd("~/Desktop/Analyses/quality")

#read in data
sym_dif <- read.csv("~/Desktop/Analyses/quality/all_symmetric_dif.csv")

#density plot of all partitions
rf_dens <- ggplot(sym_dif, aes(x=dif, fill=dataset)) + 
  geom_density(alpha=.3) +
  ylab("Density") + xlab("RF Distances of all Partitions") +
  scale_fill_discrete(name = "Dataset", breaks = c("bad", "good"),
                      labels = c("Low-Quality", "High-Quality")) +
  theme(axis.title = element_text(size=20), axis.text = element_text(size = 14),
        panel.grid.major = element_blank(), panel.grid.minor = element_blank(), 
        panel.background = element_blank(), axis.line = element_line(colour = "black"),
        legend.title = element_text(size = 16), legend.text = element_text(size = 14))

rf_dens


########################################################
#partitions common to both datasets

#reading in data
common_dist <- read.csv("~/Desktop/Analyses/quality/all_common_rfdistances.csv")

#density plot
common_rf_dens <- ggplot(common_dist, aes(x=dist, fill=dataset)) + 
  geom_density(alpha=.3) +
  ylab("Density") + xlab("RF Distances of Common Partitions") +
  scale_fill_discrete(name = "Dataset", breaks = c("bad", "good"),
                      labels = c("Low-Quality", "High-Quality")) +
  theme(axis.title = element_text(size=20), axis.text = element_text(size = 14),
        panel.grid.major = element_blank(), panel.grid.minor = element_blank(), 
        panel.background = element_blank(), axis.line = element_line(colour = "black"),
        legend.title = element_text(size = 16), legend.text = element_text(size = 14))

common_rf_dens


########################################################
#adding the plots together

library(ggpubr)

ggarrange(rf_dens, common_rf_dens,
          labels = c("A", "B"),
          ncol = 2, nrow = 1, align = "h", font.label = list(size = 20),
          common.legend = TRUE, legend = "right")
