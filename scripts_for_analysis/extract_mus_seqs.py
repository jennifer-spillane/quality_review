#! /usr/bin/env python3

import argparse
import os
import Bio.SeqIO

def mus():
    try:
        mus_list = []
        for entry in os.scandir("{0}".format(args.in_dir)):
            for record in Bio.SeqIO.parse("{0}".format(entry.path), "fasta"):
                if record.id == "Mus":
                    mus_list.append(record)
        Bio.SeqIO.write(mus_list, "{0}".format(args.out_fasta), "fasta")

    except IOError:
        print("issue reading file")

parser = argparse.ArgumentParser(description = "Arguments for taking long contigs")
parser.add_argument("-i", "--in_dir", help = "path to input directory full of alignment files")
parser.add_argument("-o", "--out_fasta", help = "path to output fasta file")
args = parser.parse_args()

mus()
