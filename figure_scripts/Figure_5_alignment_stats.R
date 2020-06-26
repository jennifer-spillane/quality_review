#Created 5-22-2020
#Last Modified 6-23-2020
#Author: Jennifer Spillane

#################################################################
#Comparisons of four alignment metrics in the partitions common to both high and low quality datasets
##########################################################

library(ggplot2)
setwd("~/Desktop/Analyses/quality")

############################################
############################################
#Percentage of constant sites in each alignment
############################################
############################################

#reading in data
constant_sites <- read.csv("~/Desktop/Analyses/quality/all_common_constants.csv")

#Wilcoxon rank sum test
wilcox.test(constants ~ dataset, data=constant_sites) 
#W = 52908, p-value = 0.3727
#alternative hypothesis: true location shift is not equal to 0

#density plot
constants_dens <- ggplot(constant_sites, aes(x=constants, fill=dataset)) + 
  geom_density(alpha=.3) +
  ylab("Density") + xlab("Percent Constant Sites") +
  scale_fill_discrete(name = "Dataset", breaks = c("bad", "good"),
                      labels = c("Low-Quality", "High-Quality")) +
  theme(axis.title = element_text(size=20), axis.text = element_text(size = 14),
        panel.grid.major = element_blank(), panel.grid.minor = element_blank(), 
        panel.background = element_blank(), axis.line = element_line(colour = "black"),
        legend.title = element_text(size = 16), legend.text = element_text(size = 14))

constants_dens




############################################
############################################
#Percentage of parsimony informative sites in each alignment
############################################
############################################

#reading in data
parsimony_sites <- read.csv("~/Desktop/Analyses/quality/all_common_parsimony.csv")

#Wilcoxon rank sum test
wilcox.test(parsimony ~ dataset, data=parsimony_sites) 
#W = 54754, p-value = 0.8851
#alternative hypothesis: true location shift is not equal to 0

#density plot
parsimony_dens <- ggplot(parsimony_sites, aes(x=parsimony, fill=dataset)) + 
  geom_density(alpha=.3) +
  ylab("Density") + xlab("Percent Parsimony Informative Sites") +
  scale_fill_discrete(name = "Dataset", breaks = c("bad", "good"),
                      labels = c("Low-Quality", "High-Quality")) +
  theme(axis.title = element_text(size=20), axis.text = element_text(size = 14),
        panel.grid.major = element_blank(), panel.grid.minor = element_blank(), 
        panel.background = element_blank(), axis.line = element_line(colour = "black"),
        legend.title = element_text(size = 16), legend.text = element_text(size = 14))

parsimony_dens




############################################
############################################
#Number of sequences that failed the composition test
############################################
############################################

#reading in data
num_composition <- read.csv("~/Desktop/Analyses/quality/all_common_composition.csv")

#Wilcoxon rank sum test
wilcox.test(sequences ~ dataset, data=num_composition) 
#W = 60621, p-value = 0.01306
#alternative hypothesis: true location shift is not equal to 0

#density plot
composition_dens <- ggplot(num_composition, aes(x=sequences, fill=dataset)) + 
  geom_density(alpha=.3, adjust = 2) +
  ylab("Density") + xlab("Number of Sequences Failing the Composition Test") +
  scale_fill_discrete(name = "Dataset", breaks = c("bad", "good"),
                      labels = c("Low-Quality", "High-Quality")) +
  theme(axis.title = element_text(size=20), axis.text = element_text(size = 14),
        panel.grid.major = element_blank(), panel.grid.minor = element_blank(), 
        panel.background = element_blank(), axis.line = element_line(colour = "black"),
        legend.title = element_text(size = 16), legend.text = element_text(size = 14))

composition_dens




############################################
############################################
#Number of sequences that failed the composition test divided by length of the alignment
############################################
############################################

#using the same data file as above (all_common_composition.csv)

#Wilcoxon rank sum test
wilcox.test(norm_seqs ~ dataset, data=num_composition) 
#W = 61242, p-value = 0.006031
#alternative hypothesis: true location shift is not equal to 0

#density plot
norm_composition_dens <- ggplot(num_composition, aes(x=norm_seqs, fill=dataset)) + 
  geom_density(alpha=.3) +
  ylab("Density") + xlab("Number of Sequences Failing the Composition Test/Alignment Length") +
  scale_fill_discrete(name = "Dataset", breaks = c("bad", "good"),
                      labels = c("Low-Quality", "High-Quality")) +
  theme(axis.title = element_text(size=20), axis.text = element_text(size = 14),
        panel.grid.major = element_blank(), panel.grid.minor = element_blank(), 
        panel.background = element_blank(), axis.line = element_line(colour = "black"),
        legend.title = element_text(size = 16), legend.text = element_text(size = 14))

norm_composition_dens



#Wilcox test of length
wilcox.test(length ~ dataset, data=norm_composition) 

#density plot of length
length_dens <- ggplot(norm_composition, aes(x=length, fill=dataset)) + 
  geom_density(alpha=.3) +
  ylab("Density") + xlab("Alignment Length") +
  scale_fill_discrete(name = "Dataset", breaks = c("bad", "good"),
                      labels = c("Low-Quality", "High-Quality")) +
  theme(axis.title = element_text(size=20), axis.text = element_text(size = 14),
        panel.grid.major = element_blank(), panel.grid.minor = element_blank(), 
        panel.background = element_blank(), axis.line = element_line(colour = "black"),
        legend.title = element_text(size = 16), legend.text = element_text(size = 14))

length_dens

#scatterplot of length and number of seqs failing the composition test
comp_scat <- ggplot(norm_composition, aes(x = sequences, y = length, shape = dataset, color = dataset)) + 
  geom_point() +
  geom_smooth(method = lm, se = FALSE) +
  xlab("Number of Seqs Failing the Comp Test") +
  ylab("Length of Alignment") +
  xlim(0, 18) +
  theme(panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(), panel.background = element_blank(), 
        axis.line = element_line(colour = "black"), axis.title.x = element_text(size = 20), 
        axis.text = element_text(size = 14), axis.title.y = element_text(size = 20),
        legend.title = element_text(size = 16), legend.text = element_text(size = 14))


comp_scat


#plotting the un-normalized and normalized side by side
library(ggpubr)

ggarrange(composition_dens, norm_composition_dens,
          labels = c("A", "B"),
          align = "h", font.label = list(size = 20), 
          common.legend = TRUE, legend = "right")




############################################
############################################
#Number of sequences with more than 50% gaps/ambiguity - does not include all partitions in this group
############################################
############################################

#reading in data
num_ambiguity <- read.csv("~/Desktop/Analyses/quality/all_common_ambiguity.csv")

#Wilcoxon rank sum test
wilcox.test(sequences ~ dataset, data=num_ambiguity) 
#W = 31622, p-value = 2.056e-07
#alternative hypothesis: true location shift is not equal to 0

#density plot
ambiguity_dens <- ggplot(num_ambiguity, aes(x=sequences, fill=dataset)) + 
  geom_density(alpha=.3) +
  ylab("Density") + xlab("Number of Sequences with more than 50% gaps/ambiguity") +
  scale_fill_discrete(name = "Dataset", breaks = c("bad", "good"),
                      labels = c("Low-Quality", "High-Quality")) +
  theme(axis.title = element_text(size=20), axis.text = element_text(size = 14),
        panel.grid.major = element_blank(), panel.grid.minor = element_blank(), 
        panel.background = element_blank(), axis.line = element_line(colour = "black"),
        legend.title = element_text(size = 16), legend.text = element_text(size = 14))

ambiguity_dens




############################################
############################################
#Number of sequences with more than 50% gaps/ambiguity with 0s added in for sequences missing values
############################################
############################################

#reading in data
num_ambiguity_zeros <- read.csv("~/Desktop/Analyses/quality/all_common_ambiguity_zeros.csv")

#Wilcoxon rank sum test
wilcox.test(sequences ~ dataset, data=num_ambiguity_zeros) 
#W = 81532, p-value < 2.2e-16
#alternative hypothesis: true location shift is not equal to 0

#density plot
ambiguity_zeros_dens <- ggplot(num_ambiguity_zeros, aes(x=sequences, fill=dataset)) + 
  geom_density(alpha=.3) +
  ylab("Density") + xlab("Number of Sequences with more than 50% gaps/ambiguity") +
  scale_fill_discrete(name = "Dataset", breaks = c("bad", "good"),
                      labels = c("Low-Quality", "High-Quality")) +
  theme(axis.title = element_text(size=20), axis.text = element_text(size = 14),
        panel.grid.major = element_blank(), panel.grid.minor = element_blank(), 
        panel.background = element_blank(), axis.line = element_line(colour = "black"),
        legend.title = element_text(size = 16), legend.text = element_text(size = 14))

ambiguity_zeros_dens




############################################
############################################
#Combining the four we want for the figure: constant, parsimony, normalized composition, ambiguity
############################################
############################################


library(ggpubr)


#I'm going to recreate the relevent plots here, so that I can mess with the axis titles without making the ones
#above unintelligible on their own.

#constant sites
constants_plot <- ggplot(constant_sites, aes(x=constants, fill=dataset)) + 
  geom_density(alpha=.3) +
  ylab("Density") + xlab("Percent Constant Sites") +
  scale_fill_discrete(name = "Dataset", breaks = c("bad", "good"),
                      labels = c("Low-Quality", "High-Quality")) +
  theme(axis.title = element_text(size=20), axis.text = element_text(size = 14),
        panel.grid.major = element_blank(), panel.grid.minor = element_blank(), 
        panel.background = element_blank(), axis.line = element_line(colour = "black"),
        legend.title = element_text(size = 16), legend.text = element_text(size = 14))


#parsimony-informative sites
parsimony_plot <- ggplot(parsimony_sites, aes(x=parsimony, fill=dataset)) + 
  geom_density(alpha=.3) +
  ylab("Density") + xlab(expression(atop("Percentage parsimony-", "informative sites"))) +
  scale_fill_discrete(name = "Dataset", breaks = c("bad", "good"),
                      labels = c("Low-Quality", "High-Quality")) +
  theme(axis.title = element_text(size=20), axis.text = element_text(size = 14),
        panel.grid.major = element_blank(), panel.grid.minor = element_blank(), 
        panel.background = element_blank(), axis.line = element_line(colour = "black"),
        legend.title = element_text(size = 16), legend.text = element_text(size = 14))


#sequences failing the composition test normalized by sequence length
composition_plot <- ggplot(num_composition, aes(x=norm_seqs, fill=dataset)) + 
  geom_density(alpha=.3) +
  ylab("Density") + xlab(expression(atop("Sequences that fail the composition", "test normalized by alignment length"))) +
  scale_fill_discrete(name = "Dataset", breaks = c("bad", "good"),
                      labels = c("Low-Quality", "High-Quality")) +
  theme(axis.title = element_text(size=20), axis.text = element_text(size = 14),
        panel.grid.major = element_blank(), panel.grid.minor = element_blank(), 
        panel.background = element_blank(), axis.line = element_line(colour = "black"),
        legend.title = element_text(size = 16), legend.text = element_text(size = 14))



#sequences with over 50% gaps/ambiguity
ambiguity_plot <- ggplot(num_ambiguity_zeros, aes(x=sequences, fill=dataset)) + 
  geom_density(alpha=.3) +
  ylab("Density") + xlab(expression(atop("Sequences with more than", "50% gaps/ambiguity"))) +
  scale_fill_discrete(name = "Dataset", breaks = c("bad", "good"),
                      labels = c("Low-Quality", "High-Quality")) +
  theme(axis.title = element_text(size=20), axis.text = element_text(size = 14),
        panel.grid.major = element_blank(), panel.grid.minor = element_blank(), 
        panel.background = element_blank(), axis.line = element_line(colour = "black"),
        legend.title = element_text(size = 16), legend.text = element_text(size = 14))



#plotting them all together
ggarrange(constants_plot, parsimony_plot, composition_plot, ambiguity_plot,
          labels = c("A", "B", "C", "D"),
          ncol = 2, nrow = 2, align = "hv", font.label = list(size = 20), 
          common.legend = TRUE, legend = "right")



