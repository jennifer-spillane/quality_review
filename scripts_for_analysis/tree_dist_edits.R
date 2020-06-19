#some tree distance calculations from individual gene trees to a constraint tree.
#Last modified 4-24-20 


#load libraries
library("ape")
library("phangorn")
library("ggplot2")

#set working directory.
setwd("~/Desktop/Analyses/quality")

#read trees in - correct_tree_branches.tre is the constraint tree.
#bad_gene_trees.tre is all of the low-quality gene trees concattenated together.
#good_gene_trees.tre is all of the high-quality gene trees concattenated together.
constraint_tree<- read.tree("correct_tree_branches.tre")
bad_parts_trees<-read.tree("bad_gene_trees.tre")
good_parts_trees<-read.tree("good_gene_trees.tre")

#calculating Robinson-Foulds distances 
bad_rf_dist <- RF.dist(bad_parts_trees, constraint_tree)
good_rf_dist <- RF.dist(good_parts_trees, constraint_tree)




########################################
#just the gene trees from the partitions common to both datasets
############################

#read trees just as before

bad_common_trees <- read.tree("bad_common_gene_trees.tre")
good_common_trees <- read.tree("good_common_gene_trees.tre")

#calculate distances
bad_common_rf_dists <- RF.dist(bad_common_trees, correct_tree)
good_common_rf_dists <- RF.dist(good_common_trees, correct_tree)



########################################
#basic plotting and checking for differences in distributions
############################


##########################################
#density plot of symmetric differences

#making the csv files
write.table(good_rf_dist, file = "good_symmetric_dif.csv", sep = ",", row.names = F)
write.table(bad_rf_dist, file = "bad_symmetric_dif.csv", sep = ",", row.names = F)
#I then combined them just using excel - also fixed the headers and put in the dataset info

# Density plots with semi-transparent fill
sym_dif <- read.csv("~/Desktop/Analyses/quality/all_symmetric_dif.csv")
ggplot(sym_dif, aes(x=dif, fill=dataset)) + geom_density(alpha=.3)

#Wilcoxon rank sum test
wilcox.test(dif ~ dataset, data=sym_dif) 
#data:  dif by dataset
#W = 457260, p-value = 0.0003334
#the distributions are significantly different






##########################################
#Common partitions rf distances

#density plot of common RF distances

#making the csv files
write.table(common_good_distances, file = "common_good_rfdistances.csv", sep = ",", row.names = F)
write.table(common_bad_distances, file = "common_bad_rfdistances.csv", sep = ",", row.names = F)
#I then combined them just using excel - also fixed the headers and put in the dataset info


# Density plots with semi-transparent fill
common_dist <- read.csv("~/Desktop/Analyses/quality/all_common_rfdistances.csv")
ggplot(common_dist, aes(x=dist, fill=dataset)) + geom_density(alpha=.3)

#Wilcoxon rank sum test
wilcox.test(dist ~ dataset, data=common_dist) 
#W = 60489, p-value = 0.02948
#the distributions are significantly different 
