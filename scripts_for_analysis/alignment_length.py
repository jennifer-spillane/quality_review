#! /usr/bin/env python3

#function to extract the alignment lengths from seqCat output (nexus file) and make a file in which
#the one column is the OG name and the other is the length of the alignment. To be used in plotting later.

import argparse
import re

def get_lengths():
    try:
        with open("{0}".format(args.alnfile), "r") as aln_file:
            with open("{0}".format(args.outfile), "w") as out_file:
                #going through each line looking for the ones at the end of the alignment file 
                for line in aln_file:
                    stripped = line.strip()
                    #setting up the regex with three capture groups - one for the name and two for the alignment range
                    if stripped.startswith("charset"):
                        aln_range = re.match("charset\s[\/\w]*pruned\d*\/(Mus_musculus\|\d+)_rename\s=\s(\d+)\s-\s(\d+);", "{0}".format(stripped))
                        if aln_range:
                            aln_start = int(aln_range.group(2))
                            aln_end = int(aln_range.group(3))
                            #finding the alignment length and writing it with the name of the partition to the outfile
                            aln_length = aln_end - aln_start
                            out_file.write("{0}\t{1}\n".format(aln_range.group(1), aln_length))

    except IOError:
        print("Problem reading file")


parser = argparse.ArgumentParser(description = "arguments for pulling out partition names and alignment lengths")
parser.add_argument("-a", "--alnfile", required = True, help = "path to concattenated alignment file")
parser.add_argument("-o", "--outfile", required = True, help = "output file name")
args = parser.parse_args()

get_lengths()
