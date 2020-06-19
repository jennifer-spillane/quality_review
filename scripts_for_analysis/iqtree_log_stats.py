#! /usr/bin/env python3

import argparse
import os
import re

# a function to find and extract measures of alignment length, composition info, and ambiguity from the log files of iqtree.

def iqtree_log_stats():
    try:
        length = ""
        composition = ""
        ambiguity = ""
        with open("{0}".format(args.outfile), "w") as out_file:
            out_file.write("file_name\talignment_length\tseqs_failing_composition_test\tseqs_with_more_than_50_percent_ambiguity\n")
            for file in os.scandir("{0}".format(args.indir)):
                if file.name.endswith("phylip.log"):
                    with open("{0}".format(file.path), "r") as infile:
                        for jumble in infile:

                            #pulling out the length of the alignment
                            if jumble.startswith("Alignment has 39 sequences with"):
                                length_data = jumble.strip()
                                length_match = re.match("Alignment has 39 sequences with (\d+) columns, \d+ distinct patterns", "{0}".format(length_data))
                                if length_match:
                                    length = length_match.group(1)
                                else:
                                    length = "0"

                            #pulling out the number of sequences that have at least 50% gaps/ambiguity
                            if jumble.startswith("WARNING"):
                                ambiguity_data = jumble.strip()
                                ambiguity_match = re.match("WARNING: (\d+) sequences contain more than 50% gaps\/ambiguity", "{0}".format(ambiguity_data))
                                if ambiguity_match:
                                    ambiguity = ambiguity_match.group(1)
                                else:
                                    ambiguity = "0"

                            #pulling out the number of sequences that have failed the composition test
                            if jumble.startswith("****  TOTAL"):
                                composition_data = jumble.strip()
                                composition_match = re.match("\*\*\*\*  TOTAL           \d+\.*\d*%  (\d+) sequences failed composition chi2 test", "{0}".format(composition_data))
                                if composition_match:
                                    composition = composition_match.group(1)
                                else:
                                    composition = "0"

                        #writing to the outfile
                        out_file.write("{0}\t{1}\t{2}\t{3}\n".format(file.name, length, composition, ambiguity))

    except IOError:
        print("problem reading or writing file")

parser = argparse.ArgumentParser(description = "arguments for pulling out constant numbers from alignment info files")
parser.add_argument("-i", "--indir", required = True, help = "path to directory with iqtree log files")
parser.add_argument("-o", "--outfile", required = True, help = "output file name")
args = parser.parse_args()

iqtree_log_stats()
