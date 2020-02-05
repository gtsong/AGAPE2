#!/usr/bin/env python
import sys
import os
from functools import reduce

def roman2int2(roman):
    def getdv(r):
        pos = 'IVXLCDMF'.find(r)
        return 0 if pos < 0 else 10**(pos/2)*(1+(4*(pos%2)))
    v = map(getdv, roman)
    return reduce(lambda s,x: s+x[0] if x[0]>=x[1] else s-x[0], zip(v, v[1:]+[0]),0)

def read_gff(gff_file):
    fp = open(gff_file,'r')
    gffs = sorted([line.split(' ') for line in fp], key=lambda x: (roman2int2(x[0].split('r')[1]), int(x[3])))
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
