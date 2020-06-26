################################################################################################################
################################################################################################################
########################################################
# Figure 4 - Correct tree with ICA numbers on the nodes, density plot of ICA scores
########################################################
################################################################################################################
################################################################################################################

# Tree figure:
# Viewed using dendroscope, and visualized correct tree in figtree
# Put numbers (from dendroscope) on nodes manually in keynote 

########################################################
#density plot of ica values

library(ggplot2)
setwd("~/Desktop/Analyses/quality")


ica <- read.csv("ica_scores.csv")

ica_dens <- ggplot(ica, aes(x=ica_value, fill=dataset)) + 
  geom_density(alpha=.3) +
  ylab("Density") + xlab("Internode Certainty (All) Scores") +
  scale_fill_discrete(name = "Dataset", breaks = c("bad", "good"),
                      labels = c("Low-Quality", "High-Quality")) +
  theme(axis.title = element_text(size=22), axis.text = element_text(size = 16),
        panel.grid.major = element_blank(), panel.grid.minor = element_blank(), 
        panel.background = element_blank(), axis.line = element_line(colour = "black"),
        legend.title = element_text(size = 22), legend.text = element_text(size = 20))
ica_dens


###################################################################################
#Density plot of ICA values for only the partitions the datasets have in common

com_ica <- read.csv("common_ica_scores.csv")

com_ica_dens <- ggplot(com_ica, aes(x=ica_value, fill=dataset)) + 
  geom_density(alpha=.3) +
  ylab("Density") + xlab("Internode Certainty (All) Scores") +
  theme(axis.title = element_text(size=30), axis.text = element_text(size = 24),
        panel.grid.major = element_blank(), panel.grid.minor = element_blank(), 
        panel.background = element_blank(), axis.line = element_line(colour = "black"),
        legend.title = element_text(size = 16), legend.text = element_text(size = 14))

com_ica_dens


