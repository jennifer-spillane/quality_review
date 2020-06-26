
#results for data quality paper
#last modified: 6-25-20




################################################################################################################
################################################################################################################
########################################################
# Figure 2 - Orthofinder info: scatter plots and density plots of busco and transrate scores
########################################################
################################################################################################################
################################################################################################################


####################################################################################
#orthogroup stats plots
###############################################################

setwd("~/Desktop/Analyses/quality")

##########################################################################################
#doing a linear regression between busco score and number of orthogroups for each species

#good dataset
##############################

good_scores <- read.csv("good_busco_ortho.csv")
#visualizing things
#scatterplot to check for linear relationship
scatter.smooth(x = good_scores$busco, y = good_scores$total_orthos, 
               main = "Number of orthos ~ busco score")
#boxplots to check for outliers
par(mfrow = c(1, 2))
boxplot(good_scores$busco, main = "busco score",
        sub = paste("outlier rows: ", boxplot.stats(good_scores$busco)$out))
boxplot(good_scores$total_orthos, main = "number of orthogroups",
        sub = paste("outlier rows: ", boxplot.stats(good_scores$total_orthos)$out))
#density plots to look at normality
#install.packages("e1071")
library(e1071)
plot(density(good_scores$busco), main = "density plot: busco scores",
     ylab = "frequency", 
     sub = paste("skewness: ", round(e1071::skewness(good_scores$busco), 2)))
plot(density(good_scores$total_orthos), main = "density plot: number of orthogroups",
     ylab = "frequency", 
     sub = paste("skewness: ", round(e1071::skewness(good_scores$total_orthos), 2)))

#calculating the correlation between the variables
cor(good_scores$busco, good_scores$total_orthos)
#0.6228352

#linear regression
num_orthos_by_busco <- lm(total_orthos ~ busco, data = good_scores)
num_orthos_by_busco
#Coefficients:
#  (Intercept)        busco  
#4636.39        62.61 

summary(num_orthos_by_busco)
#Residual standard error: 1060 on 36 degrees of freedom
#Multiple R-squared:  0.3879,	Adjusted R-squared:  0.3709 
#F-statistic: 22.82 on 1 and 36 DF,  p-value: 2.967e-05


#bad dataset
##############################

bad_scores <- read.csv("bad_busco_ortho.csv")
#visualizing things
#scatterplot to check for linear relationship
par(mfrow = c(1, 1))
scatter.smooth(x = bad_scores$busco, y = bad_scores$total_orthos, 
               main = "Number of orthos ~ busco score")
#boxplots to check for outliers
par(mfrow = c(1, 2))
boxplot(bad_scores$busco, main = "busco score",
        sub = paste("outlier rows: ", boxplot.stats(bad_scores$busco)$out))
boxplot(bad_scores$total_orthos, main = "number of orthogroups",
        sub = paste("outlier rows: ", boxplot.stats(bad_scores$total_orthos)$out))
#density plots to look at normality
#install.packages("e1071")
library(e1071)
plot(density(bad_scores$busco), main = "density plot: busco scores",
     ylab = "frequency", 
     sub = paste("skewness: ", round(e1071::skewness(bad_scores$busco), 2)))
plot(density(bad_scores$total_orthos), main = "density plot: number of orthogroups",
     ylab = "frequency", 
     sub = paste("skewness: ", round(e1071::skewness(bad_scores$total_orthos), 2)))

#calculating the correlation between the variables
cor(bad_scores$busco, bad_scores$total_orthos)
#0.8775629

#linear regression
bad_num_orthos_by_busco <- lm(total_orthos ~ busco, data = bad_scores)
bad_num_orthos_by_busco
#Coefficients:
#  (Intercept)        busco  
#2293.96        86.25

summary(bad_num_orthos_by_busco)
#Residual standard error: 1049 on 36 degrees of freedom
#Multiple R-squared:  0.7701,	Adjusted R-squared:  0.7637 
#F-statistic: 120.6 on 1 and 36 DF,  p-value: 4.8e-13



####################################################################################
#doing a linear regression between transrate score and number of orthogroups for each species

#good dataset
##############################

good_scores <- read.csv("good_busco_ortho.csv")
#visualizing things
#scatterplot to check for linear relationship
par(mfrow = c(1, 1))
scatter.smooth(x = good_scores$transrate, y = good_scores$total_orthos, 
               main = "Number of orthos ~ transrate score")
#boxplots to check for outliers
par(mfrow = c(1, 2))
boxplot(good_scores$transrate, main = "transrate score",
        sub = paste("outlier rows: ", boxplot.stats(good_scores$transrate)$out))
boxplot(good_scores$total_orthos, main = "number of orthogroups",
        sub = paste("outlier rows: ", boxplot.stats(good_scores$total_orthos)$out))
#density plots to look at normality
#install.packages("e1071")
library(e1071)
plot(density(good_scores$transrate), main = "density plot: transrate scores",
     ylab = "frequency", 
     sub = paste("skewness: ", round(e1071::skewness(good_scores$transrate), 2)))
plot(density(good_scores$total_orthos), main = "density plot: number of orthogroups",
     ylab = "frequency", 
     sub = paste("skewness: ", round(e1071::skewness(good_scores$total_orthos), 2)))

#calculating the correlation between the variables
cor(good_scores$transrate, good_scores$total_orthos)
#0.1311264

#linear regression
num_orthos_by_transrate <- lm(total_orthos ~ transrate, data = good_scores)
num_orthos_by_transrate
#Coefficients:
#  (Intercept)    transrate  
#9027         1589 

summary(num_orthos_by_transrate)
#not significant
#Residual standard error: 1344 on 36 degrees of freedom
#Multiple R-squared:  0.01719,	Adjusted R-squared:  -0.01011 
#F-statistic: 0.6298 on 1 and 36 DF,  p-value: 0.4326


#bad dataset
##############################

bad_scores <- read.csv("bad_busco_ortho.csv")
#visualizing things
#scatterplot to check for linear relationship
par(mfrow = c(1, 1))
scatter.smooth(x = bad_scores$transrate, y = bad_scores$total_orthos, 
               main = "Number of orthos ~ transrate score")
#boxplots to check for outliers
par(mfrow = c(1, 2))
boxplot(bad_scores$transrate, main = "transrate score",
        sub = paste("outlier rows: ", boxplot.stats(bad_scores$transrate)$out))
boxplot(bad_scores$total_orthos, main = "number of orthogroups",
        sub = paste("outlier rows: ", boxplot.stats(bad_scores$total_orthos)$out))
#density plots to look at normality
#install.packages("e1071")
library(e1071)
plot(density(bad_scores$transrate), main = "density plot: transrate scores",
     ylab = "frequency", 
     sub = paste("skewness: ", round(e1071::skewness(bad_scores$transrate), 2)))
plot(density(bad_scores$total_orthos), main = "density plot: number of orthogroups",
     ylab = "frequency", 
     sub = paste("skewness: ", round(e1071::skewness(bad_scores$total_orthos), 2)))

#calculating the correlation between the variables
cor(bad_scores$transrate, bad_scores$total_orthos)
#-0.1114769

#linear regression
bad_num_orthos_by_transrate <- lm(total_orthos ~ transrate, data = bad_scores)
bad_num_orthos_by_transrate
#Coefficients:
#  (Intercept)    transrate  
#9709        -5832

summary(bad_num_orthos_by_transrate)
#not significant
#Residual standard error: 2174 on 36 degrees of freedom
#Multiple R-squared:  0.01243,	Adjusted R-squared:  -0.01501 
#F-statistic: 0.453 on 1 and 36 DF,  p-value: 0.5052




####################################################################################
#doing a linear regression between transcript number and number of orthogroups for each species

############################
#good dataset

good_scores <- read.csv("good_busco_ortho.csv")
#visualizing things
#scatterplot to check for linear relationship
par(mfrow = c(1, 1))
scatter.smooth(x = good_scores$transcripts, y = good_scores$total_orthos, 
               main = "Number of orthos ~ num transcripts")
#boxplots to check for outliers
par(mfrow = c(1, 2))
boxplot(good_scores$transcripts, main = "transcripts",
        sub = paste("outlier rows: ", boxplot.stats(good_scores$transcripts)$out))
boxplot(good_scores$total_orthos, main = "number of orthogroups",
        sub = paste("outlier rows: ", boxplot.stats(good_scores$total_orthos)$out))
#density plots to look at normality
#install.packages("e1071")
library(e1071)
plot(density(good_scores$transcripts), main = "density plot: transcripts",
     ylab = "frequency", 
     sub = paste("skewness: ", round(e1071::skewness(good_scores$transcripts), 2)))
plot(density(good_scores$total_orthos), main = "density plot: number of orthogroups",
     ylab = "frequency", 
     sub = paste("skewness: ", round(e1071::skewness(good_scores$total_orthos), 2)))

#calculating the correlation between the variables
cor(good_scores$transcripts, good_scores$total_orthos)
#0.5302894

#linear regression
good_num_orthos_by_transcripts <- lm(total_orthos ~ transcripts, data = good_scores)
good_num_orthos_by_transcripts
#Coefficients:
#  (Intercept)  transcripts  
#8.660e+03    6.103e-03

summary(good_num_orthos_by_transcripts)
#significant
#Residual standard error: 1149 on 36 degrees of freedom
#Multiple R-squared:  0.2812,	Adjusted R-squared:  0.2612 
#F-statistic: 14.08 on 1 and 36 DF,  p-value: 0.000616




#bad dataset
##############################

bad_scores <- read.csv("bad_busco_ortho.csv")
#visualizing things
#scatterplot to check for linear relationship
par(mfrow = c(1, 1))
scatter.smooth(x = bad_scores$transcripts, y = bad_scores$total_orthos, 
               main = "Number of orthos ~ num transcripts")
#boxplots to check for outliers
par(mfrow = c(1, 2))
boxplot(bad_scores$transcripts, main = "transcripts",
        sub = paste("outlier rows: ", boxplot.stats(bad_scores$transcripts)$out))
boxplot(bad_scores$total_orthos, main = "number of orthogroups",
        sub = paste("outlier rows: ", boxplot.stats(bad_scores$total_orthos)$out))
#density plots to look at normality
#install.packages("e1071")
library(e1071)
plot(density(bad_scores$transcripts), main = "density plot: transcripts",
     ylab = "frequency", 
     sub = paste("skewness: ", round(e1071::skewness(bad_scores$transcripts), 2)))
plot(density(bad_scores$total_orthos), main = "density plot: number of orthogroups",
     ylab = "frequency", 
     sub = paste("skewness: ", round(e1071::skewness(bad_scores$total_orthos), 2)))

#calculating the correlation between the variables
cor(bad_scores$transcripts, bad_scores$total_orthos)
#0.4881242

#linear regression
bad_num_orthos_by_transcripts <- lm(total_orthos ~ transcripts, data = bad_scores)
bad_num_orthos_by_transcripts
#Coefficients:
#  (Intercept)  transcripts  
#7.256e+03    4.651e-03

summary(bad_num_orthos_by_transcripts)
#significant
#Residual standard error: 1909 on 36 degrees of freedom
#Multiple R-squared:  0.2383,	Adjusted R-squared:  0.2171 
#F-statistic: 11.26 on 1 and 36 DF,  p-value: 0.001877



#############################################################################################
#Using both datasets' data to look at differences in distributions
########################################################################


library(ggplot2)

#read in the data - and don't be fooled by the name, it also contains transrate scores and numbers of transcripts
all_scores <- read.csv("all_busco_ortho.csv")

#############################################################
#Transrate

ggplot(all_scores, aes(x=transrate, fill=dataset)) + 
  geom_density(alpha=.3)

#are the distributions significantly different?
wilcox.test(transrate ~ dataset, data=all_scores)
#W = 2, p-value < 2.2e-16



####################################################################
#Busco

ggplot(all_scores, aes(x=busco, fill=dataset)) + 
  geom_density(alpha=.3)

#are the distributions significantly different?
wilcox.test(busco ~ dataset, data=all_scores)
#W = 609, p-value = 0.2424



####################################################################
#Transcripts

ggplot(all_scores, aes(x=transcripts, fill=dataset)) + 
  geom_density(alpha=.3)

#are the distributions significantly different?
wilcox.test(transcripts ~ dataset, data=all_scores)
#W = 1038, p-value = 0.0008607





################################################################################################################
################################################################################################################
########################################################
#Analysis for Figure 3 - Partition info: venn diagram of partition numbers and density plots of alignment lengths
########################################################
################################################################################################################
################################################################################################################


library(VennDiagram)

setwd("~/Desktop/Analyses/quality")


grid.newpage()
part_num <- draw.pairwise.venn(2016, 408, 332, cex = 0, euler.d = TRUE,
                   fill = c("darkslategray2", "rosybrown2"), scaled = TRUE)

part_num

##################################################################################
#looking at alignment lengths
################################################################

yaxis = c(0, 550)
xaxis = "Length of Alignment"


good_lengths <- read.delim("good38_aln_lengths.txt", header=FALSE, stringsAsFactors=FALSE)

hist(good_lengths$V2, breaks = 40, main = "Alignment lengths for Good dataset",
     ylim = yaxis, xlab = xaxis)

bad_lengths <- read.delim("bad38_aln_lengths.txt", header=FALSE, stringsAsFactors=FALSE)

hist(bad_lengths$V2, breaks = 40, main = "Alignment lengths for Bad dataset", 
     ylim = yaxis, xlab = xaxis)

###pre-gblocks versions

pre_good_lengths <- read.delim("no_gb_good38_aln_lengths.txt", header=FALSE, stringsAsFactors=FALSE)
pre_bad_lengths <- read.delim("no_gb_bad38_aln_lengths.txt", header=FALSE, stringsAsFactors=FALSE)

hist(pre_good_lengths$V2, breaks = 40, main = "Alignment lengths for Bad dataset", 
     ylim = yaxis, xlab = xaxis)

hist(pre_bad_lengths$V2, breaks = 40, main = "Alignment lengths for Bad dataset", 
     ylim = yaxis, xlab = xaxis)


##########ggplot versions
library(ggplot2)

post_len <- read.csv("all_post_gb_lengths.csv")
pre_len <- read.csv("all_pre_gb_lengths.csv")

#are the distributions significantly different?
#pre gblocks:
wilcox.test(length ~ dataset, data=pre_len)
#W = 426870, p-value = 0.01686
#They are significantly different

#post gblocks
wilcox.test(length ~ dataset, data=post_len)
#W = 407790, p-value = 0.7878
#they are not significantly different



# Density plots with semi-transparent fill
ggplot(post_len, aes(x=length, fill=dataset)) + geom_density(alpha=.3) 

ggplot(pre_len, aes(x=length, fill=dataset)) + geom_density(alpha=.3) 





################################################################################################################
################################################################################################################
########################################################
#Analysis for Figure 4 - Correct tree with ICA numbers on the nodes, density plot of ICA scores
########################################################
################################################################################################################
################################################################################################################


########################################################
#density plot of ica values

ica <- read.csv("ica_scores.csv")

ggplot(ica, aes(x=ica_value, fill=dataset)) + 
  geom_density(alpha=.3) 

#Wilcoxon rank sum test
wilcox.test(ica_value ~ dataset, data=ica) 
#data:  ica_value by dataset
#W = 550.5, p-value = 0.47
#the distributions are NOT significantly different




###################################################################################
#Density plot of ICA values for only the partitions the datasets have in common

com_ica <- read.csv("common_ica_scores.csv")

ggplot(com_ica, aes(x=ica_value, fill=dataset)) + 
  geom_density(alpha=.3) 

#Wilcoxon rank sum test
wilcox.test(ica_value ~ dataset, data=com_ica)
#W = 612, p-value = 0.6893
#alternative hypothesis: true location shift is not equal to 0




################################################################################################################
################################################################################################################
########################################################
#Analyses for Figure 6 - RF distances: symmetric difference density plot
########################################################
################################################################################################################
################################################################################################################

# Density plots with semi-transparent fill
sym_dif <- read.csv("~/Desktop/Analyses/quality/all_symmetric_dif.csv")
ggplot(sym_dif, aes(x=dif, fill=dataset)) + geom_density(alpha=.3)

#Wilcoxon rank sum test
wilcox.test(dif ~ dataset, data=sym_dif) 
#data:  dif by dataset
#W = 457260, p-value = 0.0003334
#the distributions are significantly different


#common rf distances

# Density plots with semi-transparent fill
common_dist <- read.csv("~/Desktop/Analyses/quality/all_common_rfdistances.csv")
ggplot(common_dist, aes(x=dist, fill=dataset)) + geom_density(alpha=.3)

#Wilcoxon rank sum test
wilcox.test(dist ~ dataset, data=common_dist) 
#W = 60489, p-value = 0.02948
#alternative hypothesis: true location shift is not equal to 0

