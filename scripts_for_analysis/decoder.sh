#! /bin/bash
#SBATCH --partition=macmanes,shared
#SBATCH -J decode
#SBATCH --output decode.log
#SBATCH --mem 100Gb

module purge
module load linuxbrew/colsa

cd /mnt/lustre/macmaneslab/jlh1023/phylo_qual/actual_final/good/assemblies/

TransDecoder.LongOrfs -t Gallus_gallus_ORP_223_TMP.ORP.fasta
TransDecoder.LongOrfs -t Lethenteron_camtschaticum_ORP_223_ReRunPOST_TMP.transabyss.fasta
TransDecoder.LongOrfs -t Lepidophyma_flavimaculatum_ORP_223_TMP.transabyss.fasta
TransDecoder.LongOrfs -t Trachemys_scripta_ORP_223_ReRunPOST_TMP.spades55.fasta
TransDecoder.LongOrfs -t Lepisosteus_oculatus_ORP_223_ReRunPOST_TMP.transabyss.fasta

TransDecoder.Predict -t Gallus_gallus_ORP_223_TMP.ORP.fasta
TransDecoder.Predict -t Lethenteron_camtschaticum_ORP_223_ReRunPOST_TMP.transabyss.fasta
TransDecoder.Predict -t Lepidophyma_flavimaculatum_ORP_223_TMP.transabyss.fasta
TransDecoder.Predict -t Trachemys_scripta_ORP_223_ReRunPOST_TMP.spades55.fasta
TransDecoder.Predict -t Lepisosteus_oculatus_ORP_223_ReRunPOST_TMP.transabyss.fasta

# a sample transdecoder script - this one was for five species added after initial testing
