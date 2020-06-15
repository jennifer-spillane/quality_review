#! /usr/bin/env python3

#a script to pull out the orthogroups that are common to both (or all) datasets

import argparse
import os
import shutil


def samedata():

    #making lists of the files contained in the directories
    dir1_set = set(os.listdir("{0}".format(args.directory1)))
    dir2_set = set(os.listdir("{0}".format(args.directory2)))

    #finding the mouse transcripts that they both have in common
    #and the mouse transcripts that each one has separately
    same_set = dir1_set.intersection(dir2_set)
    only_dir1 = dir1_set.difference(dir2_set)
    only_dir2 = dir2_set.difference(dir1_set)

    #creating the new directory to transfer in the files common to both datasets
    os.mkdir("{0}".format(args.new_dir1))
    #os.mkdir("{0}".format(args.new_dir2))

    #going through the files in the first directory and finding the ones it has in common with the second
    for file1 in os.scandir("{0}".format(args.directory1)):
        if file1.name.startswith("Mus"):
            if file1.name.endswith("_rename"):
                #if the file is in the set of common files, copy it to a new directory
                if file1.name in same_set:
                    shutil.copy(file1.path, args.new_dir1)


parser = argparse.ArgumentParser(description = "arguments for pulling out the same data from multiple datasets")
parser.add_argument("-d", "--directory1", required = True, help = "path to first directory containing alignment files")
parser.add_argument("-e", "--directory2", required = True, help = "path to second directory containing alignment files")
parser.add_argument("-n", "--new_dir1", required = True, help = "path to new directory for copied files from directory1")
args = parser.parse_args()

samedata()

#/mnt/lustre/macmaneslab/jlh1023/pipeline_dev/pipeline_scripts/same_data.py
#-d /mnt/lustre/macmaneslab/jlh1023/phylo_qual/third_set/good/pruned/
#-e /mnt/lustre/macmaneslab/jlh1023/phylo_qual/third_set/bad/pruned/
#-n /mnt/lustre/macmaneslab/jlh1023/phylo_qual/third_set/good/nog_common_to_bad/
