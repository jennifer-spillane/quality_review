#! /bin/bash
#SBATCH --partition=macmanes,shared
#SBATCH -J ast_good
#SBATCH --output astral_common_good.log
#SBATCH --mem 120000
#SBATCH --exclude=node117,node118

module purge
module load linuxbrew/colsa

cd /mnt/lustre/macmaneslab/jlh1023/phylo_qual/actual_final/good/trees/

java -jar /mnt/lustre/macmaneslab/jlh1023/Astral/astral.5.7.4.jar -i all_good_common_gene_trees.tre -o common_good_astral.tre
