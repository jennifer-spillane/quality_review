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


## To get the identities of the orthogroups in each dataset:

Working in this directory: /mnt/lustre/macmaneslab/jlh1023/phylo_qual/small_test
> cut -f 1 bad/lengths.txt > bad_og_ids.txt
> cut -f 1 good/lengths.txt > good_og_ids.txt
> cut -f 1 trin/lengths.txt > trin_og_ids.txt

> sort bad_og_ids.txt > sorted_bad_og_ids.txt
> sort good_og_ids.txt > sorted_good_og_ids.txt
> sort trin_og_ids.txt > sorted_trin_og_ids.txt

### Comparing the bad dataset to the good:

Pulling out OGs unique to the bad dataset:
> comm -23 sorted_bad_og_ids.txt sorted_good_og_ids.txt > bad_uniq_good.txt
> wc -l bad_uniq_good.txt

There are 3028 OGs unique to the bad dataset when compared with the good.

Pulling out OGs unique to the good dataset:
> comm -13 sorted_bad_og_ids.txt sorted_good_og_ids.txt > good_uniq_bad.txt
> wc -l good_uniq_bad.txt

There are 3451 OGs unique to the good dataset when compared with the bad.

Pulling out shared OGs:
> comm -12 sorted_bad_og_ids.txt sorted_good_og_ids.txt > shared_bad_good.txt
> wc -l shared_bad_good.txt

There are 425 OGs shared between the good and bad datasets.

### Comparing the bad dataset to the trin:

Pulling out OGs unique to the bad dataset:
> comm -23 sorted_bad_og_ids.txt sorted_trin_og_ids.txt > bad_uniq_trin.txt
> wc -l bad_uniq_trin.txt

There are 3137 OGs unique to the bad dataset when compared with the trin.

Pulling out OGs unique to the trin dataset:
> comm -13 sorted_bad_og_ids.txt sorted_trin_og_ids.txt > trin_uniq_bad.txt
> wc -l trin_uniq_bad.txt

There are 3459 OGs unique to the trin dataset when compared with the bad.

Pulling out shared OGs:
> comm -12 sorted_bad_og_ids.txt sorted_trin_og_ids.txt > shared_bad_trin.txt
> wc -l shared_bad_trin.txt

There are 316 OGs shared between the bad and trin datasets.

### Comparing the good dataset to the trin:

Pulling out OGs unique to the good dataset:
> comm -23 sorted_good_og_ids.txt sorted_trin_og_ids.txt > good_uniq_trin.txt
> wc -l good_uniq_trin.txt

There are 3555 OGs unique to the good dataset when compared with the trin.

Pulling out OGs unique to the trin dataset:
> comm -13 sorted_good_og_ids.txt sorted_trin_og_ids.txt > trin_uniq_good.txt
> wc -l trin_uniq_good.txt

There are 3454 OGs unique to the trin dataset when compared with the good.

Pulling out shared OGs:
> comm -12 sorted_good_og_ids.txt sorted_trin_og_ids.txt > shared_good_trin.txt
> wc -l shared_good_trin.txt

There are 321 OGs shared between the good and trin datasets.


So. This seems crazy. There is no way that there are actually that few shared between the different datasets. What is probably happening (I think) is that different transcripts are being pruned out at the PhyloTreePruner step, so a different mouse transcript makes it through to the final alignment. Then when I pull those out to compare, it doesn't match very often, even though some of them probably do. That's my theory, anyway.

Not totally sure what to do about that. I could go back into the log files from the PTP wrapper script and find the transcripts that are getting pruned out, and check the ones that made it into the alignment with those also. I think that would take some time.

*Update!*

So, what actually happened is that I didn't think the whole situation through as carefully as I needed to. When I renamed the orthogroups according to the mouse transcripts, I wasn't doing it based on any universal system, I was doing it based on the transcripts that were created in each assembly. So the "good" one got named with the awesome transcripts and the "trin" one got named with all the transcript names from Trinity and so on. So it's sort of a miracle that any of them matched up at all.

To get around this issue, there are a couple of options. The first option involves blasting the transcripts to the mouse reference, taking the top hit, blasting that back to the mouse assembly, and seeing if I get the original transcript. The second option involves running orthofinder on the mouse assemblies by themselves, so that all the transcripts from all of the assemblies get sorted into orthogroups, and then we would know which ones corresponded with which other ones. These may still need to happen at some point, but we're not going to worry about them for now.

For now, I am going to put in the mouse reference and use that going into Orthofinder instead of the good, bad, and trinity assemblies. I will still use those different ones for all the other species, but will use the mouse as a sort of anchor. That way, when orthofinder puts transcripts into OGs for all the three different datasets, we will be able to tell which is which because the mouse will already be there, annotated and good to go. Then when PhyloTreePruner trims out everything but the one-to-one orthologs, the mouse transcript that is left will be the name given to the OG, and we'll be able to compare them a lot more easily. Woo!

*Update over*


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

This dataset contains these organisms (in these categories) for a total of 38:

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

Mammals (8):
Felis_catus
Dasypus_novemcinctus
Balaenoptera_acutorostrata
Canis_lupusfamiliaris
Mus_musculus
Notamacropus_eugenii
Oryctolagus_cuniculus
Rhinolophus_sinicus



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
>cut -f 1, 14 > mouse_trans_goterms.tsv

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

For the trin: *not the latest version of these numbers*
Tree certainty for this tree: 10.977451
Relative tree certainty for this tree: 0.313641
Tree certainty including all conflicting bipartitions (TCA) for this tree: 10.691546
Relative tree certainty including all conflicting bipartitions (TCA) for this tree: 0.305473

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

#### Tree consistency with shortest RF distance gene trees

Next, I want to select those gene trees with the shortest RF distances (from below), and test their tree consistency. To do this, I have to get the tree distance matrix (there is one for each dataset) from R and select the top percentage of trees with the shortest distances. Then I need to find a way to pull out these gene trees from the original concatenated gene tree file. Since I don't know how to do this in R, I'm going to start in excel, and then move back onto premise so I can use python.

distance matrix files are located here: /Users/jenniferlhill/Desktop/Analyses/quality/
good_dist_matrix.csv and bad_dist_matrix.csv

I'm going to start with the shortest 10%, but can adjust to different percentages if I need to.
For the bad dataset, that means the shortest 41 (40.8) gene trees. For the good dataset, it's 202 (201.5).

To pull these gene trees out, I wrote a script called pull_short_gene_trees.py with an example below.
>/mnt/lustre/macmaneslab/jlh1023/pipeline_dev/pipeline_scripts/pull_short_gene_trees.py
-t /mnt/lustre/macmaneslab/jlh1023/phylo_qual/actual_final/bad/trees/top_ten_percent.txt \
-d /mnt/lustre/macmaneslab/jlh1023/phylo_qual/actual_final/bad/trees/gene_trees \
-n /mnt/lustre/macmaneslab/jlh1023/phylo_qual/actual_final/bad/trees/short_gene_trees

Then I can just cat them together, like I did for the first round of gene trees, and test the tree consistency.

I'll use the same commands as above for tree consistency, doing it with and without the correct tree.

With correct tree

Good dataset:
Tree certainty for this tree: 13.133104
Relative tree certainty for this tree: 0.364808
Tree certainty including all conflicting bipartitions (TCA) for this tree: 12.708873
Relative tree certainty including all conflicting bipartitions (TCA) for this tree: 0.353024

Bad dataset:
Tree certainty for this tree: 8.017451
Relative tree certainty for this tree: 0.222707
Tree certainty including all conflicting bipartitions (TCA) for this tree: 7.782765
Relative tree certainty including all conflicting bipartitions (TCA) for this tree: 0.216188


Without correct tree

Good dataset:
Tree certainty for this tree: 6.515403
Relative tree certainty for this tree: 0.180983
Tree certainty including all conflicting bipartitions (TCA) for this tree: 6.377945
Relative tree certainty including all conflicting bipartitions (TCA) for this tree: 0.177165

Bad dataset:
Tree certainty for this tree: 3.147232
Relative tree certainty for this tree: 0.087423
Tree certainty including all conflicting bipartitions (TCA) for this tree: 3.035785
Relative tree certainty including all conflicting bipartitions (TCA) for this tree: 0.084327


### Tree distances

I want to compare the good and bad trees to the correct tree in a number of different ways, and calculate the distances between them.

First, I want to do this with all of the gene trees for both datasets. A script to do this is in the quality folder of Matthias and is called tree_dist_edits.R. I have made density plots of the distributions of all of these distances, and they are also in the quality folder.

I also want to compare the orthofinder species trees to the correct tree, and I've done that in tree_dist_extended.R, which is in the same place.

Comparing OF trees to correct tree:
Good dataset:
    symmetric difference: 18
    branch score difference: 0.7919888
    path difference: 37.9209705
    quadratic path difference: 13.6807719
    weighted RF distance: 5.269694

Bad dataset:
    symmetric difference: 20
    branch score difference: 0.9238571
    path difference: 44.2040722
    quadratic path difference: 15.2308405
    weighted RF distance: 6.122862

*update*
Apparently this is irrelevant, even though I only did it on the express wishes of an advisor. So there's that. I have it now in case he changes his mind.

### Alignment lengths

I want to pull out the alignment lengths to make plots comparing the good and bad datasets.

For the post-gblocks files, this is really easy. I wrote a script called "alignment_length.py" that will take a nexus file and pull out the alignment lengths from the charsets section.

> /mnt/lustre/macmaneslab/jlh1023/pipeline_dev/pipeline_scripts/alignment_length.py -a bad39.nex -o with_gb_aln_length.txt

For the pre-gblocks version, it's a little more difficult. But I altered the script that runs PhyloTreePruner so that it processes the alignments without gblocks, and then I can run that nexus file through the same script as above.

First script to get the nexus file is here: /mnt/lustre/macmaneslab/jlh1023/phylo_qual/actual_final/bad/ptp_runs/no_gb_ptp39.sh

Then the normal command again, as above:
> /mnt/lustre/macmaneslab/jlh1023/pipeline_dev/pipeline_scripts/alignment_length.py -a no_gb_bad39.nex -o no_gb_aln_length.txt

Then I open these in excel and combine them, adding in the dataset info, so that I can plot them with ggplot in R.

### Occupancy analysis

I want to know if the numbers of orthogroups that contain all species are driven by one species or a handful of species, or if it's more spread across the dataset. I'm writing a script called "taxa_drivers.py" which will help to count these and figure this out.

The script works! I tested it on the bad39 dataset to make sure it would count correctly. All of the taxa in that dataset should have 406 partitions that they are present in, because they are all required to be in all the partitions, but when I use it on the bad38 dataset, things are a bit weird. Takifugu only has 241 in the count, which is a bit crazy. Like, I think it might be impossible. There's another (Callorhinchus) that only has 608, but this is still way more than the number when all taxa are required, so that checks out without much suspicion. But I'm going to have to take a look at the rest of the process if I'm going to figure out where the other 150ish OGs are for this species. Weird.



# Results

- size of dataset (orthogroups and later partitions) is greater with good and trinity datasets
- tree consistency is higher in the good and trinity datasets
- with STAG, good tree is a bit better than bad and trin trees
- alignment lengths both pre and post gblocks are really similar across datasets
- patristic distances
- partition finder
- GO biases

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
