#!/usr/bin/env python

def conv_gff(gff_file):
        f1 = open(gff_file,'r')
        for line in f1:
            lineOfText = line.split(' ')
            for a in range(8):
               print(lineOfText[a]+'\t'),
            WordInText = lineOfText[8].replace(';', ',').split(',')
            if (len(WordInText) != 8):
                print('ID='+WordInText[0] + '|' + WordInText[8])
            else:
                print('ID='+WordInText[0])
        f1.close()


import os.path as op
import sys

if __name__ == "__main__":

    import optparse

    parser = optparse.OptionParser(__doc__)
    parser.add_option("--noncoding", dest="cds", action="store_false",
            default=True, help="extract coding features?")
    (options, args) = parser.parse_args()

    if len(args) != 1:
        sys.exit(parser.print_help())

    gff_file = args[0]

    conv_gff(gff_file)

