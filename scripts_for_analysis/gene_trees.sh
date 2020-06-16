#! /bin/bash
#SBATCH --partition=macmanes,shared
#SBATCH -J genetree
#SBATCH --output gene_trees.log
#SBATCH --mem 100Gb

module purge
module load linuxbrew/colsa

#converting all of the ogs that are the same in good and bad datasets to phylips and then making trees out of them.

parallel -j4 '/mnt/lustre/macmaneslab/jlh1023/pipeline_dev/pipeline_scripts/seq_converter.pl -d{} -ope' ::: \
/mnt/lustre/macmaneslab/jlh1023/phylo_qual/actual_final/good/ptp_runs/passing_files39/*_rename

parallel -j4 'iqtree -s {} -m LG -nt 6' ::: \
/mnt/lustre/macmaneslab/jlh1023/phylo_qual/actual_final/good/ptp_runs/passing_files39/*.phylip
