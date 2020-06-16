#! /bin/bash
#SBATCH --partition=macmanes,shared
#SBATCH -J Alligator_mississippiensis
#SBATCH --output Alligator_mississippiensis_223_TMP.log
#SBATCH --mem 115Gb
source ~/.profile

module purge
module load anaconda/colsa

source activate orp-20190215
cd /mnt/lustre/macmaneslab/tml1019/transcriptomeData/expandedDataset/Alligator_mississippiensis


oyster.mk main \
TMP_FILT=1 \
STRAND=RF \
MEM=110 \
CPU=24 \
READ1=Alligator_mississippiensis_1.fastq \
READ2=Alligator_mississippiensis_2.fastq \
RUNOUT=Alligator_mississippiensis_ORP_223_TMP
