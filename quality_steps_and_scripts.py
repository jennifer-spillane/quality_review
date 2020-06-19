## Scripts used in the quality paper analyses:

### For assembly of transcriptome reads:

1. Change headers to remove spaces.
 > fix_headers

2. Assemble paired-end reads - example script
 > Alligator_mississippiensis.sh

3. Calculate quality scores - example script
 > Alligator_mississippiensis_reportmk.sh

4. Separate the highest-scoring assemblies and the lowest-scoring assemblies. At this point add the Mus musculus reference transcriptome into both datasets.  

4. Run TransDecoder on the two sets of assemblies - example script
 > decoder.sh

5. Pull all ".pep" files into a directory for orthofinder.


### For finding orthogroups and creating partitions:

1. Run orthofinder on each set of amino acids
 > orthofind.sh

2. Run the PhyloTreePruner script on the orthofinder output  
 > good_ptp39.sh   

 This script contains others:
 - get_og_list_min_taxa.py - generates a list of orthogroup names that have a certain number (or less) of missing taxa  
 - pull_alignments.py - takes a list of orthogroup names and extracts alignments that match them from a directory of lots of alignments  
 - gblocks_wrapper.pl - runs Gblocks on an alignment  
 - mouse_names.py - renames the alignment files so that they are named for the mouse reference transcript they contain   
 - no_empty_files.py - gets rid of alignments that have been pruned so that they no longer include all taxa  
 - seq_cat.pl - concatenates all of the alignments into one large one   

 - to convert this ending nexus file into a phylip one, use the script:  
 > seq_converter.pl

3. To assess the length of the partitions:  
 > alignment_length.py  

4. To assess the length of the partitions before Gblocks filtering run this script and then the above one:  
 > pre_gb_mouse_names.py  

5. To determine which partitions are common to both datasets and which are unique:  
 > same_data.py  

6. To create a constrained tree with the most up to date vertebrate phylogeny:  
 - Get any tree with all species on it
 - Use Mequite to move taxa into the correct positions and export the tree  
 - Use R to unroot the tree from Mequite - unrooting_tree.R  
 - Use IQTREE to combine the lengths of the branches from the high-quality dataset (phylip file from the concatenated partitions) with the topology of the tree from Mesquite: iqtree_constrained.sh


### For making gene trees and investigating them:  

1. Make the gene trees  
 > gene_trees.sh  

2. Get tree consistency values  
 - concatenate all gene trees in the relevant group together  
 - then to calculate the values:
  > raxmlHPC-PTHREADS-SSE3 -f i -m PROTGAMMAWAG -t correct_tree_branches.tre -z all_gene_trees.tre -n tc_ic  

3. Get Robinson-Foulds distances  
 - download the file with all gene trees and the constraint tree
 - use these in the tree_dist_edits.R script  

4. Get gene tree stats from iqtree files  
 - For getting measures of composition test failure and ambiguity (and alignment length) from log files: iqtree_log_stats.py   
 - For getting measures of comstant sites and parsimony-informative sites (and alighment length) from info files: iqtree_info_stats.py  
