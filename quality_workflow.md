# Workflow for the phylogenomic quality investigations

### Working with just 10 species to figure out the procedure

All datasets we downloaded from the ENA or the SRA, and assembled using the Oyster River Protocol.
ORP script:
>source activate orp-20190215
oyster.mk main \
TMP_FILT=1 \
STRAND=RF \
MEM=110 \
CPU=24 \
READ1=Alligator_mississippiensis_1.fastq \
READ2=Alligator_mississippiensis_2.fastq \
RUNOUT=Alligator_mississippiensis_ORP_223_TMP

Then we ran the report script to generate quality scores for each of the assemblies, not just the ones that come out the end of the ORP.
Report script:
>/mnt/lustre/software/anaconda/colsa/envs/orp-20190215/local/src/Oyster_River_Protocol/report.mk main \
ASSEMBLY=/mnt/lustre/macmaneslab/tml1019/transcriptomeData/expandedDataset/Alligator_mississippiensis/assemblies/Alligator_mississippiensis_ORP_223_TMP.spades55.fasta \
LINEAGE=eukaryota_odb9 \
MEM=110 \
CPU=24 \
READ1=/mnt/lustre/macmaneslab/tml1019/transcriptomeData/expandedDataset/Alligator_mississippiensis/rcorr/Alligator_mississippiensis_ORP_223_TMP.TRIM_1P.cor.fq \
READ2=/mnt/lustre/macmaneslab/tml1019/transcriptomeData/expandedDataset/Alligator_mississippiensis/rcorr/Alligator_mississippiensis_ORP_223_TMP.TRIM_2P.cor.fq \
RUNOUT=Alligator_mississippiensis_spades55_BUSCO_TransRate_Report_223_TMP

Now we find the best assembly based on TransRate scores, the worst one, and the one that Trinity generated, and put these into their own directories.

For this first pass, they are here:
- /mnt/lustre/macmaneslab/jlh1023/phylo_qual/small_test/bad/assemblies/
- /mnt/lustre/macmaneslab/jlh1023/phylo_qual/small_test/good/assemblies/
- /mnt/lustre/macmaneslab/jlh1023/phylo_qual/small_test/trin/assemblies/

Then we run TransDecoder (2 steps) on each of the assemblies to get the protein predictions.
TransDecoder sample:
> TransDecoder.LongOrfs -t Balaenoptera_borealis_ORP_223_TMP.spades75.fasta
> TransDecoder.Predict -t Balaenoptera_borealis_ORP_223_TMP.spades75.fasta

After TransDecoder I like to clean up the directory a bit. I created sub-directories in each of the bad/good/trin directories called "transdecoder_out" and put all the stuff that TD generates in those. The protein fastas I put in a directory called "bad_prots" (or whichever one) and used them in the next step.

Now I change the names of the files and the format of the headers so that they are better for the rest of the pipeline. Right now they are long and not that informative for things we care about, so I use these two lines that Dave gave me to fix them. Shown with the whale as example.

> awk '/^>/{print ">" ++i; next}{print}' < Balaenoptera_borealis_ORP_223_TMP.spades75.fasta.transdecoder.pep > Balaenoptera_borealis.fa
> perl -p -i -e 's/>/>Balaenoptera_borealis|/g' Balaenoptera_borealis.fa

Next we can run Orthofinder on each of these datasets independently.
Orthofinder script:
> orthofinder.py -a 24 -f bad_prots/ -t 24 -S diamond -M msa

So far, from the Orthofinder summaries, the three datasets look like they've produced different things. Going to try to figure out exactly how they are different, but here are some stats:

- Bad dataset:
  - Number of OGs: 16761
  - Number of OGs with all species present: 3453
  - Median size of OG: 9

- Good dataset:
  - Number of OGs: 18168
  - Number of OGs with all species present: 3876
  - Median size of OG: 10

- Trin dataset:
  - Number of OGs: 19212
  - Number of OGs with all species present: 3775
  - Median size of OG: 11


## Post-Orthofinder processing/exploring

I need to run PhyloTreePruner on each dataset, but I don't want to run it on all of the orthogroups. So I wrote a script called get_og_list_min_taxa.py (found here: /mnt/lustre/macmaneslab/jlh1023/pipeline_dev/pipeline_scripts/get_og_list_min_taxa.py) that goes through all of the OGs and makes a list of all the ones that have the user-specified minimum number of species.

Then this list gets fed into another program I wrote called pull_alignments.py (found here: /mnt/lustre/macmaneslab/jlh1023/pipeline_dev/pipeline_scripts/pull_alignments.py) that copies all of the alignment files that correspond to the OGs in the list to a new directory where they can be processed separately.

Dave gave me a wrapper script for the actual PhyloTreePruner step, and I tweaked it until it works for these data (mostly putting in absolute paths so that it is not as location and directory structure dependent, and correcting a couple of things to make it recognize the right files and run.) I adapted the script to each of the datasets individually, and they are housed in each of the datasets' directories, called "ptp_bad.sh" (or whichever one). Then I just made a second script that is just for the slurm command, and that is in the same directory (it just seemed easier to change the script, not the slurm one) called "run_ptp_bad.sh".


### Want to make trees?

I did it first with the LG model in iqtree, and it takes two seconds.

First, convert the seqCat_sequences.nex file that you got from the pipeline to a phylip format using seq_converter.pl
It can be found here: /mnt/lustre/macmaneslab/jlh1023/pipeline_dev/pipeline_scripts/seq_converter.pl
Becuase it's a perl script, it's sort of annoying to use, but this is how it looks for all of mine so far:
> /mnt/lustre/macmaneslab/jlh1023/pipeline_dev/pipeline_scripts/seq_converter.pl -dseqCat_sequences.nex -ope

The -d is for the input file (but no spaces - annoying), and the -o is for the output format (in this case "pe" for phylip?)

Then it's just a simple iqtree script to get the tree
> iqtree -s seqCat_sequences.phylip -m LG -nt 24


Making another with RAxML

> raxmlHPC-PTHREADS -f a -T 24 -x 37644 -N 100 -n good_tree_raxml -s seqCat_sequences.phylip -p 35 -m PROTGAMMALG

Trying another model

> raxmlHPC-PTHREADS -f a -T 24 -x 37644 -N 100 -n good_tree_raxml_wag -s seqCat_sequences.phylip -p 35 -m PROTGAMMAWAG




Wanted to get some summary stats, so I ran the AMAS summary script on the bad dataset.
From this directory: /mnt/lustre/macmaneslab/jlh1023/phylo_qual/small_test/bad
> /mnt/lustre/macmaneslab/jlh1023/pipeline_dev/pipeline_scripts/amas.py summary -i seqCat_sequences.nex -f nexus -d aa

For the bad dataset, this worked just fine, but for some reason I can't get it to work on the good and trin datasets yet. They give different errors.


## Round 2

### Second test dataset

I am rerunning all of the things I have done so far on another dataset with more species (20).
The only differences in processing leading up to Orthofinder are that I am running it (in Orthofinder) once with two outgroups included, and once without them. In the ones without them, we'll just use lampreys to root the trees, but we want to make sure the outgroups are not "too out".

#### Update:

The lack of outgroups do strange things to the mammals, but so I'm going to be running an outgroup-less version on all datasets going forward. Just in case.


### Pulling out comparable Orthogroups

Right now this script only works for two datasets, but has some commented out lines that will get it most of the way to incorporating a third.

To run:
> /mnt/lustre/macmaneslab/jlh1023/pipeline_dev/pipeline_scripts/same_data.py -d /mnt/lustre/macmaneslab/jlh1023/phylo_qual/third_set/good/pruned/ -e /mnt/lustre/macmaneslab/jlh1023/phylo_qual/third_set/bad/pruned/ -n /mnt/lustre/macmaneslab/jlh1023/phylo_qual/third_set/good/common_to_bad/ -m /mnt/lustre/macmaneslab/jlh1023/phylo_qual/third_set/bad/common_to_good/


#### Mouse transcripts changed to original transcript names:

> for i in $(cat mouse_ogs_only_dir2.txt | awk -F "|" '{print $2}')
do
    sed -n "$i"p <(grep ">" /mnt/lustre/macmaneslab/jlh1023/phylo_qual/second_test/bad/prots/Mus_musculus.GRCm38.pep.all.fa) | awk '{print $1}' | sed 's_>\__'
done

You have to remove the backslash from in front of the first underscore (just above) to run the command correctly, it just messes with my formatting and I am not here for it.

## Final dataset

This dataset contains these organisms (in these categories) for a total of 39:

Outgroup (jawless fish) (1):
Lethenteron_camtschaticum

Cartilaginous fish (2):
Callorhinchus_milii
Squalus_acanthias

Fish (6):
Astyanax_mexicanus
Gadus_morhua
Haplochromis_burtoni
Ictalurus_punctatus
Lepisosteus_oculatus
Takifugu_rubripes

Lobe-finned fish (2):
Latimeria_menadoensis
Protopterus_sp

Amphibians (7):
Ambystoma_mexicanum
Bufo_bufo
Caecilia_tentaculata
Lissotriton_montandoni
Oophaga_sylvatica
Rana_pipiens
Rhinella_marina

Reptiles (8):
Alligator_mississippiensis
Anolis_carolinensis
Caiman_crocodilus
Lepidophyma_flavimaculatum
Notechis_scutatus
Pelodiscus_sinensis
Pelusios_castaneus
Trachemys_scripta

Birds (4):
Calidris_pugnax
Anas_platyrhynchos
Gallus_gallus
Parus_major

Mammals (9):
Felis_catus
Dasypus_novemcinctus
Balaenoptera_acutorostrata
Canis_lupusfamiliaris
Mus_musculus
Notamacropus_eugenii
Oryctolagus_cuniculus
Rhinolophus_sinicus
Homo_sapiens



## Main analyses

Right now my work is focusing primarily on three different areas: Gene Ontology analysis, making better trees, and occupancy analysis.

First, though, I have to get rid of all the alignment files where gblocks chopped them off or they are missing altogether. I wrote a script to do this:
> /mnt/lustre/macmaneslab/jlh1023/pipeline_dev/pipeline_scripts/no_empty_files.py -d /mnt/lustre/macmaneslab/jlh1023/phylo_qual/final/bad/ptp_runs/pruned39/ -l passing_files39.txt -n /mnt/lustre/macmaneslab/jlh1023/phylo_qual/final/bad/ptp_runs/passing_files39/

It takes a directory with all of the alignment files in it (looking specifically for files that start in "Mus" and end in "rename") and checks all of the sequences in those to make sure they are actually there and not just dashes or something. It spits out a file that is a list of all of the files needed to make the nexus file, so the seq_cat.pl can be run on this file immediately afterward. The slightly updated version of this script (shown above) also copies all of the passing files into a new user-specified directory so that they can be used by all downstream scripts more easily.

#### Comparisons between datasets

I'm going to run the "same_data" script again to pull out things that are similar in each of the datasets (just as a way of exploring the data, if nothing else), and I'll just run it three times to do all the comparisons.

I made a new "comparisons" directory here: /mnt/lustre/macmaneslab/jlh1023/phylo_qual/legit_final/comparisons/ and this is where I will do all of these analyses. I'm not sure at this point if I'll do anything with these, but they will help with data visualization at the very least.

Good: 2035
Bad: 409
Trin: 2278

Bad and Good Comparison:
332 transcripts in common

Good and Trin Comparison:
1702 transcripts in common

Bad and Trin Comparison:
334 transcripts in common

All have in common:
306 transcripts

Bad has 65 transcripts that trin does not have
So, if my calculations are correct, this is how it stands:
Unique trin: 538
trin/bad: 344
trin/good: 1702
Unique good: 305
good/bad: 332
Unique bad: 39
Common to all: 306

*update*

Not really how I'm doing this anymore, because we've largely dropped the Trinity assemblies from the analysis. Now it's much easier just to use comm and to have it spit out a file with the unique things in the good and bad datasets that way.

Unique to bad dataset: 76
Unique to good dataset: 1683
Common to both: 332

I really want to know what the "unique" things are in the bad dataset though. Are they actually unique things that the good dataset didn't find? Are they the paralogous version of things that are in the good dataset? Are they just things that assembled weird and are actually totally wrong? I don't know yet, but I'm going to isolate them in each dataset and blast them to find out.

To do this, I have written a script that goes through each (alignment) files in a directory (in this case, a directory with alignment files that are unique to either the good or bad datasets) and extracts the Mus sequence from each of those files. Then it puts all of these into a fasta file (one each for the good and bad datasets) that I can then use to blast.

>/mnt/lustre/macmaneslab/jlh1023/pipeline_dev/pipeline_scripts/extract_mus_seqs.py -i only_bad_files/ -o bad_mus_unique.fasta

HOWEVER, one of the programs (I'm thinking it's gblocks or something else that was written last millenium) likes to put line feeds in the fasta files. This makes everything more difficult and annoying, and is the reason that I could not just grep out the Mus sequences in the first place using a simple bash loop, which I also wrote. I switched to python so I could use Bio.SeqIO but then BLAST still chokes on the separate lines. Too late to go back now. So I googled around for a sec and found this helpful person: https://www.ecseq.com/support/ngs-snippets/convert-interleaved-fasta-files-to-single-line who supplied me with this line of code, which I tested and seems to work really well for getting rid of those annoying line feeds and making your fasta file look the way god intended - one line for header and one line for sequence.

>awk '{if(NR==1) {print $0} else {if($0 ~ /^>/) {print "\n"$0} else {printf $0}}}' good_mus_unique.fasta > fixed_good_mus_unique.fasta

It looks like blast still chokes if you have a gap at the beginning of the sequence (dashes) but it will tell you where these are when you try to run it so you can just go in and delete them in bbedit. Then I just set the organism to Mus musculus, uploaded each file, and let it go.



### GO terms

I ran interproscan on the mouse transcripts that I have used as an anchor in each of the three datasets. I did it from this directory: /mnt/lustre/macmaneslab/jlh1023/phylo_qual/final/mouse/ with this output file: mus.tsv
> interproscan -i Mus_musculus.fa -b mus -goterms -f TSV

Then I wrote a script that parses the resulting tsv file, and pulls out the GO terms both for all of the mouse transcripts and for each dataset individually.
This is for the bad dataset:
> /mnt/lustre/macmaneslab/jlh1023/pipeline_dev/pipeline_scripts/parse_interpro.py -i mus.tsv -l -o

it requires a tsv file from interproscan that contains a GO terms column, a file that is a list of all the specific mouse transcripts of interest (from whatever dataset I'm focused on at the moment), and the name of an output file.

This is super great for getting a straight up list of the GO terms, but in reality, what I need to run topGO is much simpler than this. So I don't need to worry about the above script, and instead, I can use a quick cut command to get the columns that I need.
>cut -f 1,14 mus.tsv > mouse_trans_goterms.tsv

Then I'll also need the list of mouse transcripts that I'm interested in, which I can easily get from the directories that get spit out by my script that weeds out the files with empty bits. This is how I did it for the bad dataset (from this directory: /mnt/lustre/macmaneslab/jlh1023/phylo_qual/final/bad/ptp_runs/):
> ls bad39_complete_files/ > bad39_clean_transcripts.txt

I can follow a tutorial found here: http://avrilomics.blogspot.com/2015/07/using-topgo-to-test-for-go-term.html to do the topGO stuff, and have had to do some simple text manipulations (replacing certain symbols) to make sure my files match up with what the program is expecting. My R code is saved in this file: ~/Desktop/Analyses/quality/topGO_analyses.R

Here are the summary results from each of the three datasets after a basic fisher exact test using weight01 as the algorithm.

#### Bad:

Description: bad39go
Ontology: BP
'weight01' algorithm with the 'fisher' test
2054 GO terms scored: 25 terms with p < 0.01
Annotation data:
    Annotated genes: 111615
    Significant genes: 971
    Min. no. of genes annotated to a GO: 1
    Nontrivial nodes: 270

Once they are adjusted for multiple tests, these are the ones that are still significant:
GO.ID                                        Term Annotated Significant Expected classicFisher
1  GO:0006412                                 translation       296          19     2.58       2.6e-29
2  GO:0055114                 oxidation-reduction process       600          17     5.22       5.4e-22
3  GO:0006886             intracellular protein transport       141           5     1.23       8.0e-07
4  GO:0030168                         platelet activation         3           2     0.03       1.2e-06
5  GO:0006457                             protein folding        41           3     0.36       2.7e-06
6  GO:0005975              carbohydrate metabolic process       165           6     1.44       4.3e-05
7  GO:0016192                  vesicle-mediated transport       129           4     1.12       4.9e-05

None of these are depletions, all are enrichments

#### Good:

Description: good39go
Ontology: BP
'weight01' algorithm with the 'fisher' test
2054 GO terms scored: 56 terms with p < 0.01
Annotation data:
    Annotated genes: 111615
    Significant genes: 3644
    Min. no. of genes annotated to a GO: 1
    Nontrivial nodes: 672

Once they are adjusted for multiple tests, these are the ones that are still significant:
    GO.ID                                        Term Annotated Significant Expected classicFisher
1  GO:0055114                 oxidation-reduction process       600          40    19.59       < 1e-30
2  GO:0006412                                 translation       296          35     9.66       < 1e-30
3  GO:0006886             intracellular protein transport       141          19     4.60       1.8e-23
4  GO:0006468                     protein phosphorylation       500          22    16.32       3.5e-19
5  GO:0006508                                 proteolysis       431          27    14.07       2.6e-13
6  GO:0016192                  vesicle-mediated transport       129          15     4.21       2.7e-12
7  GO:0006457                             protein folding        41           7     1.34       1.9e-11
8  GO:0006355 regulation of transcription, DNA-templat...      1096          21    35.78       1.3e-08
9  GO:0051603 proteolysis involved in cellular protein...        68          11     2.22       1.5e-08
10 GO:0006351                transcription, DNA-templated      1184          30    38.66       1.1e-07
11 GO:0055085                     transmembrane transport       496          15    16.19       2.3e-07
12 GO:0006511 ubiquitin-dependent protein catabolic pr...        57           7     1.86       2.7e-07
13 GO:0006614 SRP-dependent cotranslational protein ta...        13           3     0.42       5.3e-06
14 GO:0006367 transcription initiation from RNA polyme...        14           3     0.46       6.7e-06
15 GO:0051258                      protein polymerization        37           4     1.21       2.1e-05
16 GO:0030168                         platelet activation         3           2     0.10       2.1e-05

Of these, 8, 10, and 11 are depletions, and the rest are enrichments.

#### Trinity:
Description: trin39go
Ontology: BP
'weight01' algorithm with the 'fisher' test
2054 GO terms scored: 64 terms with p < 0.01
Annotation data:
    Annotated genes: 111615
    Significant genes: 3828
    Min. no. of genes annotated to a GO: 1
    Nontrivial nodes: 716

Once they are adjusted for multiple tests, these are the ones that are still significant:
GO.ID                                        Term Annotated Significant Expected classicFisher
1  GO:0006412                                 translation       296          48    10.15       < 1e-30
2  GO:0055114                 oxidation-reduction process       600          46    20.58       < 1e-30
3  GO:0006886             intracellular protein transport       141          20     4.84       5.3e-21
4  GO:0006468                     protein phosphorylation       500          21    17.15       6.9e-16
5  GO:0006457                             protein folding        41           8     1.41       4.7e-13
6  GO:0006508                                 proteolysis       431          28    14.78       1.1e-11
7  GO:0016192                  vesicle-mediated transport       129          18     4.42       8.3e-11
8  GO:0055085                     transmembrane transport       496          18    17.01       3.7e-09
9  GO:0006351                transcription, DNA-templated      1184          26    40.61       4.0e-09
10 GO:0006511 ubiquitin-dependent protein catabolic pr...        57           8     1.95       9.9e-09
11 GO:0006355 regulation of transcription, DNA-templat...      1096          18    37.59       2.1e-08
12 GO:0005975              carbohydrate metabolic process       165          14     5.66       2.2e-08
13 GO:0051603 proteolysis involved in cellular protein...        68          12     2.33       2.2e-08
14 GO:0006614 SRP-dependent cotranslational protein ta...        13           4     0.45       5.3e-08
15 GO:0015986      ATP synthesis coupled proton transport        23           4     0.79       6.4e-07
16 GO:0006096                          glycolytic process        30           4     1.03       1.9e-06
17 GO:0006888      ER to Golgi vesicle-mediated transport        10           3     0.34       3.0e-06
18 GO:0034314    Arp2/3 complex-mediated actin nucleation        17           3     0.58       1.7e-05
19 GO:0006397                             mRNA processing        33           4     1.13       2.0e-05

Of these, 9 and 11 are depletions, the rest are enrichments.

Overall:
if you take the number of GOs that are significant in each dataset and divide them by the number of partitions in that dataset, these are the numbers you get:
Bad: 0.01711
Good: 0.00786
Trin: 0.00834

So we can see that at least looking at them like this, the good dataset seems the least biased (although none is very much)

Next, I'm going to try to run these same analyses with the subset of partitions that are unique to each dataset, rather than all of the ones that they have. Stay tuned.

### OG Analysis with only unique partitions from the good and bad datasets

I did these analyses the same way as before, but made sure to change the names of the transcripts to match the ones in the tsv file (had to take out the pipes and put in an underscore, and shave off the rename part at the end).

Results from that:

#### Bad dataset:

Description: bad39go
Ontology: BP
'weight01' algorithm with the 'fisher' test
2054 GO terms scored: 7 terms with p < 0.01
Annotation data:
    Annotated genes: 111615
    Significant genes: 174
    Min. no. of genes annotated to a GO: 1
    Nontrivial nodes: 117


After controlling for multiple tests, these are the ones that are significant (4 was originally 0.00058, now 0.04408)

    GO.ID                                        Term Annotated Significant Expected
1  GO:0006412                                 translation       296           3     0.46
2  GO:0006419                  alanyl-tRNA aminoacylation         3           1     0.00
3  GO:0006807         nitrogen compound metabolic process      3404           7     5.31
4  GO:0006801                superoxide metabolic process         5           1     0.01


#### Good dataset:

Description: good39go
Ontology: BP
'weight01' algorithm with the 'fisher' test
2054 GO terms scored: 61 terms with p < 0.01
Annotation data:
    Annotated genes: 111615
    Significant genes: 2584
    Min. no. of genes annotated to a GO: 1
    Nontrivial nodes: 623


After controlling for multiple tests, these are the ones that are significant (14 was originally 1.7e-05, now 0.028611)

    GO.ID                                        Term Annotated Significant Expected
1  GO:0055114                 oxidation-reduction process       600          25    13.89
2  GO:0006412                                 translation       296          20     6.85
3  GO:0006886             intracellular protein transport       141          14     3.26
4  GO:0006468                     protein phosphorylation       500          19    11.58
5  GO:0006508                                 proteolysis       431          25     9.98
6  GO:0051603 proteolysis involved in cellular protein...        68          11     1.57
7  GO:0006355 regulation of transcription, DNA-templat...      1096          18    25.37
8  GO:0055085                     transmembrane transport       496          13    11.48
9  GO:0016192                  vesicle-mediated transport       129          10     2.99
10 GO:0006457                             protein folding        41           4     0.95
11 GO:0006351                transcription, DNA-templated      1184          26    27.41
12 GO:0006367 transcription initiation from RNA polyme...        14           3     0.32
13 GO:0006511 ubiquitin-dependent protein catabolic pr...        57           6     1.32
14 GO:0006812                            cation transport       316          13     7.32


##### Overall:
if you take the number of GOs that are significant in each dataset and divide them by the number of partitions in that dataset, these are the numbers you get:
Bad: 0.0526
Good: 0.00832


### New GO term analysis  

We realized we needed to be using only the liver transcriptome of the mouse as the "background" to check for enrichment, instead of the entire mouse reference transcriptome. So I ran interproscan on the ORP mouse liver transcriptome that Troy assembled forever ago (when we thought we would be able to use it in the full analysis). This is after it's been translated into amino acids and the headers changed.

Inside: /mnt/lustre/macmaneslab/jlh1023/phylo_qual/actual_final/mouse
> interproscan -i Mus_musculus_liver.fa -b mus_liver_inter -goterms -f TSV  

Honestly, now that I'm thinking about this, this might not be necessary. I need the names to match up between the background go terms and the ones I'm interested in, so I'll have to pull them from the original interproscan results anyway.

But now the problem is that none of the gene names match the transcripts from the partitions, because they were all made with the mouse reference. So I made a blast database from the mouse reference:  
> makeblastdb -in mus_ref.fa -out mus_ref -dbtype prot  

And then I blasted all of the mouse liver transcripts against the mouse reference transcriptome to see where the transcripts (which have already been interproscanned) match up with the reference:  
> blastp -db mus_ref -max_target_seqs 1 -query Mus_musculus_liver.fa -outfmt '6 qseqid qlen length pident gaps evalue stitle' -evalue 1e-10 -num_threads 6 -out mus_blast.out  

So the columns in the output file are: sequence ID of the query, length of the query, length of the match (?), percent identity, number of gaps, e-value, and match name (which for me is the transcript name that matches literally everything else in my analysis). Example below.  

> Mus_musculus_liver|1    813     813     100.000 0       0.0     Mus_musculus|3619
> Mus_musculus_liver|2    354     354     100.000 0       0.0     Mus_musculus|12936
> Mus_musculus_liver|2    354     159     38.994  10      2.08e-28        Mus_musculus|12936
> Mus_musculus_liver|2    354     134     35.075  9       1.00e-16        Mus_musculus|12936  

Ok great! Now I'll write a script that will pull out the things that are 97% identity matches or higher (all the e-values should be good to go), and then write another thing that will pull out the mouse reference transcripts that match the relevant mouse liver transcripts. Easy peasy.  

This is in the same script, located here: /mnt/lustre/macmaneslab/jlh1023/pipeline_dev/pipeline_scripts/blast_similarity.py and I ran it like this from the same directory as above:  
> /mnt/lustre/macmaneslab/jlh1023/pipeline_dev/pipeline_scripts/blast_similarity.py -i mus_blast.out -g mus_ref_inter.tsv -o mus_ref_liver_matches.tsv

Ok, something is going wrong with this and I don't know what it is. Since it works perfectly in all my small tests (when I just head the file with 10 or 100 lines and run it with that), I'm just going to test it using increasingly large test sets, have them all run in different tmux windows, and see at what point they start being the weird incorrect output that I'm seeing when I run the whole thing. The tests are as follows:  
mus_blast1.out = lines 1-5000 of mus_blast.out - this will go into an output file called mus_test_matches1.tsv  
mus_blast2.out = lines 1-10000  
mus_blast3.out = lines 1-15000  
mus_blast4.out = lines 1-20000  
mus_blast5.out = lines 1-25000  

If these all come out normal, I'll know the issue is somewhere in the last 5000 lines (or so - the whole file is 30,356 lines long).  

mus_test_matches1.tsv - normal  
mus_test_matches2.tsv - normal
mus_test_matches3.tsv - normal
mus_test_matches4.tsv - normal
mus_test_matches5.tsv - normal  

Either there is nothing wrong, or the problem is in the very last section of the blast output file.  
Doing one more test, this time with the last few lines of the file  
> tail -n +25000 mus_blast.out > mus_blast6.out  #this file has 5357 lines, so I think I got what I was trying to.  

mus_blast6.out (lines 25000-end) > mus_test_matches6.tsv - weird
mus_blast7.out (lines 26000-end) > mus_test_matches7.tsv - weird
mus_blast8.out (lines 27000-end) > mus_test_matches8.tsv - weird
mus_blast9.out (lines 28000-end) > mus_test_matches9.tsv - normal
mus_blast10.out (lines 29000-end) > mus_test_matches10.tsv -normal

Ok, so it seems like the issue is somewhere between lines 27,000 and 28,000.  

> head -n 1000 mus_blast8.out > mus_blast_spec.out

mus_blast_spec.out - produces a weird output file  
So now I'm going to narrow down this one.  

> head -n 900 mus_blast_spec.out > mus_blast_spec9.out

mus_blast_spec9.out (lines 27,000-27,900) > mus_test_matches_spec9 - weird
mus_blast_spec8.out (lines 27,000-27,800) > mus_test_matches_spec8 - weird
mus_blast_spec7.out (lines 27,000-27,700) > mus_test_matches_spec7 - weird
mus_blast_spec6.out (lines 27,000-27,600) > mus_test_matches_spec6 - weird
mus_blast_spec5.out (lines 27,000-27,500) > mus_test_matches_spec5 - weird
mus_blast_spec4.out (lines 27,000-27,400) > mus_test_matches_spec4 - weird
mus_blast_spec3.out (lines 27,000-27,300) > mus_test_matches_spec3 - normal
mus_blast_spec2.out (lines 27,000-27,200) > mus_test_matches_spec2 - normal
mus_blast_spec1.out (lines 27,000-27,100) > mus_test_matches_spec1 - normal

Ok, so looks like the problem is somewhere between 27,300 and 27,400 in the mus_blast.out file.
Testing it on those hundred:
> tail -n 100 mus_blast_spec4.out > mus_blast_spec4.1.out
> /mnt/lustre/macmaneslab/jlh1023/pipeline_dev/pipeline_scripts/blast_similarity.py -i mus_blast_spec4.1.out -g mus_ref_inter.tsv -o mus_test_matches_spec4.1.tsv    

This one is also weirdly formatted, so I think that's the culprit.
However, there is nothing that looks particularly weird in this section of the output. So there's that.

Just to make sure, I'm going to subset out the last few thousand lines from the blast output and run them through as well. I expect them to be normal, since the issue should be right before these lines.
> tail -n +27400 mus_blast.out > mus_test_end.out  
> /mnt/lustre/macmaneslab/jlh1023/pipeline_dev/pipeline_scripts/blast_similarity.py -i mus_test_end.out -g mus_ref_inter.tsv -o mus_test_matches_end.tsv

 It's weird formatting. Need to look at again when I'm less tired.



 Trying again:
 > head -n 27300 mus_blast.out > top_mus_blast.out
 > /mnt/lustre/macmaneslab/jlh1023/pipeline_dev/pipeline_scripts/blast_similarity.py -i top_mus_blast.out -g mus_ref_inter.tsv -o top_test_matches.tsv  

I expected this one to be totally normal, and it was, thank goodness.

30356 lines - 27300 lines = 3056 lines  

> tail -n 3056 mus_blast.out > bottom_mus_blast.out
> /mnt/lustre/macmaneslab/jlh1023/pipeline_dev/pipeline_scripts/blast_similarity.py -i bottom_mus_blast.out -g mus_ref_inter.tsv -o bottom_test_matches.tsv  

I expected this one to be weird formatting, and it was. Now trying to "rescue" the end of the file, thereby isolating the bad part.

> tail -n 2956 mus_blast.out > bottom1_blast.out  #bottom1_test_matches.tsv is still weird. Trying another.
> tail -n 2856 mus_blast.out > bottom2_blast.out  #bottom2_test_matches.tsv is still weird.
> tail -n 2756 mus_blast.out > bottom3_blast.out  #bottom3_test_matches.tsv is weird.  
> tail -n 2656 mus_blast.out > bottom_2656_blast.out #weird
> tail -n 2556 mus_blast.out > bottom_2556_blast.out #weird  

2456 = weird  
2356 = normal!  

So, if I do this: `head -n 100 bottom_2456_blast.out > problem_27900-28000_blast.out` it should be the actual part that is messed up.  
And if I do this: `head -n 27900 mus_blast.out > top_27900_blast.out` it should be normal still.  

Seems like success! The top part (top_27900_blast.out) works great, the bottom part (bottom_2356_blast.out) is normal, and the middle 100 lines (problem_27900-28000_blast.out) looks like garbage!


I ran the blast command again to see if it had just been a strange thing that happened that one time, but it wasn't, and the results were the same as the first time. So instead of trying to fix it, I'm going to continue my testing, and find the line that is the problem, and throw it out so I can continue the rest of the analysis. I can start from the problem_27900-28000_blast.out file that I made above, as I know this is where the issue is. Going to be testing from inside this directory from now on: /mnt/lustre/macmaneslab/jlh1023/phylo_qual/actual_final/mouse/blast_testing, hence the change in some of the paths.

> head -n 10 ../problem_27900-28000_blast.out > problem1-10_blast.out
> /mnt/lustre/macmaneslab/jlh1023/pipeline_dev/pipeline_scripts/blast_similarity.py -i top10_blast.out -g ../mus_ref_inter.tsv -o problem1-10.tsv  #weird  

> tail -n 90 ../problem_27900-28000_blast.out | head -n 10 > problem11-20_blast.out
> /mnt/lustre/macmaneslab/jlh1023/pipeline_dev/pipeline_scripts/blast_similarity.py -i problem11-20_blast.out -g ../mus_ref_inter.tsv -o problem11-20.tsv #normal  

> tail -n 80 ../problem_27900-28000_blast.out | head -n 10 > problem21-30_blast.out #weird  
> tail -n 70 ../problem_27900-28000_blast.out | head -n 10 > problem31-40_blast.out #normal  
> tail -n 60 ../problem_27900-28000_blast.out | head -n 10 > problem41-50_blast.out #weird  
> tail -n 50 ../problem_27900-28000_blast.out | head -n 10 > problem51-60_blast.out #normal  
> tail -n 40 ../problem_27900-28000_blast.out | head -n 10 > problem61-70_blast.out #normal  
> tail -n 30 ../problem_27900-28000_blast.out | head -n 10 > problem71-80_blast.out #normal  
> tail -n 20 ../problem_27900-28000_blast.out | head -n 10 > problem81-90_blast.out #weird    
> tail -n 10 ../problem_27900-28000_blast.out > problem91-100_blast.out #normal  

These are not the results I was expecting. I thought I would find one line that I could cut out, but it looks like there are multiple. I guess I have more testing to do than I thought. Thinking that brute force testing them might end up taking the least amount of time, even though it will give me loads of files. I'll try it with the first of these problem files first, and see if I can isolate it further. As usual, the tsv files that result will be named with the same prefix as the blast files.  

The four problem sections are:  
problem1-10_blast.out  
problem21-30_blast.out  
problem41-50_blast.out  
problem81-90_blast.out  

> head -n 1 problem1-10_blast.out > problem1_blast.out #empty  
tail -n 9 problem1-10_blast.out | head -n 1 > problem2_blast.out #normal  
tail -n 8 problem1-10_blast.out | head -n 1 > problem3_blast.out #normal  
tail -n 7 problem1-10_blast.out | head -n 1 > problem4_blast.out #normal  
tail -n 6 problem1-10_blast.out | head -n 1 > problem5_blast.out #weird  
tail -n 5 problem1-10_blast.out | head -n 1 > problem6_blast.out #weird   
tail -n 4 problem1-10_blast.out | head -n 1 > problem7_blast.out #normal  
tail -n 3 problem1-10_blast.out | head -n 1 > problem8_blast.out #normal  
tail -n 2 problem1-10_blast.out | head -n 1 > problem9_blast.out #normal  
tail -n 1 problem1-10_blast.out > problem10_blast.out #normal  

I've marked the ones that are strange in a file and I'll get rid of them all from (a copy of) the original file when I'm finished. So far, I can see absolutely nothing that separates them from any other line. Moving on to the next batch.  

> head -n 1 problem21-30_blast.out > problem21_blast.out #weird  
tail -n 9 problem21-30_blast.out | head -n 1 > problem22_blast.out #normal   
tail -n 8 problem21-30_blast.out | head -n 1 > problem23_blast.out #normal  
tail -n 7 problem21-30_blast.out | head -n 1 > problem24_blast.out #empty  
tail -n 6 problem21-30_blast.out | head -n 1 > problem25_blast.out #weird  
tail -n 5 problem21-30_blast.out | head -n 1 > problem26_blast.out #weird  
tail -n 4 problem21-30_blast.out | head -n 1 > problem27_blast.out #weird  
tail -n 3 problem21-30_blast.out | head -n 1 > problem28_blast.out #weird  
tail -n 2 problem21-30_blast.out | head -n 1 > problem29_blast.out #weird  
tail -n 1 problem21-30_blast.out > problem30_blast.out #normal  

> head -n 1 problem41-50_blast.out > problem41_blast.out #normal  
tail -n 9 problem41-50_blast.out | head -n 1 > problem42_blast.out #normal  
tail -n 8 problem41-50_blast.out | head -n 1 > problem43_blast.out #normal  
tail -n 7 problem41-50_blast.out | head -n 1 > problem44_blast.out #normal  
tail -n 6 problem41-50_blast.out | head -n 1 > problem45_blast.out #normal  
tail -n 5 problem41-50_blast.out | head -n 1 > problem46_blast.out #normal  
tail -n 4 problem41-50_blast.out | head -n 1 > problem47_blast.out #empty  
tail -n 3 problem41-50_blast.out | head -n 1 > problem48_blast.out #weird  
tail -n 2 problem41-50_blast.out | head -n 1 > problem49_blast.out #normal  
tail -n 1 problem41-50_blast.out > problem50_blast.out #normal  

> head -n 1 problem81-90_blast.out > problem81_blast.out #normal  
tail -n 9 problem81-90_blast.out | head -n 1 > problem82_blast.out #normal  
tail -n 8 problem81-90_blast.out | head -n 1 > problem83_blast.out #weird  
tail -n 7 problem81-90_blast.out | head -n 1 > problem84_blast.out #normal  
tail -n 6 problem81-90_blast.out | head -n 1 > problem85_blast.out #normal  
tail -n 5 problem81-90_blast.out | head -n 1 > problem86_blast.out #normal  
tail -n 4 problem81-90_blast.out | head -n 1 > problem87_blast.out #normal  
tail -n 3 problem81-90_blast.out | head -n 1 > problem88_blast.out #normal  
tail -n 2 problem81-90_blast.out | head -n 1 > problem89_blast.out #normal  
tail -n 1 problem81-90_blast.out > problem90_blast.out #normal  


OK. Now I will make a copy of the blast output file, and delete the lines that I've identified as being the problems.  I'm going to download it and put it in a text editor just to make it easier and make me feel more confident.  

# IT WORKED!!!  

Thank God.




Now I can do the analysis pretty much like I did before. I'll isolate the columns of this file that I need:  
> cut -f 1,14 edited_mus_matches.tsv > liver_goterms.tsv  

And download this file. Then I'll pop it into a text editor and change the pipes (the bane of my existence) to underscores.  

I've downloaded four transcript files (these are just lists of transcript names) that are found here on premise:  
- /mnt/lustre/macmaneslab/jlh1023/phylo_qual/actual_final/comparisons/unique_good.txt (unique_good_transcripts_1684.txt)  
- /mnt/lustre/macmaneslab/jlh1023/phylo_qual/actual_final/comparisons/unique_bad.txt (unique_bad_transcripts_76.txt)  
- /mnt/lustre/macmaneslab/jlh1023/phylo_qual/actual_final/comparisons/bad_sorted.txt (all_bad_transcripts_408.txt)  
- /mnt/lustre/macmaneslab/jlh1023/phylo_qual/actual_final/comparisons/good_sorted.txt   (all_good_transcripts_2016.txt)

They have been renamed (in parentheses), their pipes changed to underscores, and the "underscore rename" part of their names removed. I'll do the TopGo analysis on each of these four datasets.  

#### Total Good  

I'll paste in the top few lines of the results for this one, but after adjusting for multiple tests, none are significant (0.00023 became 0.46368).  

GO.ID                                        Term Annotated Significant Expected classicFisher
1  GO:0006355 regulation of transcription, DNA-templat...         8           2     0.66       0.00023
2  GO:0015031                           protein transport         6           3     0.50       0.00253
3  GO:0006614 SRP-dependent cotranslational protein ta...         1           1     0.08       0.00303
4  GO:0006659     phosphatidylserine biosynthetic process         1           1     0.08       0.00303
5  GO:0055114                 oxidation-reduction process         3           1     0.25       0.00907
6  GO:0006886             intracellular protein transport         5           2     0.41       0.01107
7  GO:0006412                                 translation         4           1     0.33       0.01207
8  GO:0045454                      cell redox homeostasis         5           1     0.41       0.01507
9  GO:0006396                              RNA processing         7           1     0.58       0.02104
10 GO:0006351                transcription, DNA-templated        17           3     1.41       0.02257
11 GO:0035556           intracellular signal transduction        21           1     1.74       0.06190
12 GO:0006793                phosphorus metabolic process        11           1     0.91       1.00000

#### Unique Good  

Pasting in the top few lines again, but again, no significant results (0.00019 became 0.31996).  

GO.ID                                        Term Annotated Significant Expected classicFisher
1  GO:0006355 regulation of transcription, DNA-templat...         8           2     0.63       0.00019
2  GO:0015031                           protein transport         6           3     0.48       0.00228
3  GO:0006614 SRP-dependent cotranslational protein ta...         1           1     0.08       0.00278
4  GO:0006659     phosphatidylserine biosynthetic process         1           1     0.08       0.00278
5  GO:0006886             intracellular protein transport         5           2     0.40       0.01007
6  GO:0006412                                 translation         4           1     0.32       0.01107
7  GO:0045454                      cell redox homeostasis         5           1     0.40       0.01382
8  GO:0006396                              RNA processing         7           1     0.56       0.01930
9  GO:0006351                transcription, DNA-templated        17           3     1.35       0.02033
10 GO:0035556           intracellular signal transduction        21           1     1.67       0.05688
11 GO:0006793                phosphorus metabolic process        11           1     0.87       1.00000

#### Total Bad  

I'm just going to pop in the very top of this table. There are no significantly enriched or depleted GO terms once I controlled for multiple testing (0.00076 became 0.31008).  

GO.ID                                        Term Annotated Significant Expected classicFisher
1  GO:0055114                 oxidation-reduction process         3           1     0.01       0.00076
2  GO:0008150                          biological_process       186           1     0.66       1.00000
3  GO:0008152                           metabolic process        79           1     0.28       1.00000

#### Unique Bad  

For this one, there are no significant GO terms even by the original p values, let alone after correcting for multiple tests.  




### Better trees

The trees I've been working with were made with models that didn't fit them super well, and I want to make some more robust ones using the same datasets. Working in this directory: /mnt/lustre/macmaneslab/jlh1023/phylo_qual/final/bad/trees/   (or good, or trin)

I'm using iqtree and allowing it to look at each partition and choose the best model for that partition, then group partitions together if they have the same model. It will take a while, and here is an example of a script:
>iqtree -s trin39.phylip -sp trin39_clean.txt -pre trin39_clean -m MFP+MERGE -nt AUTO

These will probably take a million years, so there's that.

*Update 9-9-19*
I am no longer going to try to make the trees this way. I don't think it will finish in anything close to a reasonable time. We are shifting to partition finder and raxml instead
*Update over*

Now what I am doing is using partition finder and then raxml to make the better trees. It works much more quickly and is therefore a feasible way of making well supported trees that we can feel more confident in. Really, the trees are not the most important part of this, but we want to have good branch lengths to compare things to.

For this process, I start with the same phylip file I was using in the iqtrees, but I also need to make a configuration file for partition finder. It looks like this: (I've put ">" at the beginning of the commented out parts for formatting sake, but these are not part of the file.)

>## ALIGNMENT FILE ##
alignment = bad38.phylip;

>## BRANCHLENGTHS: linked | unlinked ##
branchlengths = linked;

>## MODELS OF EVOLUTION: all | allx | mrbayes | beast | gamma | gammai | <list> ##
models = all;

># MODEL SELECCTION: AIC | AICc | BIC #
model_selection = aicc;

>## DATA BLOCKS: see manual for how to define ##
[data_blocks]
Mus_musculus_10378_rename = 1 - 666;
Mus_musculus_10401_rename = 667 - 1506;
Mus_musculus_10492_rename = 1507 - 1946;
...
Mus_musculus_9910_rename = 133752 - 133910;

>## SCHEMES, search: all | user | greedy | rcluster | rclusterf | kmeans ##
[schemes]
search = rcluster;

To make this file I just need a phylip file (at the top as the alignment file), to make some decisions about settings (I got mine from the Kayal et al. paper github) and to put in the right data blocks. These are just the charsets from the nexus file from which I made the phylip file, but I have removed those pesky pipes from the names and taken out the full paths, which I think partition finder doesn't like.

Note: this file must be called "partition_finder.cfg" and must exist in a directory that does not have a preexisting partition finder run results in it, because it will error out rather than overwrite.

Once I get this file in order, the command is really easy:
>PartitionFinderProtein.py /mnt/lustre/macmaneslab/jlh1023/phylo_qual/legit_final/bad/trees/partfind/ --raxml \
--rcluster-max 1000 --rcluster-percent 10

I just tell it where to find the stuff it will need (the config file and the phylip file), tell it which tree building program to use, and some directions about partitioning (also from Kayal et al.)

Takes a few days for 2200 partitions, but not too bad.
And then I can use raxml to make the trees.

At the end of the partition finder run, I have a file called "best_scheme.txt" which is in the output "analysis" directory that partition finder spits out. In this file are the partitions in all the formats that you might need for literally any tree building software I have ever heard of. We want the raxml one, which is maybe halfway down. I need to excise this portion (just the partitions - every line must have an "=" in it, no other info), and put it into a separate text file. I've been calling mine "part.txt" for almost no reason.

The top of it looks like this:
>JTT, Subset1 = 1-300
LG4X, Subset2 = 301-739
JTTF, Subset3 = 740-1308
LG4X, Subset4 = 1309-1540
VTF, Subset5 = 1541-1914

Then the command is another one line situation:
>raxmlHPC-PTHREADS-SSE3 -T 24 -m PROTGAMMAAUTO -q part.txt -s good38.phylip -n good38_partitioned -p 94329

The part.txt and phylip are supplied, and then I also have to give it a name to call the output (-n) and a "random" number (-p).


##### New version

I think it will be better to constrain the tree to the "real" topology and then test all the gene trees from each dataset against it to see which are more consistent. So I took a tree that has all the taxa on it (it really doesn't matter how it was made) and moved things around (with mesquite, so there's no code) so that they are correct according to our best current hypotheses. Then I ran partition finder on the good dataset to get branch lengths, and now I'll run raxml with the partitions and the tree with the correct configuration to make the best most awesome tree ever. Command below.

>raxmlHPC-PTHREADS-SSE3 -T 24 -m PROTGAMMAAUTO -q part.txt -s good39.phylip -p 94324 \
-r correct_tree39.phy -n good39_constrained3

*Update 11-5-19*
Raxml seems to be using the partition file instead of paying attention to the tree that I gave it, so we are going to take out the partition file and just rely on the alignment file to get the branch lengths closer to what they should be. Also changed the model being used because it shouldn't matter.

>raxmlHPC-PTHREADS-SSE3 -T 24 -m PROTGAMMAWAG -s good39.phylip -p 94324 \
-r correct_tree39.phy -n good39_no_partfind

*Update 11-6-19*
Same thing seems to be happening still.
Going to try it in iqtree instead.

##### IQtree

>iqtree -s good39.phylip -m TIM2+I+G -g correct_tree39.phy -pre iqtree_constrained1 -nt AUTO



### Tree Consistency

Worth knowing the tree consistency scores between the different datasets. First you have to make gene trees with all of the partitions:
>parallel -j4 '/mnt/lustre/macmaneslab/jlh1023/pipeline_dev/pipeline_scripts/seq_converter.pl -d{} -ope' ::: \
/mnt/lustre/macmaneslab/jlh1023/phylo_qual/legit_final/bad/ptp_runs/passing_files38/*_rename

Ignore the weird formatting, markdown doesn't get that sometimes you need to use asterisks for wildcards.

parallel -j4 'iqtree -s {} -m LG -nt 6' ::: \
/mnt/lustre/macmaneslab/jlh1023/phylo_qual/legit_final/bad/ptp_runs/passing_files38/*.phylip

Now we concatenate all the gene trees together:
>cat passing_files38/\*treefile > all_gene_trees.tre

(but take out the backslash before the asterisk *rolls eyes*)

Then this command:
>raxmlHPC-PTHREADS -L MR -z all_gene_trees.tre -m GTRCAT -n bad38

For the bad:
Tree certainty for this tree: 5.070238
Relative tree certainty for this tree: 0.140840
Tree certainty including all conflicting bipartitions (TCA) for this tree: 5.062962
Relative tree certainty including all conflicting bipartitions (TCA) for this tree: 0.140638

For the good:
Tree certainty for this tree: 9.516118
Relative tree certainty for this tree: 0.264337
Tree certainty including all conflicting bipartitions (TCA) for this tree: 9.260231
Relative tree certainty including all conflicting bipartitions (TCA) for this tree: 0.257229



Or if we want the consistency using the correct tree, we use this command:
>raxmlHPC-PTHREADS-SSE3 -f i -m PROTGAMMAWAG -t correct_tree_branches.tre -z all_gene_trees.tre -n tc_ic

Good dataset:
Tree certainty for this tree: 14.221583
Relative tree certainty for this tree: 0.395044
Tree certainty including all conflicting bipartitions (TCA) for this tree: 13.707097
Relative tree certainty including all conflicting bipartitions (TCA) for this tree: 0.380753

Bad dataset:
Tree certainty for this tree: 12.286685
Relative tree certainty for this tree: 0.341297
Tree certainty including all conflicting bipartitions (TCA) for this tree: 11.902500
Relative tree certainty including all conflicting bipartitions (TCA) for this tree: 0.330625  


These commands also spit out a tree with all the ICAs for each node depicted on the nodes themselves. For the good and bad datasets (in their respective directories) these are the files that are named "RAxML_IC_Score_BranchLabels.tc_ic".  

These are great because I can pop them into a janky tree viewing program (dendroscope) and make them into pretty comparative ICA figures by plotting the tree in a pretty way in figtree, and then manually putting all of the numbers on.  

If you record all the numbers for each dataset also, you can make other plots (density ones come to mind) and compare the data points in other ways in R.  

### Tree distances

I want to compare the good and bad trees to the correct tree in a number of different ways, and calculate the distances between them.

First, I want to do this with all of the gene trees for both datasets. A script to do this is in the quality folder of Matthias and is called tree_dist_edits.R. I have made density plots of the distributions of all of these distances, and they are also in the quality folder.

I looked specifically at RF distances (symmetric difference) using the script above, and then also weighted RF distances, using some code I added to that script. It's actually a much simpler process when you're just doing one of the calculations.

### Alignment lengths

I want to pull out the alignment lengths to make plots comparing the good and bad datasets.

For the post-gblocks files, this is really easy. I wrote a script called "alignment_length.py" that will take a nexus file and pull out the alignment lengths from the charsets section.

> /mnt/lustre/macmaneslab/jlh1023/pipeline_dev/pipeline_scripts/alignment_length.py -a bad39.nex -o with_gb_aln_length.txt

For the pre-gblocks version, it's a little more difficult. But I altered the script that runs PhyloTreePruner so that it processes the alignments without gblocks, and then I can run that nexus file through the same script as above.

First script to get the nexus file is here: /mnt/lustre/macmaneslab/jlh1023/phylo_qual/actual_final/bad/ptp_runs/no_gb_ptp39.sh

Then the normal command again, as above:
> /mnt/lustre/macmaneslab/jlh1023/pipeline_dev/pipeline_scripts/alignment_length.py -a no_gb_bad39.nex -o no_gb_aln_length.txt

Then I open these in excel and combine them, adding in the dataset info, so that I can plot them with ggplot in R.


### Alignment stats  

I thought it could be interesting to see if there are easy quality things we can pull out about the alignments to figure out why the ones in the good dataset appear to be better than the ones in the bad dataset. I wrote a script called "alignment_stats.py" that pulls out the number of constant sites (thought it could be easily changed to some other side in the same file) in the info file from when the gene trees were made.

You just give it an input directory path with a bunch of iqtree info files in it, and an output file, and you can get all the numbers of constant sites for all the partitions in the dataset.  

Then I plotted these with ggplot2 in R to look at distributions and stuff.  

#### More alignment stats

Since the last analysis was not that informative (they were pretty similar distributions), I want to look at some other alignment stats as well.

I pulled out all the iqtree log and info files for all the partitions common to both datasets using these scripts:  
/mnt/lustre/macmaneslab/jlh1023/pipeline_dev/pipeline_scripts/get_log_files.py
/mnt/lustre/macmaneslab/jlh1023/pipeline_dev/pipeline_scripts/get_info_files.py  

I'm sort of working on a script that will pull all of these things out at once, but since I have them all separately, who knows if/when that will actually happen.  

So we can look at 4 measures total.

1.  Constants: percentage of constant sites in each alignment - alignment_stats.py  
    All alignments have this, and it is recorded in the info file as a percentage that I can pull out directly.
    /mnt/lustre/macmaneslab/jlh1023/phylo_qual/actual_final/comparisons/common_bad_constants.tsv
    /mnt/lustre/macmaneslab/jlh1023/phylo_qual/actual_final/comparisons/common_good_constants.tsv

2.  Parsimony: percentage of parsimony informative sites in each alignment - alignment_parsimony.py  
    All alignments have this, and it is recorded in the info file as a number. The number of total sites is also recorded, so the script pulls out both of these numbers and calculates a percentage to report.  
    /mnt/lustre/macmaneslab/jlh1023/phylo_qual/actual_final/comparisons/common_bad_parsimony.tsv
    /mnt/lustre/macmaneslab/jlh1023/phylo_qual/actual_final/comparisons/common_good_parsimony.tsv

3.  Composition: number of sequences that failed the composition chi2 test - alignment_composition.py  
    All alignments should have this measure, as the log file reports this number for each one, even if the number is 0.   
    /mnt/lustre/macmaneslab/jlh1023/phylo_qual/actual_final/comparisons/common_bad_composition.tsv
    /mnt/lustre/macmaneslab/jlh1023/phylo_qual/actual_final/comparisons/common_good_composition.tsv  

    I've updated this script so that it now extracts the number of sequences that fail the composition test even if that number is 0 (which it was struggling with before).  
    In the file "all_common_composition.csv" I have also added in the lengths of each alignment and normalized the number of sequences that fail the composition test with the alignment length.

4.  Ambiguity: number of sequences that contain more than 50% gaps or ambiguity - alignment_ambiguity.py  
    Only some of the alignments have this measure also, as some will not have any sequences that contain that much ambiguity.  Those that have this measure I have pulled into a file like the others.  
    Of the 332 partitions common to both datasets:
    288 alignments in the bad dataset have sequences with more than 50% gaps/ambiguity  
    171 alignments in the good dataset have sequences with more than 50% gaps/ambiguity  
    /mnt/lustre/macmaneslab/jlh1023/phylo_qual/actual_final/comparisons/common_bad_ambiguity.tsv
    /mnt/lustre/macmaneslab/jlh1023/phylo_qual/actual_final/comparisons/common_good_ambiguity.tsv  


I have downloaded all of these tsv files and imported them into excel. I combined them and added dataset information and made density plots in R the same way I have for everything else. I also tested whether the distributions were significantly different from one another using a Wilcoxon rank sum test.  

Dave pointed out that in measure 4, the rest of the sequences would just have 0 as their score, and it might make more sense to have the total number of alignments represented, with 0s entered for all the ones that don't have scores. So I've done this as well, and have further values looking at the difference between distributions when all of the alignments have scores.  

1.  Constants:  p-value = 0.3727, *not* significantly different  
2.  Parsimony:  p-value = 0.8851, *not* significantly different  
3.  Composition:  p-value = 0.006031, significantly different
4.  Ambiguity:  p-value < 2.2e-16, significantly different




### Tree branch lengths of common partitions

I edited another script to pull out information from the info files (makes sense), this time the branch lengths of the gene trees. Each info file gives the total length, and the internal length. It says that they are unrooted trees, but it uses the first organism in the alignment that you give it as the root when it is drawing the tree, so I wasn't sure how much the total measure might be influenced by that. I pulled out both measures, just to check them both out.  

Script is here: /mnt/lustre/macmaneslab/jlh1023/pipeline_dev/pipeline_scripts/tree_length.py  
Files are here: /mnt/lustre/macmaneslab/jlh1023/phylo_qual/actual_final/comparisons/common_good_treelength.tsv  
                /mnt/lustre/macmaneslab/jlh1023/phylo_qual/actual_final/comparisons/common_bad_treelength.tsv  

I popped them into R as usual and made density plots. Super the same distribution-wise.  
Total tree length: p-value = 0.5037  
Internal tree length: p-value = 0.9397


### Investigating the unique partitions

Are the 76 unique partitions in the bad dataset really unique? We are calling them unique because they have Mus names that do not match the Mus names in the high-quality dataset, but we don't really know what they are. From here /mnt/lustre/macmaneslab/jlh1023/phylo_qual/actual_final/comparisons/ I ran the following two scripts to run interproscan on the unique partitions in each dataset. Remember that interproscan is picky and doesn't like asterisks or dashes. Which is annoying when trying to figure out what aligned sequences are, but nevermind.  

> interproscan -i fixed_good_mus_unique_no_dashes.fasta -b good_unique_inter -goterms -f TSV
> interproscan -i fixed_bad_mus_unique_no_dashes.fasta -b bad_unique_inter -goterms -f TSV  

Then I took these output files and started comparing them in various ways. I could pull out the go-terms, but those have a super annoying format, so before I mess with that, I pulled out the description column (column 6) which contains a short phrase describing the function of that particular sequence. When I sort and compare these lists of descriptions, I get the following results:  

High-quality dataset unique partitions: total descriptions = 21117  
                                        unique descriptions = 20311

Low-quality dataset unique partitions: total descriptions = 964
                                       unique descriptions = 158  

Descriptions shared between the (supposedly unique) partitions = 806  

I'm not really sure if any of this is a valid comparison, but it certainly seems suggestive.


#### Investigating the unique partitions using the same alignment stats as above  

Pulled out the log and info files for the unique partitions for both datasets the same way I pulled out the common ones.  
> /mnt/lustre/macmaneslab/jlh1023/pipeline_dev/pipeline_scripts/get_log_files.py -l unique_bad.txt -a all_bad_log_files/ -n unique_bad_log_files
> /mnt/lustre/macmaneslab/jlh1023/pipeline_dev/pipeline_scripts/get_info_files.py -l unique_bad.txt -a all_bad_info_files/ -n unique_bad_info_files  

And now I can use the same scripts I used above to pull out the four alignment metrics for these as well.

1.  Constants: percentage of constant sites in each alignment - alignment_stats.py  
    All alignments have this, and it is recorded in the info file as a percentage that I can pull out directly.
    /mnt/lustre/macmaneslab/jlh1023/phylo_qual/actual_final/comparisons/unique_bad_constants.tsv
    /mnt/lustre/macmaneslab/jlh1023/phylo_qual/actual_final/comparisons/unique_good_constants.tsv

2.  Parsimony: percentage of parsimony informative sites in each alignment - alignment_parsimony.py  
    All alignments have this, and it is recorded in the info file as a number. The number of total sites is also recorded, so the script pulls out both of these numbers and calculates a percentage to report.  
    /mnt/lustre/macmaneslab/jlh1023/phylo_qual/actual_final/comparisons/unique_bad_parsimony.tsv
    /mnt/lustre/macmaneslab/jlh1023/phylo_qual/actual_final/comparisons/unique_good_parsimony.tsv

3.  Composition: number of sequences that failed the composition chi2 test - alignment_composition.py  
    All alignments should have this measure, as the log file reports this number for each one, even if the number is 0.   
    /mnt/lustre/macmaneslab/jlh1023/phylo_qual/actual_final/comparisons/unique_bad_composition.tsv
    /mnt/lustre/macmaneslab/jlh1023/phylo_qual/actual_final/comparisons/unique_good_composition.tsv  

4.  Ambiguity: number of sequences that contain more than 50% gaps or ambiguity - alignment_ambiguity.py  
    Only some of the alignments have this measure also, as some will not have any sequences that contain that much ambiguity.  Those that have this measure I have pulled into a file like the others.  
    Of the 76 partitions unique to the bad dataset:  
    64 alignments in the bad dataset have sequences with more than 50% gaps/ambiguity  
    of the 1684 partitions unique to the good dataset:  
    1297 alignments in the good dataset have sequences with more than 50% gaps/ambiguity  
    /mnt/lustre/macmaneslab/jlh1023/phylo_qual/actual_final/comparisons/unique_bad_ambiguity.tsv
    /mnt/lustre/macmaneslab/jlh1023/phylo_qual/actual_final/comparisons/unique_good_ambiguity.tsv  


### Occupancy analysis

I want to know if the numbers of orthogroups that contain all species are driven by one species or a handful of species, or if it's more spread across the dataset. I'm writing a script called "taxa_drivers.py" which will help to count these and figure this out.

I finally got a chance to run the script I wrote:  
> /mnt/lustre/macmaneslab/jlh1023/pipeline_dev/pipeline_scripts/taxa_drivers.py -a passing_files36/ -o good36_counts.txt

Had to alter the ptp scripts a little bit to make the setup correct. An example is here:  
> /mnt/lustre/macmaneslab/jlh1023/phylo_qual/actual_final/good/ptp_runs/ptp36.sh  

I ran this with missing taxa from 1-4, and all of the count files have the same style name as the example above.  


# Results

- size of dataset (orthogroups and later partitions) is greater with good dataset
- tree consistency is higher in the good dataset
- with STAG, good tree is a bit better than bad tree
- alignment lengths both pre gblocks is longer in the good dataset, but the same post-gblocks
- GO biases
- RF distances (weighted and not) are shorter (closer to the constraint tree) in the good vs. bad dataset

## Figures

I want to plot the busco scores of the species against how many orthogroups they appear in. I'm not using all the orthogroups for this, because there are likely a lot of singletons that we're not as interested in. So I've narrowed it down to just those orthogroups that contain at least half of the species (20 of them) and am going to try to find the stats with just those.

Good dataset:
Running things from /mnt/lustre/macmaneslab/jlh1023/phylo_qual/actual_final/good/ptp_runs
>/mnt/lustre/macmaneslab/jlh1023/pipeline_dev/pipeline_scripts/get_og_list_min_taxa.py \
-c /mnt/lustre/macmaneslab/jlh1023/phylo_qual/actual_final/good/for_orthofinder/OrthoFinder/Results_Oct15/Orthogroups/Orthogroups.GeneCount.tsv \
-o /mnt/lustre/macmaneslab/jlh1023/phylo_qual/actual_final/good/ptp_runs/half_og_names.txt \
-m 19

>/mnt/lustre/macmaneslab/jlh1023/pipeline_dev/pipeline_scripts/pull_alignments.py \
-l half_og_names.txt \
-a ../for_orthofinder/OrthoFinder/Results_Oct15/MultipleSequenceAlignments/ \
-n half_species_alns

Now I have the alignment files for the good dataset (I can just do the same thing for the bad), but I need to know which species are actually in these alignments.

### Getting TCA/ICA scores for common gene trees

I want to examine the partitions that are common to both the good and bad datasets. I've written tons of scripts that pull various interesting files out of directories into new collections, and this one is called "pull_certain_gene_trees.py".

To run it, I'll need a list of partition names that correspond to the names of the gene trees I'm after. Then just a path to the directory containing the gene trees to pull from, and a new directory to house the gene trees I end up pulling using the script.

I already have a list of the partition names that are common to both datasets (/mnt/lustre/macmaneslab/jlh1023/phylo_qual/actual_final/comparisons/common_to_both.txt) so I can use that for the first argument.    

I'll have to run this for the good and bad datasets, because even though they are the same partitions by identity, they do not contain identical sequences (that's the whole point - some of them were assembled much better than others).  

Now I'll head into the good dataset tree directory (/mnt/lustre/macmaneslab/jlh1023/phylo_qual/actual_final/good/trees) and I can run the script like this:  

> /mnt/lustre/macmaneslab/jlh1023/pipeline_dev/pipeline_scripts/pull_certain_gene_trees.py -t /mnt/lustre/macmaneslab/jlh1023/phylo_qual/actual_final/comparisons/common_to_both.txt -d /mnt/lustre/macmaneslab/jlh1023/phylo_qual/actual_final/good/trees/gene_trees/ -n /mnt/lustre/macmaneslab/jlh1023/phylo_qual/actual_final/good/trees/good_common_gene_trees/

Then I can cat them all together (into a file called all_good_common_gene_trees.tre) and run the raxml command on them:  
>raxmlHPC-PTHREADS-SSE3 -f i -m PROTGAMMAWAG -t correct_tree_branches.tre -z all_good_common_gene_trees.tre -n common_trees  

All of the files that are the result of these runs in their respective directories should have "common_trees" at the end of them.  

Overall scores:  

Good dataset common partition trees:  
Tree certainty for this tree: 13.614095
Relative tree certainty for this tree: 0.378169
Tree certainty including all conflicting bipartitions (TCA) for this tree: 13.479639
Relative tree certainty including all conflicting bipartitions (TCA) for this tree: 0.374434  

Bad dataset common partition trees:  
Tree certainty for this tree: 12.513293
Relative tree certainty for this tree: 0.347591
Tree certainty including all conflicting bipartitions (TCA) for this tree: 12.188808
Relative tree certainty including all conflicting bipartitions (TCA) for this tree: 0.338578
