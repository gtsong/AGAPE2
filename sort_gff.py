#!/usr/bin/env python
import sys
import os

def read_gff(gff_file):
    fp = open(gff_file,'r')
    gffs = sorted([line.split(' ') for line in fp], key=lambda x: (x[0],int(x[3])))
    return gffs

def write_gff(all_data):
    fp = open(gff_file+".sorted",'w')
    size = len(all_data)
    for index in range(size):
	fp.write(" ".join(all_data[index]))
    fp.close()

def main(gff_file):
    all_data = read_gff(gff_file)
    write_gff(all_data)

if __name__ == '__main__':
    gff_file = sys.argv[1]
    main(gff_file)
