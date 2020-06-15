# Notes for Chapter 3: putting together Dave's phylogenetics with Matt's transcriptomics

## Extracting phylogenetic signal and accounting for bias in whole-genome data sets supports the Ctenophora as sister to remaining Metazoa - Borowiec, Lee, Chiu, and Plachetzki

Phylogenetic factors to think about:
1. Transcriptomes are a bit fraught because they only represent what was being expressed at that moment, in that tissue. - "Because different tissues may express different paralogs with distinct evolutionary histories, inaccuracies in the assessment of orthologous groups across taxa could result from this approach."
2. Transcriptomes can also be quite sparse, as they are only accounting for expressed things.
3. Transcriptomes are sometimes contaminated with other taxa (which really applies to genomes also, so not sure why this is unique to transcriptomes).


Their basic process:
1. Compile 34 animal and 2 choanoflagellate genomes
2. Use highly accurate orthology prediction procedure and then stringent alignment filtering
3. Results in 1080 orthologous groups
4. Assess different measures for each data partition (content, saturation, rate of evolution, long-branch score, and taxon occupancy)
5. Explore how these characteristics impact phylogeny estimation
6. Use these data to make a reduced set of partitions (with optimal numbers in all these criteria)
7. These partitions can be subjected to all tree-making methods (incuding site-heterogenous models)

Long Branch Attraction:
1. They used several taxa with long branches and non-controversial placements and monitored where these fell out in the trees
2. tested the potential of outgroups and locus selection to induce topological artifacts

Specific categories of genes could support conflicting phylogenies?
- little evidence for a relationship between gene ontology and species topology

### Methods
1. Taxon selection
- looking for diversity of Metazoa but only with whole genomes
- included long-branching taxa (of known placement) to monitor LBA in the dataset as a whole
2. Orthology prediction
- OrthologID pipeline (uses MCL algorithm, has automated extraction of orthologs from gene trees)
- 26,612 orthogroups that contained at least 4 of the species
- selected orthogroups with at least 27 taxa - gives 1162 orthogroups
- they aligned these in MUSCLE and trimmed out taxa with poor sequence representation and gap-rich columns from the alignment
- they did ML tree estimation on each locus (!!)
- got rid of potentially spurious sequences (those with branch lengths more then 5 times longer than the average for the tree). Just an arbitrary cut off. This got rid of 211 sequences.
- also got rid of partitions that had more than 40% missing data, leaving 1080 orthogroups.
3. Gene ontology
- randomly chose one gene from each OG, blasted it, annotated it, and mapped it
- they found GO IDs and used Singular Enrichment Analyses and Fisher's Exact Test in agriGO to test them for enrichment against GO IDs from Arabidopsis (so it would be far enough away)
- also did the same enrichment analyses between individual bins of OGs and the whole metazoan dataset.
- used REVIGO to visualize
4. Gene trees, locus selection, and construction of the Best108 dataset
- used Phyutility to concatenate all multiple-gene matrices
- used MESQUITE to convert file formats
- estimated a tree for each of the 1080 alignments under ML in RAxML
- 200 bootstrap replicates for each gene tree
  1. Locus selection based on information content
  
  2. Taxon occupancy and missing data
  3. Saturation
  4. Long-branch score
  5. Rate of molecular evolution
  6. Construction of the Best108 matrix
5. Maximum likelihood analyses of partitioned datasets
6. Jackknife support in the Total1080 dataset
7. Bayesian analysis of concatenated datasets
8. Progressive concatenation and binned analyses
9. Estimating marginal likelihoods using stepping stone integration

### Results

- All analyses found Ctenophora as sister to remaining Metazoa (with varying support) including the Bayesian test of topology
