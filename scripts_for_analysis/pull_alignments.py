#! /usr/bin/env python3

import re
import argparse
import os
import shutil

def pull_alignments():
    try:
        with open("{0}".format(args.listfile), "r") as list_file:
            try:
                os.mkdir("{0}".format(args.newdir))
            except FileExistsError:
                print("This directory already exists. Please provide a different name")
            #put all the OG names in the file into a set for checking against
            og_names = set()
            for og in list_file:
                og_names.add(og.strip())
            #go through all the files in the directory, find the ones that match the OGs in the set
            for item in os.scandir("{0}".format(args.aligndir)):
                just_name = re.match("OG[0-9]{7}", "{0}".format(item.name))
                if just_name is None:
                    continue
                if just_name.group(0) in og_names:
                    #copy the ones that match into the directory you made earlier
                    destination = os.path.join(args.newdir, item.name)
                    shutil.copy(item.path, destination)
    except IOError:
        print("Problem reading listfile")


parser = argparse.ArgumentParser(description = "arguments for filtering OGs to only those with a given number of taxa")
parser.add_argument("-l", "--listfile", required = True, help = "GeneCount.csv file from Orthofinder")
parser.add_argument("-a", "--aligndir", required = True, help = "path to a directory with alignments in it")
parser.add_argument("-n", "--newdir", required = True, help = "path to a directory for the desired alignments")
args = parser.parse_args()

pull_alignments()
