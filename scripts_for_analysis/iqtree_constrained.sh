#! /bin/bash
#SBATCH --partition=macmanes,shared
#SBATCH -J iqtree
#SBATCH --output iqtree_constrained5.log
#SBATCH --mem 100Gb
#SBATCH --exclude=node117,node118

module purge
module load linuxbrew/colsa

cd /mnt/lustre/macmaneslab/jlh1023/phylo_qual/actual_final/good/trees/

iqtree -s good39.phylip -m LG -g unrooted_correct.phy -pre iqtree_constrained5 -nt AUTO
