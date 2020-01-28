#! /usr/bin/env python3

import argparse
import Bio.SeqIO
import os

#function to filter orthogroups to only those that have a specified number of taxa represented in them and make a list of these.
#then you can use the pull_prots.py script to pull the sequences out once you make the list file.

def make_og_list():
    try:
        with open("{0}".format(args.countfile), "r") as count_file:
            with open("{0}".format(args.outfile), "w") as out_file:
                #going through each line of the GeneCount.csv file from orthofinder
                #skipping the first line and splitting the others on tabs
                #populating a dictionary with the OG name as the key and a list of
                #the number of seqs for each taxon as the value
                for line in count_file:
                    if line.startswith("OG"):
                        #og_nums = {}
                        stripped = line.strip()
                        fields = stripped.split("\t")
                        #og_nums[fields[0]] = fields[1:]
                        #num_zeros = og_nums[fields[0]].count("0")
                        num_zeros = fields[1:].count("0")
                        if num_zeros <= args.missing:
                            out_file.write("{0}\n".format(fields[0]))

    except IOError:
        print("Issue reading or writing file")

parser = argparse.ArgumentParser(description = "arguments for filtering OGs to only those with a given number of taxa")
parser.add_argument("-c", "--countfile", required = True, help = "GeneCount.csv file from Orthofinder")
parser.add_argument("-o", "--outfile", required = True, help = "name of file to write the list to")
parser.add_argument("-m", "--missing", type = int, required = True, help = "number of missing taxa tolerated from a given OG")
args = parser.parse_args()

make_og_list()
