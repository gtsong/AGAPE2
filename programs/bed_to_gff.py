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
    info = ''
    file = open(gff_file+'.modified','w')
    for index in range(gffLength):
        item = gff.__getitem__(index)
        if item.type == 'gene' and item.accn != 'UNDEF' :
            gene_bed = bed.__getitem__(gff_index).__str__().split('\t')[3]
	    print(gene_bed)
            paralist = item.accn.split(';')
            if len(paralist) != 1:
                gene1, gene2 = paralist[0].split(',')[0], paralist[1].split(',')[0]
                if gene_bed == gene1:
                    item.__setattr__("accn", paralist[0])
		    info = paralist[0]
                else:
                    item.__setattr__("accn", paralist[1])
		    info = paralist[1]
	    else :
	        info = paralist[0]
	    gff_index = gff_index + 1

	elif item.type == 'CDS' and item.accn != 'UNDEF' :
	    item.__setattr__("accn",info)
	
	file.write(str(item)+'\n')
    file.close()

if __name__ == '__main__':
	 gff_file = sys.argv[1]
	 bed_file = sys.argv[2]
	 main(gff_file,bed_file);

