#! /bin/bash
#SBATCH --partition=macmanes,shared
#SBATCH -J Alligator_mississippiensis
#SBATCH --output Alligator_mississippiensis_report_223_TMP.log
#SBATCH --mem 115Gb
source ~/.profile

#-----------------------------------------------------------------------------------------------------------------------------------------------"
#---------------------- Variables --------------------------------------------------------------------------------------------------------------"
#-----------------------------------------------------------------------------------------------------------------------------------------------"

ORP_assembly=/mnt/lustre/macmaneslab/tml1019/transcriptomeData/expandedDataset/Alligator_mississippiensis/assemblies/Alligator_mississippiensis_ORP_223_TMP.ORP.fasta
spades55_assembly=/mnt/lustre/macmaneslab/tml1019/transcriptomeData/expandedDataset/Alligator_mississippiensis/assemblies/Alligator_mississippiensis_ORP_223_TMP.spades55.fasta
spades75_assembly=/mnt/lustre/macmaneslab/tml1019/transcriptomeData/expandedDataset/Alligator_mississippiensis/assemblies/Alligator_mississippiensis_ORP_223_TMP.spades75.fasta
transabyss_assembly=/mnt/lustre/macmaneslab/tml1019/transcriptomeData/expandedDataset/Alligator_mississippiensis/assemblies/Alligator_mississippiensis_ORP_223_TMP.transabyss.fasta
trinity_assembly=/mnt/lustre/macmaneslab/tml1019/transcriptomeData/expandedDataset/Alligator_mississippiensis/assemblies/Alligator_mississippiensis_ORP_223_TMP.trinity.Trinity.fasta

read1=rcorr/Alligator_mississippiensis_ORP_223_TMP.TRIM_1P.cor.fq
read2=rcorr/Alligator_mississippiensis_ORP_223_TMP.TRIM_2P.cor.fq

referenceGenome=/mnt/lustre/macmaneslab/tml1019/transcriptomeData/expandedDataset/Alligator_mississippiensis/ami_ref_ASM28112v4_chrUn.fa
refrenceAnnotation=/mnt/lustre/macmaneslab/tml1019/transcriptomeData/expandedDataset/Alligator_mississippiensis/Alligator_mississippiensis_refAno.gtf

echo "-----------------------------------------------------------------------------------------------------------------------------------------------"
echo "---------------------- BUSCO and TransRate ----------------------------------------------------------------------------------------------------"
echo "-----------------------------------------------------------------------------------------------------------------------------------------------"
echo ""
echo ""

module purge
module load anaconda/colsa

source activate orp-20190215
cd /mnt/lustre/macmaneslab/tml1019/transcriptomeData/expandedDataset/Alligator_mississippiensis

echo ""
echo "---------------------- ORP_assembly -----------------------------------------------------------------------------------------------------------"

/mnt/lustre/software/anaconda/colsa/envs/orp-20190215/local/src/Oyster_River_Protocol/report.mk main \
ASSEMBLY=$ORP_assembly \
LINEAGE=eukaryota_odb9 \
MEM=110 \
CPU=24 \
READ1=$read1 \
READ2=$read2 \
RUNOUT=Alligator_mississippiensis_ORP_BUSCO_TransRate_Report_223_TMP

echo ""
echo "---------------------- spade55_assembly -------------------------------------------------------------------------------------------------------"
/mnt/lustre/software/anaconda/colsa/envs/orp-20190215/local/src/Oyster_River_Protocol/report.mk main \
ASSEMBLY=$spades55_assembly \
LINEAGE=eukaryota_odb9 \
MEM=110 \
CPU=24 \
READ1=$read1 \
READ2=$read2 \
RUNOUT=Alligator_mississippiensis_spades55_BUSCO_TransRate_Report_223_TMP

echo ""
echo "---------------------- spade75_assembly -------------------------------------------------------------------------------------------------------"
/mnt/lustre/software/anaconda/colsa/envs/orp-20190215/local/src/Oyster_River_Protocol/report.mk main \
ASSEMBLY=$spades75_assembly \
LINEAGE=eukaryota_odb9 \
MEM=110 \
CPU=24 \
READ1=$read1 \
READ2=$read2 \
RUNOUT=Alligator_mississippiensis_spades75_BUSCO_TransRate_Report_223_TMP

echo ""
echo "---------------------- transabyss_assembly ----------------------------------------------------------------------------------------------------"

/mnt/lustre/software/anaconda/colsa/envs/orp-20190215/local/src/Oyster_River_Protocol/report.mk main  \
ASSEMBLY=$transabyss_assembly \
LINEAGE=eukaryota_odb9 \
MEM=110 \
CPU=24 \
READ1=$read1 \
READ2=$read2 \
RUNOUT=Alligator_mississippiensis_transabyss_BUSCO_TransRate_Report_223_TMP

echo ""
echo "---------------------- trinity_assembly -------------------------------------------------------------------------------------------------------"

/mnt/lustre/software/anaconda/colsa/envs/orp-20190215/local/src/Oyster_River_Protocol/report.mk main \
ASSEMBLY=$trinity_assembly \
LINEAGE=eukaryota_odb9 \
MEM=110 \
CPU=24 \
READ1=$read1 \
READ2=$read2 \
RUNOUT=Alligator_mississippiensis_trinity_BUSCO_TransRate_Report_223_TMP

echo ""
echo ""
echo ""

echo "COMPLETED!"
