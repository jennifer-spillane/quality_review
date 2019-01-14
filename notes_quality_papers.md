# Notes for phylogenomic data quality chapter

This chapter will start with a review of data quality in phylogenomics, the ways people have been thinking about it historically, and the metrics they've used. Then talking about the parts of data quality that they haven't been considering as much (contamination, assembly quality), and trying to demonstrate that you can get different results/relationships if you do not consider these things.

### TransRate: reference free quality assessment of de-novo transcriptome assemblies (2016)

Richard Smith-Unna, Chris Boursnell, Rob Patro, Julian M Hibberd, and Steven Kelly

- transrate is a tool we can use to evaluate de novo transcriptome assemblies
- all you need is the assembly and the reads
- previously the only way to evaluate was with a reference genome
- RSEM_eval is another program that was trying to evaluate these assemblies, but did not give statistics, only compared assemblies to one another

TransRate is trying to assess 4 things.
If a transcript is assembled correctly, these should be true:
1. the identity of the nucs in the contig should match those in the real transcript
2. the order of the nucs in the contig should match those in the real transcript
3. the length of the contig should match the real transcript
4. the contig should only contain one real transcript


### Phylogenomics of Annelida revisited: a cladistic approach using genome-wide expressed sequence tag data mining and examining the effects of missing data (2012)

Sebastian Kvist and Mark E. Siddall

- The phylogeny of annelids is all over the place, with lots of different groups assigned based on morphology, and then reassigned based on genes.
- Most studies at this point had focused on only a few genes, so the support for monophyly or paraphyly was not amazing.
- 
