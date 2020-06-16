#! /bin/bash
#SBATCH --partition=macmanes,shared
#SBATCH -J goodorth
#SBATCH --output ortho.log
#SBATCH --mem 100Gb

module purge
module load linuxbrew/colsa

cd /mnt/lustre/macmaneslab/jlh1023/phylo_qual/actual_final/good/

orthofinder.py -a 24 -f for_orthofinder/ -t 24 -S diamond -M msa
