#! /usr/bin/env python3

#go into each file in a directory that ends a certain way (_aln-gb).
#Find the mouse transcript name and make a new file that uses that transcript name as the file name.
#Then concatenate as usual so that the names at the end of the catted file show the mouse transcript name
#Pull these out with the length to compare between datasets

import argparse
import re
import os
import shutil


def assigning_names():
    cur_dir = os.getcwd()
    for entry in os.scandir("{0}".format(args.indir)):
        if entry.name.endswith("_aln"):
            print(entry.name)
            try:
                with open("{0}".format(entry.path), "r") as aln_file:
                    print("opened file!")
                    for line in aln_file:
                        stripped = line.strip()
                        print("the line is better now")
                        mouse_name = re.match(">Mus_musculus_(Mus_musculus\|\d+)", "{0}".format(stripped))
                        print("attempting to make a match")
                        if mouse_name:
                            print(mouse_name.group(1))
                            new_name = mouse_name.group(1)
                            dest = os.path.join(args.indir, new_name)
                            shutil.copy(entry.path, dest)
                        else:
                            print("no match")
            except IOError:
                print("Issue reading or writing file")


parser = argparse.ArgumentParser(description = "arguments for renaming files according to mouse transcript names")
parser.add_argument("-i", "--indir", required = True, help = "path to directory containing alignment files")
args = parser.parse_args()

assigning_names()
