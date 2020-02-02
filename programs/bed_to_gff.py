#!/usr/bin/env python
from bed_utils import Bed, BlastLine
import sys

class GffLine(object):
    __slots__ = ("seqid","program","type", "start", "end", "accn", "stuff")

    def __init__(self, sline):
        args = sline.strip().split(" ")
        self.seqid = args[0]
        self.program = args[1]
        self.type = args[2]
        self.start = int(args[3])
        self.end = int(args[4])
        self.stuff = args[5:8]
        self.accn = args[8]

    def __str__(self):
        s = " ".join(map(str, [getattr(self, attr) for attr in GffLine.__slots__[:-2]]))
        if self.stuff:
            s += " " + " ".join(self.stuff)
            s += " " + "".join(self.accn)
        return s

    def __getitem__(self, key):
        return getattr(self, key)

class Gff(list):
    def __init__(self, filename, key=None):
        self.filename = filename
        # the sorting key provides some flexibility in ordering the features
        # for example, user might not like the lexico-order of seqid
        self.key = key or (lambda x: (x.seqid, x.start))
        for line in open(filename):
            self.append(GffLine(line))

        self.seqids = sorted(set(b.seqid for b in self))
        self.sort(key=self.key)


def main(gff_file,bed_corrected):
    gff = Gff(gff_file)
    bed = Bed(bed_corrected)
    gffLength = gff.__len__()
    gff_index = 0
    info, before = '',''
    fp=open(gff_file+'.modified','w')
    for index in range(gffLength):
        item = gff.__getitem__(index)
        info = item.accn
        if item.accn != 'UNDEF':
            if item.type == 'gene':
                gene_bed = bed.__getitem__(gff_index).__str__().split('\t')[3]
                gene_list = gene_bed.split('|')
                paralist = item.accn.split(';')
                print(gene_bed, paralist)
                if len(gene_list) == 1 and len(paralist)==2:
                    gene1, gene2 = paralist[0].split(',')[0], paralist[1].split(',')[0]
                    if gene_bed == gene1:
                        item.__setattr__("accn", paralist[0])
                        before = paralist[0]
                    elif gene_bed == gene2:
                        item.__setattr__("accn", paralist[1])
                        before = paralist[1]
                    else:
                        before = item.accn
                else :
                    before = item.accn
                gff_index = gff_index + 1
            else:
                item.__setattr__("accn",before)
        else:
            pass
        fp.write(str(item)+'\n')
    fp.close()

if __name__ == '__main__':
         gff_file = sys.argv[1]
         bed_file = sys.argv[2]
         main(gff_file,bed_file)
