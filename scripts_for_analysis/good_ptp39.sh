#! /bin/bash
#SBATCH --partition=macmanes,shared
#SBATCH -J ptp39
#SBATCH --output ptp39.log
#SBATCH --mem 100Gb

#this is an example of the PhyloTreePruner wrapper that Dave Plachetzki originally sent me, and I modified extensively to fit
#the needs of the project. This one is for the final high-quality dataset, so paths and names would need to be changed for a different dataset.

module purge
module load linuxbrew/colsa

cd /mnt/lustre/macmaneslab/jlh1023/phylo_qual/actual_final/good/ptp_runs/

#We want to run PhyloTree Pruner but have too many orthogroups, so we filter them down based on how many missing taxa they have.
#use get_og_list_min_taxa.py to filter down the orthogroup list, and then pull_alignments.py to get the alignments in their own di$

/mnt/lustre/macmaneslab/jlh1023/pipeline_dev/pipeline_scripts/get_og_list_min_taxa.py \
-c /mnt/lustre/macmaneslab/jlh1023/phylo_qual/actual_final/good/for_orthofinder/OrthoFinder/Results_Oct15/Orthogroups/Orthogroups.GeneCount.tsv \
-o /mnt/lustre/macmaneslab/jlh1023/phylo_qual/actual_final/good/ptp_runs/passing_og_names39.txt \
-m 0

/mnt/lustre/macmaneslab/jlh1023/pipeline_dev/pipeline_scripts/pull_alignments.py \
-l /mnt/lustre/macmaneslab/jlh1023/phylo_qual/actual_final/good/ptp_runs/passing_og_names39.txt \
-a /mnt/lustre/macmaneslab/jlh1023/phylo_qual/actual_final/good/for_orthofinder/OrthoFinder/Results_Oct15/MultipleSequenceAlignments/ \
-n /mnt/lustre/macmaneslab/jlh1023/phylo_qual/actual_final/good/ptp_runs/top_alignments39/


#now I have to pull out the trees that correspond to the alignments

mkdir /mnt/lustre/macmaneslab/jlh1023/phylo_qual/actual_final/good/ptp_runs/top_trees39

for file in /mnt/lustre/macmaneslab/jlh1023/phylo_qual/actual_final/good/ptp_runs/top_alignments39/*.fa
do
    fanamepath=${file%.fa}
    faname=${fanamepath##*/}
    #echo $faname
        if [ -s /mnt/lustre/macmaneslab/jlh1023/phylo_qual/actual_final/good/for_orthofinder/OrthoFinder/Results_Oct15/Gene_Trees/${faname}_tree.txt ]
        treefile=/mnt/lustre/macmaneslab/jlh1023/phylo_qual/actual_final/good/for_orthofinder/OrthoFinder/Results_Oct15/Gene_Trees/${faname}_tree.txt
        then cp $treefile /mnt/lustre/macmaneslab/jlh1023/phylo_qual/actual_final/good/ptp_runs/top_trees39
        fi
done

#and run PhyloTree Pruner on the desired OGs

parallel -j14 --xapply 'PhyloTreePruner {1} 10 {2} 0.5 u' :::  \
/mnt/lustre/macmaneslab/jlh1023/phylo_qual/actual_final/good/ptp_runs/top_trees39/*_tree.txt :::  \
/mnt/lustre/macmaneslab/jlh1023/phylo_qual/actual_final/good/ptp_runs/top_alignments39/*.fa

mkdir /mnt/lustre/macmaneslab/jlh1023/phylo_qual/actual_final/good/ptp_runs/pruned39; \
mv /mnt/lustre/macmaneslab/jlh1023/phylo_qual/actual_final/good/ptp_runs/top_alignments39/*pruned* \
/mnt/lustre/macmaneslab/jlh1023/phylo_qual/actual_final/good/ptp_runs/pruned39/

#align pruned OGs

parallel -j14 'mafft --auto {} > {.}_aln'  ::: /mnt/lustre/macmaneslab/jlh1023/phylo_qual/actual_final/good/ptp_runs/pruned39/*.fa

#trim alignments

parallel -j14 '/mnt/lustre/macmaneslab/jlh1023/pipeline_dev/pipeline_scripts/gblocks_wrapper.pl {}' ::: \
/mnt/lustre/macmaneslab/jlh1023/phylo_qual/actual_final/good/ptp_runs/pruned39/*_aln

rm /mnt/lustre/macmaneslab/jlh1023/phylo_qual/actual_final/good/ptp_runs/pruned39/*.htm

sed -i 's/\ //g' /mnt/lustre/macmaneslab/jlh1023/phylo_qual/actual_final/good/ptp_runs/pruned39/*gb

#change the names of the files to the names of the mouse transcripts in the alignment

/mnt/lustre/macmaneslab/jlh1023/pipeline_dev/pipeline_scripts/mouse_names.py \
-i /mnt/lustre/macmaneslab/jlh1023/phylo_qual/actual_final/good/ptp_runs/pruned39/

#cut off OG idenfier, leaving only species label so that seqCat can concatenate

parallel -j14 'cut -f1 -d"_" {} > {.}_rename' ::: \
/mnt/lustre/macmaneslab/jlh1023/phylo_qual/actual_final/good/ptp_runs/pruned39/Mus*

/mnt/lustre/macmaneslab/jlh1023/pipeline_dev/pipeline_scripts/no_empty_files.py \
-d /mnt/lustre/macmaneslab/jlh1023/phylo_qual/actual_final/good/ptp_runs/pruned39/ \
-l /mnt/lustre/macmaneslab/jlh1023/phylo_qual/actual_final/good/ptp_runs/passing_files39.txt \
-n /mnt/lustre/macmaneslab/jlh1023/phylo_qual/actual_final/good/ptp_runs/passing_files39/

#concatenate all OGs into single nexus

/mnt/lustre/macmaneslab/jlh1023/pipeline_dev/pipeline_scripts/seqCat.pl \
-d/mnt/lustre/macmaneslab/jlh1023/phylo_qual/actual_final/good/ptp_runs/passing_files39.txt

#rename nexus into something informative

mv /mnt/lustre/macmaneslab/jlh1023/phylo_qual/actual_final/good/ptp_runs/seqCat_sequences.nex \
/mnt/lustre/macmaneslab/jlh1023/phylo_qual/actual_final/good/ptp_runs/good39.nex
