#! /usr/bin/env python3

import argparse
import os
import re

# a function to find and extract measures of alignment length, parsimony informative sites, and constant sites from a collection of iqtree info files 

def iqtree_info_stats():
    try:
        length = ""
        parsimony = ""
        constant = ""
        with open("{0}".format(args.outfile), "w") as out_file:
            #writing the top line of the output file
            out_file.write("file_name\talignment_length\tparsimony_informative_sites\tpercent_constant_sites\n")
            for file in os.scandir("{0}".format(args.indir)):
                if file.name.endswith("iqtree"):
                    with open("{0}".format(file.path), "r") as infile:
                        for jumble in infile:

                            #pulling out the length of the alignment
                            if jumble.startswith("Input data"):
                                length_data = jumble.strip()
                                length_match = re.match("Input data: 39 sequences with (\d+) amino-acid sites", "{0}".format(length_data))
                                if length_match:
                                    length = length_match.group(1)
                                else:
                                    length = "0"

                            #pulling out the number of parsimony informative sites in each alignment
                            if jumble.startswith("Number of parsimony informative sites:"):
                                parsimony_data = jumble.strip()
                                parsimony_match = re.match("Number of parsimony informative sites: (\d+)", "{0}".format(parsimony_data))
                                if parsimony_match:
                                    parsimony = parsimony_match.group(1)
                                else:
                                    parsimony = "0"

                            #pulling out the percentage of constant sites in each alignment
                            if jumble.startswith("Number of constant sites:"):
                                constant_data = jumble.strip()
                                constant_match = re.match("Number of constant sites: [0-9]+ \(= ([0-9]+\.*[0-9]*)% of all sites\)", "{0}".format(constant_data))
                                if constant_match:
                                    constant = constant_match.group(1)
                                else:
                                    constant = "0"

                        #writing to the outfile
                        out_file.write("{0}\t{1}\t{2}\t{3}\n".format(file.name, length, parsimony, constant))
    except IOError:
        print("problem reading or writing file")

parser = argparse.ArgumentParser(description = "arguments for pulling out constant numbers from alignment info files")
parser.add_argument("-i", "--indir", required = True, help = "path to directory with iqtree info files")
parser.add_argument("-o", "--outfile", required = True, help = "output file name")
args = parser.parse_args()

iqtree_info_stats()
