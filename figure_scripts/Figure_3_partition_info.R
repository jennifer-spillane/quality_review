################################################################################################################
################################################################################################################
########################################################
#Analysis for Figure 3 - Partition info: venn diagram of partition numbers and density plots of alignment lengths
########################################################
################################################################################################################
################################################################################################################

setwd("~/Desktop/Analyses/quality")
library(ggplot2)

post_len <- read.csv("all_post_gb_lengths.csv")
pre_len <- read.csv("all_pre_gb_lengths.csv")


# Density plots with semi-transparent fill
postgb <- ggplot(post_len, aes(x=length, fill=dataset)) + geom_density(alpha=.3) +
  ylab("Density") + xlab("Alignment Length Post Gblocks") + 
  ylim(0, 0.002) + 
  theme(axis.title.x = element_text(size=30), axis.text = element_text(size = 24),
        axis.title.y = element_blank(),
        panel.grid.major = element_blank(), panel.grid.minor = element_blank(), 
        panel.background = element_blank(), axis.line = element_line(colour = "black"),
        legend.title = element_text(size = 16), legend.text = element_text(size = 14))

postgb


pregb <- ggplot(pre_len, aes(x=length, fill=dataset)) + geom_density(alpha=.3) +
  ylab("Density") + xlab("Alignment Length Pre Gblocks") +
  ylim(0, 0.002) +
  theme(axis.title = element_text(size=30), axis.text = element_text(size = 24),
        panel.grid.major = element_blank(), panel.grid.minor = element_blank(), 
        panel.background = element_blank(), axis.line = element_line(colour = "black"),
        legend.title = element_text(size = 16), legend.text = element_text(size = 14))

pregb


########################################################
#putting the plots together - plots I am interested in are pregb and postgb
########################################################


ggarrange(pregb, postgb, 
          labels = c("A", "B"),
          ncol = 2, nrow = 1, common.legend = TRUE, legend = "right",
          align = "h", font.label = list(size = 30))



########################################################
#proportional venn diagram
########################################################

grid.newpage()
part_num <- draw.pairwise.venn(2016, 408, 332, cex = 0, euler.d = TRUE,
                               fill = c("darkslategray2", "rosybrown2"), scaled = TRUE)

part_num

