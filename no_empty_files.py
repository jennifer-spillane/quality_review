#! /usr/bin/env python3

import Bio.SeqIO
import argparse
import os
import shutil

#a function to find the partition files that have no sequence information in them, even for one species, and not
#include those in the final nexus file that will be used to make trees
#this should also solve the problem of iqtree having the wrong range

def weed_out():
    os.mkdir("{0}".format(args.newdir))
    good_file_list = []
    for file in os.scandir("{0}".format(args.directory)):
        if file.name.startswith("Mus"):
            if file.name.endswith("rename"):
                weeds = False
                try:
                    for record in Bio.SeqIO.parse("{0}".format(file.path), "fasta"):
                        aminos = set(record.seq)
                        #print(aminos)
                        if aminos == {"-"}:
                            print("excluded {0} in {1} for all dashes".format(record.id, file.name))
                            weeds = True
                        if aminos == set():
                            print("excluded {0} in {1} for empty sequences".format(record.id, file.name))
                            weeds = True

                    if not weeds:
                        good_file_list.append(file.path)
                        destination = os.path.join(args.newdir, file.name)
                        shutil.copy(file.path, destination)

                except IOError:
                    print("garbage")

                try:
                    with open("{}".format(args.listfile), "w") as output:
                        for item in good_file_list:
                            output.write("{0}\n".format(item))

                except IOError:
                    print("Issue reading file")




#make a boolean flag - set to false at the beginning - have it change to true if the conditions are met, and then
#check to see if it has flipped - and if it has (or not, or whatever), write that file name to a new file


parser = argparse.ArgumentParser(description = "arguments for finding the frequencies of each species in the OGs")
parser.add_argument("-d", "--directory", required = True, help = "path to directory containing pruned alignmnet files")
parser.add_argument("-l", "--listfile", required = True, help = "path to an output file that will have a list of complete files")
parser.add_argument("-n", "--newdir", required = True, help = "path to a new directory to hole all complete files")
args = parser.parse_args()

weed_out()
