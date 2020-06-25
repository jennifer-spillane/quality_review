################################################################################################################
################################################################################################################
########################################################
# Figure 2 - Orthofinder info: scatter plots and density plots of busco and transrate scores and number of transcripts
########################################################
################################################################################################################
################################################################################################################



#############################################################################################
#scatterplots with density plots of number of transcripts, transrate, and busco scores above them
########################################################################

#install.packages("gridExtra")
library(ggplot2)
library(gridExtra)
library(plyr)

#if(!require(devtools)) install.packages("devtools")
#devtools::install_github("kassambara/ggpubr")

library(ggpubr)

par(mfrow = c(1, 1))
grid.newpage()

#read in the data - and don't be fooled by the name, it also contains transrate scores and numbers of transcripts
all_scores <- read.csv("all_busco_ortho.csv")


##################################################################################################
#Making the plots I will later arrange together


#############################################################
#Transrate

#calculate medians
med.transrate <- ddply(all_scores, "dataset", summarise, trans.med = median(transrate))
med.transrate
#dataset trans.med
#1     bad   0.15943
#2    good   0.47236

#density plot with semi-transparent fill and median lines
trans_dens <- ggplot(all_scores, aes(x=transrate, fill=dataset)) + 
  geom_density(alpha=.3) +
  geom_vline(data=med.transrate, aes(xintercept=trans.med,  colour=dataset),
             linetype="dashed", size=1) +
  ylab("Density") +
  xlim(0, 0.8) +
  scale_fill_discrete(name = "Dataset", breaks = c("bad", "good"),
                      labels = c("Low-Quality", "High-Quality")) +
  scale_color_discrete(guide = FALSE) +
  theme(axis.title.x = element_blank(), axis.title.y = element_blank(),
        panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"),
        axis.text = element_text(size = 14),
        legend.title = element_text(size = 16), legend.text = element_text(size = 14))

trans_dens


#density plot meant to stand on it's own rather than be part of the larger figure
trans_dens2 <- ggplot(all_scores, aes(x=transrate, fill=dataset)) + 
  geom_density(alpha=.3) +
  geom_vline(data=med.transrate, aes(xintercept=trans.med,  colour=dataset),
             linetype="dashed", size=1) +
  ylab("Density") + xlab("Transrate Score") +
  xlim(0, 0.8) +
  scale_fill_discrete(name = "Dataset", breaks = c("bad", "good"),
                      labels = c("Low-Quality", "High-Quality")) +
  scale_color_discrete(guide = FALSE) +
  theme(axis.title = element_text(size=30), axis.text = element_text(size = 24),
        panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"),
        legend.title = element_text(size = 26), legend.text = element_text(size = 24))

trans_dens2



#scatterplot from above of the transrate scores vs. orthogroup numbers
trans_scat <- ggplot(all_scores, aes(x = transrate, y = total_orthos, shape = dataset, color = dataset)) + 
  geom_point() +
  xlab("Transrate Score") + ylab("Number of Orthogroups") +
  xlim(0, 0.8) +
  scale_fill_discrete(name = "Dataset", breaks = c("bad", "good"),
                      labels = c("Low-Quality", "High-Quality")) +
  scale_color_discrete(guide = FALSE) +
  theme(axis.title.y = element_blank(), panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(), panel.background = element_blank(), 
        axis.line = element_line(colour = "black"), axis.title.x = element_text(size = 20), 
        axis.text = element_text(size = 14), 
        legend.title = element_text(size = 16), legend.text = element_text(size = 14))

trans_scat


####################################################################
#Busco

#calculate medians
med.busco <- ddply(all_scores, "dataset", summarise, busco.med = median(busco))
med.busco
#dataset trans.busco
#1     bad     82.00
#2    good     84.65

#density plot with semi-transparent fill and median lines
busco_dens <- ggplot(all_scores, aes(x=busco, fill=dataset)) + 
  geom_density(alpha=.3) +
  geom_vline(data=med.busco, aes(xintercept=busco.med,  colour=dataset),
             linetype="dashed", size=1) +
  ylab("Density") +
  xlim(0, 100) +
  scale_fill_discrete(name = "Dataset", breaks = c("bad", "good"),
                      labels = c("Low-Quality", "High-Quality")) +
  scale_color_discrete(guide = FALSE) +
  theme(axis.title.x = element_blank(), axis.title.y = element_blank(),
        panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"),
        axis.text = element_text(size = 14),
        legend.title = element_text(size = 16), legend.text = element_text(size = 14))

busco_dens


#scatterplot from above of the busco scores vs. orthogroup numbers
busco_scat <- ggplot(all_scores, aes(x = busco, y = total_orthos, shape = dataset, color = dataset)) + 
  geom_point() +
  geom_smooth(method = lm, se = FALSE) +
  xlab("BUSCO Score") +
  xlim(0, 100) +
  scale_fill_discrete(name = "Dataset", breaks = c("bad", "good"),
                      labels = c("Low-Quality", "High-Quality")) +
  scale_color_discrete(guide = FALSE) +
  theme(axis.title.y = element_blank(), panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(), panel.background = element_blank(), 
        axis.line = element_line(colour = "black"), axis.title.x = element_text(size = 20), 
        axis.text = element_text(size = 14), 
        legend.title = element_text(size = 16), legend.text = element_text(size = 14))



busco_scat



####################################################################
#Transcripts

#calculate medians
med.scripts <- ddply(all_scores, "dataset", summarise, scripts.med = median(transcripts))
med.scripts
#dataset scripts.med
#1     bad    275699.5
#2    good    157353.0

#density plot with semi-transparent fill and median lines
scripts_dens <- ggplot(all_scores, aes(x=transcripts, fill=dataset)) + 
  geom_density(alpha=.3) +
  geom_vline(data=med.scripts, aes(xintercept=scripts.med,  colour=dataset),
             linetype="dashed", size=1) +
  ylab("Density") +
  xlim(34000, 1100000) +
  scale_fill_discrete(name = "Dataset", breaks = c("bad", "good"),
                      labels = c("Low-Quality", "High-Quality")) +
  scale_color_discrete(guide = FALSE) +
  theme(axis.title.x = element_blank(),
        panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"),
        axis.title.y = element_text(size = 20), axis.text = element_text(size = 14),
        legend.title = element_text(size = 16), legend.text = element_text(size = 14))

scripts_dens


#scatterplot from above of the transcript numbers vs. orthogroup numbers
scripts_scat <- ggplot(all_scores, aes(x = transcripts, y = total_orthos, shape = dataset, color = dataset)) + 
  geom_point() +
  geom_smooth(method = lm, se = FALSE) +
  xlab("Total Transcripts") + ylab("Total Orthogroups") +
  xlim(34000, 1100000) +
  scale_fill_discrete(name = "Dataset", breaks = c("bad", "good"),
                      labels = c("Low-Quality", "High-Quality")) +
  scale_color_discrete(guide = FALSE) +
  theme(panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(), panel.background = element_blank(), 
        axis.line = element_line(colour = "black"), axis.title.y = element_text(size = 20),
        axis.title.x = element_text(size = 20), axis.text = element_text(size = 14),
        legend.title = element_text(size = 16), legend.text = element_text(size = 14))

scripts_scat

########################################################
#putting the plots together - plots I am interested in are trans_dens, trans_scat, busco_dens, and busco_scat
########################################################

ggarrange(scripts_dens, trans_dens, busco_dens, scripts_scat, trans_scat, busco_scat,
          labels = c("A", "C", "E", "B", "D", "F"),
          ncol = 3, nrow = 2, align = "hv", font.label = list(size = 20), 
          common.legend = TRUE, legend = "right")



